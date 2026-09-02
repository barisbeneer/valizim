import 'packing_rules.dart';
import 'trip.dart';

/// Resolves the display label for a checklist item in the current language.
///
/// Generated items store an English label plus the rule key that produced them.
/// Looking the key up here means a user who switches their device to Turkish
/// sees Turkish names on trips they created in English, with no data rewrite
/// and no migration.
///
/// The lookup is built from the *same merged rule layers* the trip was
/// generated from, so an item a trip type renamed keeps that name: a city trip
/// shows "Comfortable walking shoes", not the base "Everyday shoes".
class ItemLabelResolver {
  ItemLabelResolver._(this._byKey, this._languageCode);

  /// Builds a resolver for one trip.
  factory ItemLabelResolver.forTrip({
    required PackingRules rules,
    required Trip trip,
    required String languageCode,
  }) {
    return ItemLabelResolver._(
      rules.mergedFor(trip.tripType, trip.options.enabledIds),
      languageCode,
    );
  }

  final Map<String, PackingRuleItem> _byKey;
  final String _languageCode;

  /// Falls back to the stored label whenever the item was typed by the user, or
  /// its rule no longer exists because the rules asset changed under it.
  String labelFor(TripItem item) {
    final key = item.ruleKey;
    if (key == null) return item.label;
    return _byKey[key]?.label(_languageCode) ?? item.label;
  }
}
