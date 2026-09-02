import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/notifications/notification_gateway.dart';
import '../../../../core/notifications/reminder_scheduler.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/trip.dart';
import '../../domain/trip_options.dart';

/// Turns departure reminders on or off for one trip.
///
/// This is the only place the app asks for notification permission, and it only
/// asks after the user switches something on - never at launch (spec section 6).
Future<void> showReminderSheet({
  required BuildContext context,
  required WidgetRef ref,
  required Trip trip,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) => _ReminderSheet(trip: trip, ref: ref),
  );
}

class _ReminderSheet extends StatefulWidget {
  const _ReminderSheet({required this.trip, required this.ref});

  final Trip trip;
  final WidgetRef ref;

  @override
  State<_ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<_ReminderSheet> {
  late ReminderSettings _settings = widget.trip.reminders;
  NotificationPermission _permission = NotificationPermission.notRequested;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refreshPermission();
  }

  Future<void> _refreshPermission() async {
    // iOS reports "not enabled" both before the first prompt and after a
    // denial, so the plugin alone cannot tell them apart. Without the app's own
    // "have we ever asked" flag this sheet would greet a brand-new user with
    // "Notifications are turned off" and send them to iOS Settings for a
    // permission nobody had requested yet.
    final asked =
        widget.ref.read(entitlementStoreProvider).hasAskedForNotifications;
    final status =
        await widget.ref.read(notificationGatewayProvider).permissionStatus();
    if (!mounted) return;
    setState(
      () => _permission = asked ? status : NotificationPermission.notRequested,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final hasDate = widget.trip.hasStartDate;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        AppSpacing.sm,
        AppSpacing.pageGutter,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(l10n.remindersTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          if (!hasDate)
            _Notice(
              icon: Icons.event_busy_rounded,
              title: l10n.remindersNeedsDateTitle,
              body: l10n.remindersNeedsDateBody,
            )
          else ...<Widget>[
            if (_permission == NotificationPermission.denied)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _Notice(
                  icon: Icons.notifications_off_rounded,
                  title: l10n.remindersBlockedTitle,
                  body: l10n.remindersBlockedBody,
                  action: l10n.actionOpenSettings,
                  onAction: () => widget.ref
                      .read(notificationGatewayProvider)
                      .openSystemSettings(),
                  emphasis: true,
                ),
              ),
            SwitchListTile.adaptive(
              value: _settings.dayBefore,
              onChanged: _busy
                  ? null
                  : (bool value) => _update(
                        _settings.copyWith(dayBefore: value),
                        requestPermission: value,
                      ),
              title: Text(l10n.remindersDayBefore),
              subtitle: Text(_describe(ReminderSlot.dayBefore, l10n)),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile.adaptive(
              value: _settings.hoursBefore,
              onChanged: _busy
                  ? null
                  : (bool value) => _update(
                        _settings.copyWith(hoursBefore: value),
                        requestPermission: value,
                      ),
              title: Text(l10n.remindersHoursBefore(AppConfig.lateReminderHours)),
              subtitle: Text(_describe(ReminderSlot.hoursBefore, l10n)),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule_rounded),
              title: Text(l10n.remindersDepartureTime),
              trailing: Text(
                _formatTime(context),
                style: theme.textTheme.titleMedium,
              ),
              onTap: _busy ? null : _pickTime,
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(BuildContext context) {
    final time = TimeOfDay(
      hour: _settings.departureHour,
      minute: _settings.departureMinute,
    );
    // Respects the device's 12/24-hour setting.
    return time.format(context);
  }

  /// Describes when a slot will fire, or says it has already passed.
  String _describe(ReminderSlot slot, AppL10n l10n) {
    final trip = widget.trip.copyWith(
      settings: widget.trip.settings.copyWith(
        reminders: _settings.copyWith(
          dayBefore: slot == ReminderSlot.dayBefore,
          hoursBefore: slot == ReminderSlot.hoursBefore,
        ),
      ),
    );
    final planned = ReminderScheduler.plan(trip);
    if (planned.isEmpty) return l10n.remindersInThePast;
    final at = planned.single.fireAt;
    return l10n.remindersScheduledAt(
      TimeOfDay.fromDateTime(at).format(context),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _settings.departureHour,
        minute: _settings.departureMinute,
      ),
    );
    if (picked == null) return;
    await _update(
      _settings.copyWith(
        departureHour: picked.hour,
        departureMinute: picked.minute,
      ),
      requestPermission: false,
    );
  }

  Future<void> _update(
    ReminderSettings next, {
    required bool requestPermission,
  }) async {
    final l10n = AppL10n.of(context);
    setState(() => _busy = true);

    try {
      if (requestPermission && _permission != NotificationPermission.granted) {
        final gateway = widget.ref.read(notificationGatewayProvider);
        final granted = await gateway.requestPermission();
        await widget.ref
            .read(entitlementStoreProvider)
            .markNotificationsAsked();
        if (!mounted) return;
        setState(
          () => _permission = granted
              ? NotificationPermission.granted
              : NotificationPermission.denied,
        );
        if (!granted) {
          // Keep the switch off rather than showing a reminder that can never
          // be delivered.
          setState(() => _busy = false);
          return;
        }
      }

      setState(() => _settings = next);

      final updated = widget.trip.copyWith(
        settings: widget.trip.settings.copyWith(reminders: next),
      );
      await widget.ref.read(tripRepositoryProvider).updateTrip(updated);
      await widget.ref.read(reminderSchedulerProvider).sync(
            updated,
            (PlannedReminder reminder) => (
              title: l10n.notificationTitle(updated.name),
              body: l10n.notificationBodyReady,
            ),
          );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
    this.emphasis = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final background =
        emphasis ? scheme.errorContainer : scheme.surfaceContainerHighest;
    final foreground =
        emphasis ? scheme.onErrorContainer : scheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: foreground, size: 20),
              const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: foreground),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      body,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: foreground),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (action != null && onAction != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(foregroundColor: foreground),
                child: Text(action!),
              ),
            ),
        ],
      ),
    );
  }
}
