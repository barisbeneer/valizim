import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valizim/app/providers.dart';
import 'package:valizim/core/database/database.dart';
import 'package:valizim/core/theme/app_theme.dart';
import 'package:valizim/features/trips/data/trip_repository.dart';
import 'package:valizim/features/trips/domain/packing_generator.dart';
import 'package:valizim/features/trips/domain/packing_rules.dart';
import 'package:valizim/features/trips/domain/trip_options.dart';
import 'package:valizim/features/trips/domain/trip_type.dart';
import 'package:valizim/l10n/generated/app_localizations.dart';

import 'fake_notification_gateway.dart';
import 'rules_fixture.dart';
import 'test_database.dart';

/// Viewports the UI/UX validation gate requires: one small iPhone-class screen
/// and one large one (spec section 11).
class TestViewport {
  const TestViewport(this.name, this.size);

  /// iPhone SE-class. The tightest layout the app must survive.
  static const TestViewport small = TestViewport('small', Size(320, 568));

  /// iPhone Pro Max-class.
  static const TestViewport large = TestViewport('large', Size(430, 932));

  final String name;
  final Size size;
}

/// Everything a screen needs, wired to in-memory doubles.
class TestHarness {
  TestHarness._(this.container, this.database, this.gateway);

  final ProviderContainer container;
  final AppDatabase database;
  final FakeNotificationGateway gateway;

  TripRepository get trips => container.read(tripRepositoryProvider);

  static Future<TestHarness> create({bool isPro = false}) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      if (isPro) 'entitlement.pro_lifetime': true,
    });
    final preferences = await SharedPreferences.getInstance();
    final database = openTestDatabase();
    final gateway = FakeNotificationGateway();
    final rules = PackingRules.parse(fixtureRulesJson);

    final container = ProviderContainer(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(preferences),
        appDatabaseProvider.overrideWithValue(database),
        notificationGatewayProvider.overrideWithValue(gateway),
        // Provided directly so no screen has to wait on an asset load.
        packingRulesProvider.overrideWith((Ref ref) => rules),
        packingGeneratorProvider.overrideWithValue(PackingGenerator(rules)),
      ],
    );
    await container.read(packingRulesProvider.future);
    return TestHarness._(container, database, gateway);
  }

  /// Seeds a trip with a real generated checklist.
  Future<String> seedTrip({
    String name = 'Antalya',
    TripType type = TripType.beach,
    int days = 5,
    int travelers = 2,
    DateTime? startDate,
    PackingOptions options = const PackingOptions(),
  }) {
    final items = container.read(packingGeneratorProvider).generate(
          tripType: type,
          durationDays: days,
          travelerCount: travelers,
          options: options,
        );
    return trips.createTrip(
      name: name,
      tripType: type,
      durationDays: days,
      travelerCount: travelers,
      settings: TripSettings(packing: options),
      items: items,
      startDate: startDate,
    );
  }

  Future<void> dispose() async {
    container.dispose();
    await database.close();
  }
}

/// Pumps [child] inside the real app scaffolding: localizations, theme and the
/// provider container, at a given viewport, text scale, locale and brightness.
Future<void> pumpScreen(
  WidgetTester tester,
  TestHarness harness,
  Widget child, {
  TestViewport viewport = TestViewport.small,
  double textScale = 1.0,
  Locale locale = const Locale('en'),
  Brightness brightness = Brightness.light,
  bool reduceMotion = false,
}) async {
  tester.view.physicalSize = viewport.size * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: harness.container,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: const <LocalizationsDelegate<Object>>[
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppL10n.supportedLocales,
        theme: brightness == Brightness.dark
            ? AppTheme.dark()
            : AppTheme.light(),
        home: MediaQuery(
          data: MediaQueryData(
            size: viewport.size,
            devicePixelRatio: 3,
            textScaler: TextScaler.linear(textScale),
            platformBrightness: brightness,
            disableAnimations: reduceMotion,
          ),
          child: child,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
