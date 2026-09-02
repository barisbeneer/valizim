import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/motion.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../templates/domain/custom_template.dart';
import '../domain/item_category.dart';
import '../domain/item_label_resolver.dart';
import '../domain/trip.dart';
import 'trip_display.dart';
import 'widgets/item_editor_sheet.dart';
import 'widgets/reminder_sheet.dart';

/// Overflow menu actions on the checklist.
enum _ListMenuAction { edit, template, uncheckAll, regenerate }

/// The checklist. This is where users spend their time, so it prioritises fast
/// ticking: one tap anywhere on a row toggles it, and the ring reacts at once.
class PackingListScreen extends ConsumerStatefulWidget {
  const PackingListScreen({required this.tripId, super.key});

  final String tripId;

  @override
  ConsumerState<PackingListScreen> createState() => _PackingListScreenState();
}

class _PackingListScreenState extends ConsumerState<PackingListScreen> {
  bool _hideChecked = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final detail = ref.watch(tripDetailProvider(widget.tripId));

    return detail.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (Object error, StackTrace stack) => Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.errorGeneric,
          body: error.toString(),
        ),
      ),
      data: (TripWithItems? data) {
        if (data == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.help_outline_rounded,
              title: l10n.listNotFound,
              body: l10n.homeEmptyBody,
              actionLabel: l10n.actionClose,
              onAction: () => context.goNamed(AppRoute.home),
            ),
          );
        }
        return _buildList(context, data);
      },
    );
  }

  Widget _buildList(BuildContext context, TripWithItems data) {
    final l10n = AppL10n.of(context);
    final rules = ref.watch(packingRulesProvider).valueOrNull;
    final resolver = rules == null
        ? null
        : ItemLabelResolver.forTrip(
            rules: rules,
            trip: data.trip,
            languageCode: Localizations.localeOf(context).languageCode,
          );

    final grouped = data.grouped;
    final anyChecked = data.packed > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(data.trip.name, overflow: TextOverflow.ellipsis),
        actions: <Widget>[
          IconButton(
            onPressed: () => _openReminders(data.trip),
            icon: Icon(
              data.trip.reminders.anyEnabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_none_rounded,
            ),
            tooltip: l10n.remindersTitle,
          ),
          IconButton(
            onPressed: () => context.pushNamed(
              AppRoute.share,
              pathParameters: <String, String>{tripIdParam: widget.tripId},
            ),
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: l10n.shareTitle,
          ),
          PopupMenuButton<_ListMenuAction>(
            onSelected: (_ListMenuAction action) => _onMenu(action, data),
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<_ListMenuAction>>[
              PopupMenuItem<_ListMenuAction>(
                value: _ListMenuAction.edit,
                child: Text(l10n.listMenuEdit),
              ),
              PopupMenuItem<_ListMenuAction>(
                value: _ListMenuAction.template,
                child: Text(l10n.listMenuTemplate),
              ),
              PopupMenuItem<_ListMenuAction>(
                value: _ListMenuAction.uncheckAll,
                enabled: anyChecked,
                child: Text(l10n.listUncheckAll),
              ),
              PopupMenuItem<_ListMenuAction>(
                value: _ListMenuAction.regenerate,
                child: Text(l10n.listMenuRegenerate),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addItem(data),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.listAddItem),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: _ProgressHeader(
              data: data,
              hideChecked: _hideChecked,
              onToggleHideChecked: () =>
                  setState(() => _hideChecked = !_hideChecked),
            ),
          ),
          if (data.total == 0)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.checklist_rounded,
                title: l10n.listEmptyTitle,
                body: l10n.listEmptyBody,
                actionLabel: l10n.listAddItem,
                onAction: () => _addItem(data),
              ),
            )
          else
            for (final entry in grouped.entries)
              ..._section(context, data, entry.key, entry.value, resolver),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.floatingActionClearance),
          ),
        ],
      ),
    );
  }

  List<Widget> _section(
    BuildContext context,
    TripWithItems data,
    ItemCategory category,
    List<TripItem> items,
    ItemLabelResolver? resolver,
  ) {
    final visible =
        _hideChecked ? items.where((TripItem i) => !i.checked).toList() : items;
    if (visible.isEmpty) return const <Widget>[];

    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return <Widget>[
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.lg,
            AppSpacing.pageGutter,
            AppSpacing.sm,
          ),
          // Wrap, not Row: a translated section name plus its count needs
          // more than one line at accessibility text sizes.
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              Icon(
                category.icon,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              Text(
                category.label(l10n),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                '${visible.where((TripItem i) => i.checked).length}'
                '/${visible.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
      SliverList.builder(
        itemCount: visible.length,
        itemBuilder: (BuildContext context, int index) {
          final item = visible[index];
          return _ItemRow(
            key: ValueKey<String>(item.id),
            item: item,
            label: resolver?.labelFor(item) ?? item.label,
            onToggle: () => _toggle(item),
            onEdit: () => _editItem(data, item, resolver),
            onDelete: () => _deleteItem(item),
          );
        },
      ),
    ];
  }

  Future<void> _toggle(TripItem item) async {
    Haptics.selection();
    await ref.read(tripRepositoryProvider).setChecked(item.id, !item.checked);

    // Celebrate only the transition into "everything packed".
    final updated = await ref
        .read(tripRepositoryProvider)
        .getTripWithItems(widget.tripId);
    if (updated != null && updated.isComplete && !item.checked) {
      Haptics.success();
    }
  }

  Future<void> _addItem(TripWithItems data) async {
    final l10n = AppL10n.of(context);
    if (data.total >= AppConfig.maxItemsPerTrip) {
      Haptics.warning();
      context.showMessage(l10n.listItemLimit(AppConfig.maxItemsPerTrip));
      return;
    }
    final result = await showItemEditorSheet(context: context);
    if (result == null) return;
    await ref.read(tripRepositoryProvider).addItem(
          tripId: widget.tripId,
          label: result.label,
          category: result.category,
          quantity: result.quantity,
          isEssential: result.isEssential,
        );
  }

  Future<void> _editItem(
    TripWithItems data,
    TripItem item,
    ItemLabelResolver? resolver,
  ) async {
    final result = await showItemEditorSheet(
      context: context,
      initial: ItemEditorResult(
        label: resolver?.labelFor(item) ?? item.label,
        category: item.category,
        quantity: item.quantity,
        isEssential: item.isEssential,
      ),
    );
    if (result == null) return;
    await ref.read(tripRepositoryProvider).updateItem(
          item.copyWith(
            label: result.label,
            category: result.category,
            quantity: result.quantity,
            isEssential: result.isEssential,
          ),
        );
  }

  Future<void> _deleteItem(TripItem item) async {
    final l10n = AppL10n.of(context);
    final repository = ref.read(tripRepositoryProvider);
    await repository.deleteItem(item.id);
    if (!mounted) return;
    // Undo rather than a confirmation: deleting one row is cheap to reverse and
    // a dialog for every swipe would make the list tedious.
    context.showMessage(
      l10n.listItemRemoved,
      action: SnackBarAction(
        label: l10n.actionUndo,
        onPressed: () => unawaited(repository.restoreItem(item)),
      ),
    );
  }

  Future<void> _openReminders(Trip trip) async {
    await showReminderSheet(context: context, ref: ref, trip: trip);
  }

  Future<void> _onMenu(_ListMenuAction action, TripWithItems data) async {
    final l10n = AppL10n.of(context);
    switch (action) {
      case _ListMenuAction.edit:
        await context.pushNamed(
          AppRoute.editTrip,
          pathParameters: <String, String>{tripIdParam: widget.tripId},
        );

      case _ListMenuAction.template:
        await _saveAsTemplate(data);

      case _ListMenuAction.uncheckAll:
        await ref.read(tripRepositoryProvider).uncheckAll(widget.tripId);
        if (!mounted) return;
        context.showMessage(l10n.listUncheckAllDone);

      case _ListMenuAction.regenerate:
        final confirmed = await AppDialogs.confirm(
          context,
          title: l10n.listRegenerateTitle,
          message: l10n.listRegenerateBody,
          confirmLabel: l10n.listRegenerateAction,
          destructive: true,
        );
        if (!confirmed || !mounted) return;
        final items = ref.read(packingGeneratorProvider).generate(
              tripType: data.trip.tripType,
              durationDays: data.trip.durationDays,
              travelerCount: data.trip.travelerCount,
              options: data.trip.options,
            );
        await ref
            .read(tripRepositoryProvider)
            .updateTrip(data.trip, regeneratedItems: items);
        if (!mounted) return;
        context.showMessage(l10n.listRegenerated);
    }
  }

  Future<void> _saveAsTemplate(TripWithItems data) async {
    final l10n = AppL10n.of(context);
    if (!ref.read(isProProvider)) {
      Haptics.warning();
      context.showMessage(l10n.proLockedTemplates);
      await context.pushNamed(AppRoute.paywall);
      return;
    }

    final controller = TextEditingController(text: data.trip.name);
    final name = await showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.templateSaveTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: AppConfig.maxTemplateNameLength,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.templateNameLabel),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || !mounted) return;

    await ref.read(templateRepositoryProvider).saveTemplate(
          name: name,
          tripType: data.trip.tripType,
          items: data.items.map(TemplateItem.fromTripItem).toList(),
        );
    if (!mounted) return;
    context.showMessage(l10n.templateSaved);
  }
}

/// The payoff header: a large ring plus the counts it summarises.
class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.data,
    required this.hideChecked,
    required this.onToggleHideChecked,
  });

  final TripWithItems data;
  final bool hideChecked;
  final VoidCallback onToggleHideChecked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        AppSpacing.md,
        AppSpacing.pageGutter,
        0,
      ),
      child: Column(
        children: <Widget>[
          Semantics(
            liveRegion: true,
            label: l10n.packedOfTotal(data.packed, data.total),
            excludeSemantics: true,
            child: ProgressRing(
              progress: data.progress,
              label: '${data.progressPercent}%',
              caption: l10n.packedOfTotal(data.packed, data.total),
              complete: data.isComplete,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AnimatedSwitcher(
            duration: Motion.normal(context),
            child: data.isComplete
                ? Text(
                    l10n.listAllPacked,
                    key: const ValueKey<String>('complete'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.tertiary,
                    ),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    data.packed == 0
                        ? l10n.listNothingPacked
                        : l10n.remainingCount(data.remaining),
                    key: const ValueKey<String>('progress'),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
          if (data.packed > 0) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: onToggleHideChecked,
              icon: Icon(
                hideChecked
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 18,
              ),
              label: Text(
                hideChecked ? l10n.listShowChecked : l10n.listHideChecked,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.label,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final TripItem item;
  final String label;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Dismissible(
      key: ValueKey<String>('dismiss-${item.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        color: scheme.errorContainer,
        child: Icon(Icons.delete_outline_rounded, color: scheme.onErrorContainer),
      ),
      child: ListTile(
        onTap: onToggle,
        onLongPress: onEdit,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageGutter,
        ),
        leading: Checkbox(
          value: item.checked,
          onChanged: (_) => onToggle(),
          // The row itself is the label, so the box needs no separate one.
          semanticLabel: label,
        ),
        // Quantity and the essential marker sit inline with the label rather
        // than in `subtitle` and `trailing`. Two reasons: it keeps every row a
        // single line, which matters on a list that routinely runs to 40 items,
        // and it moves the badges out from under the floating action button,
        // which used to cover the trailing quantity while scrolling. `Wrap`
        // lets the badges fall to a second line for a very long label instead
        // of squeezing or truncating it.
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: <Widget>[
            Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                decoration: item.checked ? TextDecoration.lineThrough : null,
                color: item.checked ? scheme.onSurfaceVariant : null,
              ),
            ),
            if (item.quantity > 1)
              _Badge(
                text: '×${item.quantity}',
                background: scheme.surfaceContainerHighest,
                foreground: scheme.onSurfaceVariant,
              ),
            if (item.isEssential)
              _Badge(
                text: l10n.listEssentialBadge,
                background: item.checked
                    ? scheme.surfaceContainerHighest
                    : scheme.errorContainer,
                foreground: item.checked
                    ? scheme.onSurfaceVariant
                    : scheme.onErrorContainer,
              ),
          ],
        ),
      ),
    );
  }
}

/// Compact inline marker used for quantities and the essential flag.
class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.background,
    required this.foreground,
  });

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
