import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/dialogs.dart';

/// In-app privacy explanation.
///
/// Describes the app's actual behaviour, not a generic policy: nothing here is
/// aspirational. It must be kept in step with the shipping dependency list and
/// with the App Store Connect privacy declarations - see
/// `docs/ios_release_checklist.md`.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageGutter),
        children: <Widget>[
          Text(l10n.privacyHeadline, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          _Point(
            icon: Icons.phone_iphone_rounded,
            title: l10n.privacyOnDeviceTitle,
            body: l10n.privacyOnDeviceBody,
          ),
          _Point(
            icon: Icons.person_off_outlined,
            title: l10n.privacyNoAccountTitle,
            body: l10n.privacyNoAccountBody,
          ),
          _Point(
            icon: Icons.notifications_none_rounded,
            title: l10n.privacyNotificationsTitle,
            body: l10n.privacyNotificationsBody,
          ),
          _Point(
            icon: Icons.credit_card_off_outlined,
            title: l10n.privacyPurchaseTitle,
            body: l10n.privacyPurchaseBody,
          ),
          _Point(
            icon: Icons.ios_share_rounded,
            title: l10n.privacySharingTitle,
            body: l10n.privacySharingBody,
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => _open(context),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(l10n.privacyOpenPolicy),
          ),
        ],
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final l10n = AppL10n.of(context);
    final uri = Uri.tryParse(AppConfig.privacyPolicyUrl);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      context.showMessage(l10n.privacyLinkFailed);
    }
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
