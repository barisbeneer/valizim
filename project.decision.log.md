# Decision-Changer Log - Valizim

Obstacles that forced a change of approach mid-build. Chronological.

### CocoaPods missing from the machine - 2026-08-31
**Attempted:** Run and build the iOS app directly after `flutter create`.
**Broke because:** `flutter doctor` reported `CocoaPods not installed`. Every plugin
in this project (drift/sqlite3, flutter_local_notifications, in_app_purchase,
share_plus, path_provider, url_launcher) needs pods to link on iOS, so no
simulator run and no archive was possible.
**Root cause:** Fresh macOS toolchain. Xcode 26.6 was present, the Ruby gem was not.
**Fix:** `brew install cocoapods` (1.17.0). Chosen over `sudo gem install` because it
needs no password and does not touch the system Ruby.
**Impact:** None on architecture. Added to the README as a prerequisite so a clean
checkout on another machine does not hit the same wall.

### Android SDK unavailable - 2026-08-31
**Attempted:** Ship the shared Flutter project with both platforms wired, per the
spec's cross-platform baseline.
**Broke because:** `flutter doctor` reported `Unable to locate Android SDK`. Nothing
Android could be compiled or verified on this machine.
**Root cause:** Android Studio / command-line tools not installed.
**Fix:** Scoped v1 to iOS only (user decision). The project was generated with
`--platforms=ios`; there is no `android/` directory to rot.
**Impact:** Architecture is unaffected - nothing above the platform channels is
iOS-specific, so `flutter create --platforms=android .` regenerates the folder when
Android returns to scope. Documented in README under "Platform scope".

### sqlite3_flutter_libs is end-of-life - 2026-08-31
**Attempted:** Add `sqlite3_flutter_libs` alongside drift, which is the long-standing
recipe for bundling SQLite on mobile.
**Broke because:** Not a failure, but pub resolved it to `0.6.0+eol`, whose changelog
states the package "no longer does anything".
**Root cause:** `package:sqlite3` 3.x ships its own native build; the Flutter-specific
build scripts were removed and the package kept only as a version marker.
**Fix:** Removed the direct dependency. `drift_flutter` still pulls it transitively as
a compatibility marker, and `sqlite3` 3.5.2 provides the native library.
**Impact:** One fewer direct dependency. Would have been silent dead weight otherwise.

### SQLite rejects non-constant defaults in ALTER TABLE - 2026-08-31
**Attempted:** Add the v2 columns `trips.updated_at` and `custom_templates.created_at`
as NOT NULL with `withDefault(currentDateAndTime)`, so drift's `Migrator.addColumn`
would emit a legal `ALTER TABLE`.
**Broke because:** `SqliteException(1): Cannot add a column with non-constant default`
on `ALTER TABLE "trips" ADD COLUMN "updated_at" TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP)`.
**Root cause:** SQLite permits `ALTER TABLE ... ADD COLUMN` only with a *constant*
default. `CURRENT_TIMESTAMP` is evaluated per row and is therefore not constant. The
restriction does not apply to `CREATE TABLE`, so this only shows up on the upgrade path
- a fresh install would have passed and the bug would have shipped to the first update.
**Fix:** Declared both columns with a constant epoch sentinel
(`Constant(DateTime.utc(1970))`, exported as `schemaEpoch` in `tables.dart`) and had
the migration immediately backfill real values: `trips.updated_at` from `created_at`,
`custom_templates.created_at` from the migration timestamp, since v1 recorded nothing
about template age.
**Impact:** Positive. Declaring the default on the column rather than only inside the
migration keeps a freshly created database byte-identical to a migrated one, so the two
paths cannot drift apart. The sentinel is never read - every insert supplies a real
timestamp. Covered by `test/core/database/migration_test.dart`.

### Ticking an item did nothing on screen - 2026-08-31
**Attempted:** Build the checklist screen on `watchTripWithItems`, which watched the
`trips` table and loaded the items inside an `asyncMap` callback.
**Broke because:** On the simulator, tapping a checkbox appeared to do nothing: the
ring stayed at 0%, the row stayed unticked. Force-quitting and reopening the app
revealed "2 of 38 packed" - the writes had all succeeded.
**Root cause:** Drift re-emits a watched query only when a table that query *reads*
changes. The outer stream read only `trips`; the items were fetched in a callback, so
drift never knew the stream depended on `trip_items`. Every checkbox tick wrote to
`trip_items` and nothing re-emitted. The unit tests missed it because they asserted
against `getTripWithItems`, a one-shot read, rather than the stream.
**Fix:** Replaced the two queries with a single `leftOuterJoin`, so drift sees both
tables as dependencies and a write to either pushes a new value. Added six regression
tests in `trip_repository_test.dart` that assert re-emission after check, add, delete
and rename, plus a widget test that taps a real checkbox and asserts the percentage
changes.
**Impact:** Fixed the app's primary interaction. Also one query instead of two per
emission. The lesson generalised: any watched query must read every table it depends
on, which is now stated in a comment on the method.

### Progress ring overflowed at large accessibility text - 2026-08-31
**Attempted:** A fixed 148pt progress ring with the percentage and a caption stacked
inside it.
**Broke because:** At the largest iOS accessibility text size the ring reported
"BOTTOM OVERFLOWED BY 87 PIXELS"; the numeral was clipped and the caption spilled out
over the list below it.
**Root cause:** Fixed-geometry artwork containing user-scaled text. The `SizedBox` was
constant while its `Column` child grew with the text scaler.
**Fix:** The diameter now scales with the text scale (capped at 1.6x) and is then
clamped to the available width; the numeral is laid out inside the ring's inner square
with `FittedBox(scaleDown)` so it can never exceed it; the caption moved outside the
ring entirely.
**Impact:** Uncovered a whole class of the same problem. Auditing for it found four
more overflows: the free-tier banner, the trip card's progress row, the settings
steppers, and `ListTile` rows that cannot reflow their leading and trailing at large
text. Added `AppLayout.isStacked` and `AdaptiveFieldRow` as shared answers, and a
108-case widget test matrix (`layout_resilience_test.dart`) that renders every screen
across two viewports, three text scales and both languages so this cannot regress.

### Trip end dates were a day early in DST zones - 2026-08-31
**Attempted:** `TripDate.endDate` computed the last day of a trip as
`localMidnight.add(Duration(days: n - 1))`.
**Broke because:** `tool/test_timezones.sh` failed under `TZ=Europe/Berlin` while
passing under UTC, Istanbul, New York, Sydney, Kathmandu and Chatham. A five-day trip
starting 29 October 2027 ended on 1 November instead of 2 November.
**Root cause:** `Duration(days: n)` is exactly `n * 24h`, but a local day containing a
DST transition is 23 or 25 hours. Adding 96 hours to a 25-hour day lands at 23:00 on
the previous calendar date. A second instance of the same mistake was next to it:
`daysFromToday` differenced two local midnights, and across a spring-forward five
calendar days is 119 elapsed hours, which `Duration.inDays` truncates to 4.
**Fix:** Both now work in the UTC calendar domain, where no day is ever 23 or 25 hours:
`endDate` constructs `DateTime.utc(y, m, d + n)` and lets Dart normalise the overflow,
and `daysFromToday` reduces both ends to UTC midnight before subtracting. Added
explicit tests for the EU, US and southern-hemisphere transition weekends and a
four-year walk asserting the sequence never skips or repeats a date.
**Impact:** Real user-visible consequences avoided: trips would have been filed under
"Past" a day early, and the countdown on the home card would have been off by one for
anyone in a DST zone - which is most of Europe and North America. The launch market
(Turkey) has had no DST since 2016, so this would never have shown up in local testing.
Confirms the spec's insistence on testing DST even for a fixed-offset market.

### PurchaseService was disposed twice - 2026-08-31
**Attempted:** Register `ref.onDispose(service.dispose)` inside
`ChangeNotifierProvider<PurchaseService>` to be explicit about cleanup.
**Broke because:** 72 widget tests failed in teardown with "A PurchaseService was used
after being disposed."
**Root cause:** `ChangeNotifierProvider` already disposes the notifier it holds. The
explicit registration made it happen twice.
**Fix:** Removed the redundant `onDispose`. Also made `InAppPurchase.instance` resolve
lazily on first use rather than in the constructor, so screens that only read the
cached entitlement can be widget-tested with no store present.
**Impact:** Test-only symptom, but it would have thrown in production on any
provider-container teardown. Found only because the widget-test matrix exercised the
disposal path repeatedly.
