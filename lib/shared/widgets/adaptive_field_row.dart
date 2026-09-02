import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/layout.dart';

/// A label beside a control, that becomes a label *above* a control when the
/// user's text is large.
///
/// A stepper next to a translated label ("Varsayılan kişi sayısı") has no room
/// left on a small phone at accessibility text sizes, and a Row would simply
/// overflow. Stacking gives the control the full width instead, which is the
/// behaviour iOS itself adopts in Settings at large type.
class AdaptiveFieldRow extends StatelessWidget {
  const AdaptiveFieldRow({
    required this.label,
    required this.child,
    super.key,
    this.subtitle,
  });

  final String label;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stack = AppLayout.isStacked(context);

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: theme.textTheme.titleSmall),
        if (subtitle != null)
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );

    if (stack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          text,
          const SizedBox(height: AppSpacing.sm),
          Align(alignment: AlignmentDirectional.centerStart, child: child),
        ],
      );
    }

    return Row(
      children: <Widget>[
        Expanded(child: text),
        const SizedBox(width: AppSpacing.sm),
        child,
      ],
    );
  }
}
