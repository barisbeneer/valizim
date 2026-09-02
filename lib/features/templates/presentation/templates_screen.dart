import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/haptics.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/pro_badge.dart';
import '../../trips/domain/packing_generator.dart';
import '../../trips/domain/trip_options.dart';
import '../../trips/domain/trip_type.dart';
import '../../trips/presentation/trip_display.dart';
import '../domain/custom_template.dart';

/// Built-in trip templates and the user's saved ones.
///
/// Built-ins are the six trip types: tapping one starts a trip from it. Saved
/// templates are a Pro feature and appear underneath.
class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final custom = ref.watch(customTemplatesProvider);
    final isPro = ref.watch(isProProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.templatesTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageGutter,
          AppSpacing.sm,
          AppSpacing.pageGutter,
          AppSpacing.xxl,
        ),
        children: <Widget>[
          _GroupHeader(
            title: l10n.templatesBuiltIn,
            subtitle: l10n.templatesBuiltInCount(TripType.values.length),
          ),
          for (final type in TripType.values)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _BuiltInTile(type: type),
            ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Flexible(child: _GroupHeader(title: l10n.templatesCustom)),
              if (!isPro) ...<Widget>[
                const SizedBox(width: AppSpacing.sm),
                ProBadge(label: l10n.proBadge),
              ],
            ],
          ),
          custom.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (Object error, StackTrace stack) => Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(l10n.errorGeneric),
            ),
            data: (List<CustomTemplate> templates) {
              if (templates.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: EmptyState(
                    icon: Icons.bookmark_border_rounded,
                    title: l10n.templatesCustomEmptyTitle,
                    body: isPro
                        ? l10n.templatesCustomEmptyBody
                        : l10n.proLockedTemplates,
                    actionLabel: isPro ? null : l10n.proSeeWhatsIncluded,
                    onAction:
                        isPro ? null : () => context.pushNamed(AppRoute.paywall),
                  ),
                );
              }
              return Column(
                children: <Widget>[
                  for (final template in templates)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _CustomTile(template: template),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.sm + AppSpacing.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: theme.textTheme.titleMedium),
          if (subtitle != null)
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

class _BuiltInTile extends ConsumerWidget {
  const _BuiltInTile({required this.type});

  final TripType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final rules = ref.watch(packingRulesProvider);
    final count = rules.whenOrNull(
      data: (_) => ref
          .read(packingGeneratorProvider)
          .generate(
            tripType: type,
            durationDays: 3,
            travelerCount: 1,
            options: const PackingOptions(),
          )
          .length,
    );

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
          child: Icon(type.icon),
        ),
        title: Text(type.label(l10n)),
        subtitle: Text(
          count == null
              ? type.hint(l10n)
              : '${type.hint(l10n)} · ${l10n.itemsCount(count)}',
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          if (!ref.read(canCreateTripProvider)) {
            Haptics.warning();
            unawaited(context.pushNamed(AppRoute.paywall));
            return;
          }
          context.pushNamed(AppRoute.newTrip);
        },
      ),
    );
  }
}

class _CustomTile extends ConsumerWidget {
  const _CustomTile({required this.template});

  final CustomTemplate template;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppL10n.of(context);
    final type = template.tripType;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
          child: Icon(type?.icon ?? Icons.bookmark_rounded),
        ),
        title: Text(template.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          type == null
              ? l10n.itemsCount(template.itemCount)
              : '${type.label(l10n)} · ${l10n.itemsCount(template.itemCount)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          tooltip: l10n.actionDelete,
          onPressed: () => _delete(context, ref),
        ),
        onTap: () => _use(context, ref),
      ),
    );
  }

  /// Creates a trip from the saved rows verbatim, so a template reproduces
  /// exactly the list the user saved rather than re-running generation.
  Future<void> _use(BuildContext context, WidgetRef ref) async {
    if (!ref.read(canCreateTripProvider)) {
      Haptics.warning();
      unawaited(context.pushNamed(AppRoute.paywall));
      return;
    }

    final repository = ref.read(tripRepositoryProvider);
    final prefs = ref.read(appPreferencesProvider);
    final id = await repository.createTrip(
      name: template.name,
      tripType: template.tripType ?? TripType.general,
      durationDays: prefs.defaultDurationDays,
      travelerCount: prefs.defaultTravelerCount,
      settings: const TripSettings(),
      items: template.items
          .map(
            (TemplateItem item) => GeneratedItem(
              ruleKey: item.ruleKey,
              label: item.label,
              category: item.category,
              quantity: item.quantity,
              isEssential: item.isEssential,
              sortOrder: item.sortOrder == 0
                  ? item.category.order * 1000
                  : item.sortOrder,
            ),
          )
          .toList(),
    );
    if (!context.mounted) return;
    context.pushReplacementNamed(
      AppRoute.trip,
      pathParameters: <String, String>{tripIdParam: id},
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = AppL10n.of(context);
    final confirmed = await AppDialogs.confirm(
      context,
      title: l10n.templatesDeleteTitle,
      message: l10n.templatesDeleteBody(template.name),
      confirmLabel: l10n.actionDelete,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(templateRepositoryProvider).deleteTemplate(template.id);
    if (!context.mounted) return;
    context.showMessage(l10n.templatesDeleted);
  }
}
