import 'dart:convert';
import 'dart:math' as math;

import '../../../core/config/app_config.dart';
import '../../../core/utils/parse.dart';
import 'item_category.dart';
import 'trip_type.dart';

/// Thrown when the bundled rules asset cannot be understood.
///
/// This is a programming/packaging error, never a user-facing condition: the
/// asset ships inside the binary, so if it fails to parse the build is broken.
class PackingRulesFormatException implements Exception {
  const PackingRulesFormatException(this.message);

  final String message;

  @override
  String toString() => 'PackingRulesFormatException: $message';
}

/// How one item's quantity scales with trip length and party size.
///
/// Formula, applied in this exact order:
/// ```
/// days'  = laundry && laundryCapDays != null ? min(days, laundryCapDays) : days
/// raw    = base + ceil(perDay * days')
/// each   = raw.clamp(min, max)
/// total  = perTraveler ? each * travelers : each
/// result = total.clamp(1, AppConfig.maxItemQuantity)
/// ```
/// The clamps are what keep a 60-day trip for 10 people from asking for 600
/// t-shirts (spec section 5).
class QuantityRule {
  const QuantityRule({
    this.base = 1,
    this.perDay = 0,
    this.min = 1,
    this.max = AppConfig.maxItemQuantity,
    this.perTraveler = false,
    this.laundryCapDays,
  });

  static const QuantityRule single = QuantityRule();

  /// Constant part of the quantity.
  final int base;

  /// Added per trip day before clamping.
  final double perDay;

  /// Lower bound applied per traveler.
  final int min;

  /// Upper bound applied per traveler. This is the cap that matters most.
  final int max;

  /// Multiply by traveler count. False for shared gear (one tent, one stove).
  final bool perTraveler;

  /// When laundry is available, treat the trip as at most this many days for
  /// the purpose of this item. Null means laundry does not affect it.
  final int? laundryCapDays;

  int resolve({
    required int days,
    required int travelers,
    required bool laundry,
  }) {
    final safeDays = math.max(1, days);
    final safeTravelers = math.max(1, travelers);
    final cap = laundryCapDays;
    final effectiveDays =
        laundry && cap != null ? math.min(safeDays, cap) : safeDays;

    final raw = base + (perDay * effectiveDays).ceil();
    final each = raw.clamp(min, max);
    final total = perTraveler ? each * safeTravelers : each;
    return total.clamp(1, AppConfig.maxItemQuantity);
  }

  static QuantityRule fromMap(Map<String, Object?> map) {
    return QuantityRule(
      base: asInt(map['base']) ?? 1,
      perDay: asDouble(map['perDay']) ?? 0,
      min: asInt(map['min']) ?? 1,
      max: asInt(map['max']) ?? AppConfig.maxItemQuantity,
      perTraveler: map['perTraveler'] == true,
      laundryCapDays: asInt(map['laundryCapDays']),
    );
  }
}

/// One item definition from the bundled rules file.
class PackingRuleItem {
  const PackingRuleItem({
    required this.key,
    required this.category,
    required this.labels,
    required this.quantity,
    this.essential = false,
    this.sort = 100,
  });

  /// Stable identifier, persisted on generated trip items so labels can be
  /// re-resolved when the device language changes.
  final String key;

  final ItemCategory category;

  /// Locale code to display label. Always contains an `en` entry; the loader
  /// rejects the asset otherwise.
  final Map<String, String> labels;

  final QuantityRule quantity;
  final bool essential;

  /// Position within the category.
  final int sort;

  /// Resolves the label for [languageCode], falling back to English.
  String label(String languageCode) =>
      labels[languageCode] ?? labels['en'] ?? key;

  static PackingRuleItem fromMap(Map<String, Object?> map) {
    final key = map['key'];
    if (key is! String || key.isEmpty) {
      throw const PackingRulesFormatException('item is missing a "key"');
    }
    final rawLabels = map['labels'];
    if (rawLabels is! Map<String, Object?>) {
      throw PackingRulesFormatException('item "$key" is missing "labels"');
    }
    final labels = <String, String>{};
    for (final entry in rawLabels.entries) {
      final value = entry.value;
      if (value is String && value.isNotEmpty) labels[entry.key] = value;
    }
    if (!labels.containsKey('en')) {
      throw PackingRulesFormatException('item "$key" has no English label');
    }
    final qty = map['qty'];
    return PackingRuleItem(
      key: key,
      category: ItemCategory.fromId(map['category'] as String?),
      labels: Map<String, String>.unmodifiable(labels),
      quantity: qty is Map<String, Object?>
          ? QuantityRule.fromMap(qty)
          : QuantityRule.single,
      essential: map['essential'] == true,
      sort: asInt(map['sort']) ?? 100,
    );
  }
}

/// The parsed contents of `assets/rules/packing_rules.json`.
class PackingRules {
  const PackingRules({
    required this.rulesVersion,
    required this.base,
    required this.byTripType,
    required this.byOption,
  });

  final int rulesVersion;

  /// Applied to every trip regardless of type.
  final List<PackingRuleItem> base;

  final Map<String, List<PackingRuleItem>> byTripType;
  final Map<String, List<PackingRuleItem>> byOption;

  List<PackingRuleItem> forTripType(TripType type) =>
      byTripType[type.id] ?? const <PackingRuleItem>[];

  List<PackingRuleItem> forOption(String optionId) =>
      byOption[optionId] ?? const <PackingRuleItem>[];

  /// Merges the rule layers that apply to one trip, in the order that defines
  /// the product: base, then trip type, then options.
  ///
  /// A later layer with the same key fully replaces the earlier one - that is
  /// how a city trip turns "Everyday shoes" into "Comfortable walking shoes"
  /// without producing two entries. Insertion order is preserved, so
  /// re-assigning an existing key keeps its original position.
  ///
  /// Both the generator and the label resolver go through this, so a trip's
  /// items and their displayed names can never disagree about which layer won.
  Map<String, PackingRuleItem> mergedFor(
    TripType tripType,
    List<String> optionIds,
  ) {
    final merged = <String, PackingRuleItem>{};
    void apply(List<PackingRuleItem> items) {
      for (final item in items) {
        merged[item.key] = item;
      }
    }

    apply(base);
    apply(forTripType(tripType));
    for (final optionId in optionIds) {
      apply(forOption(optionId));
    }
    return merged;
  }

  /// Every rule key the file defines, useful for validation tests.
  Set<String> get allKeys => <String>{
        for (final item in base) item.key,
        for (final list in byTripType.values)
          for (final item in list) item.key,
        for (final list in byOption.values)
          for (final item in list) item.key,
      };

  static PackingRules parse(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw PackingRulesFormatException('invalid JSON: ${error.message}');
    }
    if (decoded is! Map<String, Object?>) {
      throw const PackingRulesFormatException('root must be an object');
    }

    final base = _itemList(decoded['base'], 'base');
    final byTripType = _itemMap(decoded['tripTypes'], 'tripTypes');
    final byOption = _itemMap(decoded['options'], 'options');

    for (final type in TripType.values) {
      if (!byTripType.containsKey(type.id)) {
        throw PackingRulesFormatException(
          'tripTypes is missing an entry for "${type.id}"',
        );
      }
    }

    return PackingRules(
      rulesVersion: asInt(decoded['rulesVersion']) ?? 1,
      base: base,
      byTripType: Map<String, List<PackingRuleItem>>.unmodifiable(byTripType),
      byOption: Map<String, List<PackingRuleItem>>.unmodifiable(byOption),
    );
  }

  static List<PackingRuleItem> _itemList(Object? raw, String field) {
    if (raw == null) return const <PackingRuleItem>[];
    if (raw is! List<Object?>) {
      throw PackingRulesFormatException('"$field" must be a list');
    }
    return List<PackingRuleItem>.unmodifiable(
      raw.map((Object? entry) {
        if (entry is! Map<String, Object?>) {
          throw PackingRulesFormatException('"$field" contains a non-object');
        }
        return PackingRuleItem.fromMap(entry);
      }),
    );
  }

  static Map<String, List<PackingRuleItem>> _itemMap(
    Object? raw,
    String field,
  ) {
    if (raw == null) return <String, List<PackingRuleItem>>{};
    if (raw is! Map<String, Object?>) {
      throw PackingRulesFormatException('"$field" must be an object');
    }
    return <String, List<PackingRuleItem>>{
      for (final entry in raw.entries)
        entry.key: _itemList(
          entry.value is Map<String, Object?>
              ? (entry.value! as Map<String, Object?>)['items']
              : entry.value,
          '$field.${entry.key}',
        ),
    };
  }
}

