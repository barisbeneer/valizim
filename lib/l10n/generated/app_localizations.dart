import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Brand name. Not translated.
  ///
  /// In en, this message translates to:
  /// **'Valizim'**
  String get appTitle;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @actionNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get actionNext;

  /// No description provided for @actionBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get actionBack;

  /// No description provided for @actionClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// No description provided for @actionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// No description provided for @actionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get actionEdit;

  /// No description provided for @actionShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get actionShare;

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @actionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get actionContinue;

  /// No description provided for @actionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get actionNotNow;

  /// No description provided for @actionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get actionOpenSettings;

  /// No description provided for @actionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get actionRemove;

  /// No description provided for @actionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionTryAgain;

  /// No description provided for @tripTypeBeach.
  ///
  /// In en, this message translates to:
  /// **'Beach'**
  String get tripTypeBeach;

  /// No description provided for @tripTypeBeachHint.
  ///
  /// In en, this message translates to:
  /// **'Sun, sand and swimming'**
  String get tripTypeBeachHint;

  /// No description provided for @tripTypeCity.
  ///
  /// In en, this message translates to:
  /// **'City break'**
  String get tripTypeCity;

  /// No description provided for @tripTypeCityHint.
  ///
  /// In en, this message translates to:
  /// **'Walking, cafés and museums'**
  String get tripTypeCityHint;

  /// No description provided for @tripTypeBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get tripTypeBusiness;

  /// No description provided for @tripTypeBusinessHint.
  ///
  /// In en, this message translates to:
  /// **'Meetings and smart clothes'**
  String get tripTypeBusinessHint;

  /// No description provided for @tripTypeCamping.
  ///
  /// In en, this message translates to:
  /// **'Camping'**
  String get tripTypeCamping;

  /// No description provided for @tripTypeCampingHint.
  ///
  /// In en, this message translates to:
  /// **'Outdoors and self-sufficient'**
  String get tripTypeCampingHint;

  /// No description provided for @tripTypeWinter.
  ///
  /// In en, this message translates to:
  /// **'Winter'**
  String get tripTypeWinter;

  /// No description provided for @tripTypeWinterHint.
  ///
  /// In en, this message translates to:
  /// **'Cold weather and layers'**
  String get tripTypeWinterHint;

  /// No description provided for @tripTypeGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get tripTypeGeneral;

  /// No description provided for @tripTypeGeneralHint.
  ///
  /// In en, this message translates to:
  /// **'The essentials, nothing extra'**
  String get tripTypeGeneralHint;

  /// No description provided for @categoryDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get categoryDocuments;

  /// No description provided for @categoryClothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get categoryClothing;

  /// No description provided for @categoryToiletries.
  ///
  /// In en, this message translates to:
  /// **'Toiletries'**
  String get categoryToiletries;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get categoryElectronics;

  /// No description provided for @categoryGear.
  ///
  /// In en, this message translates to:
  /// **'Gear'**
  String get categoryGear;

  /// No description provided for @categoryMisc.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryMisc;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'My trips'**
  String get homeTitle;

  /// No description provided for @homeCreateTrip.
  ///
  /// In en, this message translates to:
  /// **'Plan a trip'**
  String get homeCreateTrip;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No trips yet'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a trip and Valizim builds the packing list for you. No account, no internet needed.'**
  String get homeEmptyBody;

  /// No description provided for @homeEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Plan your first trip'**
  String get homeEmptyAction;

  /// No description provided for @homeSectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get homeSectionUpcoming;

  /// No description provided for @homeSectionPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get homeSectionPast;

  /// No description provided for @homeSectionUndated.
  ///
  /// In en, this message translates to:
  /// **'No date yet'**
  String get homeSectionUndated;

  /// No description provided for @homeStartsToday.
  ///
  /// In en, this message translates to:
  /// **'Starts today'**
  String get homeStartsToday;

  /// No description provided for @homeStartsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Starts tomorrow'**
  String get homeStartsTomorrow;

  /// Countdown to a trip that starts in more than one day.
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String homeStartsInDays(int days);

  /// No description provided for @homeStartedDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String homeStartedDaysAgo(int days);

  /// No description provided for @homeFreeTripsUsed.
  ///
  /// In en, this message translates to:
  /// **'{used} of {limit} free trips used'**
  String homeFreeTripsUsed(int used, int limit);

  /// No description provided for @homeMenuDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get homeMenuDuplicate;

  /// No description provided for @homeMenuArchive.
  ///
  /// In en, this message translates to:
  /// **'Move to past'**
  String get homeMenuArchive;

  /// No description provided for @homeMenuUnarchive.
  ///
  /// In en, this message translates to:
  /// **'Move to upcoming'**
  String get homeMenuUnarchive;

  /// No description provided for @homeMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete trip'**
  String get homeMenuDelete;

  /// No description provided for @homeDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this trip?'**
  String get homeDeleteTitle;

  /// No description provided for @homeDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{name} and all of its items will be removed from this device.'**
  String homeDeleteBody(String name);

  /// No description provided for @homeTripDeleted.
  ///
  /// In en, this message translates to:
  /// **'Trip deleted'**
  String get homeTripDeleted;

  /// No description provided for @homeTripArchived.
  ///
  /// In en, this message translates to:
  /// **'Moved to past'**
  String get homeTripArchived;

  /// No description provided for @homeTripRestored.
  ///
  /// In en, this message translates to:
  /// **'Moved to upcoming'**
  String get homeTripRestored;

  /// No description provided for @homeCopySuffix.
  ///
  /// In en, this message translates to:
  /// **'{name} (copy)'**
  String homeCopySuffix(String name);

  /// No description provided for @homeTripDuplicated.
  ///
  /// In en, this message translates to:
  /// **'Trip duplicated'**
  String get homeTripDuplicated;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String daysCount(int days);

  /// No description provided for @travelersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 traveller} other{{count} travellers}}'**
  String travelersCount(int count);

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// No description provided for @packedOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{packed} of {total} packed'**
  String packedOfTotal(int packed, int total);

  /// No description provided for @remainingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item left} other{{count} items left}}'**
  String remainingCount(int count);

  /// No description provided for @wizardTitle.
  ///
  /// In en, this message translates to:
  /// **'New trip'**
  String get wizardTitle;

  /// No description provided for @wizardEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit trip'**
  String get wizardEditTitle;

  /// No description provided for @wizardStepTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'What kind of trip?'**
  String get wizardStepTypeTitle;

  /// No description provided for @wizardStepTypeBody.
  ///
  /// In en, this message translates to:
  /// **'This decides what goes on your list.'**
  String get wizardStepTypeBody;

  /// No description provided for @wizardStepDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Trip details'**
  String get wizardStepDetailsTitle;

  /// No description provided for @wizardStepExtrasTitle.
  ///
  /// In en, this message translates to:
  /// **'Anything else?'**
  String get wizardStepExtrasTitle;

  /// No description provided for @wizardStepExtrasBody.
  ///
  /// In en, this message translates to:
  /// **'Optional. Each one adds a few items.'**
  String get wizardStepExtrasBody;

  /// No description provided for @wizardNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Trip name'**
  String get wizardNameLabel;

  /// No description provided for @wizardNameHint.
  ///
  /// In en, this message translates to:
  /// **'Barcelona weekend'**
  String get wizardNameHint;

  /// No description provided for @wizardNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give your trip a name'**
  String get wizardNameRequired;

  /// No description provided for @wizardNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep it under {max} characters'**
  String wizardNameTooLong(int max);

  /// No description provided for @wizardDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'How many days?'**
  String get wizardDurationLabel;

  /// No description provided for @wizardDurationValue.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}'**
  String wizardDurationValue(int days);

  /// No description provided for @wizardTravelersLabel.
  ///
  /// In en, this message translates to:
  /// **'Travellers'**
  String get wizardTravelersLabel;

  /// No description provided for @wizardStartDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get wizardStartDateLabel;

  /// No description provided for @wizardStartDateHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. Needed for departure reminders.'**
  String get wizardStartDateHelp;

  /// No description provided for @wizardStartDateNone.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get wizardStartDateNone;

  /// No description provided for @wizardStartDateClear.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get wizardStartDateClear;

  /// No description provided for @wizardOptionSwimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get wizardOptionSwimming;

  /// No description provided for @wizardOptionSwimmingHint.
  ///
  /// In en, this message translates to:
  /// **'Swimwear and a quick-dry towel'**
  String get wizardOptionSwimmingHint;

  /// No description provided for @wizardOptionFormal.
  ///
  /// In en, this message translates to:
  /// **'Formal event'**
  String get wizardOptionFormal;

  /// No description provided for @wizardOptionFormalHint.
  ///
  /// In en, this message translates to:
  /// **'A formal outfit and dress shoes'**
  String get wizardOptionFormalHint;

  /// No description provided for @wizardOptionWork.
  ///
  /// In en, this message translates to:
  /// **'Laptop / work'**
  String get wizardOptionWork;

  /// No description provided for @wizardOptionWorkHint.
  ///
  /// In en, this message translates to:
  /// **'Laptop, charger and adapter'**
  String get wizardOptionWorkHint;

  /// No description provided for @wizardOptionLaundry.
  ///
  /// In en, this message translates to:
  /// **'Laundry access'**
  String get wizardOptionLaundry;

  /// No description provided for @wizardOptionLaundryHint.
  ///
  /// In en, this message translates to:
  /// **'Packs fewer clothes for long trips'**
  String get wizardOptionLaundryHint;

  /// No description provided for @wizardSubmit.
  ///
  /// In en, this message translates to:
  /// **'Create packing list'**
  String get wizardSubmit;

  /// No description provided for @wizardSubmitEdit.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get wizardSubmitEdit;

  /// No description provided for @wizardPreview.
  ///
  /// In en, this message translates to:
  /// **'About {count} items'**
  String wizardPreview(int count);

  /// No description provided for @listProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'packed'**
  String get listProgressTitle;

  /// No description provided for @listAllPacked.
  ///
  /// In en, this message translates to:
  /// **'All packed. Have a great trip.'**
  String get listAllPacked;

  /// No description provided for @listNothingPacked.
  ///
  /// In en, this message translates to:
  /// **'Nothing packed yet.'**
  String get listNothingPacked;

  /// No description provided for @listAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get listAddItem;

  /// No description provided for @listAddItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Add an item'**
  String get listAddItemTitle;

  /// No description provided for @listEditItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get listEditItemTitle;

  /// No description provided for @listItemLabel.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get listItemLabel;

  /// No description provided for @listItemHint.
  ///
  /// In en, this message translates to:
  /// **'Sunglasses'**
  String get listItemHint;

  /// No description provided for @listItemRequired.
  ///
  /// In en, this message translates to:
  /// **'Type an item name'**
  String get listItemRequired;

  /// No description provided for @listQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get listQuantity;

  /// No description provided for @listSection.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get listSection;

  /// No description provided for @listEssentialToggle.
  ///
  /// In en, this message translates to:
  /// **'Mark as essential'**
  String get listEssentialToggle;

  /// No description provided for @listEssentialBadge.
  ///
  /// In en, this message translates to:
  /// **'Essential'**
  String get listEssentialBadge;

  /// No description provided for @listItemRemoved.
  ///
  /// In en, this message translates to:
  /// **'Item removed'**
  String get listItemRemoved;

  /// No description provided for @listItemLimit.
  ///
  /// In en, this message translates to:
  /// **'This trip already has the maximum of {max} items.'**
  String listItemLimit(int max);

  /// No description provided for @listHideChecked.
  ///
  /// In en, this message translates to:
  /// **'Hide packed'**
  String get listHideChecked;

  /// No description provided for @listShowChecked.
  ///
  /// In en, this message translates to:
  /// **'Show packed'**
  String get listShowChecked;

  /// No description provided for @listUncheckAll.
  ///
  /// In en, this message translates to:
  /// **'Uncheck everything'**
  String get listUncheckAll;

  /// No description provided for @listUncheckAllDone.
  ///
  /// In en, this message translates to:
  /// **'All items unchecked'**
  String get listUncheckAllDone;

  /// No description provided for @listMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit trip'**
  String get listMenuEdit;

  /// No description provided for @listMenuTemplate.
  ///
  /// In en, this message translates to:
  /// **'Save as template'**
  String get listMenuTemplate;

  /// No description provided for @listMenuRegenerate.
  ///
  /// In en, this message translates to:
  /// **'Rebuild list'**
  String get listMenuRegenerate;

  /// No description provided for @listRegenerateTitle.
  ///
  /// In en, this message translates to:
  /// **'Rebuild this list?'**
  String get listRegenerateTitle;

  /// No description provided for @listRegenerateBody.
  ///
  /// In en, this message translates to:
  /// **'Every item goes back to the generated list and your ticks are cleared. Items you added yourself are removed.'**
  String get listRegenerateBody;

  /// No description provided for @listRegenerateAction.
  ///
  /// In en, this message translates to:
  /// **'Rebuild'**
  String get listRegenerateAction;

  /// No description provided for @listRegenerated.
  ///
  /// In en, this message translates to:
  /// **'List rebuilt'**
  String get listRegenerated;

  /// No description provided for @listEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'This list is empty'**
  String get listEmptyTitle;

  /// No description provided for @listEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add your first item, or rebuild the list from the trip template.'**
  String get listEmptyBody;

  /// No description provided for @listSwipeDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get listSwipeDelete;

  /// No description provided for @listNotFound.
  ///
  /// In en, this message translates to:
  /// **'This trip is no longer available.'**
  String get listNotFound;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Departure reminders'**
  String get remindersTitle;

  /// No description provided for @remindersNeedsDateTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a start date first'**
  String get remindersNeedsDateTitle;

  /// No description provided for @remindersNeedsDateBody.
  ///
  /// In en, this message translates to:
  /// **'Reminders are scheduled from your departure time, so the trip needs a start date.'**
  String get remindersNeedsDateBody;

  /// No description provided for @remindersAddDate.
  ///
  /// In en, this message translates to:
  /// **'Add a start date'**
  String get remindersAddDate;

  /// No description provided for @remindersDayBefore.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get remindersDayBefore;

  /// No description provided for @remindersHoursBefore.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours before'**
  String remindersHoursBefore(int hours);

  /// No description provided for @remindersDepartureTime.
  ///
  /// In en, this message translates to:
  /// **'Departure time'**
  String get remindersDepartureTime;

  /// No description provided for @remindersScheduledAt.
  ///
  /// In en, this message translates to:
  /// **'Reminder at {time}'**
  String remindersScheduledAt(String time);

  /// No description provided for @remindersInThePast.
  ///
  /// In en, this message translates to:
  /// **'This time has already passed'**
  String get remindersInThePast;

  /// No description provided for @remindersBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off'**
  String get remindersBlockedTitle;

  /// No description provided for @remindersBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'Valizim cannot show reminders until you allow notifications in iOS Settings.'**
  String get remindersBlockedBody;

  /// No description provided for @remindersSaved.
  ///
  /// In en, this message translates to:
  /// **'Reminders updated'**
  String get remindersSaved;

  /// Local notification title.
  ///
  /// In en, this message translates to:
  /// **'Time to pack for {name}'**
  String notificationTitle(String name);

  /// No description provided for @notificationBodyRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item is still unpacked.} other{{count} items are still unpacked.}}'**
  String notificationBodyRemaining(int count);

  /// No description provided for @notificationBodyReady.
  ///
  /// In en, this message translates to:
  /// **'Your list is complete. Safe travels.'**
  String get notificationBodyReady;

  /// No description provided for @shareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share list'**
  String get shareTitle;

  /// No description provided for @shareAsText.
  ///
  /// In en, this message translates to:
  /// **'Share as text'**
  String get shareAsText;

  /// No description provided for @shareAsTextHint.
  ///
  /// In en, this message translates to:
  /// **'Works in any app'**
  String get shareAsTextHint;

  /// No description provided for @shareAsImage.
  ///
  /// In en, this message translates to:
  /// **'Share as card'**
  String get shareAsImage;

  /// No description provided for @shareAsImageHint.
  ///
  /// In en, this message translates to:
  /// **'A picture of your progress'**
  String get shareAsImageHint;

  /// No description provided for @shareFailed.
  ///
  /// In en, this message translates to:
  /// **'Sharing is not available right now.'**
  String get shareFailed;

  /// No description provided for @shareCardTagline.
  ///
  /// In en, this message translates to:
  /// **'Packed with Valizim'**
  String get shareCardTagline;

  /// No description provided for @shareTextHeader.
  ///
  /// In en, this message translates to:
  /// **'{name} - packing list'**
  String shareTextHeader(String name);

  /// Line combining the already-formatted day and traveller counts.
  ///
  /// In en, this message translates to:
  /// **'{days} - {travelers}'**
  String shareTextMeta(String days, String travelers);

  /// No description provided for @shareTextFooter.
  ///
  /// In en, this message translates to:
  /// **'Made with Valizim'**
  String get shareTextFooter;

  /// No description provided for @templatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templatesTitle;

  /// No description provided for @templatesBuiltIn.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get templatesBuiltIn;

  /// No description provided for @templatesCustom.
  ///
  /// In en, this message translates to:
  /// **'My templates'**
  String get templatesCustom;

  /// No description provided for @templatesCustomEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved templates'**
  String get templatesCustomEmptyTitle;

  /// No description provided for @templatesCustomEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Open any packing list and choose Save as template to reuse it later.'**
  String get templatesCustomEmptyBody;

  /// No description provided for @templatesUse.
  ///
  /// In en, this message translates to:
  /// **'Use this template'**
  String get templatesUse;

  /// No description provided for @templatesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this template?'**
  String get templatesDeleteTitle;

  /// No description provided for @templatesDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed. Trips already created from it are not affected.'**
  String templatesDeleteBody(String name);

  /// No description provided for @templatesDeleted.
  ///
  /// In en, this message translates to:
  /// **'Template deleted'**
  String get templatesDeleted;

  /// No description provided for @templateSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save as template'**
  String get templateSaveTitle;

  /// No description provided for @templateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Template name'**
  String get templateNameLabel;

  /// No description provided for @templateSaved.
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get templateSaved;

  /// No description provided for @templatesBuiltInCount.
  ///
  /// In en, this message translates to:
  /// **'{count} built-in templates'**
  String templatesBuiltInCount(int count);

  /// No description provided for @proTitle.
  ///
  /// In en, this message translates to:
  /// **'Valizim Pro'**
  String get proTitle;

  /// No description provided for @proSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One payment. Yours forever.'**
  String get proSubtitle;

  /// No description provided for @proFreeHeading.
  ///
  /// In en, this message translates to:
  /// **'Always free'**
  String get proFreeHeading;

  /// No description provided for @proFreeTrips.
  ///
  /// In en, this message translates to:
  /// **'{limit} saved trips'**
  String proFreeTrips(int limit);

  /// No description provided for @proFreeTemplates.
  ///
  /// In en, this message translates to:
  /// **'All six built-in trip templates'**
  String get proFreeTemplates;

  /// No description provided for @proFreeOffline.
  ///
  /// In en, this message translates to:
  /// **'Works completely offline'**
  String get proFreeOffline;

  /// No description provided for @proFreeShareText.
  ///
  /// In en, this message translates to:
  /// **'Share your list as text'**
  String get proFreeShareText;

  /// No description provided for @proUnlockHeading.
  ///
  /// In en, this message translates to:
  /// **'Pro unlocks'**
  String get proUnlockHeading;

  /// No description provided for @proUnlockUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited saved trips'**
  String get proUnlockUnlimited;

  /// No description provided for @proUnlockTemplates.
  ///
  /// In en, this message translates to:
  /// **'Save your own templates'**
  String get proUnlockTemplates;

  /// No description provided for @proUnlockDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate and reuse any trip'**
  String get proUnlockDuplicate;

  /// No description provided for @proUnlockShareCard.
  ///
  /// In en, this message translates to:
  /// **'Premium share cards'**
  String get proUnlockShareCard;

  /// No description provided for @proBuy.
  ///
  /// In en, this message translates to:
  /// **'Unlock Pro'**
  String get proBuy;

  /// No description provided for @proBuyPriced.
  ///
  /// In en, this message translates to:
  /// **'Unlock Pro - {price}'**
  String proBuyPriced(String price);

  /// No description provided for @proRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get proRestore;

  /// No description provided for @proOwnedTitle.
  ///
  /// In en, this message translates to:
  /// **'You have Pro'**
  String get proOwnedTitle;

  /// No description provided for @proOwnedBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting Valizim.'**
  String get proOwnedBody;

  /// No description provided for @proPending.
  ///
  /// In en, this message translates to:
  /// **'Your purchase is waiting for approval.'**
  String get proPending;

  /// No description provided for @proCancelled.
  ///
  /// In en, this message translates to:
  /// **'Purchase cancelled.'**
  String get proCancelled;

  /// No description provided for @proFailed.
  ///
  /// In en, this message translates to:
  /// **'The purchase could not be completed.'**
  String get proFailed;

  /// No description provided for @proRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchase restored. Pro is unlocked.'**
  String get proRestored;

  /// No description provided for @proNothingToRestore.
  ///
  /// In en, this message translates to:
  /// **'No previous purchase was found for this Apple Account.'**
  String get proNothingToRestore;

  /// No description provided for @proUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The App Store is not available right now.'**
  String get proUnavailable;

  /// No description provided for @proPriceLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading price'**
  String get proPriceLoading;

  /// No description provided for @proPriceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Price unavailable'**
  String get proPriceUnavailable;

  /// No description provided for @proLegalNote.
  ///
  /// In en, this message translates to:
  /// **'Payment is charged to your Apple Account. This is a one-time purchase, not a subscription.'**
  String get proLegalNote;

  /// No description provided for @proLimitTitle.
  ///
  /// In en, this message translates to:
  /// **'You have used all {limit} free trips'**
  String proLimitTitle(int limit);

  /// No description provided for @proLimitBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock Pro for unlimited trips, or delete a trip to free a slot.'**
  String get proLimitBody;

  /// No description provided for @proBadge.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get proBadge;

  /// No description provided for @proLockedDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicating trips is a Pro feature.'**
  String get proLockedDuplicate;

  /// No description provided for @proLockedTemplates.
  ///
  /// In en, this message translates to:
  /// **'Custom templates are a Pro feature.'**
  String get proLockedTemplates;

  /// No description provided for @proLockedShareCard.
  ///
  /// In en, this message translates to:
  /// **'Share cards are a Pro feature.'**
  String get proLockedShareCard;

  /// No description provided for @proSeeWhatsIncluded.
  ///
  /// In en, this message translates to:
  /// **'See what\'s included'**
  String get proSeeWhatsIncluded;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSectionDefaults.
  ///
  /// In en, this message translates to:
  /// **'New trip defaults'**
  String get settingsSectionDefaults;

  /// No description provided for @settingsDefaultTravelers.
  ///
  /// In en, this message translates to:
  /// **'Default travellers'**
  String get settingsDefaultTravelers;

  /// No description provided for @settingsDefaultDuration.
  ///
  /// In en, this message translates to:
  /// **'Default trip length'**
  String get settingsDefaultDuration;

  /// No description provided for @settingsSectionNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsSectionNotifications;

  /// No description provided for @settingsNotificationStatus.
  ///
  /// In en, this message translates to:
  /// **'System permission'**
  String get settingsNotificationStatus;

  /// No description provided for @settingsNotificationAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get settingsNotificationAllowed;

  /// No description provided for @settingsNotificationBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get settingsNotificationBlocked;

  /// No description provided for @settingsNotificationNotAsked.
  ///
  /// In en, this message translates to:
  /// **'Not requested yet'**
  String get settingsNotificationNotAsked;

  /// No description provided for @settingsNotificationBlockedHelp.
  ///
  /// In en, this message translates to:
  /// **'Reminders cannot be delivered until notifications are allowed in iOS Settings.'**
  String get settingsNotificationBlockedHelp;

  /// No description provided for @settingsSectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsSectionData;

  /// No description provided for @settingsResetTemplates.
  ///
  /// In en, this message translates to:
  /// **'Reset new-trip defaults'**
  String get settingsResetTemplates;

  /// No description provided for @settingsResetTemplatesBody.
  ///
  /// In en, this message translates to:
  /// **'Puts the traveller count and trip length back to their original values. Your trips and saved templates are not touched.'**
  String get settingsResetTemplatesBody;

  /// No description provided for @settingsResetTemplatesDone.
  ///
  /// In en, this message translates to:
  /// **'Defaults reset'**
  String get settingsResetTemplatesDone;

  /// No description provided for @settingsDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all app data'**
  String get settingsDeleteAll;

  /// No description provided for @settingsDeleteAllStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Delete everything?'**
  String get settingsDeleteAllStep1Title;

  /// No description provided for @settingsDeleteAllStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Every trip, item and saved template is permanently removed from this device.'**
  String get settingsDeleteAllStep1Body;

  /// No description provided for @settingsDeleteAllStep2Title.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone'**
  String get settingsDeleteAllStep2Title;

  /// No description provided for @settingsDeleteAllStep2Body.
  ///
  /// In en, this message translates to:
  /// **'There is no backup and no cloud copy. Delete {count} anyway?'**
  String settingsDeleteAllStep2Body(String count);

  /// No description provided for @settingsDeleteAllConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete everything'**
  String get settingsDeleteAllConfirm;

  /// No description provided for @settingsDeleteAllDone.
  ///
  /// In en, this message translates to:
  /// **'All app data deleted'**
  String get settingsDeleteAllDone;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsSectionAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({build})'**
  String settingsVersion(String version, String build);

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get settingsTerms;

  /// No description provided for @settingsContact.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get settingsContact;

  /// No description provided for @settingsRulesVersion.
  ///
  /// In en, this message translates to:
  /// **'Packing rules v{version}'**
  String settingsRulesVersion(int version);

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @privacyHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your trips stay on this device.'**
  String get privacyHeadline;

  /// No description provided for @privacyOnDeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Stored only on your phone'**
  String get privacyOnDeviceTitle;

  /// No description provided for @privacyOnDeviceBody.
  ///
  /// In en, this message translates to:
  /// **'Trips, items and templates live in a database inside the app. Nothing is uploaded anywhere.'**
  String get privacyOnDeviceBody;

  /// No description provided for @privacyNoAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'No account, no tracking'**
  String get privacyNoAccountTitle;

  /// No description provided for @privacyNoAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Valizim has no sign-in, no analytics and no advertising. It never asks who you are.'**
  String get privacyNoAccountBody;

  /// No description provided for @privacyNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders are local'**
  String get privacyNotificationsTitle;

  /// No description provided for @privacyNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'Departure reminders are scheduled by iOS on this device. No server sends them.'**
  String get privacyNotificationsBody;

  /// No description provided for @privacyPurchaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Purchases go through Apple'**
  String get privacyPurchaseTitle;

  /// No description provided for @privacyPurchaseBody.
  ///
  /// In en, this message translates to:
  /// **'If you unlock Pro, Apple handles the payment and tells the app whether you own it. Valizim never sees your payment details.'**
  String get privacyPurchaseBody;

  /// No description provided for @privacySharingTitle.
  ///
  /// In en, this message translates to:
  /// **'Sharing is up to you'**
  String get privacySharingTitle;

  /// No description provided for @privacySharingBody.
  ///
  /// In en, this message translates to:
  /// **'A list leaves the device only when you tap share, and only the trip name, items and progress are included.'**
  String get privacySharingBody;

  /// No description provided for @privacyOpenPolicy.
  ///
  /// In en, this message translates to:
  /// **'Read the full privacy policy'**
  String get privacyOpenPolicy;

  /// No description provided for @privacyLinkFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get privacyLinkFailed;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorGeneric;

  /// No description provided for @errorSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your changes.'**
  String get errorSaveFailed;

  /// No description provided for @stepperDecrease.
  ///
  /// In en, this message translates to:
  /// **'Decrease'**
  String get stepperDecrease;

  /// No description provided for @stepperIncrease.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get stepperIncrease;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'tr':
      return AppL10nTr();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
