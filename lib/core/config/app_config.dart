/// Single source of truth for release-configurable values.
///
/// Everything an operator may need to change before shipping lives here so no
/// grep through widgets is required. No secrets belong in this file: the app
/// has no backend and no API keys.
abstract final class AppConfig {
  const AppConfig._();

  // ---------------------------------------------------------------------------
  // Identity
  // ---------------------------------------------------------------------------

  /// Must match `PRODUCT_BUNDLE_IDENTIFIER` in the Xcode project.
  static const String bundleId = 'com.valizim.app';

  /// Shown in Settings > About. Kept out of localization on purpose: a brand
  /// name is not translated.
  static const String appName = 'Valizim';

  // ---------------------------------------------------------------------------
  // Legal links
  //
  // Served from GitHub Pages out of the repository's docs/ folder, so they cost
  // nothing to host and are versioned alongside the code they describe. Both
  // must stay reachable: App Store Connect requires a live privacy policy URL,
  // and the paywall links to the terms.
  //
  // If a custom domain is adopted later, change these two constants and nothing
  // else - every screen reads them from here.
  // ---------------------------------------------------------------------------

  static const String privacyPolicyUrl =
      'https://barisbeneer.github.io/valizim/privacy/';
  static const String termsUrl = 'https://barisbeneer.github.io/valizim/terms/';

  /// PLACEHOLDER: still points at an unregistered domain, so "Contact support"
  /// currently composes mail to nowhere. Replace with an address that actually
  /// receives mail before submission - App Review needs a reachable contact.
  static const String supportEmail = 'support@valizim.app';

  // ---------------------------------------------------------------------------
  // Monetization
  // ---------------------------------------------------------------------------

  /// Non-consumable product id. Must match App Store Connect and the local
  /// StoreKit configuration file (`ios/Runner/Valizim.storekit`).
  ///
  /// The displayed price and title always come from the store, never from here.
  static const String proProductId = 'com.valizim.app.pro_lifetime';

  static const Set<String> storeProductIds = {proProductId};

  /// Trips a user may store without Pro. Counts every saved trip, archived
  /// included, because all of them stay reusable.
  static const int freeTripLimit = 3;

  // ---------------------------------------------------------------------------
  // Input limits
  //
  // Caps exist to keep layouts intact and storage bounded (spec section 5).
  // ---------------------------------------------------------------------------

  static const int maxTripNameLength = 60;
  static const int maxItemLabelLength = 80;
  static const int maxTemplateNameLength = 60;
  static const int minDurationDays = 1;
  static const int maxDurationDays = 60;
  static const int minTravelerCount = 1;
  static const int maxTravelerCount = 10;

  /// Hard ceiling for any generated or user-entered quantity.
  static const int maxItemQuantity = 99;

  /// Items a single trip may hold. Guards against pathological imports.
  static const int maxItemsPerTrip = 400;

  // ---------------------------------------------------------------------------
  // Scheduling
  // ---------------------------------------------------------------------------

  /// Default local departure time used to anchor reminders when the user has
  /// not chosen one. Exposed in the reminder sheet.
  static const int defaultDepartureHour = 9;
  static const int defaultDepartureMinute = 0;

  /// Reminder offsets before departure, in hours (spec section 6).
  static const int earlyReminderHours = 24;
  static const int lateReminderHours = 3;

  // ---------------------------------------------------------------------------
  // Persistence
  // ---------------------------------------------------------------------------

  static const String databaseFileName = 'valizim.sqlite';
  static const int databaseSchemaVersion = 2;
}
