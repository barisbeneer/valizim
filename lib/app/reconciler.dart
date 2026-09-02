import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications/reminder_scheduler.dart';
import '../features/trips/domain/trip.dart';
import '../l10n/generated/app_localizations.dart';
import 'providers.dart';

/// Rebuilds the notification schedule from the database.
///
/// Runs once per cold launch and again whenever the app returns to the
/// foreground. Both matter: iOS can drop or retain scheduled notifications
/// across restores, upgrades and permission changes, and the user may have
/// revoked permission in Settings while the app was backgrounded. The database
/// is the only source of truth, so the schedule is rebuilt from it rather than
/// trusted (spec section 6).
///
/// Failures here are deliberately swallowed. A reminder that could not be
/// re-registered is a degraded feature; it must never block the app from
/// starting or interrupt the user with an error they cannot act on.
class ReminderReconciler extends ConsumerStatefulWidget {
  const ReminderReconciler({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ReminderReconciler> createState() => _ReminderReconcilerState();
}

class _ReminderReconcilerState extends ConsumerState<ReminderReconciler>
    with WidgetsBindingObserver {
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _reconcile());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reconcile();
  }

  Future<void> _reconcile() async {
    if (!mounted) return;
    final l10n = AppL10n.of(context);
    try {
      final trips = await ref.read(tripRepositoryProvider).watchTrips().first;
      await ref.read(reminderSchedulerProvider).reconcile(
            trips,
            (Trip trip, PlannedReminder reminder) => (
              title: l10n.notificationTitle(trip.name),
              body: l10n.notificationBodyReady,
            ),
          );
    } on Object {
      // Intentionally ignored - see the class comment.
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
