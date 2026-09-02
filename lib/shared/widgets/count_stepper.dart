import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/haptics.dart';
import '../../l10n/generated/app_localizations.dart';

/// A minus / number / plus control.
///
/// Chosen over a text field for counts because it needs no keyboard, cannot
/// receive invalid input, and keeps both targets in comfortable thumb reach.
/// The value is announced as a whole so a screen reader says "Travellers, 2"
/// rather than reading three separate controls.
class CountStepper extends StatelessWidget {
  const CountStepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.semanticLabel,
    super.key,
    this.valueLabel,
  });

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  /// What this count is, for assistive technology.
  final String semanticLabel;

  /// Display text, when the raw number is not self-explanatory.
  final String? valueLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final canDecrease = value > min;
    final canIncrease = value < max;

    void step(int delta) {
      final next = (value + delta).clamp(min, max);
      if (next == value) return;
      Haptics.selection();
      onChanged(next);
    }

    return Semantics(
      label: semanticLabel,
      value: valueLabel ?? '$value',
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _StepButton(
              icon: Icons.remove_rounded,
              onPressed: canDecrease ? () => step(-1) : null,
              tooltip: l10n.stepperDecrease,
            ),
            // Flexible + scaleDown rather than a fixed box: at 300% text a
            // value like "3 days" is wider than the whole stepper, and a rigid
            // Text would overflow the row. It shrinks only as far as it must.
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 72),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    valueLabel ?? '$value',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                    maxLines: 1,
                  ),
                ),
              ),
            ),
            _StepButton(
              icon: Icons.add_rounded,
              onPressed: canIncrease ? () => step(1) : null,
              tooltip: l10n.stepperIncrease,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      // Guarantees the 44pt minimum target even inside a compact row.
      constraints: const BoxConstraints(
        minWidth: AppSpacing.minTapTarget,
        minHeight: AppSpacing.minTapTarget,
      ),
      visualDensity: VisualDensity.standard,
    );
  }
}
