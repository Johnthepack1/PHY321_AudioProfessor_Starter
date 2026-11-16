import Foundation
import Combine
import AVFoundation
import Speech
import MediaPlayer

enum TutorPhase: String {
    case idle = "Ready"
    case teaching = "Explaining"
    case asking = "Asking"
    case listening = "Listening"
    case paused = "Paused"
}

/// Fully local audio study coach. Rule-based answer checking is deliberately conservative.
/// Designed for iOS 15+ without an account, network calls, or a downloadable AI model.
final class TutorEngine: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published private(set) var phase: TutorPhase = .idle
    @Published private(set) var status = "Ready to study. Choose a mode and press Play."
    @Published private(set) var lastRecognized = ""
    @Published private(set) var lastFeedback = ""
    @Published private(set) var correctChecks = UserDefaults.standard.integer(forKey: "correctChecks")
    @Published private(set) var retryChecks = UserDefaults.standard.integer(forKey: "retryChecksV21")
    @Published private(set) var completedLessons = UserDefaults.standard.integer(forKey: "completedLessonsV21")
    @Published private(set) var needsReviewCount = 0
    @Published private(set) var chosenVoiceID = UserDefaults.standard.string(forKey: "voiceIDV2") ?? ""
    @Published private(set) var speakingRate = UserDefaults.standard.object(forKey: "speakingRateV2") as? Double ?? 0.47
    @Published private(set) var mode: StudyMode = StudyMode(rawValue: UserDefaults.standard.string(forKey: "studyModeV21") ?? "") ?? .lecture
    @Published private(set) var focus: StudyFocus = StudyFocus(rawValue: UserDefaults.standard.string(forKey: "studyFocusV21") ?? "") ?? .exam5
    @Published private(set) var sessionMinutes = UserDefaults.standard.integer(forKey: "sessionMinutesV21")
    @Published private(set) var currentTopicID = ""

    private let synthesizer = AVSpeechSynthesizer()
    private let previewSynthesizer = AVSpeechSynthesizer()
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var audioRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var microphoneTapInstalled = false
    private var finishSpeaking: (() -> Void)?
    private var wasPausedMidSpeech = false
    private var pausedAtQuestion = false
    private var phaseBeforePause: TutorPhase = .teaching
    private var permissionsChecked = false
    private var speechAuthorized = false
    private var micAuthorized = false
    private var answerWindowToken = UUID()
    private var afterSpeechWork: DispatchWorkItem?
    private var spokenText = ""
    private var retryCount = 0
    private var currentReviewID: String?
    private var reviewQueue: [String] = UserDefaults.standard.stringArray(forKey: "reviewQueue") ?? []
    private var lessonCounter = 0

    // Audio bookmark: saved as UTF-16 offset in the lesson's generated narration.
    private var speakingLessonNarration = false
    private var speechUTF16Base = 0
    private var bookmarkID = UserDefaults.standard.string(forKey: "bookmarkLessonV21") ?? ""
    private var bookmarkUTF16 = UserDefaults.standard.integer(forKey: "bookmarkOffsetV21")

    private var activeStudySeconds: TimeInterval = 0
    private var segmentStartedAt: Date?

    var playlist: [Lesson] { StudyCatalog.topics(for: focus) }

    var topic: Lesson {
        if let current = StudyCatalog.lookup(currentTopicID) { return current }
        return playlist.first ?? Curriculum.topics[0]
    }

    var playlistCount: Int { playlist.count }
    var playlistPosition: Int {
        (playlist.firstIndex(where: { $0.id == topic.id }) ?? 0) + 1
    }
    var isMicrophoneActive: Bool { phase == .listening }
    var canRespondToQuestion: Bool { mode == .practice && (phase == .listening || (phase == .paused && pausedAtQuestion)) }
    var savedBookmarkAvailable: Bool { bookmarkID == topic.id && bookmarkUTF16 > 0 }

    var availableVoices: [AVSpeechSynthesisVoice] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en-") }
            .sorted {
                if $0.quality.rawValue != $1.quality.rawValue { return $0.quality.rawValue > $1.quality.rawValue }
                if $0.language != $1.language {
                    if $0.language == "en-US" { return true }
                    if $1.language == "en-US" { return false }
                    return $0.language < $1.language
                }
                return $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
    }

    var selectedVoiceName: String {
        selectedVoice()?.name ?? "English default"
    }

    var voiceQualityDescription: String {
        guard let voice = selectedVoice() else { return "Standard" }
        // Raw values avoid referencing a quality case that may be unavailable on iOS 15.
        if voice.quality.rawValue >= 3 { return "Premium" }
        if voice.quality.rawValue == 2 { return "Enhanced" }
        return "Standard"
    }

    override init() {
        super.init()
        synthesizer.delegate = self
        needsReviewCount = reviewQueue.count
        let list = StudyCatalog.topics(for: focus)
        var index = UserDefaults.standard.integer(forKey: positionKey(for: focus))
        // Migrate an existing V1/V2 lesson cursor where it fits the selected new focus.
        if UserDefaults.standard.object(forKey: positionKey(for: focus)) == nil {
            let olderIndex = UserDefaults.standard.integer(forKey: "regularIndex")
            if Curriculum.topics.indices.contains(olderIndex) {
                let oldID = Curriculum.topics[olderIndex].id
                index = list.firstIndex(where: { $0.id == oldID }) ?? 0
            }
        }
        currentTopicID = list.isEmpty ? Curriculum.topics[0].id : list[min(max(index, 0), list.count - 1)].id
        configureRemoteControls()
    }

    private func positionKey(for focus: StudyFocus) -> String {
        "positionV21_" + focus.rawValue.replacingOccurrences(of: " ", with: "_")
    }

    private func selectedVoice() -> AVSpeechSynthesisVoice? {
        if !chosenVoiceID.isEmpty, let voice = AVSpeechSynthesisVoice(identifier: chosenVoiceID) { return voice }
        return availableVoices.first(where: { $0.language == "en-US" }) ??
            availableVoices.first ?? AVSpeechSynthesisVoice(language: "en-US")
    }

    func selectVoice(_ id: String) {
        chosenVoiceID = id
        UserDefaults.standard.set(id, forKey: "voiceIDV2")
    }

    func setSpeakingRate(_ rate: Double) {
        speakingRate = min(0.57, max(0.38, rate))
        UserDefaults.standard.set(speakingRate, forKey: "speakingRateV2")
    }

    func setMode(_ newMode: StudyMode) {
        guard newMode != mode else { return }
        stop()
        clearBookmark()
        mode = newMode
        UserDefaults.standard.set(newMode.rawValue, forKey: "studyModeV21")
        status = "\(newMode.rawValue) mode selected. Press Play to start."
    }

    func setFocus(_ newFocus: StudyFocus) {
        guard newFocus != focus else { return }
        stop()
        clearBookmark()
        currentReviewID = nil
        focus = newFocus
        UserDefaults.standard.set(newFocus.rawValue, forKey: "studyFocusV21")
        let list = StudyCatalog.topics(for: newFocus)
        let index = UserDefaults.standard.integer(forKey: positionKey(for: newFocus))
        currentTopicID = list.isEmpty ? Curriculum.topics[0].id : list[min(max(index, 0), list.count - 1)].id
        status = "\(newFocus.rawValue) selected. \(list.count) lessons ready."
    }

    func setSessionMinutes(_ minutes: Int) {
        sessionMinutes = [0, 5, 10, 20].contains(minutes) ? minutes : 0
        UserDefaults.standard.set(sessionMinutes, forKey: "sessionMinutesV21")
        activeStudySeconds = 0
        segmentStartedAt = nil
    }

    func previewVoice() {
        guard phase == .idle || phase == .paused else { return }
        previewSynthesizer.stopSpeaking(at: .immediate)
        configurePlayback()
        let utterance = AVSpeechUtterance(string: "Welcome back. In this lesson, we will recognize the clues, choose an equation, and work through the reasoning step by step.")
        utterance.voice = selectedVoice()
        utterance.rate = Float(speakingRate)
        previewSynthesizer.speak(utterance)
    }

    func startOrResume() {
        if phase == .teaching || phase == .asking || phase == .listening { return }
        previewSynthesizer.stopSpeaking(at: .immediate)
        if segmentStartedAt == nil { segmentStartedAt = Date() }
        if phase == .paused && wasPausedMidSpeech && synthesizer.isPaused {
            wasPausedMidSpeech = false
            phase = phaseBeforePause
            status = "Continuing from where you paused."
            synthesizer.continueSpeaking()
            return
        }
        if phase == .paused && pausedAtQuestion {
            pausedAtQuestion = false
            if mode == .practice { askQuestion() } else { playLesson() }
            return
        }
        if mode == .practice && !permissionsChecked {
            askPermissionsThenPlay()
        } else {
            playLesson()
        }
    }

    func pause() {
        guard phase != .idle && phase != .paused else { return }
        if phase == .listening {
            endRecognition()
            pausedAtQuestion = true
        } else if synthesizer.isSpeaking {
            phaseBeforePause = phase
            synthesizer.pauseSpeaking(at: .word)
            wasPausedMidSpeech = true
        }
        phase = .paused
        pauseStudyClock()
        status = "Paused. Resume when ready. Your place is saved."
    }

    func stop() {
        endRecognition()
        finishSpeaking = nil
        previewSynthesizer.stopSpeaking(at: .immediate)
        synthesizer.stopSpeaking(at: .immediate)
        wasPausedMidSpeech = false
        pausedAtQuestion = false
        speakingLessonNarration = false
        pauseStudyClock()
        activeStudySeconds = 0
        retryCount = 0
        phase = .idle
        status = "Session stopped. Your lesson position and review topics are saved."
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    func restartLesson() {
        guard phase != .idle else { clearBookmark(); status = "Lesson reset. Press Play."; return }
        cancelCurrentAudio()
        clearBookmark()
        playLesson()
    }

    func previousLesson() {
        let wasPlaying = phase != .idle
        cancelCurrentAudio()
        currentReviewID = nil
        let list = playlist
        let index = list.firstIndex(where: { $0.id == currentTopicID }) ?? 0
        let prior = (index - 1 + list.count) % list.count
        selectTopic(list[prior])
        if wasPlaying { playLesson() }
        else { phase = .idle; status = "Previous lesson ready. Press Play." }
    }

    func skipLesson() {
        let wasPlaying = phase != .idle
        cancelCurrentAudio()
        moveToNextTopic()
        if wasPlaying { playLesson() }
        else { phase = .idle; status = "Next lesson ready. Press Play." }
    }

    func retryAnswer() {
        guard canRespondToQuestion else { return }
        endRecognition()
        pausedAtQuestion = false
        askQuestion()
    }

    func showAnswer() {
        guard canRespondToQuestion else { return }
        endRecognition()
        queueReview()
        lastFeedback = "Answer shown. Topic saved for review; no incorrect grade assigned."
        speakFeedback("Let's work through the answer. " + topic.correctExplanation + " " + topic.remediation)
    }

    func markUnderstood() {
        guard canRespondToQuestion else { return }
        endRecognition()
        lastFeedback = "Marked understood. This is self-reported, not a verified answer."
        speakFeedback(topic.correctExplanation)
    }

    private func askPermissionsThenPlay() {
        status = "Requesting microphone and speech recognition permission. No audio leaves this iPhone."
        SFSpeechRecognizer.requestAuthorization { [weak self] speechStatus in
            AVAudioSession.sharedInstance().requestRecordPermission { micAllowed in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.permissionsChecked = true
                    self.speechAuthorized = speechStatus == .authorized
                    self.micAuthorized = micAllowed
                    self.playLesson()
                }
            }
        }
    }

    private func configurePlayback() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            status = "Audio output problem: \(error.localizedDescription)"
        }
    }

    private func cancelCurrentAudio() {
        endRecognition()
        finishSpeaking = nil
        synthesizer.stopSpeaking(at: .immediate)
        wasPausedMidSpeech = false
        pausedAtQuestion = false
        speakingLessonNarration = false
        clearBookmark()
    }

    private func playSpeech(_ text: String, stage: TutorPhase, lessonNarration: Bool = false,
                            resumeOffset: Int = 0, onFinish: @escaping () -> Void) {
        endRecognition()
        previewSynthesizer.stopSpeaking(at: .immediate)
        synthesizer.stopSpeaking(at: .immediate)
        configurePlayback()
        phase = stage
        finishSpeaking = onFinish
        speakingLessonNarration = lessonNarration
        speechUTF16Base = resumeOffset
        let utterance = AVSpeechUtterance(string: SpeechText.readable(text))
        utterance.voice = selectedVoice()
        utterance.rate = Float(speakingRate)
        utterance.postUtteranceDelay = 0.12
        synthesizer.speak(utterance)
        updateNowPlaying()
    }

    private func fullNarration(for lesson: Lesson) -> String {
        let main = "\(lesson.chapter). \(lesson.title). \(lesson.explanation)"
        let worked = StudyCatalog.isDrill(lesson) ? "" : " Worked example and equation clue. " + TeachingExtras.forLesson(lesson)
        switch mode {
        case .lecture:
            return "Let's work through this carefully. " + main + worked +
                " Remember: identify what is given, what is unknown, and the physical principle that connects them."
        case .practice:
            return "Let's learn the idea before answering. " + main + worked
        case .drive:
            return "Listening lesson. " + main + worked +
                " Here's a question to think about. \(lesson.question) " +
                " Now, here's the solution. \(lesson.correctExplanation) " +
                " If the problem looked unfamiliar, use this reminder. \(lesson.remediation)"
        }
    }

    private func playLesson() {
        let lesson = topic
        pausedAtQuestion = false
        wasPausedMidSpeech = false
        retryCount = 0
        lastRecognized = ""
        status = "Explaining \(lesson.title)"
        let full = SpeechText.readable(fullNarration(for: lesson))
        let utf16Length = (full as NSString).length
        let offset = bookmarkID == lesson.id && bookmarkUTF16 > 0 && bookmarkUTF16 < utf16Length - 20 ? bookmarkUTF16 : 0
        let remaining = (full as NSString).substring(from: offset)
        let spoken = offset > 0 ? "Picking up where we left off. " + remaining : remaining
        // Resume introduction adds bytes not present in the original narration; adjust base in callback.
        let prefixLength = offset > 0 ? ("Picking up where we left off. " as NSString).length : 0
        let base = max(0, offset - prefixLength)
        playSpeech(spoken, stage: .teaching, lessonNarration: true, resumeOffset: base) { [weak self] in
            guard let self = self else { return }
            self.clearBookmark()
            if self.mode == .practice { self.askQuestion() }
            else { self.completeTopic() }
        }
    }

    private func askQuestion() {
        status = "Question: \(topic.question)"
        playSpeech("Your turn. \(topic.question) Take your time. Say show answer if you need help.", stage: .asking) { [weak self] in
            self?.listenForAnswer()
        }
    }

    private func speakFeedback(_ words: String) {
        status = "Explaining the solution"
        playSpeech(words + " Let's carry that idea to the next problem.", stage: .teaching) { [weak self] in
            self?.completeTopic()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString range: NSRange,
                           utterance: AVSpeechUtterance) {
        guard speakingLessonNarration && phase == .teaching else { return }
        let position = max(0, speechUTF16Base + range.location)
        if position > bookmarkUTF16 || bookmarkID != topic.id {
            bookmarkID = topic.id
            bookmarkUTF16 = position
            UserDefaults.standard.set(bookmarkID, forKey: "bookmarkLessonV21")
            UserDefaults.standard.set(bookmarkUTF16, forKey: "bookmarkOffsetV21")
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.phase != .idle && self.phase != .paused else { return }
            let next = self.finishSpeaking
            self.finishSpeaking = nil
            self.speakingLessonNarration = false
            next?()
        }
    }

    private func listenForAnswer() {
        spokenText = ""
        lastRecognized = ""
        afterSpeechWork?.cancel()
        let canListenOffline = recognizer?.supportsOnDeviceRecognition ?? false
        guard mode == .practice, micAuthorized, speechAuthorized, canListenOffline,
              let recognizer = recognizer else {
            phase = .paused
            pausedAtQuestion = true
            pauseStudyClock()
            status = "Offline microphone recognition unavailable or not permitted. No penalty. You can show the answer or retry."
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .measurement,
                                                              options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.requiresOnDeviceRecognition = true
            request.shouldReportPartialResults = true
            request.taskHint = .dictation
            let vocabulary = ["angular momentum", "angular impulse", "linear impulse", "moment of inertia",
                              "restitution", "torque", "omega", "zeta", "underdamped", "overdamped",
                              "frequency", "resonance", "discriminant", "differential equation",
                              "pendulum", "steady state", "parallel axis", "equilibrium",
                              "damped frequency", "natural frequency", "spring constant", "impulse momentum",
                              "show answer", "repeat question", "give an example", "slower", "stop session"]
            request.contextualStrings = Array(Set(vocabulary + topic.acceptedPhrases)).prefix(90).map { $0 }
            audioRequest = request
            let input = audioEngine.inputNode
            let format = input.outputFormat(forBus: 0)
            input.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in request.append(buffer) }
            microphoneTapInstalled = true
            audioEngine.prepare()
            try audioEngine.start()
            phase = .listening
            status = "Listening now. Speak your answer; silence pauses without penalty."
            answerWindowToken = UUID()
            let token = answerWindowToken
            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                DispatchQueue.main.async {
                    guard let self = self, self.phase == .listening && self.answerWindowToken == token else { return }
                    if let result = result {
                        let words = result.bestTranscription.formattedString
                        if words != self.spokenText {
                            self.spokenText = words
                            self.lastRecognized = words
                            if !words.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                self.scheduleSpeechEnd(token: token)
                            }
                        }
                        if result.isFinal { self.finishListening(token: token) }
                    } else if let error = error {
                        self.endRecognition()
                        self.phase = .paused
                        self.pausedAtQuestion = true
                        self.pauseStudyClock()
                        self.status = "Recognition stopped: \(error.localizedDescription). No penalty. Tap Try again or Show answer."
                    }
                }
            }
            // The Speech framework recommends less than a minute per recognition request.
            DispatchQueue.main.asyncAfter(deadline: .now() + 25) { [weak self] in
                guard let self = self, self.phase == .listening && self.answerWindowToken == token,
                      self.spokenText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                self.finishListening(token: token)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 52) { [weak self] in
                guard let self = self, self.phase == .listening && self.answerWindowToken == token else { return }
                self.finishListening(token: token)
            }
        } catch {
            endRecognition()
            phase = .paused
            pausedAtQuestion = true
            pauseStudyClock()
            status = "Microphone could not start: \(error.localizedDescription). No penalty."
        }
    }

    private func scheduleSpeechEnd(token: UUID) {
        afterSpeechWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self = self, self.phase == .listening && self.answerWindowToken == token else { return }
            self.finishListening(token: token)
        }
        afterSpeechWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.5, execute: work)
    }

    private func finishListening(token: UUID) {
        guard phase == .listening && answerWindowToken == token else { return }
        let answer = spokenText.trimmingCharacters(in: .whitespacesAndNewlines)
        endRecognition()
        if answer.isEmpty {
            phase = .paused
            pausedAtQuestion = true
            pauseStudyClock()
            status = "No answer detected. Paused without penalty."
            lastFeedback = "Press Try again, Show answer, or Resume when ready."
        } else {
            processAnswer(answer)
        }
    }

    private func endRecognition() {
        answerWindowToken = UUID()
        afterSpeechWork?.cancel()
        afterSpeechWork = nil
        if audioEngine.isRunning { audioEngine.stop() }
        if microphoneTapInstalled {
            audioEngine.inputNode.removeTap(onBus: 0)
            microphoneTapInstalled = false
        }
        audioRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        audioRequest = nil
    }

    private func processAnswer(_ answer: String) {
        if let command = AnswerEvaluator.command(in: answer) {
            switch command {
            case .stop:
                stop()
            case .pause:
                pausedAtQuestion = true
                phase = .paused
                pauseStudyClock()
                status = "Paused by voice."
            case .repeatQuestion:
                askQuestion()
            case .repeatLesson:
                clearBookmark()
                playLesson()
            case .showAnswer:
                queueReview()
                lastFeedback = "You asked to see the answer. Queued for review."
                speakFeedback(topic.correctExplanation + " " + topic.remediation)
            case .example:
                let detail = StudyCatalog.isDrill(topic) ? topic.remediation : TeachingExtras.forLesson(topic)
                playSpeech("Let's look at an example. " + detail + " I'll repeat the question.", stage: .teaching) { [weak self] in
                    self?.askQuestion()
                }
            case .slower:
                setSpeakingRate(speakingRate - 0.03)
                playSpeech("I'll slow down. Let me repeat that question.", stage: .teaching) { [weak self] in self?.askQuestion() }
            case .faster:
                setSpeakingRate(speakingRate + 0.03)
                playSpeech("I'll speak a little faster. Here is the question again.", stage: .teaching) { [weak self] in self?.askQuestion() }
            case .skip:
                lastFeedback = "Skipped without grading."
                completeTopic()
            }
            return
        }

        switch AnswerEvaluator.evaluate(answer, for: topic) {
        case .confirmed:
            correctChecks += 1
            UserDefaults.standard.set(correctChecks, forKey: "correctChecks")
            lastFeedback = "Heard \"\(answer)\". Matched the required concept."
            speakFeedback("That's the expected idea. " + topic.correctExplanation)
        case .uncertain:
            retryChecks += 1
            UserDefaults.standard.set(retryChecks, forKey: "retryChecksV21")
            retryCount += 1
            lastFeedback = "Heard \"\(answer)\". Couldn't confirm it; not marked incorrect."
            if retryCount == 1 {
                playSpeech("I heard: \(answer). I can't confidently check that wording. Please say the main idea another way. You can also say show answer.", stage: .teaching) { [weak self] in
                    self?.listenForAnswer()
                }
            } else {
                queueReview()
                speakFeedback("I still can't reliably confirm it. That does not mean your physics was wrong. " + topic.correctExplanation + " " + topic.remediation)
            }
        }
    }

    private func queueReview() {
        let id = topic.id
        if !reviewQueue.contains(id) { reviewQueue.append(id) }
        UserDefaults.standard.set(reviewQueue, forKey: "reviewQueue")
        needsReviewCount = reviewQueue.count
    }

    private func completeTopic() {
        completedLessons += 1
        UserDefaults.standard.set(completedLessons, forKey: "completedLessonsV21")
        lessonCounter += 1
        let reachedSessionLimit = sessionMinutes > 0 && elapsedStudySeconds >= Double(sessionMinutes * 60)
        moveToNextTopic()
        if reachedSessionLimit {
            pauseStudyClock()
            activeStudySeconds = 0
            phase = .idle
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            status = "Your \(sessionMinutes)-minute session is complete. The next lesson is ready."
            return
        }
        playLesson()
    }

    private var elapsedStudySeconds: TimeInterval {
        activeStudySeconds + (segmentStartedAt.map { Date().timeIntervalSince($0) } ?? 0)
    }

    private func pauseStudyClock() {
        if let began = segmentStartedAt { activeStudySeconds += Date().timeIntervalSince(began) }
        segmentStartedAt = nil
    }

    private func moveToNextTopic() {
        clearBookmark()
        let list = playlist
        guard !list.isEmpty else { return }
        if currentReviewID != nil {
            // Resume the normal course position saved before the review insertion.
            currentReviewID = nil
            let savedIndex = min(max(UserDefaults.standard.integer(forKey: positionKey(for: focus)), 0), list.count - 1)
            selectTopic(list[savedIndex])
        } else {
            let currentIndex = list.firstIndex(where: { $0.id == currentTopicID }) ?? 0
            let nextIndex = (currentIndex + 1) % list.count
            selectTopic(list[nextIndex])
        }
        if lessonCounter % 3 == 0 && !reviewQueue.isEmpty {
            // Revisit only a weak topic that belongs to the currently selected focus.
            if let index = reviewQueue.firstIndex(where: { id in list.contains(where: { $0.id == id }) }) {
                let id = reviewQueue.remove(at: index)
                UserDefaults.standard.set(reviewQueue, forKey: "reviewQueue")
                needsReviewCount = reviewQueue.count
                currentReviewID = id
                currentTopicID = id
                status = "Reviewing a topic that needs practice."
            }
        }
    }

    private func selectTopic(_ lesson: Lesson) {
        currentTopicID = lesson.id
        if let index = playlist.firstIndex(where: { $0.id == lesson.id }) {
            UserDefaults.standard.set(index, forKey: positionKey(for: focus))
        }
    }

    private func clearBookmark() {
        bookmarkID = ""
        bookmarkUTF16 = 0
        UserDefaults.standard.removeObject(forKey: "bookmarkLessonV21")
        UserDefaults.standard.removeObject(forKey: "bookmarkOffsetV21")
    }

    private func updateNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: topic.title,
            MPMediaItemPropertyArtist: "PHY 321 · \(focus.rawValue) · \(mode.rawValue)"
        ]
    }

    private func configureRemoteControls() {
        let commands = MPRemoteCommandCenter.shared()
        commands.playCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async { self?.startOrResume() }
            return .success
        }
        commands.pauseCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async { self?.pause() }
            return .success
        }
        commands.togglePlayPauseCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if self.phase == .paused || self.phase == .idle { self.startOrResume() }
                else { self.pause() }
            }
            return .success
        }
        commands.nextTrackCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async { self?.skipLesson() }
            return .success
        }
        commands.previousTrackCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async { self?.previousLesson() }
            return .success
        }
        commands.stopCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async { self?.stop() }
            return .success
        }
    }
}
