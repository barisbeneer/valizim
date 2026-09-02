import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/layout.dart';
import '../../../../core/utils/trip_date.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/trip.dart';
import '../trip_display.dart';

/// Row actions offered from a trip card's overflow menu.
enum TripCardAction { duplicate, archive, unarchive, delete }

/// One trip on the home list.
class TripCard extends StatelessWidget {
  const TripCard({
    required this.trip,
    required this.onTap,
    required this.onAction,
    super.key,
    this.progress,
    this.dimmed = false,
  });

  final Trip trip;

  /// Packed/total counts, absent while the query is still loading.
  final ({int packed, int total})? progress;

  final VoidCallback onTap;
  final ValueChanged<TripCardAction> onAction;

  /// Past trips are visually recessed without being unreadable.
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final counts = progress;
    final total = counts?.total ?? 0;
    final packed = counts?.packed ?? 0;
    final ratio = total == 0 ? 0.0 : packed / total;
    final complete = total > 0 && packed == total;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xxs),
                    decoration: BoxDecoration(
                      color: dimmed
                          ? scheme.surfaceContainerHighest
                          : scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      trip.tripType.icon,
                      size: 22,
                      color: dimmed
                          ? scheme.onSurfaceVariant
                          : scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          trip.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: dimmed ? scheme.onSurfaceVariant : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          _subtitle(context, l10n),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _Menu(trip: trip, onAction: onAction),
                ],
              ),
              const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
              // At large text the count moves under the bar: "38 esyanin 3
              // tanesi hazir" beside a progress bar leaves the bar no width.
              if (AppLayout.isStacked(context)) ...<Widget>[
                _progressBar(context, ratio, complete, l10n, packed, total),
                const SizedBox(height: AppSpacing.sm),
                _progressText(theme, scheme, complete, l10n, packed, total),
              ] else
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _progressBar(
                        context, ratio, complete, l10n, packed, total,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + AppSpacing.xs),
                    // Flexible because the Turkish count string
                    // ("38 esyanin 0 tanesi hazir") is long enough to crowd the
                    // bar off a 320pt card on its own.
                    Flexible(
                      child: _progressText(
                        theme, scheme, complete, l10n, packed, total,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressBar(
    BuildContext context,
    double ratio,
    bool complete,
    AppL10n l10n,
    int packed,
    int total,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: LinearProgressIndicator(
        value: ratio,
        minHeight: 8,
        backgroundColor: scheme.surfaceContainerHighest,
        color: complete ? scheme.tertiary : scheme.primary,
        // The adjacent text carries the same information.
        semanticsLabel: l10n.packedOfTotal(packed, total),
      ),
    );
  }

  Widget _progressText(
    ThemeData theme,
    ColorScheme scheme,
    bool complete,
    AppL10n l10n,
    int packed,
    int total,
  ) {
    return Text(
      l10n.packedOfTotal(packed, total),
      style: theme.textTheme.labelMedium?.copyWith(
        color: complete ? scheme.tertiary : scheme.onSurfaceVariant,
        fontWeight: complete ? FontWeight.w700 : null,
      ),
    );
  }

  /// Trip type, length, party size, and how far away it is.
  String _subtitle(BuildContext context, AppL10n l10n) {
    final parts = <String>[
      trip.tripType.label(l10n),
      l10n.daysCount(trip.durationDays),
      if (trip.travelerCount > 1) l10n.travelersCount(trip.travelerCount),
    ];

    final days = trip.daysUntilStart();
    if (days != null && !trip.archived) {
      if (days == 0) {
        parts.add(l10n.homeStartsToday);
      } else if (days == 1) {
        parts.add(l10n.homeStartsTomorrow);
      } else if (days > 1) {
        parts.add(l10n.homeStartsInDays(days));
      } else {
        parts.add(l10n.homeStartedDaysAgo(-days));
      }
    } else if (trip.startDate == null) {
      parts.add(l10n.homeSectionUndated);
    }

    return parts.join(' · ');
  }
}

class _Menu extends StatelessWidget {
  const _Menu({required this.trip, required this.onAction});

  final Trip trip;
  final ValueChanged<TripCardAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final isPast = trip.archived ||
        (trip.startDate != null &&
            TripDate.isPast(trip.startDate!, trip.durationDays));

    return PopupMenuButton<TripCardAction>(
      onSelected: onAction,
      tooltip: MaterialLocalizations.of(context).showMenuTooltip,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<TripCardAction>>[
        PopupMenuItem<TripCardAction>(
          value: TripCardAction.duplicate,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.copy_all_outlined),
            title: Text(l10n.homeMenuDuplicate),
          ),
        ),
        if (!trip.archived && !isPast)
          PopupMenuItem<TripCardAction>(
            value: TripCardAction.archive,
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.archive_outlined),
              title: Text(l10n.homeMenuArchive),
            ),
          ),
        if (trip.archived)
          PopupMenuItem<TripCardAction>(
            value: TripCardAction.unarchive,
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.unarchive_outlined),
              title: Text(l10n.homeMenuUnarchive),
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<TripCardAction>(
          value: TripCardAction.delete,
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.delete_outline_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l10n.homeMenuDelete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ),
      ],
    );
  }
}
