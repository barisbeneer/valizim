import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valizim/app/providers.dart';
import 'package:valizim/core/config/app_config.dart';
import 'package:valizim/features/trips/domain/trip_type.dart';
import 'package:valizim/features/trips/presentation/home_screen.dart';
import 'package:valizim/features/trips/presentation/packing_list_screen.dart';
import 'package:valizim/l10n/generated/app_localizations.dart';

import '../support/harness.dart';

/// Widget coverage for the core loop and the entitlement gates.
///
/// These drive real widgets against a real (in-memory) database, so they cover
/// the wiring that unit tests cannot: that a tap reaches the repository, and
/// that the repository's answer reaches the screen.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('packing list', () {
    testWidgets('the generated checklist is rendered in sections',
        (WidgetTester tester) async {
      final harness = await TestHarness.create();
      addTearDown(harness.dispose);
      final id = await harness.seedTrip(type: TripType.beach);

      await pumpScreen(tester, harness, PackingListScreen(tripId: id),
          viewport: TestViewport.large);

      expect(find.text('Passport / ID'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('ticking an item updates progress on screen',
        (WidgetTester tester) async {
      // The regression that motivated this: the write succeeded but the screen
      // never refreshed, so the checklist looked frozen.
      final harness = await TestHarness.create();
      addTearDown(harness.dispose);
      final id = await harness.seedTrip(type: TripType.beach);

      await pumpScreen(tester, harness, PackingListScreen(tripId: id),
          viewport: TestViewport.large);
      expect(find.text('0%'), findsOneWidget);

      await tester.tap(find.text('Passport / ID'));
      await tester.pumpAndSettle();

      expect(find.text('0%'), findsNothing);
      final data = await harness.trips.getTripWithItems(id);
      expect(data!.packed, 1);
    });

    testWidgets('ticking twice returns to the original state',
        (WidgetTester tester) async {
      final harness = await TestHarness.create();
      addTearDown(harness.dispose);
      final id = await harness.seedTrip(type: TripType.beach);

      await pumpScreen(tester, harness, PackingListScreen(tripId: id),
          viewport: TestViewport.large);

      await tester.tap(find.text('Wallet & cards'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wallet & cards'));
      await tester.pumpAndSettle();

      final data = await harness.trips.getTripWithItems(id);
      expect(data!.packed, 0);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('a fully packed list shows the completion message',
        (WidgetTester tester) async {
      final harness = await TestHarness.create();
      addTearDown(harness.dispose);
      final id = await harness.seedTrip(type: TripType.general, days: 1);

      final data = await harness.trips.getTripWithItems(id);
      for (final item in data!.items) {
        await harness.trips.setChecked(item.id, true);
      }

      await pumpScreen(tester, harness, PackingListScreen(tripId: id),
          viewport: TestViewport.large);

      expect(find.text('100%'), findsOneWidget);
      final l10n = await AppL10n.delegate.load(const Locale('en'));
      expect(find.text(l10n.listAllPacked), findsOneWidget);
    });

    testWidgets('item labels follow the device language',
        (WidgetTester tester) async {
      // The trip is created once; only the locale changes. Nothing is rewritten
      // in the database.
      final harness = await TestHarness.create();
      addTearDown(harness.dispose);
      final id = await harness.seedTrip(type: TripType.beach);

      await pumpScreen(tester, harness, PackingListScreen(tripId: id),
          viewport: TestViewport.large, locale: const Locale('tr'));

      expect(find.text('Pasaport / kimlik'), findsOneWidget);
      expect(find.text('Passport / ID'), findsNothing);
      expect(find.text('Belgeler'), findsOneWidget);
    });

    testWidgets('a city trip shows the label its own rule layer defines',
        (WidgetTester tester) async {
      final harness = await TestHarness.create();
      addTearDown(harness.dispose);
      final id = await harness.seedTrip(type: TripType.city);

      await pumpScreen(tester, harness, PackingListScreen(tripId: id),
          viewport: TestViewport.large);

      // Slivers only build what is on screen, so scroll it into view first.
      await tester.scrollUntilVisible(
        find.text('Comfortable walking shoes'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Comfortable walking shoes'), findsOneWidget);
      expect(find.text('Everyday shoes'), findsNothing);
    });

    testWidgets('a missing trip shows a recoverable empty state, not a crash',
        (WidgetTester tester) async {
      final harness = await TestHarness.create();
      addTearDown(harness.dispose);

      await pumpScreen(
        tester,
        harness,
        const PackingListScreen(tripId: 'does-not-exist'),
        viewport: TestViewport.large,
      );

      final l10n = await AppL10n.delegate.load(const Locale('en'));
      expect(find.text(l10n.listNotFound), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('home', () {
    testWidgets('the empty state teaches the first action',
        (WidgetTester tester) async {
      final harness = await TestHarness.create();
      addTearDown(harness.dispose);

      await pumpScreen(tester, harness, const HomeScreen(),
          viewport: TestViewport.large);

      final l10n = await AppL10n.delegate.load(const Locale('en'));
      expect(find.text(l10n.homeEmptyTitle), findsOneWidget);
      expect(find.text(l10n.homeEmptyAction), findsOneWidget);
    });

    testWidgets('trips are split into upcoming and past',
        (WidgetTester tester) async {
      final harness = await TestHarness.create();
      addTearDown(harness.dispose);
      final now = DateTime.now();
      await harness.seedTrip(
        name: 'Future trip',
        startDate: DateTime.utc(now.year + 1, 6),
      );
      await harness.seedTrip(
        name: 'Old trip',
        days: 1,
        startDate: DateTime.utc(now.year - 1, 6),
      );

      await pumpScreen(tester, harness, const HomeScreen(),
          viewport: TestViewport.large);

      final l10n = await AppL10n.delegate.load(const Locale('en'));
      expect(find.text(l10n.homeSectionUpcoming.toUpperCase()), findsOneWidget);
      expect(find.text(l10n.homeSectionPast.toUpperCase()), findsOneWidget);
      expect(find.text('Future trip'), findsOneWidget);
      expect(find.text('Old trip'), findsOneWidget);
    });

    testWidgets('the free-tier banner counts stored trips',
        (WidgetTester tester) async {
      final harness = await TestHarness.create();
      addTearDown(harness.dispose);
      await harness.seedTrip(name: 'One');
      await harness.seedTrip(name: 'Two');

      await pumpScreen(tester, harness, const HomeScreen(),
          viewport: TestViewport.large);

      final l10n = await AppL10n.delegate.load(const Locale('en'));
      expect(
        find.text(l10n.homeFreeTripsUsed(2, AppConfig.freeTripLimit)),
        findsOneWidget,
      );
    });

    testWidgets('Pro hides the free-tier banner', (WidgetTester tester) async {
      final harness = await TestHarness.create(isPro: true);
      addTearDown(harness.dispose);
      await harness.seedTrip(name: 'One');

      await pumpScreen(tester, harness, const HomeScreen(),
          viewport: TestViewport.large);

      final l10n = await AppL10n.delegate.load(const Locale('en'));
      expect(
        find.text(l10n.homeFreeTripsUsed(1, AppConfig.freeTripLimit)),
        findsNothing,
      );
    });
  });

  group('entitlement gate', () {
    // Plain `test`, not `testWidgets`: these assert provider state and need no
    // widget tree, and a real `Future.delayed` never completes inside the
    // fake-async zone `testWidgets` installs.
    /// Subscribes to the gate the way the UI does, so the underlying count
    /// stream is actually running before anything is asserted.
    Future<void> settle(TestHarness harness) async {
      harness.container.listen<bool>(
        canCreateTripProvider,
        (bool? previous, bool next) {},
        fireImmediately: true,
      );
      await Future<void>.delayed(const Duration(milliseconds: 40));
    }

    test('a free user may create up to the limit', () async {
      final harness = await TestHarness.create();
      addTearDown(harness.dispose);

      await settle(harness);
      expect(harness.container.read(canCreateTripProvider), isTrue);

      for (var i = 0; i < AppConfig.freeTripLimit; i++) {
        await harness.seedTrip(name: 'Trip $i');
      }
      await settle(harness);
      expect(harness.container.read(canCreateTripProvider), isFalse);
    });

    test('Pro removes the limit', () async {
      final harness = await TestHarness.create(isPro: true);
      addTearDown(harness.dispose);

      for (var i = 0; i < AppConfig.freeTripLimit + 2; i++) {
        await harness.seedTrip(name: 'Trip $i');
      }
      await settle(harness);
      expect(harness.container.read(canCreateTripProvider), isTrue);
    });

    test('archived trips still count against the free limit', () async {
      // Archiving is not a way around the limit: an archived trip is still
      // stored and still reusable.
      final harness = await TestHarness.create();
      addTearDown(harness.dispose);

      final ids = <String>[];
      for (var i = 0; i < AppConfig.freeTripLimit; i++) {
        ids.add(await harness.seedTrip(name: 'Trip $i'));
      }
      await harness.trips.setArchived(ids.first, true);
      await settle(harness);
      expect(harness.container.read(canCreateTripProvider), isFalse);

      // Deleting one does free a slot.
      await harness.trips.deleteTrip(ids.first);
      await settle(harness);
      expect(harness.container.read(canCreateTripProvider), isTrue);
    });
  });

  group('reduced motion', () {
    testWidgets('the list renders with animations disabled',
        (WidgetTester tester) async {
      final harness = await TestHarness.create();
      addTearDown(harness.dispose);
      final id = await harness.seedTrip();

      await pumpScreen(
        tester,
        harness,
        PackingListScreen(tripId: id),
        viewport: TestViewport.large,
        reduceMotion: true,
      );

      expect(find.byType(PackingListScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
