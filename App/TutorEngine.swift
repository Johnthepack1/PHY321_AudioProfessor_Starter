import Foundation
import Combine
import AVFoundation
import Speech
import MediaPlayer

enum TutorPhase: String {
    case idle = "Stopped"
    case teaching = "Teaching"
    case asking = "Asking a question"
    case listening = "Listening for your answer"
    case paused = "Paused"
}

/// A deterministic, fully local proof of concept. It does NOT use a language model.
/// Spoken answer assessment is limited to accepted key phrases and may misjudge nuanced answers.
final class TutorEngine: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published private(set) var phase: TutorPhase = .idle
    @Published private(set) var status = "Ready. Press Start to begin offline physics lessons."
    @Published private(set) var lastRecognized = ""
    @Published private(set) var correctChecks: Int = UserDefaults.standard.integer(forKey: "correctChecks")
    @Published private(set) var needsReviewCount = 0

    private let synthesizer = AVSpeechSynthesizer()
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()

    private var audioRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var microphoneTapInstalled = false
    private var finishSpeaking: (() -> Void)?
    private var answerWindowToken = UUID()
    private var afterSpeechWork: DispatchWorkItem?
    private var spokenText = ""
    private var wasPausedMidSpeech = false
    private var pausedAtQuestion = false
    private var permissionsChecked = false
    private var speechAuthorized = false
    private var micAuthorized = false

    private var regularIndex: Int = UserDefaults.standard.integer(forKey: "regularIndex")
    private var currentReviewIndex: Int?
    private var reviewQueue: [String] = UserDefaults.standard.stringArray(forKey: "reviewQueue") ?? []
    private var lessonCount = 0

    var topic: Lesson {
        let index = currentReviewIndex ?? regularIndex
        return Curriculum.topics[max(0, min(index, Curriculum.topics.count - 1))]
    }

    override init() {
        super.init()
        synthesizer.delegate = self
        needsReviewCount = reviewQueue.count
        configureRemoteControls()
    }

    func startOrResume() {
        if phase == .teaching || phase == .asking || phase == .listening { return }
        if phase == .paused && wasPausedMidSpeech && synthesizer.isPaused {
            wasPausedMidSpeech = false
            phase = .teaching
            status = "Continuing the explanation."
            synthesizer.continueSpeaking()
            return
        }
        if phase == .paused && pausedAtQuestion {
            pausedAtQuestion = false
            askCurrentQuestion()
            return
        }
        if !permissionsChecked {
            requestPermissionsThenStart()
        } else {
            teachCurrentLesson()
        }
    }

    func pause() {
        if phase == .idle || phase == .paused { return }
        if phase == .listening {
            endRecognition()
            pausedAtQuestion = true
        } else if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .word)
            wasPausedMidSpeech = true
        }
        phase = .paused
        status = "Paused. Resume with the app or compatible headphone media control."
    }

    func stop() {
        endRecognition()
        afterSpeechWork?.cancel()
        finishSpeaking = nil
        synthesizer.stopSpeaking(at: .immediate)
        wasPausedMidSpeech = false
        pausedAtQuestion = false
        phase = .idle
        status = "Session stopped. Your lesson position and review topics were saved."
    }

    func repeatExplanation() {
        if phase == .idle { return }
        endRecognition()
        synthesizer.stopSpeaking(at: .immediate)
        finishSpeaking = nil
        wasPausedMidSpeech = false
        pausedAtQuestion = false
        teachCurrentLesson()
    }

    func manualUnknown() {
        guard phase == .paused || phase == .listening else { return }
        endRecognition()
        processAnswer("I don't know", fromMicrophone: false)
    }

    func manualUnderstood() {
        guard phase == .paused || phase == .listening else { return }
        endRecognition()
        status = "Self-reported understanding. Not counted as a verified spoken answer."
        explainAndAdvance(topic.correctExplanation)
    }

    private func requestPermissionsThenStart() {
        status = "Requesting microphone and speech permission. Playback still works if speech recognition is unavailable."
        SFSpeechRecognizer.requestAuthorization { [weak self] speechStatus in
            AVAudioSession.sharedInstance().requestRecordPermission { micPermission in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.permissionsChecked = true
                    self.speechAuthorized = speechStatus == .authorized
                    self.micAuthorized = micPermission
                    self.teachCurrentLesson()
                }
            }
        }
    }

    private func configurePlayback() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            status = "Audio playback setup issue: \(error.localizedDescription)"
        }
    }

    private func speak(_ text: String, stage: TutorPhase, then: @escaping () -> Void) {
        endRecognition()
        synthesizer.stopSpeaking(at: .immediate)
        configurePlayback()
        phase = stage
        finishSpeaking = then
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.47
        utterance.postUtteranceDelay = 0.15
        synthesizer.speak(utterance)
        updateNowPlaying()
    }

    private func teachCurrentLesson() {
        pausedAtQuestion = false
        wasPausedMidSpeech = false
        lastRecognized = ""
        let lesson = topic
        status = "Explaining: \(lesson.title)"
        let lessonText = "New lesson. \(lesson.chapter). \(lesson.title). \(lesson.explanation)"
        speak(lessonText, stage: .teaching) { [weak self] in
            self?.askCurrentQuestion()
        }
    }

    private func askCurrentQuestion() {
        let question = topic.question
        status = "Question: \(question)"
        speak("Let's check your understanding. \(question) You can also say I don't know.", stage: .asking) { [weak self] in
            self?.listenForAnswer()
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.phase != .idle, self.phase != .paused else { return }
            let callback = self.finishSpeaking
            self.finishSpeaking = nil
            callback?()
        }
    }

    private func listenForAnswer() {
        lastRecognized = ""
        spokenText = ""
        afterSpeechWork?.cancel()
        let onDeviceSupported = recognizer?.supportsOnDeviceRecognition ?? false
        guard micAuthorized && speechAuthorized && onDeviceSupported, let recognizer = recognizer else {
            phase = .paused
            pausedAtQuestion = true
            status = "Offline speech recognition isn't available or allowed. Paused without penalty. Use the on-screen controls to continue."
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .measurement, options: [.defaultToSpeaker, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.requiresOnDeviceRecognition = true  // DO NOT fall back to the network.
            request.shouldReportPartialResults = true
            request.contextualStrings = ["angular momentum", "moment of inertia", "torque", "underdamped", "resonance", "derivative", "integral"]
            audioRequest = request

            let inputNode = audioEngine.inputNode
            let format = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                request.append(buffer)
            }
            microphoneTapInstalled = true
            audioEngine.prepare()
            try audioEngine.start()

            phase = .listening
            status = "Listening (25-second maximum). Silence will pause, not count as incorrect."
            answerWindowToken = UUID()
            let thisWindow = answerWindowToken
            recognitionTask = recognizer.recognitionTask(with: request) { [weak self] result, error in
                DispatchQueue.main.async {
                    guard let self = self, self.phase == .listening, self.answerWindowToken == thisWindow else { return }
                    if let result = result {
                        self.spokenText = result.bestTranscription.formattedString
                        self.lastRecognized = self.spokenText
                        if !self.spokenText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            self.scheduleEndAfterSpeech(window: thisWindow)
                        }
                        if result.isFinal { self.finishListening(window: thisWindow) }
                    } else if let error = error {
                        self.endRecognition()
                        self.phase = .paused
                        self.pausedAtQuestion = true
                        self.status = "Speech recognition stopped: \(error.localizedDescription). Paused without penalty."
                    }
                }
            }

            // Timeout is counted from the START of the listening window.
            DispatchQueue.main.asyncAfter(deadline: .now() + 25) { [weak self] in
                guard let self = self, self.phase == .listening, self.answerWindowToken == thisWindow else { return }
                self.finishListening(window: thisWindow)
            }
        } catch {
            endRecognition()
            phase = .paused
            pausedAtQuestion = true
            status = "Microphone couldn't start: \(error.localizedDescription). Paused without penalty."
        }
    }

    private func scheduleEndAfterSpeech(window: UUID) {
        afterSpeechWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self = self, self.phase == .listening, self.answerWindowToken == window else { return }
            self.finishListening(window: window)
        }
        afterSpeechWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8, execute: work)
    }

    private func finishListening(window: UUID) {
        guard phase == .listening && answerWindowToken == window else { return }
        let answer = spokenText.trimmingCharacters(in: .whitespacesAndNewlines)
        endRecognition()
        if answer.isEmpty {
            phase = .paused
            pausedAtQuestion = true
            status = "No answer heard. Paused after 25 seconds with NO penalty."
        } else {
            processAnswer(answer, fromMicrophone: true)
        }
    }

    private func endRecognition() {
        answerWindowToken = UUID() // Invalidate all old callbacks and timers.
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

    private func processAnswer(_ answer: String, fromMicrophone: Bool) {
        let lower = answer.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        lastRecognized = fromMicrophone ? answer : lastRecognized
        if lower == "stop" || lower.contains("turn off") || lower == "end session" {
            stop()
            return
        }
        if lower == "pause" || lower.contains("hold on") {
            phase = .paused
            pausedAtQuestion = true
            status = "Paused by voice command."
            return
        }
        if lower.contains("repeat") || lower.contains("say that again") {
            teachCurrentLesson()
            return
        }
        if lower.contains("don't know") || lower.contains("do not know") || lower.contains("not sure") || lower.contains("no idea") {
            queueCurrentForReview()
            explainAndAdvance("That's a useful place to review. " + topic.remediation)
            return
        }

        // Simple phrase matching only; NOT equivalent to semantic AI grading.
        let isMatch = topic.acceptedPhrases.contains(where: { lower.contains($0.lowercased()) })
        if isMatch {
            correctChecks += 1
            UserDefaults.standard.set(correctChecks, forKey: "correctChecks")
            explainAndAdvance("That's the idea. " + topic.correctExplanation)
        } else {
            queueCurrentForReview()
            explainAndAdvance("I couldn't confirm the expected idea from that answer. This may be a recognition limitation, not a physics mistake. " + topic.remediation)
        }
    }

    private func explainAndAdvance(_ explanation: String) {
        status = "Explaining the answer and preparing the next lesson."
        speak(explanation + " Let's connect this with the next idea.", stage: .teaching) { [weak self] in
            self?.advance()
        }
    }

    private func queueCurrentForReview() {
        let id = topic.id
        if !reviewQueue.contains(id) { reviewQueue.append(id) }
        UserDefaults.standard.set(reviewQueue, forKey: "reviewQueue")
        needsReviewCount = reviewQueue.count
    }

    private func advance() {
        lessonCount += 1
        if currentReviewIndex != nil {
            currentReviewIndex = nil
        } else {
            regularIndex = (regularIndex + 1) % Curriculum.topics.count
            UserDefaults.standard.set(regularIndex, forKey: "regularIndex")
        }
        // Revisit one weak concept after every two completed lessons.
        if lessonCount % 3 == 0 && !reviewQueue.isEmpty {
            let reviewID = reviewQueue.removeFirst()
            if let found = Curriculum.topics.firstIndex(where: { $0.id == reviewID }) {
                currentReviewIndex = found
            }
            UserDefaults.standard.set(reviewQueue, forKey: "reviewQueue")
            needsReviewCount = reviewQueue.count
        }
        teachCurrentLesson() // Automatic continuation. No "another question?" prompt.
    }

    private func updateNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: topic.title,
            MPMediaItemPropertyArtist: "PHY 321 Offline Audio Professor"
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
                if self.phase == .paused { self.startOrResume() } else { self.pause() }
            }
            return .success
        }
        commands.stopCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async { self?.stop() }
            return .success
        }
    }
}
