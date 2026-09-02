import '../../features/trips/domain/trip.dart';
import '../config/app_config.dart';
import '../utils/trip_date.dart';
import 'notification_gateway.dart';

/// The two reminder slots a trip can occupy.
enum ReminderSlot {
  dayBefore(0, AppConfig.earlyReminderHours),
  hoursBefore(1, AppConfig.lateReminderHours);

  const ReminderSlot(this.slotBit, this.hoursBeforeDeparture);

  /// Low bit of the notification id. Two slots per trip.
  final int slotBit;

  final int hoursBeforeDeparture;
}

/// Text for one scheduled reminder. Built by the caller because only the widget
/// layer has access to localized strings.
typedef ReminderCopy = ({String title, String body});

/// A reminder that should exist, with the exact local time it fires.
class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.slot,
    required this.fireAt,
  });

  final int id;
  final ReminderSlot slot;

  /// Local wall-clock time.
  final DateTime fireAt;
}

/// Decides which reminders a trip should have, and keeps the OS in sync.
///
/// Pure planning ([plan]) is separated from the side-effecting sync ([sync] /
/// [reconcile]) so the interesting logic - which reminders exist, when they
/// fire, whether they are already in the past - is unit-testable with no
/// platform channel involved.
class ReminderScheduler {
  const ReminderScheduler(this._gateway);

  final NotificationGateway _gateway;

  /// Reminders [trip] should currently have.
  ///
  /// Empty when there is no start date (spec section 6: no date, no reminder),
  /// when both toggles are off, or when the computed time has already passed -
  /// scheduling a notification for the past would either fire instantly or be
  /// dropped, and neither is what the user asked for.
  static List<PlannedReminder> plan(Trip trip, {DateTime? now}) {
    final start = trip.startDate;
    if (start == null) return const <PlannedReminder>[];

    final reminders = trip.reminders;
    if (!reminders.anyEnabled) return const <PlannedReminder>[];

    final departure = TripDate.atLocalTime(
      start,
      reminders.departureHour,
      reminders.departureMinute,
    );
    final reference = now ?? DateTime.now();

    final planned = <PlannedReminder>[];
    void add(ReminderSlot slot, bool enabled) {
      if (!enabled) return;
      final fireAt =
          departure.subtract(Duration(hours: slot.hoursBeforeDeparture));
      if (!fireAt.isAfter(reference)) return;
      planned.add(
        PlannedReminder(
          id: notificationId(trip.id, slot),
          slot: slot,
          fireAt: fireAt,
        ),
      );
    }

    add(ReminderSlot.dayBefore, reminders.dayBefore);
    add(ReminderSlot.hoursBefore, reminders.hoursBefore);
    return planned;
  }

  /// Stable 31-bit notification id derived from the trip's UUID.
  ///
  /// `String.hashCode` is not guaranteed stable across processes, and an
  /// unstable id would leave orphaned notifications the app can no longer
  /// cancel. FNV-1a is deterministic everywhere, so an id computed today still
  /// cancels a notification scheduled last week.
  static int notificationId(String tripId, ReminderSlot slot) {
    var hash = 0x811c9dc5;
    for (final unit in tripId.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    // Two slots per trip: shift left one bit and use the low bit for the slot.
    return ((hash & 0x3FFFFFFF) << 1) | slot.slotBit;
  }

  /// Brings the OS in line with [trip]: cancels both slots, then re-schedules
  /// the ones that should exist. Cancel-then-schedule rather than diffing keeps
  /// this idempotent and safe to call after any edit.
  Future<List<PlannedReminder>> sync(
    Trip trip,
    ReminderCopy Function(PlannedReminder) copy, {
    DateTime? now,
  }) async {
    await cancelFor(trip.id);
    final planned = plan(trip, now: now);
    for (final reminder in planned) {
      final text = copy(reminder);
      await _gateway.schedule(
        id: reminder.id,
        localDateTime: reminder.fireAt,
        title: text.title,
        body: text.body,
        payload: trip.id,
      );
    }
    return planned;
  }

  Future<void> cancelFor(String tripId) async {
    for (final slot in ReminderSlot.values) {
      await _gateway.cancel(notificationId(tripId, slot));
    }
  }

  /// Cold-launch reconciliation.
  ///
  /// The OS keeps its own copy of the schedule and can lose or retain
  /// notifications across restores, upgrades and permission changes. Rather
  /// than trust it, the app clears everything and rebuilds the schedule from
  /// the database, which is the only source of truth (spec section 6).
  Future<void> reconcile(
    List<Trip> trips,
    ReminderCopy Function(Trip, PlannedReminder) copy, {
    DateTime? now,
  }) async {
    await _gateway.cancelAll();
    for (final trip in trips) {
      if (trip.archived) continue;
      for (final reminder in plan(trip, now: now)) {
        final text = copy(trip, reminder);
        await _gateway.schedule(
          id: reminder.id,
          localDateTime: reminder.fireAt,
          title: text.title,
          body: text.body,
          payload: trip.id,
        );
      }
    }
  }
}
