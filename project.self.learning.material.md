# Valizim — a linear walkthrough from zero

This explains the whole project assuming nothing beyond basic programming
familiarity. Every term is defined the first time it appears. Read it in order;
each part builds on the last.

---

## Part 1 — The problem, and why it is harder than it looks

People rebuild the same packing checklist before every trip, and still forget
things. The obvious fix is an app that generates the list for you.

The obvious *implementation* is to call a weather API for the destination, maybe
an AI model to suggest items, and store lists in the cloud so they sync. That
implementation is what makes most versions of this app fail before launch:

- **Cost.** A weather API and an AI endpoint cost money per user, forever, on a
  product people open maybe six times a year.
- **Latency.** A network round trip means a spinner. The moment of value — "here
  is your list" — arrives in a second or two instead of instantly.
- **Failure modes.** Airports and planes have bad connectivity. That is exactly
  where someone opens a packing app.
- **Policy surface.** A cloud account means privacy policies, data deletion
  requests, breach exposure, and App Store review questions about data handling.

So the interesting constraint here is not technical difficulty. It is
*discipline*: build something genuinely useful with no backend, no account, and
no paid API, so it costs nothing to run, works on a plane, and has almost no
policy surface.

Everything below follows from that one constraint.

---

## Part 2 — What "deterministic generation" means

**Deterministic** means the same inputs always produce the same output. No
randomness, no clock, no network.

Instead of asking a server what to pack, the app ships a data file describing
what each kind of trip needs, and computes the list locally.

That data file is `assets/rules/packing_rules.json`. It contains 84 item
definitions. A simplified entry:

```json
{
  "key": "tshirt",
  "category": "clothing",
  "labels": { "en": "T-shirts", "tr": "Tişört" },
  "sort": 30,
  "qty": { "base": 0, "perDay": 0.7, "min": 2, "max": 8,
           "perTraveler": true, "laundryCapDays": 4 }
}
```

Reading that: t-shirts are clothing; they are called "T-shirts" in English and
"Tişört" in Turkish; you need roughly 0.7 per day, never fewer than 2 and never
more than 8 per person, multiplied by the number of travellers, and if you have
laundry access the trip counts as at most 4 days for this item.

The file is bundled inside the app binary, so reading it needs no network and
takes about a millisecond.

---

## Part 3 — The layer system

A beach trip and a business trip share most of their list — passport, charger,
toothbrush — and differ in a handful of items. Repeating the shared 28 items in
six places would guarantee they drift apart.

So the rules are organised in **layers**:

1. **base** — applies to every trip (28 items)
2. **tripTypes[type]** — one of beach, city, business, camping, winter, general
3. **options** — swimming, formal event, laptop/work, laundry access

Generation merges them in that exact order. When a later layer defines a key
that an earlier layer already defined, it **replaces** it entirely.

That replacement rule is what makes the system expressive rather than merely
additive. The base layer has:

```
everyday_shoes → "Everyday shoes"
```

and the city layer redefines the *same key*:

```
everyday_shoes → "Comfortable walking shoes", essential: true
```

A city trip therefore shows one row saying "Comfortable walking shoes", marked
essential — not two rows, and not a generic label. The trip type refines the
meaning of an item rather than piling another item on top.

Implementation: `PackingRules.mergedFor()` builds a `Map<String, PackingRuleItem>`
by inserting each layer in turn. Dart maps preserve insertion order, and
re-assigning an existing key keeps its original position, so the output order
stays stable while later layers still win.

---

## Part 4 — The quantity formula, and why the caps matter

Given a merged rule, how many do you need? In order:

```
days'  = laundry && laundryCapDays != null ? min(days, laundryCapDays) : days
raw    = base + ceil(perDay * days')
each   = raw.clamp(min, max)
total  = perTraveler ? each * travelers : each
result = total.clamp(1, 99)
```

Worked example — t-shirts, 10-day trip, 2 travellers, no laundry:

```
days'  = 10
raw    = 0 + ceil(0.7 × 10) = 7
each   = clamp(7, 2, 8) = 7
total  = 7 × 2 = 14
```

Same trip with laundry access:

```
days'  = min(10, 4) = 4
raw    = 0 + ceil(0.7 × 4) = 3
each   = clamp(3, 2, 8) = 3
total  = 3 × 2 = 6
```

Fourteen t-shirts becomes six. That is a real product decision expressed as
data, not code.

**Why the clamps exist:** the app allows up to 60 days and 10 travellers.
Without `max`, a 60-day trip for 10 people would ask for 420 t-shirts — output
that is not merely unhelpful but actively makes the app look broken. `min`
handles the opposite end: a 1-day trip should still suggest 2 t-shirts, not the
0.7 the arithmetic implies.

The order matters too. The cap is applied **per person**, then multiplied. Cap
first and multiply after, and 3 people on a long trip get 8 shirts total to
share. Multiply first and cap after, and they get 8 between them. Per-person
capping is the only interpretation that means anything.

---

## Part 5 — Storing data on a phone

The app uses **SQLite**, a small database engine that stores everything in a
single file. Every phone has it built in.

Talking to SQLite from Dart means writing SQL strings, and a typo in a SQL
string is only discovered when that line runs. **Drift** solves this: you
describe tables as Dart classes, and it generates type-safe query code.

```dart
class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get durationDays => integer()();
  DateTimeColumn get startDate => dateTime().nullable()();
  // ...
}
```

Run `dart run build_runner build` and Drift writes `database.g.dart` with
methods that will not compile if you get a column name wrong.

Three tables: `trips`, `trip_items` (the checklist rows), `custom_templates`.

### Schema migration

Apps ship updates, and updates sometimes need new columns. But existing users
already have a database file in the old shape. **Migration** is the code that
upgrades an old file without losing data.

Getting this wrong is one of the worst bugs an app can have — silent data loss,
discovered by users, unrecoverable. So the app ships with a migration path
already built and tested:

- **v1** is the schema the specification describes
- **v2** adds `trips.updated_at`, `trip_items.rule_key`, `custom_templates.created_at`

`test/core/database/migration_test.dart` builds a v1 database by hand, opens it
with the current code, and asserts everything survives: names, ticks, foreign
keys. The migration only ever *adds* columns; it never drops or recreates a
table, so no upgrade can silently discard anything.

**A concrete trap found here:** SQLite allows `ALTER TABLE ... ADD COLUMN` only
with a *constant* default. The natural choice for a timestamp column,
`CURRENT_TIMESTAMP`, is evaluated per row and is therefore rejected. Worse, this
restriction does not apply to `CREATE TABLE` — so a fresh install would have
worked perfectly and only the *upgrade* path would have failed, meaning the bug
would have shipped and broken the first update. The fix was a constant sentinel
default plus an immediate backfill.

---

## Part 6 — Dates are not instants

This part is worth reading carefully, because it produced a real bug that a
whole test suite missed.

A trip's start date is **a calendar date** — "14 September" — not a moment in
time. Those are different things, and conflating them breaks in two ways.

**Daylight saving time (DST)** is the practice of shifting clocks by an hour
twice a year. On those two days, a local day is not 24 hours long: it is 23 or
25.

Now consider computing the last day of a 5-day trip starting 29 October in
Berlin. The obvious code:

```dart
localMidnight.add(Duration(days: 4))
```

`Duration(days: 4)` is exactly 96 hours. But 29 October to 2 November contains
the autumn transition, so those four calendar days are 97 hours. Adding 96 hours
lands at **23:00 on 1 November** — the wrong calendar date. The trip is reported
as ending a day early, which means it is filed under "Past" a day early.

The mirror bug sat right next to it. Counting days between two local midnights:

```dart
to.difference(from).inDays
```

Across a spring-forward, five calendar days is 119 elapsed hours.
`Duration.inDays` truncates, giving **4**. The home screen's countdown would be
off by one for a large part of the year.

**The fix** is to do calendar arithmetic in a domain where no day is ever 23 or
25 hours: UTC.

```dart
static DateTime endDate(DateTime start, int durationDays) {
  final days = durationDays < 1 ? 1 : durationDays;
  return DateTime.utc(start.year, start.month, start.day + (days - 1));
}
```

`DateTime.utc` normalises overflow — day 32 of October becomes 1 November — and
UTC has no DST.

The rule the whole app follows: **store the calendar date as UTC midnight; never
do arithmetic on the stored instant; extract year/month/day and rebuild.** All of
it lives in one class, `TripDate`, so the rule is enforced in one place.

**How it was caught.** Not by the test suite, which passed. Dart reads local time
from the process `TZ` variable, so a normal test run only proves behaviour in the
developer's zone — and Turkey, the launch market, has had no DST since 2016.
`tool/test_timezones.sh` re-runs the date tests under seven zones. Six passed;
Berlin failed. The spec insisted on DST testing "even if the launch market
commonly uses a fixed offset", and that insistence was correct.

---

## Part 7 — Two languages, one data file

The app ships English and Turkish from day one.

**UI chrome** — buttons, headings, messages — lives in ARB files
(`lib/l10n/app_en.arb`, `app_tr.arb`), a JSON format Flutter compiles into a
type-safe `AppL10n` class. 238 keys, full parity, enforced by a generated
`untranslated_messages.json` that must stay empty.

**Item names** are different, because they are data, not chrome. They live in
the rules file with `en` and `tr` variants.

Now the interesting problem. A user creates a trip in English. Their list is
generated and stored. Later they switch their phone to Turkish. What happens?

Storing only the resolved label — "T-shirts" — leaves the old trip in English
forever. Rewriting every stored row on language change means a migration that
can fail halfway.

The solution: each generated row stores the **rule key** that produced it
(`tshirt`), alongside the resolved label as a fallback. At display time the UI
looks the key up in the current language.

There is a subtlety. Because layers can override labels, the same key means
different things in different trips — `everyday_shoes` is "Everyday shoes"
normally but "Comfortable walking shoes" on a city trip. So the lookup rebuilds
the *same merged layers the trip was generated from*
(`ItemLabelResolver.forTrip`), rather than consulting a flat table. A trip's
items and their displayed names can never disagree about which layer won.

Verified on device: a trip created in English renders fully Turkish after a
language switch, with nothing written to the database.

---

## Part 8 — Reactive UI, and the bug that hid in it

The app is built with **Riverpod** for state management and Drift's *watchable*
queries. A watched query returns a stream: whenever the underlying data changes,
the query re-runs and the UI rebuilds. No manual refreshing.

The checklist screen needs a trip and its items. The natural implementation:

```dart
tripQuery.watchSingleOrNull().asyncMap((row) async {
  final items = await itemQuery.get();   // load items here
  return TripWithItems(trip: row, items: items);
});
```

This is wrong, and the way it is wrong is instructive.

Drift re-emits a watched query when a table **that query reads** changes. The
outer query reads only `trips`. The items are fetched inside a callback, which
Drift cannot see. So the stream depends on `trips` alone.

Every checkbox tick writes to `trip_items`. Nothing re-emits.

On the simulator the effect was that tapping a checkbox did nothing at all — the
ring stayed at 0%, the row stayed unticked. Force-quitting and reopening the app
showed "2 of 38 packed". **Every write had succeeded.** Only the screen was
wrong.

The unit tests passed throughout, because they asserted against
`getTripWithItems` — a one-shot read — not the stream.

The fix is a single query that genuinely reads both tables:

```dart
_db.select(_db.trips).join([
  leftOuterJoin(_db.tripItems, _db.tripItems.tripId.equalsExp(_db.trips.id)),
])
```

Now Drift knows both tables are dependencies, and a write to either pushes a new
value. Six regression tests assert re-emission after check, add, delete and
rename, plus a widget test that taps a real checkbox.

**The generalisable lesson:** a reactive query is only as reactive as its
declared dependencies. Loading data inside a callback hides that dependency from
the framework.

---

## Part 9 — Accessibility as a correctness property

iOS lets users scale text up to about 300% of the default. The app must remain
usable, not merely not-crash.

The progress ring was a fixed 148pt circle with the percentage and a caption
inside it. At maximum text size Flutter rendered its debug overflow stripe:
"BOTTOM OVERFLOWED BY 87 PIXELS". The numeral was clipped and the caption spilled
over the list below.

The cause is a category, not a one-off: **fixed-geometry artwork containing
user-scaled text**. The `SizedBox` stayed constant while its text child grew.

The fix has three parts: the diameter scales with the text scale (capped), then
clamps to available width; the numeral is fitted inside the ring's inner square
with `FittedBox(scaleDown)` so it can never exceed it; and the caption moved
outside the ring entirely.

Auditing for the same category found four more instances — the home banner, the
trip card's progress row, the settings steppers, and `ListTile` rows, which
cannot reflow their leading and trailing content at large text.

Turkish made it worse. Turkish strings here run roughly a third longer than
English, so the home banner overflowed on a small phone even at *default* text
size. The final rule keys off measured width as well as text scale.

Rather than fix five bugs and hope, the project added
`test/features/layout_resilience_test.dart`: every screen × 2 viewports × 3 text
scales × 2 languages = 108 cases. Flutter raises an error on overflow, and the
test asserts no error was raised. The whole category is now a compile-and-run
guarantee.

---

## Part 10 — Notifications without a server

Reminders fire 24 hours and 3 hours before departure. Doing that with a server
would mean push notifications, a device-token registry, and a scheduler — plus
the privacy and cost surface the whole project is avoiding.

Instead the app uses **local notifications**: iOS is told "show this text at this
time" and the OS handles the rest. No server, works offline, nothing leaves the
device.

Three problems worth understanding:

**Notification ids must be stable.** Cancelling a notification requires the id
it was scheduled with. `String.hashCode` in Dart is not guaranteed stable across
process restarts, so an id computed today might not match one from last week,
leaving notifications that can never be cancelled. The app uses FNV-1a, a small
deterministic hash, over the trip's UUID.

**The OS schedule drifts from the truth.** iOS can lose or retain notifications
across restores, upgrades and permission changes. Rather than trust it, the app
clears everything and rebuilds the schedule from the database on every cold
launch and every foreground resume. The database is the only source of truth.

**Permission must be asked in context.** Asking at launch, before the user knows
what the app does, gets denied. The app asks only in the moment someone switches
a reminder on. Verified on device: a clean install shows no prompt at launch.

That last point produced its own bug. iOS reports "notifications not enabled"
identically before a first prompt and after a denial. The reminder sheet
therefore greeted brand-new users with "Notifications are turned off — allow them
in iOS Settings", for a permission nobody had requested. The app now tracks
whether it has ever asked, and only shows that banner after a real denial.

---

## Part 11 — Monetization without a backend

Free: built-in templates, 3 saved trips, offline use, text sharing.
Pro (one payment, forever): unlimited trips, custom templates, duplication,
premium share cards.

**Non-consumable** means bought once and restorable forever — as opposed to a
subscription (recurring, more complexity) or a consumable (spent, like coins).
Chosen deliberately for a first release.

Three details that matter:

**The price is never hard-coded.** It is fetched from StoreKit, already localised
and currency-correct. Hard-coding "$4.99" breaks in every other country and
violates store guidelines.

**The entitlement cache is sticky.** The store is the authority, but reaching it
needs network. Without a cache, a paying user opening the app on a plane would
look like a free user. So the answer is cached locally and cleared *only* by an
explicit "delete all data" — never by a failed or offline query. A store lookup
that fails must not revoke something already paid for.

**Client-side verification is a documented trade-off.** Apple and Google both
recommend verifying receipts on a server, because a jailbroken device can defeat
an on-device check. v1 has no server by design. The trade-off is accepted
explicitly: a one-time unlock on a local-only utility, low incentive to defeat,
blast radius of one device. It is written down in the README and in a comment on
`PurchaseService` rather than left as an unexamined gap.

---

## Part 12 — Results, honestly

**What works, verified:**

- 257 automated tests pass; `flutter analyze` is clean
- Date logic passes under seven time zones including three DST regimes
- A v1 → v2 schema migration preserves data, verified against a hand-built v1 database
- The core loop runs offline: 38 items generated in milliseconds with no network
- Data survives force-close and relaunch
- English and Turkish are at full parity, and stored items re-localize live
- Light and dark, and text from 100% to 300%, without clipping on a 320pt screen
- Notification permission is requested only in context; reminders schedule and persist
- A release build succeeds at 22.7 MB

**What is not verified, and should not be claimed:**

- Everything was tested on the simulator. Haptics, real notification delivery at
  the scheduled time, and device-restart behaviour need a physical iPhone.
- Purchases were exercised against a local StoreKit configuration file, not App
  Store Connect sandbox. The states to cover are enumerated in the release
  checklist.
- Semantics are set, but no VoiceOver pass was run on a device.
- Android is out of scope for v1; no Android SDK was available.
- Icon, launch glyph and legal URLs are placeholders.

**Two specification items were deliberately dropped rather than faked.** A
"units" setting, because nothing in the product has units; and "reset built-in
templates", because the spec elsewhere makes built-in templates immutable,
leaving nothing to reset. Both are documented in the README. Shipping a button
that does nothing would have been worse than shipping neither.

---

## Part 13 — Portfolio narrative

The six strongest points to make when explaining this project:

**1. The constraint was the design.** No backend, no account, no paid API is not
a limitation worked around — it is what makes the app instant, free to run,
private by construction, and functional on a plane. The layered rules engine
exists because "call an API" was ruled out, and the result is better: sub-frame
generation with no failure mode.

**2. A reactive bug that all the tests missed.** Ticking a checkbox wrote to the
database correctly and never updated the screen, because the watched query did
not read the table it depended on. The unit tests passed because they asserted
against a one-shot read. It was found by tapping around on a simulator, and the
fix came with six regression tests that assert stream re-emission specifically.
It is a good illustration of what unit tests cannot see.

**3. A DST bug found by infrastructure built to find it.** Adding
`Duration(days: 4)` to a local midnight lands on the wrong calendar date when
those days contain a clock change. It passed in the launch market (Turkey, no
DST since 2016) and failed in Berlin. A seven-zone test runner caught it; the fix
moved all calendar arithmetic into UTC. The spec asked for DST testing "even if
the launch market uses a fixed offset", and that turned out to be load-bearing.

**4. Accessibility treated as correctness, not polish.** A 300%-text overflow in
the progress ring turned out to be one instance of a category — fixed-geometry
artwork holding scaled text — with four more instances elsewhere, made worse by
Turkish strings running a third longer than English. Rather than fix them
individually, a 108-case matrix now renders every screen across two viewports,
three text scales and both languages, with overflow as a test failure.

**5. Localization that survives a language change.** Storing a rule key next to
each generated item, and resolving labels through the same merged layers the trip
was generated from, means a trip created in English displays in Turkish the
moment the phone's language changes — no data rewrite, no migration, and no
mismatch when a trip type has renamed an item.

**6. Honest scoping.** Two specified features were dropped, with reasons, rather
than shipped as buttons that do nothing. A migration path was built and tested
before the first release rather than after the first upgrade broke. The
client-side purchase verification trade-off is written down, with its blast
radius, instead of being quietly ignored. Knowing what not to build, and saying
so, is part of the work.

---

*For implementation details, see CLAUDE.md.*
