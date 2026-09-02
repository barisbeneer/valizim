#!/usr/bin/env bash
# Run the date-sensitive tests under several time zones.
#
# Dart reads the process TZ environment variable for local time, so a single
# test run only ever proves the behaviour in one zone - usually the developer's,
# which for Turkey has had no DST since 2016 and would never exercise a
# transition at all.
#
# The zones below were chosen to cover: no DST at all, southern-hemisphere DST
# (transitions in the opposite months), a half-hour offset, and both the EU and
# US transition dates.
#
# Usage: tool/test_timezones.sh
set -euo pipefail

ZONES=(
  "UTC"                 # no offset, no DST
  "Europe/Istanbul"     # +03 fixed, no DST since 2016 (the launch market)
  "Europe/Berlin"       # EU DST, last Sunday of March/October
  "America/New_York"    # US DST, different dates from the EU
  "Australia/Sydney"    # southern hemisphere, DST inverted
  "Asia/Kathmandu"      # +05:45, a 45-minute offset
  "Pacific/Chatham"     # +12:45/+13:45, a 45-minute offset *with* DST
)

TARGETS=(
  "test/core/utils/trip_date_test.dart"
  "test/core/notifications/reminder_scheduler_test.dart"
)

FLUTTER="${FLUTTER:-flutter}"
failed=0

for zone in "${ZONES[@]}"; do
  echo ""
  echo "=============================================================="
  echo " TZ=$zone"
  echo "=============================================================="
  if TZ="$zone" "$FLUTTER" test "${TARGETS[@]}"; then
    echo "PASS  $zone"
  else
    echo "FAIL  $zone"
    failed=1
  fi
done

echo ""
if [ "$failed" -eq 0 ]; then
  echo "All time zones passed."
else
  echo "At least one time zone failed."
fi
exit "$failed"
