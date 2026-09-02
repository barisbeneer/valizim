import 'package:flutter/material.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/adaptive_field_row.dart';
import '../../../../shared/widgets/count_stepper.dart';
import '../../domain/item_category.dart';
import '../trip_display.dart';

/// What the sheet hands back. Null means the user backed out.
class ItemEditorResult {
  const ItemEditorResult({
    required this.label,
    required this.category,
    required this.quantity,
    required this.isEssential,
  });

  final String label;
  final ItemCategory category;
  final int quantity;
  final bool isEssential;
}

/// Adds or edits one checklist item.
///
/// A bottom sheet rather than a screen: it keeps the list visible behind it and
/// costs one tap to dismiss.
Future<ItemEditorResult?> showItemEditorSheet({
  required BuildContext context,
  ItemEditorResult? initial,
}) {
  return showModalBottomSheet<ItemEditorResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (BuildContext context) => _ItemEditorSheet(initial: initial),
  );
}

class _ItemEditorSheet extends StatefulWidget {
  const _ItemEditorSheet({this.initial});

  final ItemEditorResult? initial;

  @override
  State<_ItemEditorSheet> createState() => _ItemEditorSheetState();
}

class _ItemEditorSheetState extends State<_ItemEditorSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial?.label ?? '');

  late ItemCategory _category = widget.initial?.category ?? ItemCategory.misc;
  late int _quantity = widget.initial?.quantity ?? 1;
  late bool _essential = widget.initial?.isEssential ?? false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final isEditing = widget.initial != null;

    return Padding(
      // Lifts the sheet clear of the keyboard.
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.sm,
            AppSpacing.pageGutter,
            AppSpacing.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  isEditing ? l10n.listEditItemTitle : l10n.listAddItemTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _controller,
                  autofocus: !isEditing,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  maxLength: AppConfig.maxItemLabelLength,
                  decoration: InputDecoration(
                    labelText: l10n.listItemLabel,
                    hintText: l10n.listItemHint,
                  ),
                  validator: (String? value) =>
                      (value == null || value.trim().isEmpty)
                          ? l10n.listItemRequired
                          : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.listSection,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    for (final category in ItemCategory.ordered)
                      ChoiceChip(
                        selected: category == _category,
                        onSelected: (_) => setState(() => _category = category),
                        avatar: Icon(category.icon, size: 18),
                        label: Text(category.label(l10n)),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AdaptiveFieldRow(
                  label: l10n.listQuantity,
                  child: CountStepper(
                    value: _quantity,
                    min: 1,
                    max: AppConfig.maxItemQuantity,
                    semanticLabel: l10n.listQuantity,
                    onChanged: (int value) => setState(() => _quantity = value),
                  ),
                ),
                SwitchListTile.adaptive(
                  value: _essential,
                  onChanged: (bool value) => setState(() => _essential = value),
                  title: Text(l10n.listEssentialToggle),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: AppSpacing.sm),
                FilledButton(
                  onPressed: _submit,
                  child: Text(isEditing ? l10n.actionSave : l10n.actionAdd),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      ItemEditorResult(
        label: _controller.text.trim(),
        category: _category,
        quantity: _quantity,
        isEssential: _essential,
      ),
    );
  }
}
