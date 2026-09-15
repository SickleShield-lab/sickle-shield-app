# Sickle Shield

A health companion app for people living with sickle cell disease (SCD) — crisis tracking, medication reminders, medical report storage, and an emergency SOS flow, backed by a REST API.

Private repo. Currently in active development, pre-launch.

## What's in here

```
backend/spectre0110-backend-main/   Node.js + Express + Prisma (Postgres) API
ios/                                 Native SwiftUI iOS app
```

Each half has its own setup README:

- [`backend/spectre0110-backend-main/README.md`](backend/spectre0110-backend-main/README.md)
- [`ios/README.md`](ios/README.md)

## Features

- **Explore** — daily health snapshot: pain score, water intake, weight, next appointment, educational resources
- **Tracker** — crisis logging (severity, likely triggers) with a pain-trend history chart
- **Reminders** — medication schedule with add/delete
- **Reports** — upload and manage medical documents (blood tests, discharge letters, etc.)
- **Emergency** — emergency contacts plus a native SOS flow that shares live location via SMS

## Tech stack

- **Backend**: Node.js, Express, TypeScript, Prisma ORM, PostgreSQL, JWT auth, DigitalOcean Spaces (file storage), OneSignal (push), Firebase Admin
- **iOS**: Swift, SwiftUI (no third-party dependencies), native `URLSession` networking, Keychain-backed session storage, XcodeGen for project generation

## Status

- Backend: functional, security-hardened (see commit history — fixed several IDOR issues, removed hardcoded secrets, corrected a data-modeling bug in crisis logging)
- iOS: full five-tab UI wired to live backend data, written but not yet compiled/run (built without local Xcode/macOS access) — first Xcode build should be treated as a debugging pass
- Not yet submitted to the App Store

## Design

Neumorphic design system with a red-tinted "liquid glass" header (`.ultraThinMaterial`-based), matching the agreed prototype. See `ios/SickleShield/DesignSystem/` for the reusable style modifiers and components.
