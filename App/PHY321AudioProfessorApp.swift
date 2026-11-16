import SwiftUI

@main
struct PHY321AudioProfessorApp: App {
    @StateObject private var tutor = TutorEngine()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tutor)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var tutor: TutorEngine

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("PHY 321")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                    Text("Offline Audio Professor")
                        .font(.title2.weight(.medium))
                    Label("No network calls • Lessons stored on device", systemImage: "wifi.slash")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    GroupBox(label: Label("Current lesson", systemImage: "book.closed")) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(tutor.topic.chapter)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(tutor.topic.title)
                                .font(.title3.weight(.bold))
                            Text(tutor.status)
                                .font(.body)
                            Text("Status: \(tutor.phase.rawValue)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                    }

                    HStack(spacing: 12) {
                        Button(action: tutor.startOrResume) {
                            Label("Start / Resume", systemImage: "play.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button(action: tutor.pause) {
                            Label("Pause", systemImage: "pause.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    Button(action: tutor.stop) {
                        Label("Stop session", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    GroupBox(label: Label("Answer controls", systemImage: "mic")) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("During a question, the app listens for at most 25 seconds. If no answer is heard, it pauses without lowering your score.")
                                .font(.callout)
                            Text("Last recognized: \(tutor.lastRecognized.isEmpty ? "(nothing yet)" : tutor.lastRecognized)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            HStack {
                                Button("I don't know") { tutor.manualUnknown() }
                                Button("I understood") { tutor.manualUnderstood() }
                            }
                            .buttonStyle(.bordered)
                            Button("Repeat explanation") { tutor.repeatExplanation() }
                                .buttonStyle(.bordered)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                    }

                    GroupBox(label: Label("Learning progress", systemImage: "brain.head.profile")) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Practice concepts: \(Curriculum.topics.count)")
                            Text("Understood checks: \(tutor.correctChecks)")
                            Text("Needs review: \(tutor.needsReviewCount)")
                            Text("Current teaching position is saved automatically.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                    }

                    Text("IMPORTANT: For safety, use listening-only lessons while driving. Use spoken answer practice when safely parked. Microphone recognition with the screen locked may vary by iOS version and headset.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}
