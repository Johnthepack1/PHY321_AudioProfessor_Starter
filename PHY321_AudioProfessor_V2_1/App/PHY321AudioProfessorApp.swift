import SwiftUI

private enum Brand {
    static let ink = Color(red: 0.08, green: 0.16, blue: 0.25)
    static let navy = Color(red: 0.07, green: 0.15, blue: 0.25)
    static let teal = Color(red: 0.05, green: 0.48, blue: 0.48)
    static let mint = Color(red: 0.84, green: 0.94, blue: 0.90)
    static let gold = Color(red: 0.98, green: 0.75, blue: 0.40)
    static let paper = Color(red: 0.965, green: 0.974, blue: 0.973)
    static let muted = Color(red: 0.42, green: 0.49, blue: 0.54)
}

@main
struct PHY321AudioProfessorApp: App {
    @StateObject private var tutor = TutorEngine()

    var body: some Scene {
        WindowGroup {
            ProfessorDashboard()
                .environmentObject(tutor)
                .preferredColorScheme(.light)
        }
    }
}

private struct ProfessorDashboard: View {
    @EnvironmentObject var tutor: TutorEngine
    @State private var showVoice = false
    @State private var showMicrophoneDetails = false

    private var active: Bool { tutor.phase != .idle }
    private var canAnswer: Bool { tutor.canRespondToQuestion }

    var body: some View {
        NavigationView {
            ZStack {
                Brand.paper.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        header
                        nowPlayingCard
                        playbackControls
                        focusControls
                        if tutor.mode == .practice { answerCard }
                        progressCard
                        voiceCard
                        helpCard
                        Text("OFFLINE BY DESIGN  ·  iOS 15+  ·  V2.1")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .tracking(1.6)
                            .foregroundColor(Brand.muted)
                            .padding(.top, 3)
                            .padding(.bottom, 12)
                    }
                    .padding(.horizontal, 17)
                    .padding(.top, 14)
                }
            }
            .navigationBarHidden(true)
            .tint(Brand.teal)
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("PHY 321")
                    .font(.system(size: 35, weight: .black, design: .rounded))
                    .tracking(-1.4)
                    .foregroundColor(Brand.ink)
                Text("YOUR OFFLINE AUDIO PROFESSOR")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.7)
                    .foregroundColor(Brand.muted)
            }
            Spacer()
            ZStack {
                Circle().fill(Brand.mint).frame(width: 54, height: 54)
                Image(systemName: "waveform.path")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(Brand.teal)
            }
        }
        .padding(.bottom, 2)
    }

    private var nowPlayingCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label(tutor.focus.rawValue.uppercased(), systemImage: "book.closed.fill")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
                    .tracking(1.1)
                    .foregroundColor(Brand.gold)
                Spacer()
                HStack(spacing: 6) {
                    Circle().fill(tutor.isMicrophoneActive ? Color(red: 1, green: 0.55, blue: 0.35) : Brand.mint)
                        .frame(width: 7, height: 7)
                    Text(tutor.phase.rawValue.uppercased())
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.92))
                }
            }
            VStack(alignment: .leading, spacing: 7) {
                Text(tutor.topic.title)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                Text(tutor.topic.chapter)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.71))
            }
            HStack(spacing: 8) {
                Image(systemName: tutor.isMicrophoneActive ? "mic.fill" : "waveform")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Brand.gold)
                Text(tutor.status)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.90))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.10))
            .cornerRadius(12)
            HStack {
                Text("LESSON \(tutor.playlistPosition) OF \(tutor.playlistCount)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1)
                    .foregroundColor(.white.opacity(0.75))
                Spacer()
                if tutor.savedBookmarkAvailable {
                    Label("Place saved", systemImage: "bookmark.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Brand.gold)
                }
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(.white.opacity(0.17))
                    Capsule().fill(Brand.gold)
                        .frame(width: max(8, geometry.size.width * CGFloat(tutor.playlistPosition) / CGFloat(max(1, tutor.playlistCount))))
                }
            }
            .frame(height: 5)
        }
        .padding(20)
        .background(
            LinearGradient(colors: [Brand.navy, Color(red: 0.08, green: 0.30, blue: 0.35)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(22)
        .shadow(color: Brand.navy.opacity(0.15), radius: 16, y: 8)
    }

    private var playbackControls: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                Button(action: tutor.startOrResume) {
                    Label(tutor.phase == .paused ? "Resume lesson" : "Start lesson", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(tutor.phase == .teaching || tutor.phase == .asking || tutor.phase == .listening)
                Button(action: tutor.pause) {
                    Label("Pause", systemImage: "pause.fill")
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                }
                .buttonStyle(SecondaryButtonStyle())
                .disabled(tutor.phase == .paused || tutor.phase == .idle)
            }
            HStack(spacing: 10) {
                compactButton("Back", icon: "backward.end.fill", action: tutor.previousLesson)
                compactButton("Restart", icon: "arrow.counterclockwise", action: tutor.restartLesson)
                compactButton("Next", icon: "forward.end.fill", action: tutor.skipLesson)
                compactButton("Stop", icon: "stop.fill", action: tutor.stop)
            }
        }
    }

    private func compactButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon).font(.system(size: 16, weight: .semibold))
                Text(title).font(.system(size: 11, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 51)
        }
        .buttonStyle(QuietButtonStyle())
    }

    private var focusControls: some View {
        DashboardCard(title: "Your study session", subtitle: "Choose exactly what to work on", symbol: "slider.horizontal.3") {
            VStack(alignment: .leading, spacing: 13) {
                Text("LEARNING MODE")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(1.1)
                    .foregroundColor(Brand.muted)
                Picker("Learning mode", selection: Binding(get: { tutor.mode }, set: tutor.setMode)) {
                    ForEach(StudyMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                Text(tutor.mode.subtitle)
                    .font(.caption)
                    .foregroundColor(Brand.muted)
                Divider()
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TOPIC FOCUS")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(1.1)
                            .foregroundColor(Brand.muted)
                        Picker("Topic focus", selection: Binding(get: { tutor.focus }, set: tutor.setFocus)) {
                            ForEach(StudyFocus.allCases) { focus in
                                Text(focus.rawValue).tag(focus)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("SESSION LENGTH")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .tracking(1.1)
                            .foregroundColor(Brand.muted)
                        Picker("Session length", selection: Binding(get: { tutor.sessionMinutes }, set: tutor.setSessionMinutes)) {
                            Text("Continuous").tag(0)
                            Text("5 min").tag(5)
                            Text("10 min").tag(10)
                            Text("20 min").tag(20)
                        }
                        .pickerStyle(.menu)
                    }
                }
                Text(tutor.focus.subtitle)
                    .font(.caption)
                    .foregroundColor(Brand.muted)
                if tutor.mode == .drive {
                    Label("Passive narration. The microphone stays off in Drive mode.", systemImage: "car.fill")
                        .font(.footnote)
                        .foregroundColor(Brand.teal)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Brand.mint.opacity(0.62))
                        .cornerRadius(10)
                }
            }
        }
    }

    private var answerCard: some View {
        DashboardCard(title: "Speak your answer", subtitle: "The microphone activates only after a question", symbol: "mic") {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: tutor.isMicrophoneActive ? "mic.fill" : "mic.slash")
                        .foregroundColor(tutor.isMicrophoneActive ? Brand.teal : Brand.muted)
                    Text(tutor.isMicrophoneActive ? "MICROPHONE LISTENING" : "MICROPHONE IDLE")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(tutor.isMicrophoneActive ? Brand.teal : Brand.muted)
                }
                Text(tutor.lastRecognized.isEmpty ? "What the phone hears will appear here." : "Heard: “\(tutor.lastRecognized)”")
                    .font(.system(size: 13))
                    .foregroundColor(Brand.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                    .padding(12)
                    .background(Brand.paper)
                    .cornerRadius(10)
                if !tutor.lastFeedback.isEmpty {
                    Text(tutor.lastFeedback)
                        .font(.caption)
                        .foregroundColor(Brand.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                HStack(spacing: 9) {
                    Button("Try again", action: tutor.retryAnswer)
                        .buttonStyle(SecondaryButtonStyle())
                    Button("Show answer", action: tutor.showAnswer)
                        .buttonStyle(SecondaryButtonStyle())
                    Button("Got it", action: tutor.markUnderstood)
                        .buttonStyle(SecondaryButtonStyle())
                }
                .disabled(!canAnswer)
                DisclosureGroup("Voice commands & microphone details", isExpanded: $showMicrophoneDetails) {
                    Text("Say: repeat question, explain that again, give me an example, slower, faster, show answer, skip, pause, or stop. Commands work only in the listening window, not during narration. Initial silence for 25 seconds pauses without penalty; speaking is limited to 52 seconds total.")
                        .font(.caption)
                        .foregroundColor(Brand.muted)
                        .padding(.top, 7)
                }
                .font(.caption.weight(.medium))
                .foregroundColor(Brand.teal)
            }
        }
    }

    private var progressCard: some View {
        DashboardCard(title: "Learning progress", subtitle: "Saved privately on this iPhone", symbol: "chart.bar.fill") {
            HStack(spacing: 10) {
                stat(value: tutor.correctChecks, label: "Confirmed")
                stat(value: tutor.needsReviewCount, label: "To revisit")
                stat(value: tutor.completedLessons, label: "Completed")
            }
            Text("An unclear answer is not marked wrong. The tutor asks for a rephrase and revisits topics you want to practice.")
                .font(.caption)
                .foregroundColor(Brand.muted)
                .padding(.top, 3)
        }
    }

    private func stat(value: Int, label: String) -> some View {
        VStack(spacing: 5) {
            Text("\(value)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Brand.ink)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Brand.muted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Brand.paper)
        .cornerRadius(12)
    }

    private var voiceCard: some View {
        DashboardCard(title: "Narrator voice", subtitle: "Use a better installed iPhone voice at no cost", symbol: "speaker.wave.2.fill") {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(tutor.selectedVoiceName)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Brand.ink)
                        Text(tutor.voiceQualityDescription + " quality")
                            .font(.caption)
                            .foregroundColor(Brand.muted)
                    }
                    Spacer()
                    Button("Change") { showVoice = true }
                        .buttonStyle(SecondaryButtonStyle())
                }
                HStack(spacing: 9) {
                    Text("Slower").font(.caption).foregroundColor(Brand.muted)
                    Slider(value: Binding(get: { tutor.speakingRate }, set: tutor.setSpeakingRate), in: 0.38...0.57, step: 0.01)
                    Text("Faster").font(.caption).foregroundColor(Brand.muted)
                }
                Button(action: tutor.previewVoice) {
                    Label("Preview selected voice", systemImage: "speaker.wave.2")
                        .font(.system(size: 13, weight: .semibold))
                }
                .disabled(tutor.phase != .paused && tutor.phase != .idle)
                .sheet(isPresented: $showVoice) {
                    VoicePickerView()
                        .environmentObject(tutor)
                }
            }
        }
    }

    private var helpCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "shield.lefthalf.filled")
                .foregroundColor(Brand.teal)
                .font(.system(size: 20))
            VStack(alignment: .leading, spacing: 4) {
                Text("Study safely, even on long shifts")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Brand.ink)
                Text("Use Drive mode for passive listening while moving. Use Practice only while parked. Headphone play/pause and skip controls are supported when iOS provides them. Voice recognition is offline but may be unavailable with the screen locked.")
                    .font(.caption)
                    .foregroundColor(Brand.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Brand.mint.opacity(0.70))
        .cornerRadius(16)
    }
}

private struct VoicePickerView: View {
    @EnvironmentObject var tutor: TutorEngine
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("VOICE SELECTION"), footer: Text("Only voices installed on this iPhone are available. You can download enhanced voices in Settings → Accessibility → Spoken Content or Read & Speak → Voices.")) {
                    voiceRow("Automatic best available", id: "", detail: "Prefers a high-quality U.S. English voice")
                    ForEach(tutor.availableVoices, id: \.identifier) { voice in
                        voiceRow(voice.name, id: voice.identifier,
                                 detail: "\(voice.language) · \(voice.quality.rawValue == 3 ? "Premium" : voice.quality.rawValue == 2 ? "Enhanced" : "Standard")")
                    }
                }
            }
            .navigationTitle("Narrator voice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }

    private func voiceRow(_ name: String, id: String, detail: String) -> some View {
        Button {
            tutor.selectVoice(id)
            presentationMode.wrappedValue.dismiss()
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(name).font(.body.weight(.medium)).foregroundColor(Brand.ink)
                    Text(detail).font(.caption).foregroundColor(Brand.muted)
                }
                Spacer()
                if tutor.chosenVoiceID == id {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(Brand.teal)
                }
            }
            .padding(.vertical, 3)
        }
    }
}

private struct DashboardCard<Content: View>: View {
    let title: String
    let subtitle: String
    let symbol: String
    let content: Content

    init(title: String, subtitle: String, symbol: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.symbol = symbol
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: symbol)
                    .foregroundColor(Brand.teal)
                    .frame(width: 30, height: 30)
                    .background(Brand.mint)
                    .cornerRadius(9)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(Brand.ink)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(Brand.muted)
                }
            }
            content
        }
        .padding(17)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(19)
        .overlay(RoundedRectangle(cornerRadius: 19).stroke(Brand.navy.opacity(0.055), lineWidth: 1))
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(Brand.teal.opacity(configuration.isPressed ? 0.74 : 1))
            .cornerRadius(13)
    }
}

private struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundColor(Brand.teal)
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(Brand.mint.opacity(configuration.isPressed ? 0.55 : 1))
            .cornerRadius(12)
    }
}

private struct QuietButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Brand.ink.opacity(configuration.isPressed ? 0.55 : 1))
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Brand.navy.opacity(0.09), lineWidth: 1))
    }
}
