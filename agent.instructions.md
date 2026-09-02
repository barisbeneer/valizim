# agent.instructions.md — Valizim

Orientation for anyone, human or agent, picking this project up.

---

## Project identity

**Valizim** ("my suitcase" in Turkish) is an offline packing-list generator for
iOS, built in Flutter to a written product specification. That spec is kept
private; everything it requires is reflected in this file, the README and
`docs/`.

**Status:** MVP complete. 257 tests passing, `flutter analyze` clean, release
build verified. Placeholder artwork and URLs remain (see README →
Configuration).

**The promise:** pick a trip type, length and party size; get a grouped
checklist in milliseconds, with no network, no account and no API key. Airplane
mode changes nothing about the core loop.

---

## Folder structure

```
valizim/
├── README.md                                   Setup, architecture, release
├── agent.instructions.md                       This file
├── project.decision.log.md                     Every obstacle and its root cause
├── project.self.learning.material.md           Zero-knowledge walkthrough
├── analysis_options.yaml                       Strict lints, strict-casts/inference
├── build.yaml                                  Drift codegen options
├── l10n.yaml                                   Localization generation config
├── pubspec.yaml                                Dependencies; version lives here
│
├── assets/rules/packing_rules.json             84 item definitions, EN+TR labels
│
├── docs/
│   ├── ios_release_checklist.md                Signing, IAP, privacy, upload
│   ├── ui_ux_validation_report.md              Validation gate findings
│   └── untranslated_messages.json              Generated; must stay empty ({})
│
├── tool/
│   ├── generate_app_icons.py                   Placeholder icons, stdlib only
│   ├── generate_launch_assets.py               Launch glyph, stdlib only
│   └── test_timezones.sh                       Date tests under seven zones
│
├── ios/Runner/
│   ├── Info.plist                              Bundle config, orientations
│   ├── PrivacyInfo.xcprivacy                   Privacy manifest
│   ├── Valizim.storekit                        Local IAP testing
│   └── Assets.xcassets/                        Icons, launch background colorset
│
├── lib/
│   ├── main.dart                               Calls bootstrap()
│   ├── app/
│   │   ├── app.dart                            MaterialApp.router, themes, l10n
│   │   ├── bootstrap.dart                      Opens DB/prefs/rules, then runApp
│   │   ├── providers.dart                      Every Riverpod provider
│   │   ├── reconciler.dart                     Rebuilds notifications on launch/resume
│   │   └── router.dart                         go_router named routes
│   ├── core/
│   │   ├── config/app_config.dart              ALL release-configurable values
│   │   ├── database/
│   │   │   ├── database.dart                   AppDatabase, MigrationStrategy
│   │   │   ├── database.g.dart                 GENERATED — do not edit
│   │   │   └── tables.dart                     Drift table definitions
│   │   ├── notifications/
│   │   │   ├── notification_gateway.dart       Platform seam + interface
│   │   │   └── reminder_scheduler.dart         Pure planning + OS sync
│   │   ├── purchases/
│   │   │   ├── entitlement_store.dart          Sticky local Pro cache
│   │   │   └── purchase_service.dart           StoreKit conversation
│   │   ├── settings/app_preferences.dart       New-trip defaults
│   │   ├── theme/
│   │   │   ├── app_spacing.dart                8pt grid, radii, durations
│   │   │   └── app_theme.dart                  Light/dark from one seed colour
│   │   └── utils/
│   │       ├── haptics.dart                    Sparing tactile feedback
│   │       ├── layout.dart                     Text-scale layout decisions
│   │       ├── motion.dart                     Reduced-motion durations
│   │       ├── parse.dart                      Tolerant JSON readers
│   │       └── trip_date.dart                  Calendar-date rules (DST-safe)
│   ├── features/
│   │   ├── trips/                              THE CORE LOOP
│   │   │   ├── data/                           Repository, rules loader
│   │   │   ├── domain/                         Entities, rules, generator
│   │   │   └── presentation/                   Home, wizard, checklist
│   │   ├── templates/                          Saved templates (Pro)
│   │   ├── share/                              Text + image sharing
│   │   ├── pro/presentation/paywall_screen.dart
│   │   └── settings/presentation/              Settings, privacy
│   ├── shared/widgets/                         ProgressRing, EmptyState, etc.
│   └── l10n/                                   app_en.arb, app_tr.arb, generated/
│
└── test/
    ├── support/                                Harness, fakes, fixtures
    ├── core/                                   Dates, migration, notifications
    └── features/
        ├── core_flow_test.dart                 Core loop through real widgets
        └── layout_resilience_test.dart         108-case overflow matrix
```

---

## Domain concepts

**Trip type** — one of six archetypes (beach, city, business, camping, winter,
general). Chooses which rule layer applies. `TripType.id` is persisted; never
change an id.

**Rule layers** — generation merges `base` → `tripTypes[type]` → `options` in a
fixed order. A later layer with the same key *replaces* the earlier one. This is
how city turns "Everyday shoes" into "Comfortable walking shoes" without
duplicating the row.

**Rule key** — the stable identifier of a generated item, stored on the row.
Labels are resolved from it at display time, which is why a trip created in
English shows Turkish names after a language change with no data rewrite.

**Calendar date vs instant** — a trip's start date is a *calendar date*, stored
as UTC midnight. Never do arithmetic on the stored instant; go through
`TripDate`. This is not pedantry: doing it the obvious way produced end dates a
day early in every DST zone.

**Entitlement** — free users may store three trips, archived ones included.
Pro is a one-time non-consumable. The cached answer is sticky and never revoked
by a failed store query.

---

## Tech stack

| | |
|---|---|
| Flutter | 3.47.2 stable (pin it), Dart 3.13.2 |
| State / DI | `flutter_riverpod` 2.6 |
| Navigation | `go_router` 18 |
| Persistence | `drift` 2.34 over SQLite, schema v2 |
| Notifications | `flutter_local_notifications` 22 + `timezone` |
| Purchases | `in_app_purchase` 3.3 |
| Codegen | `build_runner` + `drift_dev` |
| Tests | `flutter_test`, in-memory drift, hand-written fakes |

```bash
dart run build_runner build
```

Run that after any change to `lib/core/database/tables.dart`.

---

## Conventions

**Never hard-code a user-facing string in a widget.** Everything goes through
`AppL10n`. Item vocabulary lives in the rules asset with `en`/`tr` variants.
`docs/untranslated_messages.json` must stay `{}`.

**Never hard-code a release value.** `AppConfig` is the single source. If you
find yourself typing a URL, a product id or a limit into a widget, stop.

**Never hard-code a colour or a gap.** `AppTheme` and `AppSpacing`. The whole
scheme derives from one seed.

**Every watched query must read every table it depends on.** Drift only
re-emits when a table the query *reads* changes. This caused the worst bug in
the project's history — see the decision log.

**Layouts must survive 3× text in Turkish on a 320pt screen.** Use
`AppLayout.isStacked` / `AdaptiveFieldRow` for label-plus-control rows, and
`Wrap` where a `Row` would be rigid. The layout matrix will catch you if you
forget, which is the point.

**Corrupt persisted JSON degrades, never throws.** `optionsJson` and
`itemsJson` are free-form blobs. Read them through `core/utils/parse.dart`.

**Destructive actions are reversible or confirmed.** Deleting one item offers
undo; deleting a trip confirms; deleting all data confirms twice.

---

## Navigating the codebase

**Changing what gets packed** — `assets/rules/packing_rules.json`. Both EN and
TR labels are required; `packing_rules_test.dart` enforces it.

**Changing the generation maths** — `packing_generator.dart` and `QuantityRule`
in `packing_rules.dart`. Heavily tested; start by reading the tests.

**Adding a screen** — feature folder under `lib/features/<name>/presentation/`,
a named route in `app/router.dart`, and a case in the layout matrix.

**Adding a database column** — edit `tables.dart`, bump
`AppConfig.databaseSchemaVersion`, add an `onUpgrade` branch, extend
`migration_test.dart`, re-run codegen. A NOT NULL column added by migration
needs a *constant* default — SQLite rejects `CURRENT_TIMESTAMP` in
`ALTER TABLE`.

---

## Things to avoid

- **Do not add a backend, account, analytics SDK, ads SDK or paid API.** The
  no-backend, no-tracking posture is the product, not an oversight.
- **Do not request a permission the app does not need.** Notifications is the
  only one, requested in context.
- **Do not add `Duration(days: n)` to a local `DateTime`.** Use `TripDate`.
- **Do not hard-code a purchase price.** It comes from the store.
- **Do not edit `*.g.dart`.** Regenerate.
- **Do not register `ref.onDispose` on a `ChangeNotifierProvider`.** It already
  disposes its notifier.
- **Do not ship a stub.** Two spec items were deliberately dropped rather than
  faked; see README → Deliberate deviations.

---

## Before calling anything done

```bash
flutter analyze && flutter test && tool/test_timezones.sh
```

Then run it on a simulator and look at it. Three of the five most serious
defects in this project's history were invisible to the test suite at the time
and were found by tapping around — including one where the database was written
correctly and only the screen was wrong.
