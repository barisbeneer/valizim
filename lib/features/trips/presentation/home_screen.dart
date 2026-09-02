import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/layout.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/empty_state.dart';
import '../domain/trip.dart';
import 'widgets/trip_card.dart';

/// The one screen the app opens on.
///
/// Trips split into upcoming and past. The single dominant action is "plan a
/// trip"; everything else is a menu or a row tap.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final trips = ref.watch(tripsProvider);
    final progress = ref.watch(tripProgressProvider).valueOrNull ??
        const <String, ({int packed, int total})>{};
    final isPro = ref.watch(isProProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: <Widget>[
          IconButton(
            onPressed: () => context.pushNamed(AppRoute.templates),
            icon: const Icon(Icons.dashboard_customize_outlined),
            tooltip: l10n.templatesTitle,
          ),
          IconButton(
            onPressed: () => context.pushNamed(AppRoute.settings),
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTitle,
          ),
        ],
      ),
      floatingActionButton: trips.valueOrNull?.isEmpty ?? true
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _createTrip(context, ref),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.homeCreateTrip),
            ),
      body: trips.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stack) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.errorGeneric,
          body: error.toString(),
        ),
        data: (List<Trip> all) {
          if (all.isEmpty) {
            return EmptyState(
              icon: Icons.luggage_rounded,
              title: l10n.homeEmptyTitle,
              body: l10n.homeEmptyBody,
              actionLabel: l10n.homeEmptyAction,
              onAction: () => _createTrip(context, ref),
            );
          }

          final upcoming = all.where((Trip t) => !t.isPast()).toList();
          final past = all.where((Trip t) => t.isPast()).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageGutter,
              AppSpacing.sm,
              AppSpacing.pageGutter,
              AppSpacing.floatingActionClearance,
            ),
            children: <Widget>[
              if (!isPro)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _FreeTierBanner(used: all.length),
                ),
              if (upcoming.isNotEmpty) ...<Widget>[
                _SectionLabel(l10n.homeSectionUpcoming),
                for (final trip in upcoming)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm + AppSpacing.xs),
                    child: TripCard(
                      trip: trip,
                      progress: progress[trip.id],
                      onTap: () => context.pushNamed(
                        AppRoute.trip,
                        pathParameters: <String, String>{tripIdParam: trip.id},
                      ),
                      onAction: (TripCardAction action) =>
                          _handleAction(context, ref, trip, action),
                    ),
                  ),
              ],
              if (past.isNotEmpty) ...<Widget>[
                if (upcoming.isNotEmpty) const SizedBox(height: AppSpacing.md),
                _SectionLabel(l10n.homeSectionPast),
                for (final trip in past)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm + AppSpacing.xs),
                    child: TripCard(
                      trip: trip,
                      progress: progress[trip.id],
                      dimmed: true,
                      onTap: () => context.pushNamed(
                        AppRoute.trip,
                        pathParameters: <String, String>{tripIdParam: trip.id},
                      ),
                      onAction: (TripCardAction action) =>
                          _handleAction(context, ref, trip, action),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Gates trip creation on the free limit. The paywall explains the limit
  /// rather than the button silently doing nothing.
  static void _createTrip(BuildContext context, WidgetRef ref) {
    if (!ref.read(canCreateTripProvider)) {
      Haptics.warning();
      context.pushNamed(AppRoute.paywall);
      return;
    }
    context.pushNamed(AppRoute.newTrip);
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    Trip trip,
    TripCardAction action,
  ) async {
    final l10n = AppL10n.of(context);
    final repository = ref.read(tripRepositoryProvider);
    final scheduler = ref.read(reminderSchedulerProvider);

    switch (action) {
      case TripCardAction.duplicate:
        if (!ref.read(isProProvider)) {
          Haptics.warning();
          context.showMessage(l10n.proLockedDuplicate);
          unawaited(context.pushNamed(AppRoute.paywall));
          return;
        }
        if (!ref.read(canCreateTripProvider)) {
          Haptics.warning();
          unawaited(context.pushNamed(AppRoute.paywall));
          return;
        }
        await repository.duplicateTrip(
          trip.id,
          l10n.homeCopySuffix(trip.name),
        );
        if (!context.mounted) return;
        context.showMessage(l10n.homeTripDuplicated);

      case TripCardAction.archive:
        await repository.setArchived(trip.id, true);
        // An archived trip is over: its reminders would be noise.
        await scheduler.cancelFor(trip.id);
        if (!context.mounted) return;
        context.showMessage(
          l10n.homeTripArchived,
          action: SnackBarAction(
            label: l10n.actionUndo,
            onPressed: () => unawaited(repository.setArchived(trip.id, false)),
          ),
        );

      case TripCardAction.unarchive:
        await repository.setArchived(trip.id, false);
        if (!context.mounted) return;
        context.showMessage(l10n.homeTripRestored);

      case TripCardAction.delete:
        final confirmed = await AppDialogs.confirm(
          context,
          title: l10n.homeDeleteTitle,
          message: l10n.homeDeleteBody(trip.name),
          confirmLabel: l10n.actionDelete,
          destructive: true,
        );
        if (!confirmed) return;
        await scheduler.cancelFor(trip.id);
        await repository.deleteTrip(trip.id);
        if (!context.mounted) return;
        context.showMessage(l10n.homeTripDeleted);
    }
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.sm + AppSpacing.xs,
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

/// Shows how much of the free tier is used, and doubles as the entry point to
/// the paywall. Free users always know where they stand before they hit a wall.
class _FreeTierBanner extends StatelessWidget {
  const _FreeTierBanner({required this.used});

  final int used;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    final atLimit = used >= AppConfig.freeTripLimit;
    final largeText = AppLayout.isStacked(context);

    return Material(
      color: atLimit ? scheme.errorContainer : scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => context.pushNamed(AppRoute.paywall),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm + AppSpacing.xs,
          ),
          // The call to action moves below the message when the row is tight:
          // side by side, a translated message and a translated CTA together
          // overflow the row on a small phone. In both layouts the message is
          // the flexible part - without that it claims its full intrinsic
          // width and pushes the CTA off the edge.
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              // Width matters as much as text scale here: the Turkish message
              // and call to action together do not fit side by side on a 320pt
              // screen even at the default text size.
              final stacked = largeText || constraints.maxWidth < 300;
              return stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _message(context, atLimit, scheme, l10n),
                        const SizedBox(height: AppSpacing.sm),
                        _callToAction(context, atLimit, scheme, l10n),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: _message(context, atLimit, scheme, l10n),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          flex: 2,
                          child:
                              _callToAction(context, atLimit, scheme, l10n),
                        ),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }

  Widget _message(
    BuildContext context,
    bool atLimit,
    ColorScheme scheme,
    AppL10n l10n,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          atLimit ? Icons.lock_outline_rounded : Icons.auto_awesome_rounded,
          size: 20,
          color: atLimit ? scheme.onErrorContainer : scheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
        Flexible(
          child: Text(
            l10n.homeFreeTripsUsed(used, AppConfig.freeTripLimit),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: atLimit
                      ? scheme.onErrorContainer
                      : scheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  Widget _callToAction(
    BuildContext context,
    bool atLimit,
    ColorScheme scheme,
    AppL10n l10n,
  ) {
    return Text(
      l10n.proSeeWhatsIncluded,
      textAlign: TextAlign.end,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: atLimit ? scheme.onErrorContainer : scheme.primary,
          ),
    );
  }
}
