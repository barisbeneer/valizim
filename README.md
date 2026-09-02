# Valizim

A fast, offline packing-list generator for iOS. Pick a trip type, a length and a
party size; Valizim builds a grouped checklist from deterministic local rules,
in a few milliseconds, with no network, no account and no API key.

Built to a written product specification (kept private; the requirements it
sets are reflected throughout this README and in `docs/`).

---

## Status

| | |
|---|---|
| Platform | iOS (see [Platform scope](#platform-scope)) |
| Flutter | 3.47.2 stable, Dart 3.13.2 (pinned below) |
| Tests | 257 passing (`flutter test`) |
| Static analysis | `flutter analyze` clean |
| Release build | `flutter build ios --release` succeeds, 22.7 MB |

---

## Prerequisites

| Tool | Version used | Notes |
|---|---|---|
| Flutter SDK | **3.47.2** (stable) | Pin this. `flutter --version` must match. |
| Dart | 3.13.2 | Ships with the Flutter version above. |
| Xcode | 26.6 | Required for any iOS build. |
| CocoaPods | 1.17.0 | **Required.** Every plugin here needs pods to link. |

CocoaPods is the one prerequisite a clean macOS install usually lacks:

```bash
brew install cocoapods
```

If your shell warns about encoding, CocoaPods wants a UTF-8 locale:

```bash
export LANG=en_US.UTF-8
```

---

## Setup

```bash
flutter pub get
```

```bash
dart run build_runner build
```

The second command generates `lib/core/database/database.g.dart` from the Drift
table definitions. It must be re-run after any change to
`lib/core/database/tables.dart`. Localizations are generated automatically by
the build, or on demand with `flutter gen-l10n`.

---

## Run

```bash
flutter run
```

To pick a simulator explicitly:

```bash
flutter devices && flutter run -d "iPhone 17 Pro"
```

There is nothing to configure before the app is usable. No key, no login, no
backend. Turning on airplane mode changes nothing about the core loop.

---

## Test

Everything:

```bash
flutter test
```

Static analysis:

```bash
flutter analyze
```

### Time-zone and DST coverage

Dart reads local time from the process `TZ`, so one test run only ever proves
behaviour in one zone. This script re-runs the date-sensitive suites under seven
zones covering no-DST, EU, US and southern-hemisphere transitions plus
45-minute offsets:

```bash
tool/test_timezones.sh
```

This is not ceremony. It caught a real off-by-one in trip end dates that passed
in the launch market (Turkey has had no DST since 2016) and failed in Berlin.
See `project.decision.log.md`.

### What the suites cover

| Suite | What it proves |
|---|---|
| `test/features/trips/packing_generator_test.dart` | Quantity maths, caps, laundry scaling, determinism, layer overrides |
| `test/features/trips/packing_rules_test.dart` | The shipped rules asset parses, is complete, and has EN+TR labels for every item |
| `test/core/utils/trip_date_test.dart` | Calendar-date invariants across DST transitions |
| `test/core/database/migration_test.dart` | v1 → v2 upgrade against a hand-built v1 database, with data intact |
| `test/features/trips/trip_repository_test.dart` | CRUD, duplication independence, cascade delete, stream re-emission |
| `test/core/notifications/reminder_scheduler_test.dart` | Which reminders exist, when they fire, id stability, reconciliation |
| `test/features/templates/custom_template_test.dart` | Corrupt/oversized template blobs degrade instead of throwing |
| `test/features/core_flow_test.dart` | The core loop end to end through real widgets, plus entitlement gates |
| `test/features/layout_resilience_test.dart` | Every screen × 2 viewports × 3 text scales × 2 languages, with overflow as a failure |

---

## Architecture

Feature-first, with platform concerns behind interfaces so they can be faked in
tests.

```
lib/
  app/            bootstrap, router, providers, cold-launch reconciliation
  core/
    config/       AppConfig - every release-configurable value, in one file
    database/     Drift schema, migrations
    notifications/ gateway interface + reminder planning
    purchases/    StoreKit wrapper + local entitlement cache
    settings/     user defaults
    theme/        design tokens (spacing, radii, durations, colour)
    utils/        calendar dates, tolerant JSON parsing, motion, haptics, layout
  features/
    trips/        data / domain / presentation - the core loop
    templates/    saved templates (Pro)
    share/        text and image sharing
    pro/          paywall
    settings/     settings and privacy screens
  shared/widgets/ reusable UI pieces
  l10n/           app_en.arb, app_tr.arb (238 keys, full parity)
assets/rules/     packing_rules.json - the generator's data
test/             unit + widget tests
tool/             icon generation, time-zone test runner
docs/             release checklist, UI/UX validation report
```

| Concern | Choice |
|---|---|
| State / DI | Riverpod (`flutter_riverpod`), providers close to their feature |
| Navigation | `go_router`, named routes only |
| Persistence | Drift over SQLite, migrations from day one |
| Notifications | `flutter_local_notifications` + `timezone`, local only |
| Purchases | `in_app_purchase`, one non-consumable |
| Sharing | `share_plus` |

### How generation works

`assets/rules/packing_rules.json` holds 84 item definitions across a base layer,
six trip-type layers and four option layers. Generation merges them in a fixed
order - base → trip type → options - where a later layer with the same key
*replaces* the earlier one. That is how a city trip turns "Everyday shoes" into
"Comfortable walking shoes" without producing two rows.

Quantities resolve as:

```
days'  = laundry && laundryCapDays != null ? min(days, laundryCapDays) : days
raw    = base + ceil(perDay * days')
each   = raw.clamp(min, max)
total  = perTraveler ? each * travelers : each
result = total.clamp(1, 99)
```

The clamps are what stop a 60-day trip for 10 people asking for 600 t-shirts.

The whole thing is pure and synchronous: no clock, no randomness, no network.
That is what makes "the list appears instantly, offline" both true and testable.

### Localized item labels

Item labels live in the rules asset with `en` and `tr` variants, and each
generated row stores the `ruleKey` that produced it. The UI resolves the label
at display time from the *same merged layers* the trip was generated from. A
trip created in English shows Turkish names the moment the device language
changes - no data rewrite, no migration.

### Database schema

| Version | Change |
|---|---|
| v1 | The shape described in spec section 4 |
| v2 | Adds `trips.updated_at`, `trip_items.rule_key`, `custom_templates.created_at` |

The v1 → v2 upgrade is exercised against a hand-built v1 database in
`test/core/database/migration_test.dart`. The migration only ever adds columns
and backfills them; it never drops or recreates a table, so no upgrade can
silently discard user data.

---

## Configuration

Everything an operator changes before shipping is in
[`lib/core/config/app_config.dart`](lib/core/config/app_config.dart). No secrets
live there, because the app has none.

**Placeholders to replace before submission:**

| Value | Current | Needed for |
|---|---|---|
| `privacyPolicyUrl` | `https://valizim.app/privacy` | App Store Connect requires a reachable URL |
| `termsUrl` | `https://valizim.app/terms` | Linked from the paywall |
| `supportEmail` | `support@valizim.app` | Settings → Contact support |
| `AppTheme.seed` | `#0D9488` | Brand accent; the whole scheme derives from it |
| App icon | Generated placeholder | See below |

The icon and launch glyph are generated placeholders, not final artwork:

```bash
python3 tool/generate_app_icons.py
```

```bash
python3 tool/generate_launch_assets.py
```

Both are dependency-free (stdlib only). Replace the PNGs directly when studio
artwork arrives, or change `ACCENT` and re-run.

---

## Monetization

Free: built-in templates, 3 saved trips, full offline use, text sharing.
Pro (one-time, non-consumable): unlimited trips, custom templates, duplication,
premium share cards.

The displayed price and title always come from the store. Nothing is hard-coded.

### Local purchase testing

`ios/Runner/Valizim.storekit` is wired into the Runner scheme, so a debug run on
the simulator can complete a purchase with no App Store Connect setup. In Xcode:
Product → Scheme → Edit Scheme → Run → Options → StoreKit Configuration.

### Purchase verification

**v1 verifies entitlement on device.** Apple and Google both recommend
server-side receipt verification, and a jailbroken or instrumented device can
defeat a client-side check. This is a deliberate, documented trade-off: the app
has no backend by design, and the product is a one-time unlock on a local-only
utility where the incentive to defeat it is low and the blast radius is one
device. Revisit if revenue justifies a verification service. The reasoning is
repeated in a comment on `PurchaseService`.

The entitlement cache is deliberately sticky: it is cleared only by an explicit
"delete all app data", never by a failed or offline store query, so a paying
user is never demoted because their plane has no wifi.

---

## Privacy

Trips, items and templates live in a SQLite file inside the app container.
Nothing is uploaded. There is no account, no analytics SDK, no advertising SDK,
no attribution SDK. The only network activity is StoreKit's own.

The single permission the app ever requests is notifications, and only in the
moment a user switches a reminder on - never at launch.

`ios/Runner/PrivacyInfo.xcprivacy` declares no tracking, no collected data, and
required-reason API usage for UserDefaults, file timestamps and disk space.
Keep it, the in-app Privacy screen and the App Store Connect answers in step.

---

## Platform scope

**v1 is iOS only.** The machine this was built on had no Android SDK, so nothing
Android could be compiled or verified, and shipping an unverified `android/`
folder would have been worse than not shipping one. Nothing above the platform
channels is iOS-specific; `flutter create --platforms=android .` regenerates the
folder when Android returns to scope. If it does, note that Google Play requires
new apps and updates to target Android 16 / API 36 from 31 August 2026.

---

## Release

See [`docs/ios_release_checklist.md`](docs/ios_release_checklist.md) for the full
signing, versioning and App Store Connect sequence.

```bash
flutter build ios --release
```

Then archive in Xcode (Product → Archive) with a configured signing team.

Version and build number come from `pubspec.yaml` (`version: 1.0.0+1`) and flow
into `CFBundleShortVersionString` / `CFBundleVersion`.

---

## Deliberate deviations from the specification

Three, all documented rather than silently dropped:

1. **No "units" setting.** Spec section 3 lists units under Settings, but nothing
   in the MVP has a unit - there are no measurements, weights or currencies in
   the product. A settings row that changes nothing is a stub, and the
   Definition of Done forbids stubs.

2. **"Reset built-in templates" became "Reset new-trip defaults".** Spec section
   5 states that user edits never mutate a built-in template, which makes
   built-ins immutable, which leaves a reset action with nothing to reset. The
   row now resets the traveller-count and trip-length defaults, which is a real
   action with a real effect.

3. **Departure time is editable, in the reminder sheet.** The spec defines
   reminders at 24 and 3 hours before "trip start" but collects no time. Rather
   than hard-code one, the reminder sheet exposes a departure time defaulting to
   09:00, shown only once a user opens reminders. Without it the 3-hour reminder
   would fire at 06:00 with no way to change it.

---

## Further reading

| Document | What it is |
|---|---|
| `project.decision.log.md` | Every obstacle that forced a change of approach, with root causes |
| `docs/ui_ux_validation_report.md` | The validation gate: findings by severity and their resolutions |
| `docs/ios_release_checklist.md` | Signing, entitlements, privacy declarations, StoreKit, verification |
| `agent.instructions.md` | Orientation for anyone (or any agent) picking this up |
