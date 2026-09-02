import 'package:flutter_test/flutter_test.dart';
import 'package:valizim/features/trips/domain/item_category.dart';
import 'package:valizim/features/trips/domain/packing_rules.dart';
import 'package:valizim/features/trips/domain/trip_type.dart';

import '../../support/rules_fixture.dart';

/// Guards the shipped rules asset. It is data, not code, so nothing else stops
/// a typo in it from reaching a device.
void main() {
  late PackingRules rules;

  setUp(() => rules = PackingRules.parse(fixtureRulesJson));

  test('the bundled asset parses', () {
    expect(rules.rulesVersion, greaterThan(0));
    expect(rules.base, isNotEmpty);
  });

  test('every trip type has an entry', () {
    for (final type in TripType.values) {
      expect(
        rules.byTripType.containsKey(type.id),
        isTrue,
        reason: 'missing rules for ${type.id}',
      );
    }
  });

  test('every option referenced by the wizard has an entry', () {
    for (final option in <String>['swimming', 'formalEvent', 'work', 'laundry']) {
      expect(rules.forOption(option), isNotEmpty, reason: 'missing $option');
    }
  });

  test('every item has both an English and a Turkish label', () {
    final missing = <String>[];
    void check(Iterable<PackingRuleItem> items) {
      for (final item in items) {
        if (!item.labels.containsKey('en')) missing.add('${item.key}:en');
        if (!item.labels.containsKey('tr')) missing.add('${item.key}:tr');
      }
    }

    check(rules.base);
    rules.byTripType.values.forEach(check);
    rules.byOption.values.forEach(check);
    expect(missing, isEmpty);
  });

  test('label lookup falls back to English for an unknown locale', () {
    final item = rules.base.first;
    expect(item.label('de'), item.labels['en']);
  });

  test('every item lands in a known category', () {
    final all = <PackingRuleItem>[
      ...rules.base,
      for (final list in rules.byTripType.values) ...list,
      for (final list in rules.byOption.values) ...list,
    ];
    for (final item in all) {
      expect(ItemCategory.values, contains(item.category));
    }
  });

  test('items sharing a key across layers also share a category', () {
    // A key that changes category between layers would move between sections
    // depending on the options chosen, which reads as a bug to a user.
    final categories = <String, ItemCategory>{};
    final conflicts = <String>[];
    void check(Iterable<PackingRuleItem> items) {
      for (final item in items) {
        final existing = categories[item.key];
        if (existing != null && existing != item.category) {
          conflicts.add('${item.key}: ${existing.id} vs ${item.category.id}');
        }
        categories[item.key] = item.category;
      }
    }

    check(rules.base);
    rules.byTripType.values.forEach(check);
    rules.byOption.values.forEach(check);
    expect(conflicts, isEmpty);
  });

  test('no rule can produce a quantity outside its own bounds', () {
    final all = <PackingRuleItem>[
      ...rules.base,
      for (final list in rules.byTripType.values) ...list,
      for (final list in rules.byOption.values) ...list,
    ];
    for (final item in all) {
      expect(
        item.quantity.min,
        lessThanOrEqualTo(item.quantity.max),
        reason: '${item.key} has min > max',
      );
    }
  });

  group('malformed input', () {
    test('invalid JSON is rejected', () {
      expect(
        () => PackingRules.parse('{not json'),
        throwsA(isA<PackingRulesFormatException>()),
      );
    });

    test('a non-object root is rejected', () {
      expect(
        () => PackingRules.parse('[]'),
        throwsA(isA<PackingRulesFormatException>()),
      );
    });

    test('a missing trip type is rejected', () {
      expect(
        () => PackingRules.parse('{"base": [], "tripTypes": {}}'),
        throwsA(isA<PackingRulesFormatException>()),
      );
    });

    test('an item without an English label is rejected', () {
      const source = '{"base": [{"key":"x","category":"misc",'
          '"labels":{"tr":"X"}}], "tripTypes": {}}';
      expect(
        () => PackingRules.parse(source),
        throwsA(isA<PackingRulesFormatException>()),
      );
    });

    test('an item without a key is rejected', () {
      const source = '{"base": [{"category":"misc","labels":{"en":"X"}}],'
          '"tripTypes": {}}';
      expect(
        () => PackingRules.parse(source),
        throwsA(isA<PackingRulesFormatException>()),
      );
    });
  });
}
