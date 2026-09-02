# UI/UX validation report

Validation gate from spec section 11, run against a clean install.

**Date:** 31 August 2026
**Build:** 1.0.0+1, debug and release
**Device:** iPhone 17 Pro simulator (iOS 26), 402×874pt
**Method:** manual walkthrough on a clean install, plus an automated matrix of
every screen across two viewports, three text scales and both languages

---

## Summary

| Severity | Found | Resolved |
|---|---|---|
| P0 — blocks the task or compliance | 3 | 3 |
| P1 — major confusion or broken interaction | 2 | 2 |
| P2 — polish | 2 | 2 |

All P0 and P1 findings are resolved and covered by regression tests. The full
suite (257 tests) passes after the fixes.

---

## P0 findings

### P0-1 Ticking an item did nothing visible

**Observed:** On the checklist, tapping a checkbox produced no change. The ring
stayed at 0%, the row stayed unticked, the section count stayed at 0/4. Force
quitting and reopening showed "2 of 38 packed" — every write had succeeded.

**Impact:** The app's primary interaction appeared completely broken. A user
would have concluded the app does not work.

**Cause:** The trip-detail stream watched only the `trips` table and loaded items
inside a callback, so drift never re-emitted when `trip_items` changed.

**Fix:** Replaced two queries with a single `leftOuterJoin` so both tables are
dependencies of the watched query.

**Regression cover:** Six stream tests in `trip_repository_test.dart` and a
widget test in `core_flow_test.dart` that taps a real checkbox and asserts the
percentage changes.

---

### P0-2 Progress ring overflowed at large accessibility text

**Observed:** At the largest iOS text size the ring rendered the debug overflow
stripe and "BOTTOM OVERFLOWED BY 87 PIXELS". The numeral was clipped and the
caption spilled over the list beneath it.

**Impact:** Accessibility failure and a visible rendering defect. Spec section 9
requires text scaling without clipping.

**Fix:** The ring diameter now scales with the text scale (capped at 1.6×) and is
clamped to available width; the numeral is fitted inside the ring's inner square
with `FittedBox(scaleDown)`; the caption moved outside the ring.

**Regression cover:** `layout_resilience_test.dart` renders the checklist at 3.0×
on both viewports in both languages, with any overflow failing the test.

---

### P0-3 Home banner ran off the right edge

**Observed:** The free-tier banner overflowed horizontally — by 28pt in English
at default text on a 320pt screen, by 365pt once text scaling was involved, and
worse in Turkish where the strings are roughly a third longer.

**Impact:** Visibly broken layout on the first screen a user sees.

**Cause:** A `Row` whose message and call to action were both rigid.

**Fix:** The banner stacks when the row is tight — driven by measured width as
well as text scale, since the Turkish strings do not fit side by side on a small
phone even at default text — and both halves are flexible in the row layout.

**Regression cover:** Covered by the layout matrix, which failed on this exact
case until fixed.

---

## P1 findings

### P1-1 "Notifications are turned off" shown before ever asking

**Observed:** Opening the reminder sheet on a clean install showed a red banner
reading "Notifications are turned off — Valizim cannot show reminders until you
allow notifications in iOS Settings", with an Open Settings button. The app had
never requested permission.

**Impact:** Sends a new user to iOS Settings to fix a permission nobody asked
for, and implies the feature is broken before it has been tried.

**Cause:** iOS reports "not enabled" both before a first prompt and after a
denial. The Settings screen already distinguished them using the app's own
"have we asked" flag; the reminder sheet did not.

**Fix:** The reminder sheet now uses the same flag. The banner appears only after
a real denial.

---

### P1-2 Duration label contradicted its own value

**Observed:** The wizard asked "How many nights?" while the stepper beside it
read "3 days".

**Impact:** Directly ambiguous on the screen where a user commits to the trip
shape; the value drives every per-day quantity in the generated list.

**Cause:** Copy error. The underlying field has always been `durationDays`.

**Fix:** Label corrected to "How many days?" / "Kaç gün?" in both languages.

---

## P2 findings

### P2-1 Checklist rows were unnecessarily tall

**Observed:** Every essential item rendered "Essential" as a subtitle, doubling
the height of a large share of rows. A beach trip is 38 items; a camping trip
more.

**Fix:** Quantity and the essential marker are now compact inline badges on the
title line, in a `Wrap` so a long label still reflows rather than truncating.
Roughly a third more of the list is visible at once.

### P2-2 Floating action button covered quantity badges

**Observed:** While scrolling, the "Add item" button sat over the right-hand
quantity badges, hiding "×3" on rows beneath it.

**Fix:** Resolved by the same change — moving the badges inline puts them clear
of the button's corner.

---

## Matrix results

Automated: `test/features/layout_resilience_test.dart`, 108 cases.

| Axis | Values |
|---|---|
| Screens | Home (empty and populated), checklist, wizard, paywall, templates, settings, privacy, share |
| Viewport | 320×568 (small iPhone), 430×932 (large iPhone) |
| Text scale | 1.0×, 1.35×, 3.0× (largest iOS accessibility size) |
| Language | English, Turkish |

Any `RenderFlex` overflow fails the test, so the class of defect behind P0-2 and
P0-3 cannot silently return.

Manual, on the simulator:

| Check | Result |
|---|---|
| Clean install, no data | Empty state teaches the first action |
| No permission prompt at launch | Confirmed — nothing is requested until a reminder is switched on |
| Core loop offline | Confirmed — no network at any point; the list is generated locally in milliseconds |
| Force-close and relaunch after create/edit/tick | Data intact |
| Light and dark appearance | Both correct; no hard-coded colours |
| English and Turkish | Both correct, including long strings wrapping in the banner |
| Item labels re-localize | A trip created in English shows Turkish labels after switching device language, with no data rewrite |
| 12/24-hour time | Reminder times follow the device setting |
| Reduced motion | Covered by test; every animated surface reads its duration from `Motion` |
| Notification permission denied | Blocked banner with a route to iOS Settings |
| Reminder scheduling | Enabled, persisted, reflected in the app bar icon |

---

## Unfamiliar-tester criterion

The spec asks that someone unfamiliar with the implementation can identify the
primary action and complete the core task without explanation.

Each screen has one dominant action: Home shows a single "Plan a trip" button
(and, when empty, a full-width "Plan your first trip"); the wizard ends in one
"Create packing list"; the checklist's only floating action is "Add item".
Trip type is chosen from six labelled cards each with a one-line explanation of
what it changes, and a live count ("About 39 items") shows the effect of every
toggle before committing.

Measured on the simulator: from a clean launch to a generated 38-item checklist
took four taps and one text entry, inside the spec's 30-second target.

---

## Not covered here

Honest limits of this pass:

- **Physical device.** All verification was on the simulator. Haptics, real
  notification delivery at the scheduled time, and device restart behaviour need
  a real iPhone.
- **StoreKit sandbox.** The purchase flow was exercised against the local
  StoreKit configuration file, not App Store Connect sandbox. The states to
  cover are enumerated in the release checklist.
- **VoiceOver.** Semantics are set (progress is a live region, the stepper
  announces label and value, decorative chevrons are dropped at large text) but
  no screen-reader pass was run on a device.
- **Android.** Out of scope for v1; see the README.
