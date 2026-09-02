import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/app_config.dart';
import '../core/database/database.dart';
import '../core/notifications/notification_gateway.dart';
import '../core/notifications/reminder_scheduler.dart';
import '../core/purchases/entitlement_store.dart';
import '../core/purchases/purchase_service.dart';
import '../core/settings/app_preferences.dart';
import '../features/templates/data/template_repository.dart';
import '../features/templates/domain/custom_template.dart';
import '../features/trips/data/packing_rules_loader.dart';
import '../features/trips/data/trip_repository.dart';
import '../features/trips/domain/packing_generator.dart';
import '../features/trips/domain/packing_rules.dart';
import '../features/trips/domain/trip.dart';

/// Overridden in `bootstrap()` once the real instance exists. Reading it
/// without that override is a wiring bug, so it throws loudly rather than
/// silently handing back a stub.
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>(
  (Ref ref) => throw UnimplementedError('sharedPreferencesProvider'),
);

final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>(
  (Ref ref) => throw UnimplementedError('appDatabaseProvider'),
);

// -----------------------------------------------------------------------------
// Repositories
// -----------------------------------------------------------------------------

final Provider<TripRepository> tripRepositoryProvider = Provider<TripRepository>(
  (Ref ref) => TripRepository(ref.watch(appDatabaseProvider)),
);

final Provider<TemplateRepository> templateRepositoryProvider =
    Provider<TemplateRepository>(
  (Ref ref) => TemplateRepository(ref.watch(appDatabaseProvider)),
);

final Provider<PackingRulesLoader> packingRulesLoaderProvider =
    Provider<PackingRulesLoader>((Ref ref) => PackingRulesLoader());

/// Parsed rules. Loaded once at bootstrap, so by the time any screen reads it
/// the value is already available and generation stays synchronous.
final FutureProvider<PackingRules> packingRulesProvider =
    FutureProvider<PackingRules>(
  (Ref ref) => ref.watch(packingRulesLoaderProvider).load(),
);

/// Generator over the loaded rules. Throws if read before the rules resolve,
/// which cannot happen through the app's own navigation.
final Provider<PackingGenerator> packingGeneratorProvider =
    Provider<PackingGenerator>((Ref ref) {
  final rules = ref.watch(packingRulesProvider).requireValue;
  return PackingGenerator(rules);
});

// -----------------------------------------------------------------------------
// Platform services
// -----------------------------------------------------------------------------

final Provider<NotificationGateway> notificationGatewayProvider =
    Provider<NotificationGateway>((Ref ref) => LocalNotificationGateway());

final Provider<ReminderScheduler> reminderSchedulerProvider =
    Provider<ReminderScheduler>(
  (Ref ref) => ReminderScheduler(ref.watch(notificationGatewayProvider)),
);

final Provider<EntitlementStore> entitlementStoreProvider =
    Provider<EntitlementStore>(
  (Ref ref) => EntitlementStore(ref.watch(sharedPreferencesProvider)),
);

final ChangeNotifierProvider<PurchaseService> purchaseServiceProvider =
    ChangeNotifierProvider<PurchaseService>(
  // ChangeNotifierProvider disposes the notifier it holds, so registering an
  // onDispose here as well would dispose it twice.
  (Ref ref) => PurchaseService(
    entitlements: ref.watch(entitlementStoreProvider),
  ),
);

/// The single entitlement gate the UI reads.
final Provider<bool> isProProvider = Provider<bool>(
  (Ref ref) => ref.watch(purchaseServiceProvider).isPro,
);

// -----------------------------------------------------------------------------
// Preferences
// -----------------------------------------------------------------------------

final Provider<AppPreferencesStore> appPreferencesStoreProvider =
    Provider<AppPreferencesStore>(
  (Ref ref) => AppPreferencesStore(ref.watch(sharedPreferencesProvider)),
);

class AppPreferencesNotifier extends Notifier<AppPreferences> {
  @override
  AppPreferences build() => ref.watch(appPreferencesStoreProvider).read();

  AppPreferencesStore get _store => ref.read(appPreferencesStoreProvider);

  Future<void> setDefaultTravelerCount(int value) async {
    await _store.setDefaultTravelerCount(value);
    state = _store.read();
  }

  Future<void> setDefaultDurationDays(int value) async {
    await _store.setDefaultDurationDays(value);
    state = _store.read();
  }

  Future<void> reset() async {
    await _store.reset();
    state = _store.read();
  }
}

final NotifierProvider<AppPreferencesNotifier, AppPreferences>
    appPreferencesProvider =
    NotifierProvider<AppPreferencesNotifier, AppPreferences>(
  AppPreferencesNotifier.new,
);

// -----------------------------------------------------------------------------
// Data streams
// -----------------------------------------------------------------------------

final StreamProvider<List<Trip>> tripsProvider = StreamProvider<List<Trip>>(
  (Ref ref) => ref.watch(tripRepositoryProvider).watchTrips(),
);

final StreamProvider<Map<String, ({int packed, int total})>>
    tripProgressProvider =
    StreamProvider<Map<String, ({int packed, int total})>>(
  (Ref ref) => ref.watch(tripRepositoryProvider).watchProgressByTrip(),
);

final StreamProvider<int> tripCountProvider = StreamProvider<int>(
  (Ref ref) => ref.watch(tripRepositoryProvider).watchTripCount(),
);

final StreamProviderFamily<TripWithItems?, String> tripDetailProvider =
    StreamProvider.family<TripWithItems?, String>(
  (Ref ref, String tripId) =>
      ref.watch(tripRepositoryProvider).watchTripWithItems(tripId),
);

final StreamProvider<List<CustomTemplate>> customTemplatesProvider =
    StreamProvider<List<CustomTemplate>>(
  (Ref ref) => ref.watch(templateRepositoryProvider).watchTemplates(),
);

/// Whether the user may save another trip.
///
/// Pro is unlimited. Free counts every stored trip, archived included, because
/// all of them remain reusable - which is what the user is paying to remove.
final Provider<bool> canCreateTripProvider = Provider<bool>((Ref ref) {
  if (ref.watch(isProProvider)) return true;
  final count = ref.watch(tripCountProvider).valueOrNull ?? 0;
  return count < AppConfig.freeTripLimit;
});
