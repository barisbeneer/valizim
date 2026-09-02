import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valizim/features/pro/presentation/paywall_screen.dart';
import 'package:valizim/features/settings/presentation/privacy_screen.dart';
import 'package:valizim/features/settings/presentation/settings_screen.dart';
import 'package:valizim/features/share/presentation/share_screen.dart';
import 'package:valizim/features/templates/presentation/templates_screen.dart';
import 'package:valizim/features/trips/presentation/home_screen.dart';
import 'package:valizim/features/trips/presentation/packing_list_screen.dart';
import 'package:valizim/features/trips/presentation/trip_wizard_screen.dart';

import '../support/harness.dart';

/// The UI/UX validation gate, automated.
///
/// Every screen is rendered on a small and a large iPhone-class viewport, in
/// English and Turkish, at the default text size and at 300% - the largest
/// accessibility size iOS offers. A `RenderFlex` overflow raises a Flutter
/// error, which fails the test, so a layout that clips or runs off-screen
/// cannot reach a device unnoticed.
///
/// This exists because manual checking found two genuine overflows that unit
/// tests could never have caught: the progress ring overflowed its fixed
/// diameter by 87 logical pixels at 300%, and the free-tier banner ran off the
/// right edge once its message and call to action were both translated.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Text scales worth covering: the default, the largest non-accessibility
  /// size, and the largest accessibility size.
  const List<double> textScales = <double>[1.0, 1.35, 3.0];

  const List<TestViewport> viewports = <TestViewport>[
    TestViewport.small,
    TestViewport.large,
  ];

  const List<Locale> locales = <Locale>[Locale('en'), Locale('tr')];

  /// Runs [body] across the full matrix.
  void matrix(
    String description,
    Future<void> Function(WidgetTester, TestHarness, TestViewport, double, Locale)
        body, {
    bool isPro = false,
  }) {
    for (final viewport in viewports) {
      for (final scale in textScales) {
        for (final locale in locales) {
          testWidgets(
            '$description [${viewport.name}, ${scale}x, ${locale.languageCode}]',
            (WidgetTester tester) async {
              final harness = await TestHarness.create(isPro: isPro);
              addTearDown(harness.dispose);
              await body(tester, harness, viewport, scale, locale);
              // pumpAndSettle inside pumpScreen would already have thrown on an
              // overflow; this makes the intent explicit.
              expect(tester.takeException(), isNull);
            },
          );
        }
      }
    }
  }

  matrix('home renders with no trips', (
    WidgetTester tester,
    TestHarness harness,
    TestViewport viewport,
    double scale,
    Locale locale,
  ) async {
    await pumpScreen(
      tester,
      harness,
      const HomeScreen(),
      viewport: viewport,
      textScale: scale,
      locale: locale,
    );
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  matrix('home renders with trips and the free-tier banner', (
    WidgetTester tester,
    TestHarness harness,
    TestViewport viewport,
    double scale,
    Locale locale,
  ) async {
    await harness.seedTrip(name: 'Antalya sahil kacamagi');
    await harness.seedTrip(name: 'Berlin');
    await pumpScreen(
      tester,
      harness,
      const HomeScreen(),
      viewport: viewport,
      textScale: scale,
      locale: locale,
    );
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  matrix('the packing list renders with a full checklist', (
    WidgetTester tester,
    TestHarness harness,
    TestViewport viewport,
    double scale,
    Locale locale,
  ) async {
    final id = await harness.seedTrip();
    // Tick one item so the ring shows a partial value and its caption is long.
    final data = await harness.trips.getTripWithItems(id);
    await harness.trips.setChecked(data!.items.first.id, true);

    await pumpScreen(
      tester,
      harness,
      PackingListScreen(tripId: id),
      viewport: viewport,
      textScale: scale,
      locale: locale,
    );
    expect(find.byType(PackingListScreen), findsOneWidget);
  });

  matrix('the trip wizard renders', (
    WidgetTester tester,
    TestHarness harness,
    TestViewport viewport,
    double scale,
    Locale locale,
  ) async {
    await pumpScreen(
      tester,
      harness,
      const TripWizardScreen(),
      viewport: viewport,
      textScale: scale,
      locale: locale,
    );
    expect(find.byType(TripWizardScreen), findsOneWidget);
  });

  matrix('the paywall renders', (
    WidgetTester tester,
    TestHarness harness,
    TestViewport viewport,
    double scale,
    Locale locale,
  ) async {
    await pumpScreen(
      tester,
      harness,
      const PaywallScreen(),
      viewport: viewport,
      textScale: scale,
      locale: locale,
    );
    expect(find.byType(PaywallScreen), findsOneWidget);
  });

  matrix('templates render', (
    WidgetTester tester,
    TestHarness harness,
    TestViewport viewport,
    double scale,
    Locale locale,
  ) async {
    await pumpScreen(
      tester,
      harness,
      const TemplatesScreen(),
      viewport: viewport,
      textScale: scale,
      locale: locale,
    );
    expect(find.byType(TemplatesScreen), findsOneWidget);
  });

  matrix('settings render', (
    WidgetTester tester,
    TestHarness harness,
    TestViewport viewport,
    double scale,
    Locale locale,
  ) async {
    await pumpScreen(
      tester,
      harness,
      const SettingsScreen(),
      viewport: viewport,
      textScale: scale,
      locale: locale,
    );
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  matrix('the privacy screen renders', (
    WidgetTester tester,
    TestHarness harness,
    TestViewport viewport,
    double scale,
    Locale locale,
  ) async {
    await pumpScreen(
      tester,
      harness,
      const PrivacyScreen(),
      viewport: viewport,
      textScale: scale,
      locale: locale,
    );
    expect(find.byType(PrivacyScreen), findsOneWidget);
  });

  matrix('the share screen renders', (
    WidgetTester tester,
    TestHarness harness,
    TestViewport viewport,
    double scale,
    Locale locale,
  ) async {
    final id = await harness.seedTrip();
    await pumpScreen(
      tester,
      harness,
      ShareScreen(tripId: id),
      viewport: viewport,
      textScale: scale,
      locale: locale,
    );
    expect(find.byType(ShareScreen), findsOneWidget);
  });
}
