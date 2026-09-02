// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Valizim';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionDone => 'Done';

  @override
  String get actionNext => 'Next';

  @override
  String get actionBack => 'Back';

  @override
  String get actionClose => 'Close';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionEdit => 'Edit';

  @override
  String get actionShare => 'Share';

  @override
  String get actionUndo => 'Undo';

  @override
  String get actionContinue => 'Continue';

  @override
  String get actionNotNow => 'Not now';

  @override
  String get actionOpenSettings => 'Open Settings';

  @override
  String get actionRemove => 'Remove';

  @override
  String get actionTryAgain => 'Try again';

  @override
  String get tripTypeBeach => 'Beach';

  @override
  String get tripTypeBeachHint => 'Sun, sand and swimming';

  @override
  String get tripTypeCity => 'City break';

  @override
  String get tripTypeCityHint => 'Walking, cafés and museums';

  @override
  String get tripTypeBusiness => 'Business';

  @override
  String get tripTypeBusinessHint => 'Meetings and smart clothes';

  @override
  String get tripTypeCamping => 'Camping';

  @override
  String get tripTypeCampingHint => 'Outdoors and self-sufficient';

  @override
  String get tripTypeWinter => 'Winter';

  @override
  String get tripTypeWinterHint => 'Cold weather and layers';

  @override
  String get tripTypeGeneral => 'General';

  @override
  String get tripTypeGeneralHint => 'The essentials, nothing extra';

  @override
  String get categoryDocuments => 'Documents';

  @override
  String get categoryClothing => 'Clothing';

  @override
  String get categoryToiletries => 'Toiletries';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryElectronics => 'Electronics';

  @override
  String get categoryGear => 'Gear';

  @override
  String get categoryMisc => 'Other';

  @override
  String get homeTitle => 'My trips';

  @override
  String get homeCreateTrip => 'Plan a trip';

  @override
  String get homeEmptyTitle => 'No trips yet';

  @override
  String get homeEmptyBody =>
      'Create a trip and Valizim builds the packing list for you. No account, no internet needed.';

  @override
  String get homeEmptyAction => 'Plan your first trip';

  @override
  String get homeSectionUpcoming => 'Upcoming';

  @override
  String get homeSectionPast => 'Past';

  @override
  String get homeSectionUndated => 'No date yet';

  @override
  String get homeStartsToday => 'Starts today';

  @override
  String get homeStartsTomorrow => 'Starts tomorrow';

  @override
  String homeStartsInDays(int days) {
    return 'In $days days';
  }

  @override
  String homeStartedDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String homeFreeTripsUsed(int used, int limit) {
    return '$used of $limit free trips used';
  }

  @override
  String get homeMenuDuplicate => 'Duplicate';

  @override
  String get homeMenuArchive => 'Move to past';

  @override
  String get homeMenuUnarchive => 'Move to upcoming';

  @override
  String get homeMenuDelete => 'Delete trip';

  @override
  String get homeDeleteTitle => 'Delete this trip?';

  @override
  String homeDeleteBody(String name) {
    return '$name and all of its items will be removed from this device.';
  }

  @override
  String get homeTripDeleted => 'Trip deleted';

  @override
  String get homeTripArchived => 'Moved to past';

  @override
  String get homeTripRestored => 'Moved to upcoming';

  @override
  String homeCopySuffix(String name) {
    return '$name (copy)';
  }

  @override
  String get homeTripDuplicated => 'Trip duplicated';

  @override
  String daysCount(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String travelersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count travellers',
      one: '1 traveller',
    );
    return '$_temp0';
  }

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String packedOfTotal(int packed, int total) {
    return '$packed of $total packed';
  }

  @override
  String remainingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items left',
      one: '1 item left',
    );
    return '$_temp0';
  }

  @override
  String get wizardTitle => 'New trip';

  @override
  String get wizardEditTitle => 'Edit trip';

  @override
  String get wizardStepTypeTitle => 'What kind of trip?';

  @override
  String get wizardStepTypeBody => 'This decides what goes on your list.';

  @override
  String get wizardStepDetailsTitle => 'Trip details';

  @override
  String get wizardStepExtrasTitle => 'Anything else?';

  @override
  String get wizardStepExtrasBody => 'Optional. Each one adds a few items.';

  @override
  String get wizardNameLabel => 'Trip name';

  @override
  String get wizardNameHint => 'Barcelona weekend';

  @override
  String get wizardNameRequired => 'Give your trip a name';

  @override
  String wizardNameTooLong(int max) {
    return 'Keep it under $max characters';
  }

  @override
  String get wizardDurationLabel => 'How many days?';

  @override
  String wizardDurationValue(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get wizardTravelersLabel => 'Travellers';

  @override
  String get wizardStartDateLabel => 'Start date';

  @override
  String get wizardStartDateHelp => 'Optional. Needed for departure reminders.';

  @override
  String get wizardStartDateNone => 'Not set';

  @override
  String get wizardStartDateClear => 'Clear date';

  @override
  String get wizardOptionSwimming => 'Swimming';

  @override
  String get wizardOptionSwimmingHint => 'Swimwear and a quick-dry towel';

  @override
  String get wizardOptionFormal => 'Formal event';

  @override
  String get wizardOptionFormalHint => 'A formal outfit and dress shoes';

  @override
  String get wizardOptionWork => 'Laptop / work';

  @override
  String get wizardOptionWorkHint => 'Laptop, charger and adapter';

  @override
  String get wizardOptionLaundry => 'Laundry access';

  @override
  String get wizardOptionLaundryHint => 'Packs fewer clothes for long trips';

  @override
  String get wizardSubmit => 'Create packing list';

  @override
  String get wizardSubmitEdit => 'Save changes';

  @override
  String wizardPreview(int count) {
    return 'About $count items';
  }

  @override
  String get listProgressTitle => 'packed';

  @override
  String get listAllPacked => 'All packed. Have a great trip.';

  @override
  String get listNothingPacked => 'Nothing packed yet.';

  @override
  String get listAddItem => 'Add item';

  @override
  String get listAddItemTitle => 'Add an item';

  @override
  String get listEditItemTitle => 'Edit item';

  @override
  String get listItemLabel => 'Item';

  @override
  String get listItemHint => 'Sunglasses';

  @override
  String get listItemRequired => 'Type an item name';

  @override
  String get listQuantity => 'Quantity';

  @override
  String get listSection => 'Section';

  @override
  String get listEssentialToggle => 'Mark as essential';

  @override
  String get listEssentialBadge => 'Essential';

  @override
  String get listItemRemoved => 'Item removed';

  @override
  String listItemLimit(int max) {
    return 'This trip already has the maximum of $max items.';
  }

  @override
  String get listHideChecked => 'Hide packed';

  @override
  String get listShowChecked => 'Show packed';

  @override
  String get listUncheckAll => 'Uncheck everything';

  @override
  String get listUncheckAllDone => 'All items unchecked';

  @override
  String get listMenuEdit => 'Edit trip';

  @override
  String get listMenuTemplate => 'Save as template';

  @override
  String get listMenuRegenerate => 'Rebuild list';

  @override
  String get listRegenerateTitle => 'Rebuild this list?';

  @override
  String get listRegenerateBody =>
      'Every item goes back to the generated list and your ticks are cleared. Items you added yourself are removed.';

  @override
  String get listRegenerateAction => 'Rebuild';

  @override
  String get listRegenerated => 'List rebuilt';

  @override
  String get listEmptyTitle => 'This list is empty';

  @override
  String get listEmptyBody =>
      'Add your first item, or rebuild the list from the trip template.';

  @override
  String get listSwipeDelete => 'Delete';

  @override
  String get listNotFound => 'This trip is no longer available.';

  @override
  String get remindersTitle => 'Departure reminders';

  @override
  String get remindersNeedsDateTitle => 'Set a start date first';

  @override
  String get remindersNeedsDateBody =>
      'Reminders are scheduled from your departure time, so the trip needs a start date.';

  @override
  String get remindersAddDate => 'Add a start date';

  @override
  String get remindersDayBefore => '1 day before';

  @override
  String remindersHoursBefore(int hours) {
    return '$hours hours before';
  }

  @override
  String get remindersDepartureTime => 'Departure time';

  @override
  String remindersScheduledAt(String time) {
    return 'Reminder at $time';
  }

  @override
  String get remindersInThePast => 'This time has already passed';

  @override
  String get remindersBlockedTitle => 'Notifications are turned off';

  @override
  String get remindersBlockedBody =>
      'Valizim cannot show reminders until you allow notifications in iOS Settings.';

  @override
  String get remindersSaved => 'Reminders updated';

  @override
  String notificationTitle(String name) {
    return 'Time to pack for $name';
  }

  @override
  String notificationBodyRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items are still unpacked.',
      one: '1 item is still unpacked.',
    );
    return '$_temp0';
  }

  @override
  String get notificationBodyReady => 'Your list is complete. Safe travels.';

  @override
  String get shareTitle => 'Share list';

  @override
  String get shareAsText => 'Share as text';

  @override
  String get shareAsTextHint => 'Works in any app';

  @override
  String get shareAsImage => 'Share as card';

  @override
  String get shareAsImageHint => 'A picture of your progress';

  @override
  String get shareFailed => 'Sharing is not available right now.';

  @override
  String get shareCardTagline => 'Packed with Valizim';

  @override
  String shareTextHeader(String name) {
    return '$name - packing list';
  }

  @override
  String shareTextMeta(String days, String travelers) {
    return '$days - $travelers';
  }

  @override
  String get shareTextFooter => 'Made with Valizim';

  @override
  String get templatesTitle => 'Templates';

  @override
  String get templatesBuiltIn => 'Built-in';

  @override
  String get templatesCustom => 'My templates';

  @override
  String get templatesCustomEmptyTitle => 'No saved templates';

  @override
  String get templatesCustomEmptyBody =>
      'Open any packing list and choose Save as template to reuse it later.';

  @override
  String get templatesUse => 'Use this template';

  @override
  String get templatesDeleteTitle => 'Delete this template?';

  @override
  String templatesDeleteBody(String name) {
    return '$name will be removed. Trips already created from it are not affected.';
  }

  @override
  String get templatesDeleted => 'Template deleted';

  @override
  String get templateSaveTitle => 'Save as template';

  @override
  String get templateNameLabel => 'Template name';

  @override
  String get templateSaved => 'Template saved';

  @override
  String templatesBuiltInCount(int count) {
    return '$count built-in templates';
  }

  @override
  String get proTitle => 'Valizim Pro';

  @override
  String get proSubtitle => 'One payment. Yours forever.';

  @override
  String get proFreeHeading => 'Always free';

  @override
  String proFreeTrips(int limit) {
    return '$limit saved trips';
  }

  @override
  String get proFreeTemplates => 'All six built-in trip templates';

  @override
  String get proFreeOffline => 'Works completely offline';

  @override
  String get proFreeShareText => 'Share your list as text';

  @override
  String get proUnlockHeading => 'Pro unlocks';

  @override
  String get proUnlockUnlimited => 'Unlimited saved trips';

  @override
  String get proUnlockTemplates => 'Save your own templates';

  @override
  String get proUnlockDuplicate => 'Duplicate and reuse any trip';

  @override
  String get proUnlockShareCard => 'Premium share cards';

  @override
  String get proBuy => 'Unlock Pro';

  @override
  String proBuyPriced(String price) {
    return 'Unlock Pro - $price';
  }

  @override
  String get proRestore => 'Restore purchase';

  @override
  String get proOwnedTitle => 'You have Pro';

  @override
  String get proOwnedBody => 'Thank you for supporting Valizim.';

  @override
  String get proPending => 'Your purchase is waiting for approval.';

  @override
  String get proCancelled => 'Purchase cancelled.';

  @override
  String get proFailed => 'The purchase could not be completed.';

  @override
  String get proRestored => 'Purchase restored. Pro is unlocked.';

  @override
  String get proNothingToRestore =>
      'No previous purchase was found for this Apple Account.';

  @override
  String get proUnavailable => 'The App Store is not available right now.';

  @override
  String get proPriceLoading => 'Loading price';

  @override
  String get proPriceUnavailable => 'Price unavailable';

  @override
  String get proLegalNote =>
      'Payment is charged to your Apple Account. This is a one-time purchase, not a subscription.';

  @override
  String proLimitTitle(int limit) {
    return 'You have used all $limit free trips';
  }

  @override
  String get proLimitBody =>
      'Unlock Pro for unlimited trips, or delete a trip to free a slot.';

  @override
  String get proBadge => 'Pro';

  @override
  String get proLockedDuplicate => 'Duplicating trips is a Pro feature.';

  @override
  String get proLockedTemplates => 'Custom templates are a Pro feature.';

  @override
  String get proLockedShareCard => 'Share cards are a Pro feature.';

  @override
  String get proSeeWhatsIncluded => 'See what\'s included';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSectionDefaults => 'New trip defaults';

  @override
  String get settingsDefaultTravelers => 'Default travellers';

  @override
  String get settingsDefaultDuration => 'Default trip length';

  @override
  String get settingsSectionNotifications => 'Notifications';

  @override
  String get settingsNotificationStatus => 'System permission';

  @override
  String get settingsNotificationAllowed => 'Allowed';

  @override
  String get settingsNotificationBlocked => 'Blocked';

  @override
  String get settingsNotificationNotAsked => 'Not requested yet';

  @override
  String get settingsNotificationBlockedHelp =>
      'Reminders cannot be delivered until notifications are allowed in iOS Settings.';

  @override
  String get settingsSectionData => 'Data';

  @override
  String get settingsResetTemplates => 'Reset new-trip defaults';

  @override
  String get settingsResetTemplatesBody =>
      'Puts the traveller count and trip length back to their original values. Your trips and saved templates are not touched.';

  @override
  String get settingsResetTemplatesDone => 'Defaults reset';

  @override
  String get settingsDeleteAll => 'Delete all app data';

  @override
  String get settingsDeleteAllStep1Title => 'Delete everything?';

  @override
  String get settingsDeleteAllStep1Body =>
      'Every trip, item and saved template is permanently removed from this device.';

  @override
  String get settingsDeleteAllStep2Title => 'This cannot be undone';

  @override
  String settingsDeleteAllStep2Body(String count) {
    return 'There is no backup and no cloud copy. Delete $count anyway?';
  }

  @override
  String get settingsDeleteAllConfirm => 'Delete everything';

  @override
  String get settingsDeleteAllDone => 'All app data deleted';

  @override
  String get settingsSectionAbout => 'About';

  @override
  String settingsVersion(String version, String build) {
    return 'Version $version ($build)';
  }

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsTerms => 'Terms of use';

  @override
  String get settingsContact => 'Contact support';

  @override
  String settingsRulesVersion(int version) {
    return 'Packing rules v$version';
  }

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyHeadline => 'Your trips stay on this device.';

  @override
  String get privacyOnDeviceTitle => 'Stored only on your phone';

  @override
  String get privacyOnDeviceBody =>
      'Trips, items and templates live in a database inside the app. Nothing is uploaded anywhere.';

  @override
  String get privacyNoAccountTitle => 'No account, no tracking';

  @override
  String get privacyNoAccountBody =>
      'Valizim has no sign-in, no analytics and no advertising. It never asks who you are.';

  @override
  String get privacyNotificationsTitle => 'Reminders are local';

  @override
  String get privacyNotificationsBody =>
      'Departure reminders are scheduled by iOS on this device. No server sends them.';

  @override
  String get privacyPurchaseTitle => 'Purchases go through Apple';

  @override
  String get privacyPurchaseBody =>
      'If you unlock Pro, Apple handles the payment and tells the app whether you own it. Valizim never sees your payment details.';

  @override
  String get privacySharingTitle => 'Sharing is up to you';

  @override
  String get privacySharingBody =>
      'A list leaves the device only when you tap share, and only the trip name, items and progress are included.';

  @override
  String get privacyOpenPolicy => 'Read the full privacy policy';

  @override
  String get privacyLinkFailed => 'Could not open the link.';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get errorSaveFailed => 'Could not save your changes.';

  @override
  String get stepperDecrease => 'Decrease';

  @override
  String get stepperIncrease => 'Increase';
}
