import 'package:flutter_test/flutter_test.dart';
import 'package:valizim/core/config/app_config.dart';
import 'package:valizim/features/trips/domain/item_category.dart';
import 'package:valizim/features/trips/domain/packing_generator.dart';
import 'package:valizim/features/trips/domain/packing_rules.dart';
import 'package:valizim/features/trips/domain/trip_options.dart';
import 'package:valizim/features/trips/domain/trip_type.dart';

import '../../support/rules_fixture.dart';

void main() {
  group('QuantityRule', () {
    test('a fixed rule ignores duration and party size', () {
      const rule = QuantityRule();
      expect(rule.resolve(days: 1, travelers: 1, laundry: false), 1);
      expect(rule.resolve(days: 30, travelers: 5, laundry: false), 1);
    });

    test('per-day scaling rounds up and respects the floor', () {
      const rule = QuantityRule(base: 0, perDay: 0.7, min: 2, max: 8);
      // 1 day -> ceil(0.7) = 1, lifted to the minimum of 2.
      expect(rule.resolve(days: 1, travelers: 1, laundry: false), 2);
      // 5 days -> ceil(3.5) = 4.
      expect(rule.resolve(days: 5, travelers: 1, laundry: false), 4);
    });

    test('the max cap is what stops absurd quantities', () {
      const rule = QuantityRule(base: 0, perDay: 1, min: 2, max: 10);
      expect(rule.resolve(days: 60, travelers: 1, laundry: false), 10);
    });

    test('per-traveler multiplies after the per-person cap', () {
      const rule = QuantityRule(base: 0, perDay: 1, min: 2, max: 10, perTraveler: true);
      // Capped at 10 each, then multiplied by 3 travellers.
      expect(rule.resolve(days: 60, travelers: 3, laundry: false), 30);
    });

    test('never exceeds the global ceiling', () {
      const rule = QuantityRule(base: 99, perDay: 5, max: 99, perTraveler: true);
      expect(
        rule.resolve(days: 60, travelers: 10, laundry: false),
        AppConfig.maxItemQuantity,
      );
    });

    test('laundry caps the effective trip length', () {
      const rule = QuantityRule(base: 0, perDay: 1, min: 2, max: 20, laundryCapDays: 4);
      expect(rule.resolve(days: 14, travelers: 1, laundry: false), 14);
      expect(rule.resolve(days: 14, travelers: 1, laundry: true), 4);
    });

    test('laundry does nothing to items it does not apply to', () {
      const rule = QuantityRule(base: 0, perDay: 1, min: 1, max: 20);
      expect(rule.resolve(days: 14, travelers: 1, laundry: true), 14);
    });

    test('degenerate inputs are floored rather than producing zero', () {
      const rule = QuantityRule(base: 0, perDay: 1, min: 0, max: 10);
      expect(rule.resolve(days: 0, travelers: 0, laundry: false), 1);
      expect(rule.resolve(days: -5, travelers: -2, laundry: false), 1);
    });
  });

  group('PackingGenerator', () {
    late PackingGenerator generator;

    setUp(() {
      generator = PackingGenerator(PackingRules.parse(fixtureRulesJson));
    });

    List<GeneratedItem> generate({
      TripType type = TripType.general,
      int days = 3,
      int travelers = 1,
      PackingOptions options = const PackingOptions(),
    }) =>
        generator.generate(
          tripType: type,
          durationDays: days,
          travelerCount: travelers,
          options: options,
        );

    test('a general trip returns only the base rules', () {
      final items = generate();
      expect(
        items.map((GeneratedItem i) => i.ruleKey),
        containsAll(<String>['passport_id', 'tshirt', 'toothbrush']),
      );
      expect(
        items.map((GeneratedItem i) => i.ruleKey),
        isNot(contains('sunscreen')),
      );
    });

    test('trip type adds its own items on top of the base', () {
      final items = generate(type: TripType.beach);
      expect(
        items.map((GeneratedItem i) => i.ruleKey),
        containsAll(<String>['passport_id', 'sunscreen', 'beach_towel']),
      );
    });

    test('a trip type can override a base item without duplicating it', () {
      final items = generate(type: TripType.city);
      final shoes = items
          .where((GeneratedItem i) => i.ruleKey == 'everyday_shoes')
          .toList();
      expect(shoes, hasLength(1), reason: 'override must replace, not append');
      expect(shoes.single.isEssential, isTrue,
          reason: 'the city rule marks walking shoes essential');
    });

    test('options layer on after the trip type', () {
      final items = generate(
        type: TripType.city,
        options: const PackingOptions(work: true),
      );
      expect(
        items.map((GeneratedItem i) => i.ruleKey),
        containsAll(<String>['laptop', 'laptop_charger']),
      );
    });

    test('the same inputs always produce the same ordered output', () {
      const options = PackingOptions(swimming: true, laundry: true);
      final first = generate(type: TripType.beach, days: 7, travelers: 2, options: options);
      final second = generate(type: TripType.beach, days: 7, travelers: 2, options: options);
      expect(
        first.map((GeneratedItem i) => '${i.ruleKey}:${i.quantity}').toList(),
        second.map((GeneratedItem i) => '${i.ruleKey}:${i.quantity}').toList(),
      );
    });

    test('items come back grouped by category in display order', () {
      final items = generate(type: TripType.camping);
      final orders = items.map((GeneratedItem i) => i.category.order).toList();
      expect(
        orders,
        orderedEquals(List<int>.from(orders)..sort()),
        reason: 'category order must be non-decreasing across the list',
      );
    });

    test('laundry reduces clothing on a long trip', () {
      final without = generate(days: 14, travelers: 1);
      final with_ = generate(
        days: 14,
        travelers: 1,
        options: const PackingOptions(laundry: true),
      );
      int qty(List<GeneratedItem> items, String key) =>
          items.firstWhere((GeneratedItem i) => i.ruleKey == key).quantity;

      expect(qty(with_, 'underwear'), lessThan(qty(without, 'underwear')));
    });

    test('laundry adds its own items too', () {
      final items = generate(options: const PackingOptions(laundry: true));
      expect(
        items.map((GeneratedItem i) => i.ruleKey),
        contains('laundry_bag'),
      );
    });

    test('duration and traveller counts are clamped to configured limits', () {
      final items = generate(days: 9999, travelers: 9999);
      for (final item in items) {
        expect(item.quantity, lessThanOrEqualTo(AppConfig.maxItemQuantity));
        expect(item.quantity, greaterThanOrEqualTo(1));
      }
    });

    test('every generated item carries a rule key and a non-empty label', () {
      for (final type in TripType.values) {
        for (final item in generate(type: type)) {
          expect(item.ruleKey, isNotEmpty);
          expect(item.label, isNotEmpty);
          expect(ItemCategory.values, contains(item.category));
        }
      }
    });

    test('no trip type produces duplicate rule keys', () {
      for (final type in TripType.values) {
        final keys = generate(
          type: type,
          options: const PackingOptions(
            swimming: true,
            formalEvent: true,
            work: true,
            laundry: true,
          ),
        ).map((GeneratedItem i) => i.ruleKey).toList();
        expect(keys.toSet(), hasLength(keys.length), reason: 'in ${type.id}');
      }
    });
  });
}
