import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/motion.dart';

/// The app's visual payoff: a large numeral inside a progress ring.
///
/// The ring is fixed-geometry artwork but the numeral inside it is user-scaled
/// text, and those two facts fight each other. Three rules keep them apart, all
/// of which exist because the first version overflowed by 87 logical pixels at
/// the largest accessibility text size:
///
///  1. The diameter grows with the text scale (up to [_maxScale]) so the
///     numeral keeps its presence instead of shrinking inside a fixed circle.
///  2. It is then clamped to the width actually available, so a large scale on
///     a small phone cannot push the ring off-screen.
///  3. The numeral is laid out inside the ring's inner square and scaled down
///     to fit, so no combination of scale and value can clip or overflow.
///
/// The caption sits *below* the ring rather than inside it. Inside, a two-line
/// caption at 300% text had nowhere to go and spilled over the content beneath.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    required this.progress,
    required this.label,
    super.key,
    this.baseDiameter = 148,
    this.strokeWidth = 12,
    this.caption,
    this.complete = false,
  });

  /// 0.0 to 1.0.
  final double progress;

  /// Big centred text, usually a percentage.
  final String label;

  /// Supporting text, rendered under the ring.
  final String? caption;

  /// Diameter at the default text size.
  final double baseDiameter;

  final double strokeWidth;

  /// Switches the ring to the success colour.
  final bool complete;

  /// Beyond this the ring stops growing; the numeral scales down inside it.
  static const double _maxScale = 1.6;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final value = progress.clamp(0.0, 1.0);
    final ringColor = complete ? scheme.tertiary : scheme.primary;

    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final scaled = baseDiameter * textScale.clamp(1.0, _maxScale);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : baseDiameter;
        final diameter = math.min(scaled, math.max(96.0, available));
        // The largest square that fits inside the ring's inner circle.
        final inner = (diameter - strokeWidth * 2) / math.sqrt2;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: diameter,
              height: diameter,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: value),
                duration: Motion.slow(context),
                curve: Curves.easeOutCubic,
                builder:
                    (BuildContext context, double animated, Widget? child) {
                  return CustomPaint(
                    painter: _RingPainter(
                      progress: animated,
                      strokeWidth: strokeWidth,
                      trackColor: scheme.surfaceContainerHighest,
                      progressColor: ringColor,
                    ),
                    child: child,
                  );
                },
                child: Center(
                  child: SizedBox(
                    width: inner,
                    height: inner,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        style: theme.textTheme.displayMedium?.copyWith(
                          color:
                              complete ? scheme.tertiary : scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (caption != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm + AppSpacing.xs),
              Text(
                caption!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    if (radius <= 0) return;

    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    if (progress <= 0) return;

    final arc = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.progressColor != progressColor ||
      old.trackColor != trackColor ||
      old.strokeWidth != strokeWidth;
}
