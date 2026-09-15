# Sickle Shield iOS app

Native SwiftUI, matching the neumorphic + liquid-glass design we settled on.

## Structure

```
ios/
  project.yml                  XcodeGen spec - generates the .xcodeproj (no manual pbxproj editing)
  Shared/                      Files included in BOTH the app and widget extension targets
    SharedStore.swift          App Group bridge (main app writes, widget reads)
    CrisisActivityAttributes.swift   Live Activity data shape
  SickleShieldWidgets/         Widget extension target: home screen widget + Live Activity UI
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
5. Open `SickleShield.xcodeproj` in Xcode.
6. In the project settings under **Signing & Capabilities**, set your own Apple Developer Team **for both the `SickleShield` and `SickleShieldWidgets` targets**, and adjust `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml` if `com.sickleshield.app`/`com.sickleshield.app.widgets` aren't available to you, then re-run `xcodegen generate`.
7. **This is the step most likely to need manual fixing**: Xcode needs to actually register the App Group. With the `SickleShield` target selected, go to Signing & Capabilities and confirm `group.com.sickleshield.app` shows under App Groups (it should already be listed from the entitlements file XcodeGen wrote) - if Xcode shows an error instead of a checkmark, click the group, let Xcode create/register it with your team, then repeat for the `SickleShieldWidgets` target so both point at the exact same group ID. Multi-target + App Group + widget extension wiring is the one part of this project I could not verify at all without Xcode itself, so treat this step as the most likely place for something to need a manual nudge.
8. Pick an iPhone simulator and hit Run. To see the widget, long-press the simulator's home screen and add it; the Live Activity appears automatically the next time you trigger SOS.

Whenever `project.yml` changes (new files usually don't need this - XcodeGen picks up anything under `SickleShield/` automatically - but target settings, new frameworks, etc. do), re-run `xcodegen generate`.

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
- **Home Screen widget** (`SickleShieldWidgets/PainWidget.swift`): shows pain score and water intake without opening the app. Updates whenever the app fetches fresh data (via an App Group + `WidgetCenter.reloadAllTimelines()`), plus a once-an-hour timeline refresh as a safety net.
- **Live Activity** (`SickleShieldWidgets/CrisisLiveActivity.swift`): starts automatically when SOS fires, showing severity and who was alerted on the Lock Screen and Dynamic Island. Ends via "Mark crisis as resolved" on the Emergency tab.

**This is the part of the whole project I'd flag as highest-risk without a Mac to test on.** Adding a widget extension target by hand-editing a YAML spec (rather than through Xcode's own "New Target" wizard, which handles a lot of this invisibly) is the trickiest Xcode configuration in this codebase - multi-target builds, an App Group shared between two bundle IDs, and a Live Activity's data type needing to live in both targets at once. I validated every YAML/plist file for syntactic correctness (no macOS needed for that), but semantic correctness inside Xcode itself is unverified. See step 7 in setup above.

### Deliberately not attempted

- **True offline-first** (local persistence + sync queue) - needs its own dedicated architecture pass; would touch every screen already built.
- **Apple Watch companion app** - a full separate watchOS target with its own UI and WatchConnectivity plumbing; big enough to deserve its own pass rather than being squeezed in alongside the widget/Live Activity work.
- **Apple Wallet pass** - hard-blocked, not just harder to test: generating a `.pkpass` requires a Pass Type ID certificate that only exists once you're enrolled in the paid Apple Developer Program. Nothing to build yet.
- **Blood donor matching and peer support community** - product-safety/moderation design problems (liability, verifying claims, content moderation) more than engineering ones; deliberately not started until that design conversation happens.
- **Telehealth video** - needs picking and paying for a vendor (Twilio/Agora/Daily.co); not started pending that decision.

### Before this will actually run against your backend

1. **Set `APIConfig.baseURL`** to wherever your backend is reachable from the simulator/device - `http://localhost:5006/api/v1` only works if the backend is running locally and you're using the Simulator.
2. **Run the Pain-model migration.** While wiring the trend chart I found (and fixed) a bug in the backend: the `Pain` table had a `@@unique([pain, userId])` constraint that made every new crisis log silently overwrite the last one instead of creating history. That's fixed in `prisma/schema.prisma` and `pain.service.ts`, but the change needs `npx prisma migrate dev` run against your real database before it takes effect - I don't have DB credentials to run it myself.
3. **Push notifications are stubbed.** The backend requires an `fcmToken` on signup/login; the app currently sends the device's own vendor UUID as a placeholder so account creation works, but no push notifications will actually be delivered until Firebase Cloud Messaging is integrated (needs a `GoogleService-Info.plist` from your Firebase project, added in Xcode).

### Known scope cuts (flagging rather than silently skipping)

- Report upload only supports photos (via `PhotosPicker`), not PDFs/documents. A `UIDocumentPickerViewController` wrapper would extend this to any file type - reasonable next step, just not built yet.
- `Hospital` directory browsing and creating appointments aren't wired yet (only reading your existing appointments, for the Explore card).
- No profile-completion screen yet for the dob/gender/smoking/diagnosis fields collected in the original onboarding video - accounts work fully without it, but that data isn't collected in the current flow.

This hasn't been compiled or run yet since it was written without access to a Mac/Xcode. Once you generate and open the project, there may be small build errors to fix (e.g. exact SwiftUI API availability) - flag them and I'll correct them immediately.
