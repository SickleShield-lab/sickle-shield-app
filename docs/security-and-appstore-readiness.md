# Sickle Shield: Security & App Store Readiness

As of 2026-09-17.

## Where things stand

Security work already done this session (backend): hardcoded secrets removed from source (DigitalOcean Spaces keys, OneSignal key, Firebase service account) and moved to environment variables; several IDOR vulnerabilities closed (appointments, emergency contacts, reports and reminders were previously viewable/editable/deletable by any logged-in user, not just their owner); admin-only actions locked down (looking up any user by id, managing educational resources); a broken MongoDB-ObjectId-style validation check fixed (it was silently rejecting real Postgres UUIDs); unused dependencies removed (stripe, mongodb, cloudinary - leftover from reused boilerplate).

Not done yet: the credentials above were removed from *code*, but the old values are still technically live until rotated in each provider's dashboard (Firebase, DigitalOcean, OneSignal, JWT secret, database password, email password). Everything below is what's still needed on top of that before this is genuinely hard to hack and ready for App Store submission.

## Security hardening still needed

Credential rotation is the most urgent single item - everything else here can wait a few days, that one shouldn't.

| Item | Why it matters | Priority |
| --- | --- | --- |
| Rotate all previously-exposed credentials (Firebase key, DO Spaces keys, OneSignal key, JWT secret, DB password, email password) | These sat hardcoded in source; the old values must be treated as compromised regardless of whether they were ever pushed publicly | Critical |
| Rate-limit login, signup, and OTP endpoints | Nothing currently stops brute-forcing a 4-digit OTP (10,000 combinations) or credential-stuffing the login endpoint | Critical |
| Add a real password policy check server-side | The login schema currently validates only that an email is present, not password strength | High |
| Add `helmet` (or equivalent) security headers | No security headers (CSP, X-Content-Type-Options, X-Frame-Options) are set on API responses today | High |
| Audit every endpoint for input validation | Several routes (e.g. pain, hospital creation) skip the zod `validateRequest` schema that others use consistently | High |
| Shorten JWT access token lifetime + consider refresh tokens | Current tokens live for 15 days; a stolen token stays valid for that whole window | Medium |
| Restrict CORS to known origins in production | The API currently allows any origin (`cors()` with no config) | Medium |
| Validate uploaded files server-side (type, size, content) | Reports and profile images are user-uploaded; confirm the server checks these, not just the client | Medium |
| Remove debug `console.log` calls that print request data | At least one leftover debug log was found; health-app logs should never carry PII | Medium |
| Run `npm audit` / enable Dependabot on the backend | 12 unresolved transitive vulnerabilities remain in `firebase-admin`'s own dependency chain | Medium |
| Confirm Postgres connection uses TLS and a least-privilege DB user | Standard production DB hardening, not yet confirmed | Medium |
| Confirm "Delete account" actually purges data as the in-app privacy policy promises | The UI has this button already; needs an end-to-end check that it does what it says | Medium |

Already in good shape and worth keeping as-is: the iOS app stores its session token in the Keychain (not `UserDefaults`), and the backend already hides stack traces from API responses outside development.

## App Store submission requirements

Separate from security: these are Apple's own policy and technical requirements for a health app specifically.

| Requirement | What it means for this app | Status |
| --- | --- | --- |
| Paid Apple Developer Program membership ($99/yr) | Required to submit at all, and to distribute HealthKit/Watch/Wallet features to real users | Not yet enrolled |
| `PrivacyInfo.xcprivacy` manifest | Now required for apps using "required reason" APIs (e.g. UserDefaults, file timestamps) - missing this can block submission outright | Not yet added |
| Accurate Privacy Nutrition Label in App Store Connect | Must disclose health data, location, contacts (emergency contacts), and photos (reports) as collected data types | Not yet filled in |
| Public, linked Privacy Policy | A written policy already exists (from the original user guide); needs to be hosted at a public URL and linked both in-app and in App Store Connect | Policy exists, not hosted/linked |
| No unqualified medical claims | Apple scrutinizes health apps closely; the crisis risk score must read as informational, not diagnostic - needs a visible disclaimer | Not yet added |
| In-app account deletion (Guideline 5.1.1(v)) | Apple requires this whenever an app allows account creation | Already built - needs an end-to-end check |
| Sign in with Apple | Only required if another third-party/social login (Google, Facebook, etc.) is ever added; not required for email/password alone | Not applicable today |
| App icons (all required sizes) + launch screen | Need a real icon asset set; launch screen generation is already configured | Icon set not yet confirmed |
| Export compliance answer (encryption) | The App Store Connect submission form asks this; using only standard HTTPS typically qualifies for the usual exemption | Not yet submitted |
| Age rating questionnaire | Needs to be filled out honestly given medical/health subject matter | Not yet done |
| Support URL + Marketing URL | Required fields in the App Store Connect listing | Not yet set up |
| Real-device stability testing across screen sizes | Apple rejects apps that crash on review devices | Not yet done |
| TestFlight beta (recommended, not required) | Worth doing given the safety-critical SOS feature, before a public release | Not started |

One scoping note already settled: the app targets iPhone only (not iPad), which sidesteps some layout-review overhead but should stay a deliberate choice, not an oversight.

## Suggested order to tackle this

1. Rotate every exposed credential - zero downside to doing this immediately, and nothing else here depends on waiting.
2. Add rate limiting on login/signup/OTP - closes the most realistic near-term attack before any beta users touch the app.
3. Add security headers and audit input validation coverage across routes.
4. Add the `PrivacyInfo.xcprivacy` manifest and write the real Privacy Nutrition Label answers.
5. Get Apple Developer Program enrollment sorted - it's on the path for HealthKit/Watch/Wallet anyway, and nothing can be submitted without it.
6. Add a medical-disclaimer to the crisis risk score feature before it's ever seen by App Review.
7. Run a TestFlight internal beta before the public submission.

None of this blocks continuing feature work in parallel - it's meant to be picked up alongside everything else, not instead of it.
