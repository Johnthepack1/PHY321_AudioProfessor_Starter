# PHY 321 Offline Audio Professor — iPhone starter project

**Purpose:** A no-subscription, offline-first **native iPhone proof of concept** for older iPhones, assembled from a Windows PC using GitHub Actions (cloud macOS) and Sideloadly for installation.

**Status:** Source template prepared and structurally checked, **NOT compiled or tested on physical iOS hardware**. You must run the GitHub build and test on your iPhone. This is not a finished production app or a ChatGPT-like offline model.

## What works by design

- 22 original spoken micro-lessons in a prerequisite sequence (algebra → trigonometry → calculus → Chapters 19 and 22).
- Automatic progression without “want another?” interruptions.
- Built-in iPhone text-to-speech for lessons (no remote APIs).
- Offline speech recognition **only if** `supportsOnDeviceRecognition` is true for the current locale/device, with `requiresOnDeviceRecognition = true`. No online fallback.
- 25-second answer window. No detected speech means **PAUSE without any grade penalty**.
- Known-answer keyphrase recognition; `I don't know` leads to a simpler explanation.
- Revisit unrecognized/unknown concepts after later lessons.
- Save progress using iOS UserDefaults; same bundle ID during app re-signing is important.
- iOS media-control hooks for play/pause. Lock-screen audio behavior requires on-device testing.

## Limitations you must understand

- Spoken feedback relies on **keywords**, not semantic understanding. If you give a correct explanation using different words, it may be marked “could not confirm” and placed in review, not confidently wrong. This is intentionally conservative.
- No listening while the teacher is speaking. “Stop”/“pause” voice recognition only works during short question windows. Use headset media play/pause or phone controls otherwise.
- If offline speech recognition is unavailable or permissions fail, the tutor pauses at questions; tap the manual actions to continue. Voice interaction and Bluetooth routing can vary across iOS versions.
- The timer is a foreground/background best-effort prototype; locked-screen listening may not stay running on every device configuration. Validate it before relying on it.
- Text-to-speech uses the iPhone's locally available voices. Lessons do not send audio or transcripts anywhere.
- The 22 topics are a **starter sample**, not a complete representation of every PHY 321 slide/homework problem.
- Only test spoken active recall **while safely parked**, not while driving.
- GitHub public repositories are public: don't upload raw copyrighted lecture files, grades, or credentials.

## Part A: Build with Windows and GitHub

1. Create a free GitHub account at https://github.com.
2. Install Git for Windows (https://git-scm.com/downloads/win).
3. Unzip this starter project. Keep `project.yml`, the `App` directory, and the hidden `.github/workflows/build-ios.yml` directory intact.
4. On GitHub, choose **New repository**, name it `PHY321-AudioProfessor`, set **Public**, and leave the auto-initialize README option unchecked (the folder already includes one).
5. In Windows File Explorer, open the unzipped folder. Right-click → **Open Git Bash here** (or open Terminal in this folder).
6. Run the commands below; replace `YOUR_GITHUB_USERNAME` with your actual GitHub username:

   ```bash
   git init
   git config user.name "Your Display Name"
   git config user.email "your-github-email@example.com"
   git add .
   git commit -m "First offline audio professor prototype"
   git branch -M main
   git remote add origin https://github.com/YOUR_GITHUB_USERNAME/PHY321-AudioProfessor.git
   git push -u origin main
   ```

   The GitHub credential helper should open a browser sign-in if needed. **Never put your password or a personal access token into the repository.**

7. Open the GitHub repository. Go to **Actions** → **Build unsigned iPhone IPA** → **Run workflow**. It runs on GitHub's macOS runner, installs XcodeGen, generates an Xcode project and builds an **iPhone-device** executable with code signing disabled.
8. Open the completed workflow run. Under **Artifacts**, download `PHY321AudioProfessor-unsigned-ipa`. Unzip this GitHub artifact; inside is `PHY321AudioProfessor-unsigned.ipa`. Keep the `.ipa` file intact (do not unzip the IPA itself).
9. If the build fails, inspect the first **red step** in Actions (often `Generate iOS project` or `Build unsigned app`). Save that error text for debugging. The code has not been precompiled for you.

## Part B: Install the IPA using Sideloadly on Windows

1. Open the official Sideloadly page: https://sideloadly.io/ and its FAQ: https://sideloadly.io/faq .
2. Download Sideloadly for Windows. It requires Apple's **web-distributed** iTunes and iCloud components (not the Microsoft Store versions); use Sideloadly's official instructions and links. Restart Windows if it asks.
3. Plug the iPhone into Windows using a data-capable USB cable. Unlock the iPhone, select **Trust This Computer** if prompted, and verify the phone is visible to Sideloadly.
4. On iOS 16 or newer, enable **Developer Mode** under iPhone **Settings → Privacy & Security → Developer Mode**, and follow the reboot prompts. This option may only appear after attempting development installation.
5. In Sideloadly, drag in `PHY321AudioProfessor-unsigned.ipa`, select your phone, and use **Apple ID sideload** with your free Apple account. Sideloadly will sign and install the unsigned build.
6. If iOS reports **Untrusted Developer**, open **Settings → General → VPN & Device Management** and trust your developer profile.
7. Launch **PHY321 Professor** on the iPhone. Allow microphone and speech recognition when prompted. This app intentionally does **not** allow cloud speech recognition fallback.
8. Under Sideloadly, enable **automatic refresh**. With a free Apple ID an installed app expires after about **seven days**. Keep the same app bundle ID and Apple ID during renewals to help preserve on-device progress. Backup important data before reinstalling.

## Part C: Test offline, with the screen unlocked FIRST

1. Open the app while connected to Wi-Fi, grant permissions, then enable **Airplane Mode** (and confirm Wi-Fi and cellular are both off).
2. Tap **Start / Resume**. Hear the first explanatory lesson.
3. Wait for the question. Say an expected short answer. It should play an explanation and continue to the next lesson without asking permission to continue.
4. Say **"I don't know"** to a question. It should give a simpler explanation and add that topic to review.
5. On another question, say nothing for 25 seconds. It should **PAUSE** and leave your verified-correct count unchanged.
6. Tap **Start / Resume** to replay the question and resume. Media headset play controls are available, but Bluetooth behavior may vary.
7. Stop the session, close and reopen the app. Confirm it remembers the last regular lesson position and review count.
8. ONLY AFTER the basic tests work: lock the screen while an explanation is playing. Test whether it continues through a question and whether speech recognition still works. Log failures honestly rather than assuming background recording works.
9. Test using the actual headset and vehicle audio route **while parked**. A2DP playback and hands-free microphone input can behave differently.

## Part D: Weekly refresh, without reinstalling from scratch

- A free Apple account's app signature normally lasts seven days. Sideloadly's background daemon can refresh while the Windows PC is online and the iPhone is connected by USB or previously configured Wi-Fi sync.
- The PC and phone need to connect again before the signature expires. Without that, the app may stop launching until re-signed.
- Updating the app works best with the same Apple ID and unchanged `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml`. Never delete the app unless you have a backup and accept losing its local history.

## Files and what they do

- `project.yml`: XcodeGen's project definition; app name, privacy usage strings, iOS version, background audio setting.
- `.github/workflows/build-ios.yml`: builds unsigned IPA on GitHub macOS. You do not need a Mac locally.
- `App/PHY321AudioProfessorApp.swift`: the iPhone interface.
- `App/TutorEngine.swift`: speech synthesis, short on-device speech recognition, 25-second pause logic, reviews, saving progress.
- `App/Lessons.swift`: 22 original teaching units plus expected phrases and explanations.

## To edit the curriculum

`App/Lessons.swift` contains a `Curriculum.topics` array. Each `Lesson` defines:

- `explanation`: the teacher's main teaching audio;
- `question`: one spoken comprehension question;
- `acceptedPhrases`: simple, incomplete answer recognition (not a semantic grader);
- `correctExplanation`: what to say after a matched answer;
- `remediation`: simpler explanation if unknown or unrecognized.

Change or add a lesson in this file, commit and push, rerun GitHub Actions, and sideload the updated IPA.

## Troubleshooting

| Problem | What to check |
|---|---|
| No workflow in Actions | Confirm `.github/workflows/build-ios.yml` is present on the repository's **main** branch and Actions is enabled. |
| Build error | Open the failed Actions step and read the exact compiler message. Don't guess at a fix. |
| IPA not found | Download the workflow **Artifact**, then extract the outer ZIP once. |
| Sideloadly can't detect phone | Trust computer, try a proper USB data cable, install the web-distributed Apple components, restart. |
| App says untrusted developer | Trust the profile in Settings → General → VPN & Device Management. |
| Developer Mode required | Settings → Privacy & Security → Developer Mode, reboot/confirm. |
| Offline recognition unavailable | Check permissions, system language, and `supportsOnDeviceRecognition`; continue with manual controls. |
| No audio with screen locked | Verify audio routing, volume, background mode, interruptions; collect device logs. |
| Voice commands don't work mid-lecture | Expected in V1. Recognition only runs during question windows. Use media buttons otherwise. |
| App stops launching after several days | Refresh its free Apple ID signature using Sideloadly. |

## Useful primary docs

- GitHub macOS runners: https://docs.github.com/en/actions/reference/runners/github-hosted-runners
- XcodeGen: https://github.com/yonaskolb/XcodeGen
- Sideloadly setup: https://sideloadly.io/faq
- Apple on-device speech availability: https://developer.apple.com/documentation/speech/sfspeechrecognizer/supportsondevicerecognition
- Apple background audio: https://developer.apple.com/documentation/AVFAudio/AVAudioSession/Category-swift.struct/playback

This project is a classroom learning aid; use it to understand material, not as a substitute for doing graded work independently.
