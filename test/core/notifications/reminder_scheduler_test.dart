import 'package:flutter_test/flutter_test.dart';
import 'package:valizim/core/config/app_config.dart';
import 'package:valizim/core/notifications/reminder_scheduler.dart';
import 'package:valizim/features/trips/domain/trip.dart';
import 'package:valizim/features/trips/domain/trip_options.dart';
import 'package:valizim/features/trips/domain/trip_type.dart';

import '../../support/fake_notification_gateway.dart';

Trip buildTrip({
  String id = 'trip-1',
  DateTime? startDate,
  ReminderSettings reminders = const ReminderSettings(),
  bool archived = false,
}) {
  return Trip(
    id: id,
    name: 'Lisbon',
    tripType: TripType.city,
    startDate: startDate,
    durationDays: 3,
    travelerCount: 1,
    settings: TripSettings(reminders: reminders),
    createdAt: DateTime.utc(2027),
    updatedAt: DateTime.utc(2027),
    archived: archived,
  );
}

void main() {
  final DateTime now = DateTime(2027, 5, 1, 10);
  final DateTime departureDay = DateTime.utc(2027, 5, 10);

  group('plan', () {
    test('no start date means no reminders', () {
      final trip = buildTrip(
        reminders: const ReminderSettings(dayBefore: true, hoursBefore: true),
      );
      expect(ReminderScheduler.plan(trip, now: now), isEmpty);
    });

    test('no enabled toggle means no reminders', () {
      final trip = buildTrip(startDate: departureDay);
      expect(ReminderScheduler.plan(trip, now: now), isEmpty);
    });

    test('the day-before reminder fires 24 hours before departure', () {
      final trip = buildTrip(
        startDate: departureDay,
        reminders: const ReminderSettings(dayBefore: true, departureHour: 9),
      );
      final planned = ReminderScheduler.plan(trip, now: now);
      expect(planned, hasLength(1));
      expect(planned.single.slot, ReminderSlot.dayBefore);
      expect(planned.single.fireAt, DateTime(2027, 5, 9, 9));
    });

    test('the late reminder fires the configured hours before departure', () {
      final trip = buildTrip(
        startDate: departureDay,
        reminders: const ReminderSettings(hoursBefore: true, departureHour: 9),
      );
      final planned = ReminderScheduler.plan(trip, now: now);
      expect(planned.single.slot, ReminderSlot.hoursBefore);
      expect(
        planned.single.fireAt,
        DateTime(2027, 5, 10, 9 - AppConfig.lateReminderHours),
      );
    });

    test('both toggles produce two reminders in chronological order', () {
      final trip = buildTrip(
        startDate: departureDay,
        reminders: const ReminderSettings(
          dayBefore: true,
          hoursBefore: true,
          departureHour: 14,
          departureMinute: 30,
        ),
      );
      final planned = ReminderScheduler.plan(trip, now: now);
      expect(planned, hasLength(2));
      expect(planned.first.fireAt, DateTime(2027, 5, 9, 14, 30));
      expect(planned.last.fireAt, DateTime(2027, 5, 10, 11, 30));
      expect(planned.first.fireAt.isBefore(planned.last.fireAt), isTrue);
    });

    test('a reminder whose time has passed is not scheduled', () {
      final trip = buildTrip(
        startDate: departureDay,
        reminders: const ReminderSettings(
          dayBefore: true,
          hoursBefore: true,
          departureHour: 9,
        ),
      );
      // Between the two reminder times: only the later one is still ahead.
      final planned =
          ReminderScheduler.plan(trip, now: DateTime(2027, 5, 9, 12));
      expect(planned, hasLength(1));
      expect(planned.single.slot, ReminderSlot.hoursBefore);
    });

    test('a departure entirely in the past schedules nothing', () {
      final trip = buildTrip(
        startDate: departureDay,
        reminders: const ReminderSettings(dayBefore: true, hoursBefore: true),
      );
      expect(
        ReminderScheduler.plan(trip, now: DateTime(2027, 6, 1)),
        isEmpty,
      );
    });

    test('a reminder exactly at "now" is treated as passed', () {
      final trip = buildTrip(
        startDate: departureDay,
        reminders: const ReminderSettings(dayBefore: true, departureHour: 9),
      );
      expect(
        ReminderScheduler.plan(trip, now: DateTime(2027, 5, 9, 9)),
        isEmpty,
      );
    });
  });

  group('notificationId', () {
    test('is deterministic for the same trip and slot', () {
      final a = ReminderScheduler.notificationId('abc-123', ReminderSlot.dayBefore);
      final b = ReminderScheduler.notificationId('abc-123', ReminderSlot.dayBefore);
      expect(a, b);
    });

    test('differs between slots of the same trip', () {
      expect(
        ReminderScheduler.notificationId('abc-123', ReminderSlot.dayBefore),
        isNot(ReminderScheduler.notificationId('abc-123', ReminderSlot.hoursBefore)),
      );
    });

    test('differs between trips', () {
      expect(
        ReminderScheduler.notificationId('trip-a', ReminderSlot.dayBefore),
        isNot(ReminderScheduler.notificationId('trip-b', ReminderSlot.dayBefore)),
      );
    });

    test('stays inside the 32-bit range iOS accepts', () {
      for (final id in <String>[
        '00000000-0000-0000-0000-000000000000',
        'ffffffff-ffff-ffff-ffff-ffffffffffff',
        'a' * 200,
        '',
      ]) {
        for (final slot in ReminderSlot.values) {
          final value = ReminderScheduler.notificationId(id, slot);
          expect(value, greaterThanOrEqualTo(0));
          expect(value, lessThan(1 << 31));
        }
      }
    });

    test('does not collide across a large set of UUID-shaped ids', () {
      final ids = <int>{};
      for (var i = 0; i < 5000; i++) {
        ids.add(ReminderScheduler.notificationId(
          'ba4e7c6a-0000-4000-8000-${i.toString().padLeft(12, '0')}',
          ReminderSlot.dayBefore,
        ));
      }
      expect(ids, hasLength(5000));
    });
  });

  group('sync', () {
    late FakeNotificationGateway gateway;
    late ReminderScheduler scheduler;

    setUp(() {
      gateway = FakeNotificationGateway();
      scheduler = ReminderScheduler(gateway);
    });

    ReminderCopy copy(PlannedReminder r) => (title: 'Pack', body: 'Soon');

    test('schedules the planned reminders with their payload', () async {
      final trip = buildTrip(
        startDate: departureDay,
        reminders: const ReminderSettings(dayBefore: true),
      );
      final planned = await scheduler.sync(trip, copy, now: now);

      expect(planned, hasLength(1));
      expect(gateway.scheduled, hasLength(1));
      final entry = gateway.scheduled.values.single;
      expect(entry.at, DateTime(2027, 5, 9, 9));
      expect(entry.payload, trip.id);
      expect(entry.title, 'Pack');
    });

    test('always clears both slots first, so it is safe to call repeatedly',
        () async {
      final trip = buildTrip(
        startDate: departureDay,
        reminders: const ReminderSettings(dayBefore: true),
      );
      await scheduler.sync(trip, copy, now: now);
      await scheduler.sync(trip, copy, now: now);

      expect(gateway.scheduled, hasLength(1));
      expect(gateway.cancelled.length, ReminderSlot.values.length * 2);
    });

    test('turning reminders off removes what was scheduled', () async {
      final on = buildTrip(
        startDate: departureDay,
        reminders: const ReminderSettings(dayBefore: true, hoursBefore: true),
      );
      await scheduler.sync(on, copy, now: now);
      expect(gateway.scheduled, hasLength(2));

      final off = buildTrip(startDate: departureDay);
      await scheduler.sync(off, copy, now: now);
      expect(gateway.scheduled, isEmpty);
    });

    test('clearing the start date removes reminders', () async {
      final withDate = buildTrip(
        startDate: departureDay,
        reminders: const ReminderSettings(dayBefore: true),
      );
      await scheduler.sync(withDate, copy, now: now);
      expect(gateway.scheduled, isNotEmpty);

      await scheduler.sync(
        buildTrip(reminders: const ReminderSettings(dayBefore: true)),
        copy,
        now: now,
      );
      expect(gateway.scheduled, isEmpty);
    });

    test('cancelFor clears every slot for a trip', () async {
      final trip = buildTrip(
        startDate: departureDay,
        reminders: const ReminderSettings(dayBefore: true, hoursBefore: true),
      );
      await scheduler.sync(trip, copy, now: now);
      await scheduler.cancelFor(trip.id);
      expect(gateway.scheduled, isEmpty);
    });
  });

  group('reconcile', () {
    late FakeNotificationGateway gateway;
    late ReminderScheduler scheduler;

    setUp(() {
      gateway = FakeNotificationGateway();
      scheduler = ReminderScheduler(gateway);
    });

    ReminderCopy copy(Trip t, PlannedReminder r) =>
        (title: t.name, body: 'body');

    test('rebuilds the whole schedule from the database', () async {
      // Something the OS is holding on to that the app no longer knows about.
      await gateway.schedule(
        id: 999,
        localDateTime: DateTime(2027, 5, 5),
        title: 'stale',
        body: 'stale',
      );

      await scheduler.reconcile(
        <Trip>[
          buildTrip(
            id: 'a',
            startDate: departureDay,
            reminders: const ReminderSettings(dayBefore: true),
          ),
          buildTrip(
            id: 'b',
            startDate: DateTime.utc(2027, 5, 20),
            reminders: const ReminderSettings(hoursBefore: true),
          ),
        ],
        copy,
        now: now,
      );

      expect(gateway.cancelAllCount, 1);
      expect(gateway.scheduled.containsKey(999), isFalse);
      expect(gateway.scheduled, hasLength(2));
    });

    test('archived trips are skipped', () async {
      await scheduler.reconcile(
        <Trip>[
          buildTrip(
            id: 'a',
            startDate: departureDay,
            reminders: const ReminderSettings(dayBefore: true),
            archived: true,
          ),
        ],
        copy,
        now: now,
      );
      expect(gateway.scheduled, isEmpty);
    });

    test('past trips are skipped without error', () async {
      await scheduler.reconcile(
        <Trip>[
          buildTrip(
            id: 'a',
            startDate: DateTime.utc(2026, 1, 1),
            reminders: const ReminderSettings(dayBefore: true),
          ),
        ],
        copy,
        now: now,
      );
      expect(gateway.scheduled, isEmpty);
    });

    test('an empty database clears everything', () async {
      await gateway.schedule(
        id: 5,
        localDateTime: DateTime(2027, 5, 5),
        title: 'x',
        body: 'y',
      );
      await scheduler.reconcile(<Trip>[], copy, now: now);
      expect(gateway.scheduled, isEmpty);
    });
  });
}
