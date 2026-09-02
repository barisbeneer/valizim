import 'package:flutter_test/flutter_test.dart';
import 'package:valizim/core/utils/trip_date.dart';

/// Calendar-date invariants.
///
/// These run under whatever zone the test process has. `tool/test_timezones.sh`
/// re-runs this file under several zones with and without DST, which is how the
/// "tested across daylight-saving/time-zone changes" requirement in spec
/// section 5 is actually met.
void main() {
  group('storage round-trip', () {
    test('a local date survives the trip to storage and back', () {
      final local = DateTime(2027, 3, 14, 23, 45);
      final stored = TripDate.toStorage(local);
      expect(stored.isUtc, isTrue);
      final back = TripDate.toLocalDayStart(stored);
      expect(back.year, 2027);
      expect(back.month, 3);
      expect(back.day, 14);
      expect(back.hour, 0);
    });

    test('every day across four years round-trips to the same calendar day', () {
      // Whatever zone this runs in, its DST transitions are inside this range.
      var cursor = DateTime(2026, 1, 1, 12);
      final end = DateTime(2030, 1, 1, 12);
      var checked = 0;
      while (cursor.isBefore(end)) {
        final back = TripDate.toLocalDayStart(TripDate.toStorage(cursor));
        expect(
          <int>[back.year, back.month, back.day],
          <int>[cursor.year, cursor.month, cursor.day],
          reason: 'drifted on $cursor',
        );
        checked++;
        // Adding 24h deliberately: on a DST day this lands at 11:00 or 13:00,
        // which is exactly the case that used to shift the stored day.
        cursor = cursor.add(const Duration(hours: 24));
      }
      expect(checked, greaterThan(1400));
    });
  });

  group('atLocalTime', () {
    test('rebuilds the wall-clock time on the stored calendar day', () {
      final stored = DateTime.utc(2027, 7, 4);
      final at = TripDate.atLocalTime(stored, 9, 30);
      expect(at.year, 2027);
      expect(at.month, 7);
      expect(at.day, 4);
      expect(at.hour, 9);
      expect(at.minute, 30);
      expect(at.isUtc, isFalse);
    });

    test('is stable for every day of a year', () {
      for (var day = 0; day < 365; day++) {
        final local = DateTime(2027).add(Duration(days: day));
        final stored = TripDate.toStorage(local);
        final at = TripDate.atLocalTime(stored, 9, 0);
        expect(at.day, stored.day);
        expect(at.month, stored.month);
      }
    });
  });

  group('daysFromToday', () {
    final now = DateTime(2027, 5, 10, 15, 30);

    test('today is zero regardless of the time of day', () {
      expect(TripDate.daysFromToday(DateTime.utc(2027, 5, 10), now: now), 0);
      expect(
        TripDate.daysFromToday(
          DateTime.utc(2027, 5, 10),
          now: DateTime(2027, 5, 10, 0, 1),
        ),
        0,
      );
      expect(
        TripDate.daysFromToday(
          DateTime.utc(2027, 5, 10),
          now: DateTime(2027, 5, 10, 23, 59),
        ),
        0,
      );
    });

    test('counts whole calendar days forward and back', () {
      expect(TripDate.daysFromToday(DateTime.utc(2027, 5, 11), now: now), 1);
      expect(TripDate.daysFromToday(DateTime.utc(2027, 5, 17), now: now), 7);
      expect(TripDate.daysFromToday(DateTime.utc(2027, 5, 9), now: now), -1);
    });

    test('crosses a month and a year boundary', () {
      expect(
        TripDate.daysFromToday(
          DateTime.utc(2028, 1, 1),
          now: DateTime(2027, 12, 31, 8),
        ),
        1,
      );
    });
  });

  group('trip span', () {
    test('a one-day trip ends on its start date', () {
      final start = DateTime.utc(2027, 6, 1);
      expect(TripDate.endDate(start, 1), start);
    });

    test('a multi-day trip ends duration - 1 days later', () {
      expect(
        TripDate.endDate(DateTime.utc(2027, 6, 1), 5),
        DateTime.utc(2027, 6, 5),
      );
    });

    test('a zero or negative duration is treated as one day', () {
      final start = DateTime.utc(2027, 6, 1);
      expect(TripDate.endDate(start, 0), start);
      expect(TripDate.endDate(start, -3), start);
    });

    test('a trip is not past until its final day has gone', () {
      final start = DateTime.utc(2027, 6, 1);
      expect(TripDate.isPast(start, 3, now: DateTime(2027, 6, 3, 23)), isFalse);
      expect(TripDate.isPast(start, 3, now: DateTime(2027, 6, 4, 1)), isTrue);
    });

    test('spanning a DST transition still ends on the right calendar day', () {
      // Late March and late October cover the EU and US transitions.
      expect(
        TripDate.endDate(DateTime.utc(2027, 3, 26), 5),
        DateTime.utc(2027, 3, 30),
      );
      expect(
        TripDate.endDate(DateTime.utc(2027, 10, 29), 5),
        DateTime.utc(2027, 11, 2),
      );
    });
  });

  group('daylight saving transitions', () {
    // These are the cases that broke the first implementation. They only fail
    // when the process runs in a zone that observes DST, which is why
    // tool/test_timezones.sh exists.

    test('a trip spanning autumn fall-back ends on the right day', () {
      // Europe: clocks go back on the last Sunday of October, making that
      // local day 25 hours long.
      expect(
        TripDate.endDate(DateTime.utc(2027, 10, 29), 5),
        DateTime.utc(2027, 11, 2),
      );
      expect(
        TripDate.endDate(DateTime.utc(2027, 10, 30), 2),
        DateTime.utc(2027, 10, 31),
      );
    });

    test('a trip spanning spring forward ends on the right day', () {
      // The mirror case: a 23-hour local day.
      expect(
        TripDate.endDate(DateTime.utc(2027, 3, 26), 5),
        DateTime.utc(2027, 3, 30),
      );
      expect(
        TripDate.endDate(DateTime.utc(2027, 3, 27), 2),
        DateTime.utc(2027, 3, 28),
      );
    });

    test('the US transition dates are covered too', () {
      // The US shifts on different weekends from the EU.
      expect(
        TripDate.endDate(DateTime.utc(2027, 11, 5), 4),
        DateTime.utc(2027, 11, 8),
      );
      expect(
        TripDate.endDate(DateTime.utc(2027, 3, 12), 4),
        DateTime.utc(2027, 3, 15),
      );
    });

    test('the southern-hemisphere transitions are covered too', () {
      // Australia shifts in the opposite months.
      expect(
        TripDate.endDate(DateTime.utc(2027, 4, 2), 4),
        DateTime.utc(2027, 4, 5),
      );
      expect(
        TripDate.endDate(DateTime.utc(2027, 10, 1), 4),
        DateTime.utc(2027, 10, 4),
      );
    });

    test('day counting across a transition is exact, not truncated', () {
      // 119 elapsed hours is still five calendar days.
      expect(
        TripDate.daysFromToday(
          DateTime.utc(2027, 3, 31),
          now: DateTime(2027, 3, 26, 12),
        ),
        5,
      );
      expect(
        TripDate.daysFromToday(
          DateTime.utc(2027, 11, 3),
          now: DateTime(2027, 10, 29, 12),
        ),
        5,
      );
    });

    test('adding a day never skips or repeats a calendar date', () {
      // Walk every day of four years through endDate and assert the sequence
      // advances by exactly one calendar day each time.
      var cursor = DateTime.utc(2026, 1, 1);
      for (var i = 0; i < 365 * 4; i++) {
        final next = TripDate.endDate(cursor, 2);
        final expected = DateTime.utc(cursor.year, cursor.month, cursor.day + 1);
        expect(next, expected, reason: 'broke after $cursor');
        cursor = expected;
      }
    });

    test('a trip is still current on its final DST-spanning day', () {
      final start = DateTime.utc(2027, 10, 29);
      // Day 5 of 5 - still today, not past.
      expect(
        TripDate.isPast(start, 5, now: DateTime(2027, 11, 2, 10)),
        isFalse,
      );
      expect(
        TripDate.isPast(start, 5, now: DateTime(2027, 11, 3, 10)),
        isTrue,
      );
    });
  });

  test('isSameDay compares calendar days only', () {
    expect(
      TripDate.isSameDay(DateTime(2027, 5, 10, 1), DateTime(2027, 5, 10, 23)),
      isTrue,
    );
    expect(
      TripDate.isSameDay(DateTime(2027, 5, 10), DateTime(2027, 5, 11)),
      isFalse,
    );
  });
}
