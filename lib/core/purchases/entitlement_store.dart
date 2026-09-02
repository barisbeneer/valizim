import 'package:shared_preferences/shared_preferences.dart';

/// Local cache of what the user owns.
///
/// The store is the authority, but it needs the network and an Apple Account
/// session. Without a cache a Pro user who opens the app in airplane mode would
/// briefly - or, offline, permanently - look like a free user. So the answer is
/// persisted and read synchronously at launch (spec section 7).
///
/// This cache is deliberately *sticky*: it is only ever cleared by an explicit
/// "delete all data" action, never by a failed or offline store query. A store
/// lookup that fails must not revoke a purchase the user already paid for.
class EntitlementStore {
  EntitlementStore(this._prefs);

  static const String _proKey = 'entitlement.pro_lifetime';
  static const String _askedNotificationsKey = 'notifications.asked';

  final SharedPreferences _prefs;

  static Future<EntitlementStore> open() async =>
      EntitlementStore(await SharedPreferences.getInstance());

  bool get isPro => _prefs.getBool(_proKey) ?? false;

  Future<void> setPro({required bool value}) async {
    await _prefs.setBool(_proKey, value);
  }

  /// iOS cannot distinguish "never asked" from "asked and denied" through the
  /// notification plugin, so the app remembers whether it has ever prompted.
  bool get hasAskedForNotifications =>
      _prefs.getBool(_askedNotificationsKey) ?? false;

  Future<void> markNotificationsAsked() async {
    await _prefs.setBool(_askedNotificationsKey, true);
  }

  Future<void> clear() async {
    await _prefs.remove(_proKey);
    await _prefs.remove(_askedNotificationsKey);
  }
}
