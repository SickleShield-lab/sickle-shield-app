# Sickle Shield 2.0 — Redesign Reference

As of 2026-09-18. Visual reference: `design/sickle-shield-2.0-mockups.html` (open in a browser — static HTML/CSS, not connected to the app).

## Vision

Evolve the existing app — architecture, backend, and functionality already in place — into a premium, Apple-quality iOS health companion for people living with sickle cell disease. Not "more features." Better product design, UX, information architecture, accessibility, data visualization, and SCD-specific functionality, while staying focused.

**Product personality**: supportive without being patronizing · clinical without feeling cold · modern without being gimmicky · intelligent without pretending to be a doctor · personal without being intrusive · simple without being simplistic.

**Never build**: an AI chatbot/doctor, a diagnosis or treatment engine, a fake "Sickle Cell Health Score," social/leaderboard features, or EHR integration. Every feature must answer "what problem does this solve for a person living with SCD?" — if there's no good answer, don't build it.

## Current state audit (summary)

**Architecture** — `Features/<Domain>/{View,ViewModel}`, `Networking/<Domain>API.swift`, `Models/`, `DesignSystem/`. Real strengths already in place: `AppRouter` for cross-tab navigation, a working WidgetKit target (`PainWidget.swift`), a Siri `AppIntent` (`LogCrisisIntent.swift`), Live Activities for active crises, and a transparent (non-black-box) `RiskScoreEngine` — a visible heuristic with an explanation string, not a model. Gaps: no `Core`/`Persistence`/`Insights`/`Security` layers, no dependency injection, nothing offline-capable, mixed `ObservableObject`/`@Observable` view models.

**UX** — Home (`ExploreView`) is static tiles (Pain/Water/Weight), same order every time, no adaptivity. Logging is scattered per-domain with no universal Quick Log. Onboarding is generic marketing slides + a profile form, not gradual/contextual.

**Visual design** — 5 original tabs still run the old neumorphic `Theme.swift` (flat hex, hardcoded point sizes, soft-UI shadows). Everything built in the most recent feature work (Hospitals, Appointments, Notifications, Resources, Profile, Weight, Water Intake, Forgot Password) already uses native `List`/`Form`/`ContentUnavailableView`/Dynamic Type — there's a real style split in the app right now.

**Accessibility** — No Dynamic Type or dark-mode colors on the 5 original tabs; no VoiceOver audit anywhere. `Theme.swift` itself is unusable in Dark Mode today (same literal hex regardless of system appearance).

**Navigation** — 5 tabs (Explore/Tracker/Reports/Reminders/Emergency), no Settings surface at all, no global search.

**Missing SCD-specific functionality** — No Personal Pain Plan, no Crisis Mode, no Medical ID, no Health Record/Lab Results, no Insights beyond the single risk-score card.

## Design system

Semantic, dark-mode-aware tokens — replace `Theme.swift`'s flat hex with Asset Catalog color sets (light/dark pairs), not literals.

| Token | Light | Dark | Use |
|---|---|---|---|
| `background` | `#F5F3F1` | `#131114` | Screen background |
| `surface` | `#FFFFFF` | `#1E1B1E` | Cards |
| `surfaceSecondary` | `#F0EDEA` | `#262227` | Segmented controls, inline chart bg |
| `textPrimary` | `#1C1A1B` | `#F2EFED` | Primary text |
| `textSecondary` | `#6B6870` | `#ACA7AD` | Secondary text |
| `textMuted` | `#9C98A0` | `#7C777E` | Captions, section labels |
| `border` | `#E8E4E0` | `#322D32` | Dividers |
| `brand` | `#8C0F26` | same | Pain data, emergency, selected states, primary actions **only** |
| `brandSoft` | `#F6E4E6` | `#3A1A20` | Tinted backgrounds behind brand-colored content |
| `success` / `warning` / `info` | `#1F9D63` / `#B8860B` / `#2F6FE0` | tuned per-mode | Status, never reused for brand or category identity |

Brand red is reserved for pain-related information, emergency actions, and selected/active states — not sprinkled through every label and button as it is on the current 5 tabs.

**Reusable components** (`DesignSystem/`): `SSCard`, `SSSection`, `SSPrimaryButton`, `SSSecondaryButton`, `SSIconButton`, `SSMetricCard`, `SSChartCard`, `SSInsightCard`, `SSQuickActionTile`, `SSTimelineRow`, `SSEmptyState`, `SSLoadingState`, `SSErrorState`, `SSHealthRing`. Every screen composes from these — no screen designed in isolation.

**Charts** — single-hue sequential ramp for magnitude (pain trend: light→dark red), status colors reserved and distinct from brand/category hues, thin 2px lines with rounded data-ends, always paired with a plain-text summary underneath (meaning never carried by color alone). Validated against the project's `dataviz` skill methodology.

**Icons** — SF Symbols throughout (already the existing convention — `"bandage.fill"`, `"waveform.path.ecg"`, etc.), never emoji.

## Information architecture

Three-layer structure replacing the 5 flat tabs:

- **Today** (replaces Explore) — greeting, adaptive stat row, Quick Log, mini-timeline, one insight, next appointment. Adapts to context: surfaces medication when due, appointment when tomorrow, pain experience when a crisis is active; stays calm when nothing needs attention.
- **Understand** — Pain (full experience, not a Tracker sub-form) + Insights + (future) Health Record/Labs.
- **Prepare** — Medications + Appointments + Personal Pain Plan + Medical ID + Hospitals.
- **Emergency** — stays a top-level tab (safety-critical, never more than one tap away). Its primary state when activated is Crisis Mode.
- **Settings** — new, reached via a profile/gear entry point rather than a 6th tab (keeps the bar at 4, calmer per Apple HIG).

## Key screens (see mockup file for visual reference)

- **Today** — adaptive stat row (Pain/Hydration/Meds, only what's relevant), Quick Log row, "Your Day" timeline, one insight card ("Your pain has been lower than your recent average → View trend"), one upcoming-appointment card. Light and dark parity — re-tinted surfaces, not inverted.
- **Quick Log** — one sheet, category grid (Pain/Medication/Water/Symptom/Weight/Mood), progressive disclosure per category (e.g. pain: severity grid → location → triggers, all optional after severity), "Save now" always available without finishing optional steps.
- **Pain** — range selector (7D/30D/3M/6M/1Y), summary stats (average/highest/lowest/episode count), trend chart with a mandatory text summary, recent episodes list (severity, location, duration).
- **Crisis Mode** — user-initiated only, never auto-triggered. Full-bleed high-contrast state: large pain number, timer since started, "My Pain Plan" and "Medical ID" rows, contact call buttons, "Call Emergency Services."
- **Settings** — grouped `List` sections with drill-down: Health Profile · Emergency & Safety · Medications · Notifications · Appearance · Accessibility · Privacy & Security · Health Data · Apple Health · Support · About · Account. Not 50 toggles on one page.
- **Insights** — "Your Recent Baseline" (typical pain, average hydration, typical sleep, episodes this month — compared to the user's own history, never a generic norm), then a list of Pattern/Data-tagged observations. Every card explicitly labeled Pattern or Data, never presented as a diagnosis.

## Roadmap

**P0 — essential, unblocks everything else**
1. Design system foundation (semantic dark-mode-safe colors replacing `Theme.swift`'s flat hex)
2. Universal Quick Log
3. Home → Today redesign
4. Settings (from zero)
5. Crisis Mode + Personal Pain Plan

**P1 — high value**
6. Pain as its own full experience
7. Insights (extend `RiskScoreEngine`'s transparent-heuristic approach; add baseline comparison + medication adherence %)
8. Onboarding rework (contextual, gradual)
9. Health Record / Lab Results (needs a new backend model — the only P0/P1 item requiring backend schema work)
10. Dark mode done properly (depends on #1)
11. Delete Account flow (needs a new backend endpoint)

**P2 — future, real but not urgent**
12. Global search
13. Notification Centre (beyond the existing list view)
14. Additional widgets (medication, appointment)
15. Broader HealthKit categories (currently read-only: heart rate + oxygen)
16. Home customization/pinning

**P3 — explicitly avoid**: AI chatbot/diagnosis, fake health score, social features, EHR integration.

## Execution order

Sequence roughly matches the P0 list above — design system has to land first since every other screen visually depends on it. Each item should ship and be verified independently (build + manual check against the running local backend), same discipline as the earlier feature-buildout work: verify real backend response shapes via curl before writing Swift models, regenerate the XcodeGen project (`xcodegen generate` in `ios/`) after adding new files, confirm `XcodeListSchemes`/`XcodeListTargets` report the real project before trusting any build result.
