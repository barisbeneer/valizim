import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/database/database.dart';
import 'app.dart';
import 'providers.dart';

/// Starts the app.
///
/// Everything here is local: opening the SQLite file, reading preferences,
/// parsing the bundled rules asset, initialising the notification plugin and
/// connecting to StoreKit. Only the last of those touches the network, and it
/// is allowed to fail - the app is fully usable in airplane mode, which is the
/// operating constraint the whole product is built around.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = await SharedPreferences.getInstance();
  final database = AppDatabase();

  final container = ProviderContainer(
    overrides: <Override>[
      sharedPreferencesProvider.overrideWithValue(preferences),
      appDatabaseProvider.overrideWithValue(database),
    ],
  );

  // Parse the rules before the first frame so generation is synchronous from
  // the very first tap and the wizard never shows a spinner.
  await container.read(packingRulesProvider.future);

  // Neither of these blocks a usable app, so a failure is logged and stepped
  // over rather than allowed to abort the launch.
  await _tolerate(
    () => container.read(notificationGatewayProvider).initialize(),
    'initialising notifications',
  );
  await _tolerate(
    () => container.read(purchaseServiceProvider).initialize(),
    'connecting to the store',
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const ValizimApp(),
    ),
  );
}

Future<void> _tolerate(Future<void> Function() action, String description) async {
  try {
    await action();
  } on Object catch (error, stack) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'valizim/bootstrap',
        context: ErrorDescription(description),
      ),
    );
  }
}
