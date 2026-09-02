import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/providers.dart';
import '../../../core/config/app_config.dart';
import '../../../core/purchases/purchase_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/haptics.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/dialogs.dart';

/// The paywall.
///
/// Shows what stays free, what Pro adds, the store's own localized price,
/// Restore Purchases, and links to Terms and Privacy - the full set Apple
/// expects on a purchase screen (spec section 3).
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  PurchaseOutcome _lastShown = PurchaseOutcome.none;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final service = ref.watch(purchaseServiceProvider);
    final state = service.state;

    // Surface the result of a purchase or restore exactly once.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (state.outcome == _lastShown) return;
      _lastShown = state.outcome;
      final message = _message(state.outcome, l10n);
      if (message == null) return;
      if (state.outcome == PurchaseOutcome.purchased ||
          state.outcome == PurchaseOutcome.restored) {
        Haptics.success();
      }
      context.showMessage(message);
      service.acknowledgeOutcome();
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.proTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pageGutter),
        children: <Widget>[
          if (state.isPro)
            _OwnedBanner(title: l10n.proOwnedTitle, body: l10n.proOwnedBody)
          else
            Text(
              l10n.proSubtitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          const SizedBox(height: AppSpacing.xl),
          _FeatureGroup(
            title: l10n.proFreeHeading,
            icon: Icons.check_circle_outline_rounded,
            emphasised: false,
            features: <String>[
              l10n.proFreeTrips(AppConfig.freeTripLimit),
              l10n.proFreeTemplates,
              l10n.proFreeOffline,
              l10n.proFreeShareText,
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _FeatureGroup(
            title: l10n.proUnlockHeading,
            icon: Icons.auto_awesome_rounded,
            emphasised: true,
            features: <String>[
              l10n.proUnlockUnlimited,
              l10n.proUnlockTemplates,
              l10n.proUnlockDuplicate,
              l10n.proUnlockShareCard,
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          if (!state.isPro) ...<Widget>[
            FilledButton(
              onPressed: state.purchaseInFlight || !state.storeAvailable
                  ? null
                  : () => service.buyPro(),
              child: state.purchaseInFlight
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_buyLabel(state, l10n)),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.proLegalNote,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: state.purchaseInFlight ? null : () => service.restore(),
              child: Text(l10n.proRestore),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          // Apple expects Terms and Privacy reachable from the purchase
          // screen; Wrap keeps both reachable at any text size.
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              TextButton(
                onPressed: () => _open(AppConfig.termsUrl),
                child: Text(l10n.settingsTerms),
              ),
              TextButton(
                onPressed: () => _open(AppConfig.privacyPolicyUrl),
                child: Text(l10n.settingsPrivacy),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// The price always comes from the store; the app never hard-codes one.
  String _buyLabel(PurchaseState state, AppL10n l10n) {
    if (state.loadingProducts) return l10n.proPriceLoading;
    final price = state.formattedPrice;
    if (price == null) {
      return state.storeAvailable ? l10n.proPriceUnavailable : l10n.proUnavailable;
    }
    return l10n.proBuyPriced(price);
  }

  String? _message(PurchaseOutcome outcome, AppL10n l10n) => switch (outcome) {
        PurchaseOutcome.none => null,
        PurchaseOutcome.pending => l10n.proPending,
        PurchaseOutcome.purchased => l10n.proOwnedBody,
        PurchaseOutcome.restored => l10n.proRestored,
        PurchaseOutcome.cancelled => l10n.proCancelled,
        PurchaseOutcome.failed => l10n.proFailed,
        PurchaseOutcome.nothingToRestore => l10n.proNothingToRestore,
        PurchaseOutcome.storeUnavailable => l10n.proUnavailable,
      };

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

class _FeatureGroup extends StatelessWidget {
  const _FeatureGroup({
    required this.title,
    required this.icon,
    required this.features,
    required this.emphasised,
  });

  final String title;
  final IconData icon;
  final List<String> features;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: emphasised
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: emphasised ? scheme.onPrimaryContainer : scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final feature in features)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    icon,
                    size: 20,
                    color: emphasised
                        ? scheme.onPrimaryContainer
                        : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
                  Expanded(
                    child: Text(
                      feature,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: emphasised
                            ? scheme.onPrimaryContainer
                            : scheme.onSurface,
                      ),
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

class _OwnedBanner extends StatelessWidget {
  const _OwnedBanner({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.verified_rounded, color: scheme.onTertiaryContainer),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onTertiaryContainer,
                      ),
                ),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onTertiaryContainer,
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
