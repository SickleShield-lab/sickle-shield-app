# Sickle Shield iOS app

Native SwiftUI, matching the neumorphic + liquid-glass design we settled on.

## Structure

```
ios/
  project.yml                  XcodeGen spec - generates the .xcodeproj (no manual pbxproj editing)
  Shared/                      SharedStore.swift, CrisisActivityAttributes.swift - written for a
                                widget extension target that's currently PAUSED (see below);
                                harmless to keep, just unused right now
  SickleShieldWidgets/         Widget extension source - NOT currently part of the Xcode project
                                (see "Widget/Live Activity paused" below)
  SickleShield/
    SickleShieldApp.swift      App entry point
    RootTabView.swift          Bottom tab bar wiring the 5 screens
    DesignSystem/
      Theme.swift              Colors, radii
      NeumorphicStyles.swift   .neumorphicCard() / .neumorphicPressed() view modifiers
      GlassHeader.swift        Red-tinted frosted glass header (uses .ultraThinMaterial)
      Components/
        StatTile.swift
        ServiceTile.swift
        PulsingSOSButton.swift
    Features/
      Auth/            LoginView, SignUpView, OTPVerificationView, AuthRootView
      Explore/          + ExploreViewModel, HealthKitManager, RiskScoreEngine
      Tracker/          + TrackerViewModel
      Reminders/        + RemindersViewModel, AddReminderSheet
      Reports/          + ReportsViewModel, NameReportSheet
      Emergency/        + EmergencyViewModel, LocationManager, AddEmergencyContactSheet, WidgetReloader
    Intents/            LogCrisisIntent.swift - Siri / Shortcuts support
    Networking/
      APIConfig.swift    Backend base URL - CHANGE THIS before running against a real deploy
      APIClient.swift    Generic request/upload methods, matches the backend's {success,message,data} envelope
      KeychainHelper.swift
      AuthAPI.swift, PainAPI.swift, MedicationAPI.swift, HospitalAPI.swift, AppointmentAPI.swift, ResourceAPI.swift, GoalAPI.swift
      WeatherAPI.swift    Open-Meteo (free, no API key) - feeds the crisis risk score
    Models/              Codable structs matching the Prisma schema field-for-field
    State/
      SessionStore.swift  Holds the logged-in user + JWT, gates Auth vs main app
```

## First-time setup (on a Mac)

1. Install Xcode from the App Store (this needs macOS - there's no way around that for building/signing/submitting an iOS app).
2. Install [Homebrew](https://brew.sh) if you don't have it.
3. Install XcodeGen, which generates the `.xcodeproj` from `project.yml` so nobody has to hand-edit Xcode's project file format:
   ```
   brew install xcodegen
   ```
4. From the `ios/` folder, generate the project:
   ```
   cd ios
   xcodegen generate
   ```
5. **Quit Xcode fully if it's open**, then delete any old generated project first, to guarantee a clean slate:
   ```
   rm -rf SickleShield.xcodeproj
   xcodegen generate
   ```
6. Open `SickleShield.xcodeproj` in Xcode.
7. Select the `SickleShield` target > **Signing & Capabilities** > pick your Apple ID under Team. Adjust `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml` if `com.sickleshield.app` isn't available to you, then re-run `xcodegen generate`.
8. Pick an iPhone Simulator (or your connected device) as the destination, and hit Run (▶).

**Whenever `project.yml` changes**, re-run `xcodegen generate` from the `ios/` folder to regenerate the `.xcodeproj` (new Swift files under existing folders don't need this - XcodeGen picks those up automatically - but target settings, entitlements, etc. do).

### Widget / Live Activity - paused

This project briefly had a second Xcode target (`SickleShieldWidgets`) for a Home Screen widget and a Live Activity. It's been pulled back out of `project.yml` for now - across three rounds of real-device testing it produced a scheme-picker trap, a "supported platforms" mismatch, and finally `xcodegen generate` failing to complete at all. Rather than keep guessing at multi-target YAML blind, the source files are still in the repo (`SickleShieldWidgets/`, `Shared/`) untouched, and re-adding that target is a good candidate for a session where we add it back one step at a time with real build feedback after each change, instead of all at once.

Everything else - all five tabs, the risk score, voice logging, HealthKit, Siri, SOS black box, PDF export - only ever needed the single main app target and was not affected by this.

### Troubleshooting

**Run button greyed out:**
1. No destination selected, or the destination picker is empty. Click it (next to the scheme picker, top-left) and pick any Simulator or your connected device. If no simulators are listed, go to Xcode > Settings > Platforms and download an iOS runtime.
2. Still indexing - watch for a progress bar in the top-center status area after first opening a project; Run stays disabled until it finishes.
3. No Team selected for signing (see step 7 above).

**`xcodegen generate` doesn't finish / prints "Generating project..." and nothing else:**
1. Make sure you're on the latest `project.yml` (`git pull origin main`) - the multi-target config that could cause this has been removed.
2. Fully quit Xcode before regenerating (an open Xcode project can lock files XcodeGen needs to write).
3. If it still doesn't complete, run `xcodegen version` and send me the output, plus how long you waited.

**"Cannot find 'X' in scope" for a type that exists in the repo:**
Almost always a stale project. Quit Xcode, `rm -rf SickleShield.xcodeproj`, `xcodegen generate` again, reopen.

For anything else, send me the exact text from Xcode's Issue Navigator (the ⚠️/❌ tab in the left sidebar) rather than the toolbar popup - it usually names the specific file/setting involved.

## What's implemented

All five tabs, wired to the real backend, with the exact visual language from the prototype:

- **Auth**: sign up -> email OTP verification -> logged in; login; JWT stored in the Keychain; the app boots into the auth flow or the main tabs depending on whether a token is stored.
- **Explore**: real profile (name, pain score, water intake, weight), next appointment, educational resources.
- **Tracker**: real pain history charted as a trend line, real water intake, "Log a crisis" posts a real pain entry.
- **Reminders**: real list, add, delete.
- **Reports**: real list, delete, and upload (via the Photos picker - see note below).
- **Emergency**: real contacts (add/delete/call), and a real **SOS** button - it asks for location permission, gets your location, and opens the Messages app pre-addressed to every emergency contact with a Google Maps link **plus a "black box" summary** (crises in the last 24h, average severity, today's water intake) so whoever receives it has real context, not just a pin on a map. There's no backend endpoint for this; it's a native, client-side feature by design.

### "Spectacular" features (added on top of the base build)

- **Predictive crisis risk score** (Explore tab): a 0-100 score with a plain-language explanation, computed from *this person's own* pain history, hydration, and today's actual local weather (via Open-Meteo - free, no API key, so it works without WeatherKit/Apple Developer enrollment). It's a transparent heuristic (`RiskScoreEngine.swift`), not a trained model - the win is that it's personalized, not a generic tip feed.
- **Voice crisis logging** (Tracker tab): tap the mic, say something like "pain 7, lower back, from the cold," and it pre-fills the severity slider, trigger chips, and location from the transcript (`VoiceLogger.swift` + `VoiceCrisisParser`) using on-device Speech framework recognition. Keyword extraction, not real NLU - good enough to save typing mid-crisis, not a general assistant.
- **Doctor-ready PDF export** (Tracker tab, "Export" next to the trend chart): generates a one-page PDF with patient info, the trend chart, and a full entries table, then opens the share sheet (`PainReportExporter.swift`, pure PDFKit/Core Graphics, no dependency).

### Phase 2 - Apple-native platform features

- **Siri / Shortcuts** (`Intents/LogCrisisIntent.swift`): "Log a pain crisis in Sickle Shield" logs a real pain entry via Siri without opening the app. Works on a free Apple ID.
- **HealthKit** (`HealthKitManager.swift`): reads latest heart rate and blood oxygen (read-only, never writes), feeding into the risk score - elevated heart rate or low SpO2 now raise the score. Needs the HealthKit capability (already in the entitlements file) - works on a free account for local testing.
- **Home Screen widget & Live Activity**: built, but currently paused/not part of the Xcode project - see "Widget / Live Activity - paused" above.

### Deliberately not attempted

- **True offline-first** (local persistence + sync queue) - needs its own dedicated architecture pass; would touch every screen already built.
- **Apple Watch companion app** - a full separate watchOS target with its own UI and WatchConnectivity plumbing; big enough to deserve its own pass.
- **Apple Wallet pass** - hard-blocked, not just harder to test: generating a `.pkpass` requires a Pass Type ID certificate that only exists once you're enrolled in the paid Apple Developer Program. Nothing to build yet.
- **Blood donor matching and peer support community** - product-safety/moderation design problems (liability, verifying claims, content moderation) more than engineering ones; deliberately not started until that design conversation happens.
- **Telehealth video** - needs picking and paying for a vendor (Twilio/Agora/Daily.co); not started pending that decision.

## How to test each feature

You need the backend reachable from wherever Xcode is running it. Simplest path on your Mac: clone `backend/spectre0110-backend-main`, `npm install`, fill in `.env` (see its own README), and `npm run dev` - the Simulator can reach `http://localhost:5006` directly since it shares your Mac's network stack (a physical device needs your Mac's LAN IP instead - see `APIConfig.swift`).

1. **Auth** - Sign up, then check the email inbox you used for the OTP (see the "known issue" below - this currently fails against the real mail server). Or just log in if you already seeded a user (see the backend's test tooling from our earlier session, or create one directly).
2. **Explore** - After logging in, you should see your name, pain/water/weight tiles, and the risk score card. The risk score needs Location permission (for weather) - accept the prompt.
3. **Tracker** - Tap "Log a crisis" to use the manual form, or tap the mic button and say something like "pain 7, lower back, from the cold" - watch it transcribe live, then pre-fill the slider/chips when you tap the mic again to stop. Tap "Export" next to the trend chart to generate and share a PDF (needs at least one logged entry).
4. **Reminders** - Add one, confirm it appears in the list, delete it.
5. **Reports** - Tap "Upload report," pick a photo, name it, confirm it appears in the list.
6. **Emergency** - Add a contact first (SOS needs at least one). Tap SOS: it'll ask for Location permission, then open Messages pre-addressed with a maps link and your recent vitals.
7. **Siri Shortcut** - open the Shortcuts app (preinstalled), create a new shortcut, search for "Log a pain crisis," add it, and run it.
8. **HealthKit** - In the Simulator's **Health** app, manually add a Heart Rate or Blood Oxygen sample (Browse > search for it > Add Data Point), then reopen Sickle Shield's Explore tab and pull to refresh - the risk score's reasons should reflect it if the values are elevated/low enough to matter.

### Before this will actually run against your backend

1. **Set `APIConfig.baseURL`** to wherever your backend is reachable from the simulator/device - `http://localhost:5006/api/v1` only works if the backend is running locally and you're using the Simulator.
2. **Run the Pain-model migration.** While wiring the trend chart I found (and fixed) a bug in the backend: the `Pain` table had a `@@unique([pain, userId])` constraint that made every new crisis log silently overwrite the last one instead of creating history. That's fixed in `prisma/schema.prisma` and `pain.service.ts`, but the change needs `npx prisma migrate dev` run against your real database before it takes effect - I don't have DB credentials to run it myself.
3. **Push notifications are stubbed.** The backend requires an `fcmToken` on signup/login; the app currently sends the device's own vendor UUID as a placeholder so account creation works, but no push notifications will actually be delivered until Firebase Cloud Messaging is integrated (needs a `GoogleService-Info.plist` from your Firebase project, added in Xcode).

### Known scope cuts (flagging rather than silently skipping)

- Report upload only supports photos (via `PhotosPicker`), not PDFs/documents. A `UIDocumentPickerViewController` wrapper would extend this to any file type - reasonable next step, just not built yet.
- `Hospital` directory browsing and creating appointments aren't wired yet (only reading your existing appointments, for the Explore card).
- No profile-completion screen yet for the dob/gender/smoking/diagnosis fields collected in the original onboarding video - accounts work fully without it, but that data isn't collected in the current flow.

This was written without access to a Mac/Xcode and is now being tested for the first time on real hardware - if the build itself throws errors (as opposed to the Run-button scheme issue above), send me the exact message from Xcode's Issue Navigator and I'll fix it right away.
