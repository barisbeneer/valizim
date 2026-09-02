import '../../../core/config/app_config.dart';
import 'item_category.dart';
import 'packing_rules.dart';
import 'trip_options.dart';
import 'trip_type.dart';

/// One row produced by [PackingGenerator], before it is persisted as a
/// `TripItem`.
class GeneratedItem {
  const GeneratedItem({
    required this.label,
    required this.category,
    required this.quantity,
    required this.isEssential,
    required this.sortOrder,
    this.ruleKey,
  });

  /// Rule that produced this row. Kept on the persisted item so the label can
  /// be re-resolved if the user switches device language later.
  ///
  /// Null for rows that did not come from a rule - a template built from items
  /// the user typed themselves, for instance.
  final String? ruleKey;

  /// Label resolved at generation time, used as a fallback and for sharing.
  final String label;

  final ItemCategory category;
  final int quantity;
  final bool isEssential;
  final int sortOrder;
}

/// Turns a trip definition into a checklist.
///
/// Deterministic by construction: no clock, no randomness, no network. The same
/// inputs always produce the same list in the same order, which is what makes
/// the "instant, offline" promise in spec section 11 achievable and testable.
///
/// Merge order is fixed: base rules, then trip-type rules, then option rules in
/// [PackingOptions.enabledIds] order. A later rule with the same key replaces
/// the earlier one entirely, so a trip type can raise or lower a base quantity.
class PackingGenerator {
  const PackingGenerator(this.rules);

  final PackingRules rules;

  List<GeneratedItem> generate({
    required TripType tripType,
    required int durationDays,
    required int travelerCount,
    required PackingOptions options,
  }) {
    final days = durationDays.clamp(
      AppConfig.minDurationDays,
      AppConfig.maxDurationDays,
    );
    final travelers = travelerCount.clamp(
      AppConfig.minTravelerCount,
      AppConfig.maxTravelerCount,
    );

    final merged = rules.mergedFor(tripType, options.enabledIds);

    final resolved = <GeneratedItem>[];
    for (final rule in merged.values) {
      resolved.add(
        GeneratedItem(
          ruleKey: rule.key,
          label: rule.label('en'),
          category: rule.category,
          quantity: rule.quantity.resolve(
            days: days,
            travelers: travelers,
            laundry: options.laundry,
          ),
          isEssential: rule.essential,
          sortOrder: _sortOrder(rule),
        ),
      );
    }

    resolved.sort((a, b) {
      final bySort = a.sortOrder.compareTo(b.sortOrder);
      // Tie-break on the rule key so two items sharing a sort value never swap
      // places between runs.
      return bySort != 0 ? bySort : (a.ruleKey ?? '').compareTo(b.ruleKey ?? '');
    });

    if (resolved.length > AppConfig.maxItemsPerTrip) {
      return resolved.sublist(0, AppConfig.maxItemsPerTrip);
    }
    return resolved;
  }

  /// Category first, then position within the category. The 1000 stride leaves
  /// room for user-added items to be appended inside a section.
  static int _sortOrder(PackingRuleItem rule) =>
      rule.category.order * 1000 + rule.sort.clamp(0, 999);
}
