import 'package:flutter_test/flutter_test.dart';
import 'package:valizim/core/config/app_config.dart';
import 'package:valizim/core/database/database.dart';
import 'package:valizim/features/trips/data/trip_repository.dart';
import 'package:valizim/features/trips/domain/item_category.dart';
import 'package:valizim/features/trips/domain/packing_generator.dart';
import 'package:valizim/features/trips/domain/packing_rules.dart';
import 'package:valizim/features/trips/domain/trip.dart';
import 'package:valizim/features/trips/domain/trip_options.dart';
import 'package:valizim/features/trips/domain/trip_type.dart';

import '../../support/rules_fixture.dart';
import '../../support/test_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late TripRepository repository;
  late PackingGenerator generator;

  setUp(() {
    db = openTestDatabase();
    repository = TripRepository(db);
    generator = PackingGenerator(PackingRules.parse(fixtureRulesJson));
  });

  tearDown(() async => db.close());

  List<GeneratedItem> itemsFor(
    TripType type, {
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

  Future<String> createBeachTrip({String name = 'Antalya'}) => repository.createTrip(
        name: name,
        tripType: TripType.beach,
        durationDays: 5,
        travelerCount: 2,
        settings: const TripSettings(),
        items: itemsFor(TripType.beach, days: 5, travelers: 2),
        startDate: DateTime.utc(2027, 7, 10),
      );

  group('create', () {
    test('stores the trip and its generated items together', () async {
      final id = await createBeachTrip();
      final result = await repository.getTripWithItems(id);

      expect(result, isNotNull);
      expect(result!.trip.name, 'Antalya');
      expect(result.trip.tripType, TripType.beach);
      expect(result.trip.travelerCount, 2);
      expect(result.trip.startDate, DateTime.utc(2027, 7, 10));
      expect(result.items, isNotEmpty);
      expect(result.packed, 0);
    });

    test('items come back in section order', () async {
      final id = await createBeachTrip();
      final result = await repository.getTripWithItems(id);
      final orders = result!.items.map((TripItem i) => i.sortOrder).toList();
      expect(orders, orderedEquals(List<int>.from(orders)..sort()));
    });

    test('a trip name longer than the limit is truncated, not rejected', () async {
      final id = await repository.createTrip(
        name: 'x' * 500,
        tripType: TripType.general,
        durationDays: 2,
        travelerCount: 1,
        settings: const TripSettings(),
        items: itemsFor(TripType.general),
      );
      final result = await repository.getTripWithItems(id);
      expect(result!.trip.name.length, AppConfig.maxTripNameLength);
    });

    test('options round-trip through the JSON column', () async {
      const options = PackingOptions(swimming: true, laundry: true);
      final id = await repository.createTrip(
        name: 'Rhodes',
        tripType: TripType.beach,
        durationDays: 6,
        travelerCount: 1,
        settings: const TripSettings(packing: options),
        items: itemsFor(TripType.beach, days: 6, options: options),
      );
      final result = await repository.getTripWithItems(id);
      expect(result!.trip.options.swimming, isTrue);
      expect(result.trip.options.laundry, isTrue);
      expect(result.trip.options.work, isFalse);
    });
  });

  group('checking items', () {
    test('progress reflects checked items', () async {
      final id = await createBeachTrip();
      final before = await repository.getTripWithItems(id);
      await repository.setChecked(before!.items.first.id, true);

      final after = await repository.getTripWithItems(id);
      expect(after!.packed, 1);
      expect(after.progress, greaterThan(0));
    });

    test('uncheckAll clears every tick on that trip only', () async {
      final first = await createBeachTrip(name: 'One');
      final second = await createBeachTrip(name: 'Two');
      final firstItems = (await repository.getTripWithItems(first))!.items;
      final secondItems = (await repository.getTripWithItems(second))!.items;

      await repository.setChecked(firstItems.first.id, true);
      await repository.setChecked(secondItems.first.id, true);
      await repository.uncheckAll(first);

      expect((await repository.getTripWithItems(first))!.packed, 0);
      expect((await repository.getTripWithItems(second))!.packed, 1);
    });

    test('progressPercent only reports 100 when genuinely complete', () async {
      final id = await createBeachTrip();
      final result = await repository.getTripWithItems(id);
      for (final item in result!.items.skip(1)) {
        await repository.setChecked(item.id, true);
      }
      final almost = await repository.getTripWithItems(id);
      expect(almost!.remaining, 1);
      expect(
        almost.progressPercent,
        lessThan(100),
        reason: 'one item short must never read as finished',
      );

      await repository.setChecked(result.items.first.id, true);
      final done = await repository.getTripWithItems(id);
      expect(done!.progressPercent, 100);
      expect(done.isComplete, isTrue);
    });
  });

  group('user items', () {
    test('an added item has no rule key and lands in its section', () async {
      final id = await createBeachTrip();
      await repository.addItem(
        tripId: id,
        label: 'Snorkel',
        category: ItemCategory.gear,
        quantity: 2,
      );
      final result = await repository.getTripWithItems(id);
      final added = result!.items.firstWhere((TripItem i) => i.label == 'Snorkel');

      expect(added.ruleKey, isNull);
      expect(added.isUserAdded, isTrue);
      expect(added.quantity, 2);
      expect(
        added.sortOrder,
        inInclusiveRange(
          ItemCategory.gear.order * 1000,
          ItemCategory.gear.order * 1000 + 999,
        ),
      );
    });

    test('quantity is clamped to the allowed range', () async {
      final id = await createBeachTrip();
      await repository.addItem(
        tripId: id,
        label: 'Too many',
        category: ItemCategory.misc,
        quantity: 100000,
      );
      final result = await repository.getTripWithItems(id);
      final added = result!.items.firstWhere((TripItem i) => i.label == 'Too many');
      expect(added.quantity, AppConfig.maxItemQuantity);
    });

    test('a deleted item can be restored verbatim, which is what undo needs',
        () async {
      final id = await createBeachTrip();
      final original = (await repository.getTripWithItems(id))!.items.first;
      await repository.setChecked(original.id, true);

      final checked = (await repository.getTripWithItems(id))!
          .items
          .firstWhere((TripItem i) => i.id == original.id);
      await repository.deleteItem(original.id);
      expect(
        (await repository.getTripWithItems(id))!
            .items
            .where((TripItem i) => i.id == original.id),
        isEmpty,
      );

      await repository.restoreItem(checked);
      final restored = (await repository.getTripWithItems(id))!
          .items
          .firstWhere((TripItem i) => i.id == original.id);
      expect(restored.label, checked.label);
      expect(restored.checked, isTrue);
      expect(restored.sortOrder, checked.sortOrder);
      expect(restored.ruleKey, checked.ruleKey);
    });
  });

  group('duplicate', () {
    test('the copy owns independent item rows', () async {
      final sourceId = await createBeachTrip();
      final copyId = await repository.duplicateTrip(sourceId, 'Antalya (copy)');

      final source = await repository.getTripWithItems(sourceId);
      final copy = await repository.getTripWithItems(copyId);

      expect(copy!.items, hasLength(source!.items.length));
      final sourceIds = source.items.map((TripItem i) => i.id).toSet();
      final copyIds = copy.items.map((TripItem i) => i.id).toSet();
      expect(sourceIds.intersection(copyIds), isEmpty);
    });

    test('editing the copy does not touch the original', () async {
      final sourceId = await createBeachTrip();
      final copyId = await repository.duplicateTrip(sourceId, 'Copy');

      final copyItem = (await repository.getTripWithItems(copyId))!.items.first;
      await repository.setChecked(copyItem.id, true);
      await repository.deleteItem(
        (await repository.getTripWithItems(copyId))!.items.last.id,
      );

      final source = await repository.getTripWithItems(sourceId);
      expect(source!.packed, 0);
      expect(source.items, hasLength((await repository.getTripWithItems(copyId))!.items.length + 1));
    });

    test('ticks are cleared on the copy', () async {
      final sourceId = await createBeachTrip();
      final item = (await repository.getTripWithItems(sourceId))!.items.first;
      await repository.setChecked(item.id, true);

      final copyId = await repository.duplicateTrip(sourceId, 'Copy');
      expect((await repository.getTripWithItems(copyId))!.packed, 0);
    });

    test('the start date and reminders are dropped', () async {
      final sourceId = await createBeachTrip();
      final source = (await repository.getTripWithItems(sourceId))!.trip;
      await repository.updateTrip(
        source.copyWith(
          settings: const TripSettings(reminders: ReminderSettings(dayBefore: true)),
        ),
      );

      final copyId = await repository.duplicateTrip(sourceId, 'Copy');
      final copy = (await repository.getTripWithItems(copyId))!.trip;
      expect(copy.startDate, isNull);
      expect(copy.reminders.anyEnabled, isFalse);
    });

    test('duplicating a missing trip fails loudly', () async {
      expect(
        () => repository.duplicateTrip('nope', 'Copy'),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('update', () {
    test('edits without regeneration keep the checklist untouched', () async {
      final id = await createBeachTrip();
      final before = await repository.getTripWithItems(id);
      await repository.setChecked(before!.items.first.id, true);

      await repository.updateTrip(before.trip.copyWith(name: 'Antalya 2'));

      final after = await repository.getTripWithItems(id);
      expect(after!.trip.name, 'Antalya 2');
      expect(after.items, hasLength(before.items.length));
      expect(after.packed, 1, reason: 'ticks must survive a plain edit');
    });

    test('regeneration replaces every item and clears ticks', () async {
      final id = await createBeachTrip();
      final before = await repository.getTripWithItems(id);
      await repository.setChecked(before!.items.first.id, true);
      await repository.addItem(
        tripId: id,
        label: 'Custom thing',
        category: ItemCategory.misc,
        quantity: 1,
      );

      await repository.updateTrip(
        before.trip.copyWith(tripType: TripType.winter),
        regeneratedItems: itemsFor(TripType.winter, days: 5, travelers: 2),
      );

      final after = await repository.getTripWithItems(id);
      expect(after!.packed, 0);
      expect(
        after.items.where((TripItem i) => i.label == 'Custom thing'),
        isEmpty,
        reason: 'the rebuild is documented as removing user-added items',
      );
      expect(
        after.items.map((TripItem i) => i.ruleKey),
        contains('winter_coat'),
      );
    });

    test('updatedAt moves forward on edit', () async {
      final id = await createBeachTrip();
      final before = (await repository.getTripWithItems(id))!.trip;
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await repository.updateTrip(before.copyWith(name: 'Later'));
      final after = (await repository.getTripWithItems(id))!.trip;
      expect(after.updatedAt.isAfter(before.updatedAt), isTrue);
      expect(after.createdAt, before.createdAt);
    });
  });

  group('archive and delete', () {
    test('archiving keeps the trip and its items', () async {
      final id = await createBeachTrip();
      await repository.setArchived(id, true);
      final result = await repository.getTripWithItems(id);
      expect(result!.trip.archived, isTrue);
      expect(result.items, isNotEmpty);
      expect(await repository.countTrips(), 1);
    });

    test('deleting a trip cascades to its items', () async {
      final id = await createBeachTrip();
      expect(await repository.countItems(id), greaterThan(0));
      await repository.deleteTrip(id);
      expect(await repository.countTrips(), 0);
      expect(await repository.countItems(id), 0);
    });

    test('deleteEverything empties all tables', () async {
      await createBeachTrip(name: 'One');
      await createBeachTrip(name: 'Two');
      await repository.deleteEverything();
      expect(await repository.countTrips(), 0);
      expect(await db.select(db.tripItems).get(), isEmpty);
      expect(await db.select(db.customTemplates).get(), isEmpty);
    });
  });

  group('trip detail stream', () {
    // Regression coverage. The first implementation watched only the `trips`
    // table and loaded items inside a callback, so ticking a checkbox wrote to
    // the database but never pushed a new value and the checklist looked
    // frozen. Every test here writes to `trip_items` only.

    test('re-emits when an item is checked', () async {
      final id = await createBeachTrip();
      final emissions = <int>[];
      final sub = repository
          .watchTripWithItems(id)
          .listen((TripWithItems? d) => emissions.add(d?.packed ?? -1));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final item = (await repository.getTripWithItems(id))!.items.first;
      await repository.setChecked(item.id, true);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await sub.cancel();

      expect(emissions.first, 0);
      expect(emissions.last, 1, reason: 'the tick must reach the stream');
    });

    test('re-emits when an item is added or deleted', () async {
      final id = await createBeachTrip();
      final emissions = <int>[];
      final sub = repository
          .watchTripWithItems(id)
          .listen((TripWithItems? d) => emissions.add(d?.total ?? -1));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final initial = emissions.last;

      final newId = await repository.addItem(
        tripId: id,
        label: 'Snorkel',
        category: ItemCategory.gear,
        quantity: 1,
      );
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(emissions.last, initial + 1);

      await repository.deleteItem(newId);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await sub.cancel();
      expect(emissions.last, initial);
    });

    test('re-emits when the trip itself changes', () async {
      final id = await createBeachTrip();
      final names = <String?>[];
      final sub = repository
          .watchTripWithItems(id)
          .listen((TripWithItems? d) => names.add(d?.trip.name));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final trip = (await repository.getTripWithItems(id))!.trip;
      await repository.updateTrip(trip.copyWith(name: 'Renamed'));
      await Future<void>.delayed(const Duration(milliseconds: 30));
      await sub.cancel();

      expect(names.last, 'Renamed');
    });

    test('a trip with no items yields an empty list, not null', () async {
      final id = await repository.createTrip(
        name: 'Empty',
        tripType: TripType.general,
        durationDays: 1,
        travelerCount: 1,
        settings: const TripSettings(),
        items: const <GeneratedItem>[],
      );
      final data = await repository.watchTripWithItems(id).first;
      expect(data, isNotNull);
      expect(data!.items, isEmpty);
      expect(data.total, 0);
      expect(data.progressPercent, 0);
    });

    test('a missing trip yields null', () async {
      expect(await repository.watchTripWithItems('nope').first, isNull);
    });

    test('items arrive in section order', () async {
      final id = await createBeachTrip();
      final data = await repository.watchTripWithItems(id).first;
      final orders = data!.items.map((TripItem i) => i.sortOrder).toList();
      expect(orders, orderedEquals(List<int>.from(orders)..sort()));
    });
  });

  group('progress math', () {
    TripWithItems build(int total, int packed) => TripWithItems(
          trip: Trip(
            id: 't',
            name: 'n',
            tripType: TripType.general,
            durationDays: 1,
            travelerCount: 1,
            settings: const TripSettings(),
            createdAt: DateTime.utc(2027),
            updatedAt: DateTime.utc(2027),
          ),
          items: <TripItem>[
            for (var i = 0; i < total; i++)
              TripItem(
                id: 'i\$i',
                tripId: 't',
                label: 'item \$i',
                category: ItemCategory.misc,
                quantity: 1,
                sortOrder: i,
                checked: i < packed,
              ),
          ],
        );

    test('an empty list reads as zero, never NaN', () {
      final empty = build(0, 0);
      expect(empty.progress, 0);
      expect(empty.progressPercent, 0);
      expect(empty.isComplete, isFalse);
    });

    test('a single item is all-or-nothing', () {
      expect(build(1, 0).progressPercent, 0);
      expect(build(1, 1).progressPercent, 100);
    });

    test('percent never claims 100 before the last item', () {
      for (final total in <int>[3, 7, 38, 199, 400]) {
        expect(
          build(total, total - 1).progressPercent,
          lessThan(100),
          reason: 'total=\$total',
        );
        expect(build(total, total).progressPercent, 100);
      }
    });

    test('unpacked essentials are reported separately', () {
      final withEssentials = TripWithItems(
        trip: build(0, 0).trip,
        items: <TripItem>[
          const TripItem(
            id: 'a',
            tripId: 't',
            label: 'Passport',
            category: ItemCategory.documents,
            quantity: 1,
            sortOrder: 0,
            isEssential: true,
          ),
          const TripItem(
            id: 'b',
            tripId: 't',
            label: 'Wallet',
            category: ItemCategory.documents,
            quantity: 1,
            sortOrder: 1,
            isEssential: true,
            checked: true,
          ),
          const TripItem(
            id: 'c',
            tripId: 't',
            label: 'Snacks',
            category: ItemCategory.misc,
            quantity: 1,
            sortOrder: 2,
          ),
        ],
      );
      expect(
        withEssentials.unpackedEssentials.map((TripItem i) => i.label),
        <String>['Passport'],
      );
      expect(withEssentials.grouped.keys, <ItemCategory>[
        ItemCategory.documents,
        ItemCategory.misc,
      ]);
    });
  });

  group('streams', () {
    test('watchTrips emits on every change', () async {
      final emissions = <int>[];
      final sub = repository
          .watchTrips()
          .listen((List<Trip> trips) => emissions.add(trips.length));
      // Let the initial (empty) emission land before writing anything.
      await Future<void>.delayed(const Duration(milliseconds: 20));

      await createBeachTrip(name: 'One');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await createBeachTrip(name: 'Two');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await sub.cancel();

      expect(emissions.first, 0);
      expect(emissions.last, 2);
      expect(emissions, contains(1));
    });

    test('progress is reported per trip in one query', () async {
      final first = await createBeachTrip(name: 'One');
      final second = await createBeachTrip(name: 'Two');
      final firstItem = (await repository.getTripWithItems(first))!.items.first;
      await repository.setChecked(firstItem.id, true);

      final progress = await repository.watchProgressByTrip().first;
      expect(progress[first]!.packed, 1);
      expect(progress[second]!.packed, 0);
      expect(progress[first]!.total, greaterThan(0));
    });
  });
}
