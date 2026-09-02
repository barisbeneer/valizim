import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../trips/domain/trip.dart';

/// The image people screenshot or send to whoever they are travelling with.
///
/// Fixed logical size so the exported PNG is identical on every device, and
/// self-contained (no MediaQuery, no text scaling) so it renders the same
/// whether it is on screen or being rasterised.
class ShareCard extends StatelessWidget {
  const ShareCard({
    required this.data,
    required this.tagline,
    required this.typeLabel,
    required this.metaLabel,
    required this.progressLabel,
    super.key,
  });

  static const double width = 340;
  static const double height = 440;

  final TripWithItems data;
  final String tagline;
  final String typeLabel;
  final String metaLabel;
  final String progressLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final complete = data.isComplete;
    final accent = complete ? scheme.tertiary : scheme.primary;

    return MediaQuery.withNoTextScaling(
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color.alphaBlend(accent.withValues(alpha: 0.16), scheme.surface),
              scheme.surface,
            ],
          ),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              typeLabel.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: accent,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              data.trip.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 30,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              metaLabel,
              style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
            ),
            const Spacer(),
            Text(
              '${data.progressPercent}%',
              style: TextStyle(
                fontSize: 88,
                height: 1,
                fontWeight: FontWeight.w800,
                letterSpacing: -4,
                color: accent,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              progressLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: data.progress,
                minHeight: 10,
                backgroundColor: scheme.surfaceContainerHighest,
                color: accent,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: <Widget>[
                Icon(Icons.luggage_rounded, size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  tagline,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
