import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/notifications/notification_gateway.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/layout.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/adaptive_field_row.dart';
import '../../../shared/widgets/count_stepper.dart';
import '../../../shared/widgets/dialogs.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  NotificationPermission _permission = NotificationPermission.notRequested;
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final gateway = ref.read(notificationGatewayProvider);
    final asked = ref.read(entitlementStoreProvider).hasAskedForNotifications;
    final status = await gateway.permissionStatus();
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() {
      // Before the first prompt, iOS reports the same thing for "never asked"
      // and "denied". The app's own flag is what tells them apart.
      _permission = !asked ? NotificationPermission.notRequested : status;
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final prefs = ref.watch(appPreferencesProvider);
    final isPro = ref.watch(isProProvider);
    final info = _packageInfo;
    // ListTile lays its leading, title and trailing out in a fixed row and
    // cannot reflow. At accessibility text sizes the title alone needs the
    // whole width, so the decorative chevrons are dropped - the row is still
    // tappable and the icons carried no information of their own.
    final showTrailingChevrons = !AppLayout.isStacked(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          _SectionHeader(l10n.settingsSectionDefaults),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageGutter,
              vertical: AppSpacing.sm,
            ),
            child: AdaptiveFieldRow(
              label: l10n.settingsDefaultTravelers,
              child: CountStepper(
                value: prefs.defaultTravelerCount,
                min: AppConfig.minTravelerCount,
                max: AppConfig.maxTravelerCount,
                semanticLabel: l10n.settingsDefaultTravelers,
                onChanged: (int value) => ref
                    .read(appPreferencesProvider.notifier)
                    .setDefaultTravelerCount(value),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageGutter,
              vertical: AppSpacing.sm,
            ),
            child: AdaptiveFieldRow(
              label: l10n.settingsDefaultDuration,
              child: CountStepper(
                value: prefs.defaultDurationDays,
                min: AppConfig.minDurationDays,
                max: AppConfig.maxDurationDays,
                semanticLabel: l10n.settingsDefaultDuration,
                valueLabel: l10n.daysCount(prefs.defaultDurationDays),
                onChanged: (int value) => ref
                    .read(appPreferencesProvider.notifier)
                    .setDefaultDurationDays(value),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restart_alt_rounded),
            title: Text(l10n.settingsResetTemplates),
            subtitle: Text(l10n.settingsResetTemplatesBody),
            onTap: _resetDefaults,
          ),
          const Divider(),

          _SectionHeader(l10n.settingsSectionNotifications),
          ListTile(
            leading: Icon(
              _permission == NotificationPermission.granted
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
            ),
            title: Text(l10n.settingsNotificationStatus),
            subtitle: Text(_permissionLabel(l10n)),
            trailing: _permission == NotificationPermission.denied &&
                    showTrailingChevrons
                ? const Icon(Icons.open_in_new_rounded)
                : null,
            onTap: _permission == NotificationPermission.denied
                ? () async {
                    await ref
                        .read(notificationGatewayProvider)
                        .openSystemSettings();
                    await _load();
                  }
                : null,
          ),
          if (_permission == NotificationPermission.denied)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageGutter,
                0,
                AppSpacing.pageGutter,
                AppSpacing.sm,
              ),
              child: Text(
                l10n.settingsNotificationBlockedHelp,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          const Divider(),

          _SectionHeader(l10n.proTitle),
          ListTile(
            leading: Icon(
              isPro ? Icons.verified_rounded : Icons.auto_awesome_rounded,
              color: isPro ? Theme.of(context).colorScheme.tertiary : null,
            ),
            title: Text(isPro ? l10n.proOwnedTitle : l10n.proTitle),
            subtitle: Text(isPro ? l10n.proOwnedBody : l10n.proSubtitle),
            trailing: showTrailingChevrons
                ? const Icon(Icons.chevron_right_rounded)
                : null,
            onTap: () => context.pushNamed(AppRoute.paywall),
          ),
          const Divider(),

          _SectionHeader(l10n.settingsSectionData),
          ListTile(
            leading: Icon(
              Icons.delete_forever_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l10n.settingsDeleteAll,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: _deleteAllData,
          ),
          const Divider(),

          _SectionHeader(l10n.settingsSectionAbout),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.settingsPrivacy),
            trailing: showTrailingChevrons
                ? const Icon(Icons.chevron_right_rounded)
                : null,
            onTap: () => context.pushNamed(AppRoute.privacy),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.settingsTerms),
            trailing: showTrailingChevrons
                ? const Icon(Icons.open_in_new_rounded)
                : null,
            onTap: () => _open(AppConfig.termsUrl),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline_rounded),
            title: Text(l10n.settingsContact),
            trailing: showTrailingChevrons
                ? const Icon(Icons.open_in_new_rounded)
                : null,
            onTap: () => _open('mailto:${AppConfig.supportEmail}'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text(AppConfig.appName),
            subtitle: Text(
              info == null
                  ? ''
                  : l10n.settingsVersion(info.version, info.buildNumber),
            ),
          ),
        ],
      ),
    );
  }

  String _permissionLabel(AppL10n l10n) => switch (_permission) {
        NotificationPermission.granted => l10n.settingsNotificationAllowed,
        NotificationPermission.denied => l10n.settingsNotificationBlocked,
        NotificationPermission.notRequested =>
          l10n.settingsNotificationNotAsked,
      };

  Future<void> _resetDefaults() async {
    final l10n = AppL10n.of(context);
    await ref.read(appPreferencesProvider.notifier).reset();
    if (!mounted) return;
    context.showMessage(l10n.settingsResetTemplatesDone);
  }

  /// Two-step confirmation, as required for irreversible data loss
  /// (spec section 4).
  Future<void> _deleteAllData() async {
    final l10n = AppL10n.of(context);
    final repository = ref.read(tripRepositoryProvider);
    final tripCount = await repository.countTrips();
    if (!mounted) return;

    final first = await AppDialogs.confirm(
      context,
      title: l10n.settingsDeleteAllStep1Title,
      message: l10n.settingsDeleteAllStep1Body,
      confirmLabel: l10n.actionContinue,
      destructive: true,
    );
    if (!first || !mounted) return;

    final second = await AppDialogs.confirm(
      context,
      title: l10n.settingsDeleteAllStep2Title,
      message: l10n.settingsDeleteAllStep2Body(
        l10n.itemsCount(tripCount),
      ),
      confirmLabel: l10n.settingsDeleteAllConfirm,
      destructive: true,
    );
    if (!second || !mounted) return;

    // Order matters: cancel the OS schedule before the trips that justify it
    // disappear, or the notifications outlive their data.
    await ref.read(notificationGatewayProvider).cancelAll();
    await repository.deleteEverything();
    await ref.read(appPreferencesProvider.notifier).reset();
    // The purchase itself survives in the user's Apple Account; only the local
    // cache is cleared, and Restore Purchases brings it back.
    await ref.read(purchaseServiceProvider).clearCachedEntitlement();

    if (!mounted) return;
    Haptics.warning();
    context.showMessage(l10n.settingsDeleteAllDone);
  }

  Future<void> _open(String url) async {
    final l10n = AppL10n.of(context);
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      context.showMessage(l10n.privacyLinkFailed);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        AppSpacing.lg,
        AppSpacing.pageGutter,
        AppSpacing.sm,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
