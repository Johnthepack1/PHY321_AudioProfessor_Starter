# PHY 321 Audio Professor — V2.1

**A free, fully offline audio study coach for older iPhones (iOS 15+).**

This is the source package for your existing GitHub Actions + Sideloadly iPhone installation method. It maintains the **same bundle ID**, `org.phy321.audio.professor`, so installing over V1/V2 with the same signing account should preserve app data. **Do not delete your current app first** if you want to retain saved learning progress.

## What's new in V2.1

### Study the right exam topics

- **Exam 5:** Chapter 19 + Chapter 22 + Equation Finder scenarios (default focus).
- **Equation Finder:** 27 short scenarios teaching the reason to choose impulse-momentum, conservation, restitution, SHM, damping, particular solutions, and more.
- **Chapter 19:** rigid-body linear/angular momentum, impulse, and conservation conditions.
- **Chapter 22:** vibration, amplitude, natural frequency, free/forced motion, spring and pendulum models, rigid-body SHM, damping regimes, and second-order differential equations.
- **Math foundations** and **Full course** available.

The original 22 lessons, worked explanations, and 27 added equation drills give **49 total topics**. The new topic coverage follows the supplied Exam 5 study guide's **topic outline**; new worked stories are illustrative, not extracted exam questions.

### Three modes

1. **Lecture:** long explanations plus worked examples; automatically continues to the next lesson. No microphone.
2. **Practice:** long explanations followed by a spoken question. The microphone turns on only after the question finishes.
3. **Drive:** passive audio with a question and narrated reasoning included. **No microphone** and no requirement to respond. Choose this while moving, and avoid using on-screen controls while driving.

### Voice and controls

- Select from installed English iPhone voices; preview the voice; adjust rate.
- Math pronunciation normalization (omega, zeta, I-sub-G, x-double-dot, and others).
- Spoken commands **only while listening for an answer:** `repeat question`, `explain that again`, `give me an example`, `slower`, `faster`, `show answer`, `skip`, `pause`, `stop`.
- Answer capture: 25 seconds if completely silent; 5.5 seconds of hesitation between recognized phrases; hard limit 52 seconds for a recording (under the Speech framework's approximate one-minute task limit). Silence pauses instead of marking a wrong answer.
- More conservative offline answer checking; mismatched transcriptions are labeled **uncertain**, not incorrect. One automatic rephrase attempt, then an explanation and weak-topic review.
- Headset / lock-screen play, pause, next, and previous commands are wired through MediaPlayer. Actual behavior depends on iOS, the headset, and the app's foreground/background state. **Test it on your phone.**
- The narration keeps an on-device bookmark at the last spoken range. Restarting the app can resume near that place in the narration. A user-initiated lesson restart resets this bookmark.
- Queues weak concepts and revisits them after every few topics.
- Optional 5-, 10-, or 20-minute sessions, ending **at a lesson boundary** (so actual duration can exceed the selection).
- Redesigned native SwiftUI dashboard with prominent playback controls, status, progress, and voice settings.

## Important limitations

- **This is not ChatGPT inside the iPhone.** It cannot reliably interpret arbitrary nuanced answers. Voice grading is careful phrase/concept matching, not a generative or semantic model.
- **No always-listening wake word**; the mic is active only after practice questions. Headset/media controls are available for play/pause, but speaking `pause` while it is narrating will not interrupt narration.
- Offline speech recognition works only if `SFSpeechRecognizer` reports on-device recognition support and both permissions are granted. It may be less accurate and may not work while locked/backgrounded. The app never falls back to network recognition.
- Native TTS quality depends on the **voices available to AVSpeechSynthesizer on this iPhone**. Download available Enhanced voices through accessibility settings before checking the voice picker. The app cannot guarantee premium naturalness.
- Screen-locked narration uses the `audio` background mode and `.playback` session; continuous transitions and remote-control behavior **still require testing on your particular phone**.
- This package was parsed with the local Swift compiler; **the app itself cannot be compiled for iOS on Linux**. The GitHub Actions workflow now runs the offline evaluator tests and then builds with Xcode.
- Apple ID signing or Sideloadly free-account renewal rules are unchanged.

## Install from Windows (same process as V1)

1. Download and **Extract All** from `PHY321_AudioProfessor_V2_1.zip` to a temporary folder **outside** your cloned GitHub repository.
2. Open **GitHub Desktop → Current Repository: `PHY321_AudioProfessor_Starter` → Repository → Show in Explorer**.
3. Open the extracted `PHY321_AudioProfessor_V2_1` folder. Copy the **contents** (`App`, `.github`, `project.yml`, `README.md`, `.gitignore`, `AnswerEvaluatorTests.swift`) into the GitHub Desktop repository folder. Select **Replace the files in the destination**.
4. **Never move or delete the `.git` directory.** Do not paste a second outer V2.1 folder into the repository.
5. GitHub Desktop → **Changes → Summary:** `Upgrade PHY321 Professor to V2.1` → **Commit to main** → **Push origin**.
6. GitHub website → repository → **Actions → Build unsigned iPhone IPA → Run workflow → main → Run workflow**.
7. Open the green-check run. Under **Artifacts**, click `PHY321AudioProfessor-unsigned-ipa` and extract the ZIP once.
8. Drag `PHY321AudioProfessor-unsigned.ipa` into Sideloadly for Windows. Choose your iPhone and **the same Apple account used for the old app**. Install over the app. Do **not** first delete V1/V2 if you want to keep saved progress.
9. On iPhone, verify **Developer Mode** remains enabled under Settings → Privacy & Security. This is **separate** from developer certificate trust under Settings → General → VPN & Device Management.

### Three-minute parked test

- Open V2.1 and select **Exam 5 / Practice**. Press **Start lesson**. Let it ask a question. Watch the orange microphone indicator, and read the **Heard:** transcript.
- Say `show answer`, then say a simple correct answer at the next question. Check whether the transcript matches what you spoke.
- Switch to **Drive** mode, start a lesson, lock the screen, and test headphone pause/next. Do this **while safely parked**, before relying on it during a shift.
- Enable **Airplane Mode** and test a new practice question. Offline speech recognition may not be supported in every phone/locale combination; passive lecture and drive audio should still work.

### If GitHub Actions turns red

Open **build-iphone** and the first failed step. Copy the red compiler message, including the Swift filename and line number. The first test step catches offline curriculum issues; `Build unsigned app for real iPhones` catches iOS SDK errors. Do not reinstall until you have a green checkmark.

## Test summary

The included `AnswerEvaluatorTests.swift` checks 22 established curriculum answers, 27 new drills, 8 uncertain answers, 9 spoken commands, topic filters, duplicate IDs, and math pronunciation. Run locally on a computer with Swift:

```bash
swiftc App/Lessons.swift App/TeachingExtras.swift App/StudyModels.swift App/EquationDrills.swift App/SpeechText.swift App/AnswerEvaluator.swift AnswerEvaluatorTests.swift -o evaluator_tests
./evaluator_tests
```

No external services, passwords, or subscriptions are embedded in this project.
