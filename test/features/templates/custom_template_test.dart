import 'package:flutter_test/flutter_test.dart';
import 'package:valizim/core/config/app_config.dart';
import 'package:valizim/features/templates/data/template_repository.dart';
import 'package:valizim/features/templates/domain/custom_template.dart';
import 'package:valizim/features/trips/domain/item_category.dart';
import 'package:valizim/features/trips/domain/trip.dart';
import 'package:valizim/features/trips/domain/trip_type.dart';

import '../../support/test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('serialization', () {
    test('items round-trip', () {
      const items = <TemplateItem>[
        TemplateItem(
          label: 'Passport',
          category: ItemCategory.documents,
          quantity: 1,
          isEssential: true,
          sortOrder: 10,
          ruleKey: 'passport_id',
        ),
        TemplateItem(
          label: 'Snorkel',
          category: ItemCategory.gear,
          quantity: 2,
          sortOrder: 5900,
        ),
      ];
      final decoded = CustomTemplate.decodeItems(
        CustomTemplate.encodeItems(items),
      );

      expect(decoded, hasLength(2));
      expect(decoded.first.label, 'Passport');
      expect(decoded.first.ruleKey, 'passport_id');
      expect(decoded.first.isEssential, isTrue);
      expect(decoded.last.ruleKey, isNull);
      expect(decoded.last.quantity, 2);
    });

    test('Turkish characters survive the round-trip', () {
      const items = <TemplateItem>[
        TemplateItem(
          label: 'Güneş gözlüğü ve şapka',
          category: ItemCategory.gear,
          quantity: 1,
        ),
      ];
      final decoded = CustomTemplate.decodeItems(
        CustomTemplate.encodeItems(items),
      );
      expect(decoded.single.label, 'Güneş gözlüğü ve şapka');
    });
  });

  group('corrupt input is survivable', () {
    test('null and empty produce an empty list', () {
      expect(CustomTemplate.decodeItems(null), isEmpty);
      expect(CustomTemplate.decodeItems(''), isEmpty);
    });

    test('invalid JSON produces an empty list rather than throwing', () {
      expect(CustomTemplate.decodeItems('{not json'), isEmpty);
      expect(CustomTemplate.decodeItems('"a string"'), isEmpty);
      expect(CustomTemplate.decodeItems('{"items": []}'), isEmpty);
    });

    test('unreadable entries are skipped and readable ones kept', () {
      const source = '['
          '{"label":"Good","category":"misc","quantity":1},'
          '17,'
          '{"category":"misc","quantity":1},'
          '{"label":"   ","category":"misc"},'
          '{"label":"Also good","category":"nonsense","quantity":"3"}'
          ']';
      final decoded = CustomTemplate.decodeItems(source);

      expect(decoded.map((TemplateItem i) => i.label),
          <String>['Good', 'Also good']);
      expect(
        decoded.last.category,
        ItemCategory.misc,
        reason: 'an unknown category degrades to misc',
      );
      expect(decoded.last.quantity, 3, reason: 'a numeric string is accepted');
    });

    test('absurd values are clamped', () {
      final source = '[{"label":"${'x' * 500}","category":"misc",'
          '"quantity":999999}]';
      final decoded = CustomTemplate.decodeItems(source);
      expect(decoded.single.label.length, AppConfig.maxItemLabelLength);
      expect(decoded.single.quantity, AppConfig.maxItemQuantity);
    });

    test('a huge array is truncated rather than loaded whole', () {
      final entries = List<String>.generate(
        AppConfig.maxItemsPerTrip + 50,
        (int i) => '{"label":"item \$i","category":"misc","quantity":1}',
      );
      final decoded = CustomTemplate.decodeItems('[${entries.join(',')}]');
      expect(decoded, hasLength(AppConfig.maxItemsPerTrip));
    });
  });

  group('TemplateRepository', () {
    test('saves, lists and deletes', () async {
      final db = openTestDatabase();
      addTearDown(db.close);
      final repository = TemplateRepository(db);

      final id = await repository.saveTemplate(
        name: 'Weekender',
        tripType: TripType.city,
        items: const <TemplateItem>[
          TemplateItem(
            label: 'Charger',
            category: ItemCategory.electronics,
            quantity: 1,
          ),
        ],
      );

      final loaded = await repository.getTemplate(id);
      expect(loaded, isNotNull);
      expect(loaded!.name, 'Weekender');
      expect(loaded.tripType, TripType.city);
      expect(loaded.itemCount, 1);

      expect(await repository.countTemplates(), 1);
      await repository.deleteTemplate(id);
      expect(await repository.countTemplates(), 0);
      expect(await repository.getTemplate(id), isNull);
    });

    test('a long template name is truncated', () async {
      final db = openTestDatabase();
      addTearDown(db.close);
      final repository = TemplateRepository(db);

      final id = await repository.saveTemplate(
        name: 'n' * 400,
        items: const <TemplateItem>[],
      );
      final loaded = await repository.getTemplate(id);
      expect(loaded!.name.length, AppConfig.maxTemplateNameLength);
    });

    test('a template built from trip items keeps rule keys', () {
      const item = TripItem(
        id: 'a',
        tripId: 't',
        label: 'T-shirts',
        category: ItemCategory.clothing,
        quantity: 4,
        sortOrder: 1030,
        ruleKey: 'tshirt',
      );
      final template = TemplateItem.fromTripItem(item);
      expect(template.ruleKey, 'tshirt');
      expect(template.quantity, 4);
      expect(template.category, ItemCategory.clothing);
    });
  });
}
