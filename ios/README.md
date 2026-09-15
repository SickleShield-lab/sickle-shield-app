# Sickle Shield iOS app

Native SwiftUI, matching the neumorphic + liquid-glass design we settled on.

## Structure

```
ios/
  project.yml                  XcodeGen spec - generates the .xcodeproj (no manual pbxproj editing)
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
      Explore/          + ExploreViewModel
      Tracker/          + TrackerViewModel
      Reminders/        + RemindersViewModel, AddReminderSheet
      Reports/          + ReportsViewModel, NameReportSheet
      Emergency/        + EmergencyViewModel, LocationManager, AddEmergencyContactSheet
    Networking/
      APIConfig.swift    Backend base URL - CHANGE THIS before running against a real deploy
      APIClient.swift    Generic request/upload methods, matches the backend's {success,message,data} envelope
      KeychainHelper.swift
      AuthAPI.swift, PainAPI.swift, MedicationAPI.swift, HospitalAPI.swift, AppointmentAPI.swift, ResourceAPI.swift, GoalAPI.swift
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
6. In the project settings under **Signing & Capabilities**, set your own Apple Developer Team and adjust `PRODUCT_BUNDLE_IDENTIFIER` in `project.yml` if `com.sickleshield.app` isn't available to you, then re-run `xcodegen generate`.
7. Pick an iPhone simulator and hit Run.

Whenever `project.yml` changes (new files usually don't need this - XcodeGen picks up anything under `SickleShield/` automatically - but target settings, new frameworks, etc. do), re-run `xcodegen generate`.

## What's implemented

All five tabs, wired to the real backend, with the exact visual language from the prototype:

- **Auth**: sign up -> email OTP verification -> logged in; login; JWT stored in the Keychain; the app boots into the auth flow or the main tabs depending on whether a token is stored.
- **Explore**: real profile (name, pain score, water intake, weight), next appointment, educational resources.
- **Tracker**: real pain history charted as a trend line, real water intake, "Log a crisis" posts a real pain entry.
- **Reminders**: real list, add, delete.
- **Reports**: real list, delete, and upload (via the Photos picker - see note below).
- **Emergency**: real contacts (add/delete/call), and a real **SOS** button - it asks for location permission, gets your location, and opens the Messages app pre-addressed to every emergency contact with a Google Maps link. There's no backend endpoint for this; it's a native, client-side feature by design.

### Before this will actually run against your backend

1. **Set `APIConfig.baseURL`** to wherever your backend is reachable from the simulator/device - `http://localhost:5006/api/v1` only works if the backend is running locally and you're using the Simulator.
2. **Run the Pain-model migration.** While wiring the trend chart I found (and fixed) a bug in the backend: the `Pain` table had a `@@unique([pain, userId])` constraint that made every new crisis log silently overwrite the last one instead of creating history. That's fixed in `prisma/schema.prisma` and `pain.service.ts`, but the change needs `npx prisma migrate dev` run against your real database before it takes effect - I don't have DB credentials to run it myself.
3. **Push notifications are stubbed.** The backend requires an `fcmToken` on signup/login; the app currently sends the device's own vendor UUID as a placeholder so account creation works, but no push notifications will actually be delivered until Firebase Cloud Messaging is integrated (needs a `GoogleService-Info.plist` from your Firebase project, added in Xcode).

### Known scope cuts (flagging rather than silently skipping)

- Report upload only supports photos (via `PhotosPicker`), not PDFs/documents. A `UIDocumentPickerViewController` wrapper would extend this to any file type - reasonable next step, just not built yet.
- `Hospital` directory browsing and creating appointments aren't wired yet (only reading your existing appointments, for the Explore card).
- No profile-completion screen yet for the dob/gender/smoking/diagnosis fields collected in the original onboarding video - accounts work fully without it, but that data isn't collected in the current flow.

This hasn't been compiled or run yet since it was written without access to a Mac/Xcode. Once you generate and open the project, there may be small build errors to fix (e.g. exact SwiftUI API availability) - flag them and I'll correct them immediately.
