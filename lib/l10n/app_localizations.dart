import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('de'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Time Tracker Gothic'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @aboutMeTitle.
  ///
  /// In en, this message translates to:
  /// **'About Me'**
  String get aboutMeTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @resetEverything.
  ///
  /// In en, this message translates to:
  /// **'Reset Everything'**
  String get resetEverything;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @employerAddress.
  ///
  /// In en, this message translates to:
  /// **'Employer Address'**
  String get employerAddress;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get userName;

  /// No description provided for @requiredWeeklyHours.
  ///
  /// In en, this message translates to:
  /// **'Required Weekly Hours'**
  String get requiredWeeklyHours;

  /// No description provided for @overtimeHours.
  ///
  /// In en, this message translates to:
  /// **'Overtime Hours'**
  String get overtimeHours;

  /// No description provided for @overtimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'Overtime Minutes'**
  String get overtimeMinutes;

  /// No description provided for @vacationCarried.
  ///
  /// In en, this message translates to:
  /// **'Vacation Carried from Last Year'**
  String get vacationCarried;

  /// No description provided for @vacationThisYear.
  ///
  /// In en, this message translates to:
  /// **'Vacation for This Year'**
  String get vacationThisYear;

  /// No description provided for @vacationTaken.
  ///
  /// In en, this message translates to:
  /// **'Vacation Already Taken'**
  String get vacationTaken;

  /// No description provided for @vacationPlanned.
  ///
  /// In en, this message translates to:
  /// **'Vacation Planned'**
  String get vacationPlanned;

  /// No description provided for @regularBreakDuration.
  ///
  /// In en, this message translates to:
  /// **'Regular Break Duration (minutes)'**
  String get regularBreakDuration;

  /// No description provided for @vacationLeftAfterTaken.
  ///
  /// In en, this message translates to:
  /// **'Vacation left after taken'**
  String get vacationLeftAfterTaken;

  /// No description provided for @vacationLeftAfterPlanned.
  ///
  /// In en, this message translates to:
  /// **'Vacation left after taken & planned'**
  String get vacationLeftAfterPlanned;

  /// No description provided for @confirmResetTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Reset'**
  String get confirmResetTitle;

  /// No description provided for @confirmResetMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete ALL your data including punch times and settings. Are you sure?'**
  String get confirmResetMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteEverything.
  ///
  /// In en, this message translates to:
  /// **'Delete Everything'**
  String get deleteEverything;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @mustBeNumber.
  ///
  /// In en, this message translates to:
  /// **'Must be a number'**
  String get mustBeNumber;

  /// No description provided for @dataSaved.
  ///
  /// In en, this message translates to:
  /// **'Data saved'**
  String get dataSaved;

  /// No description provided for @allDataReset.
  ///
  /// In en, this message translates to:
  /// **'All data reset'**
  String get allDataReset;

  /// No description provided for @selectDayPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a day to begin'**
  String get selectDayPrompt;

  /// No description provided for @selectedDate.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selectedDate;

  /// No description provided for @punchInOut.
  ///
  /// In en, this message translates to:
  /// **'Punch In / Out'**
  String get punchInOut;

  /// No description provided for @addManualTime.
  ///
  /// In en, this message translates to:
  /// **'Add Manual Time'**
  String get addManualTime;

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'No entries for this day.'**
  String get noEntries;

  /// No description provided for @inLabel.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get inLabel;

  /// No description provided for @outLabel.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get outLabel;

  /// No description provided for @breakLabel.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get breakLabel;

  /// No description provided for @workedLabel.
  ///
  /// In en, this message translates to:
  /// **'Worked'**
  String get workedLabel;

  /// No description provided for @errorPunchOutBeforeIn.
  ///
  /// In en, this message translates to:
  /// **'Punch out must be after punch in'**
  String get errorPunchOutBeforeIn;

  /// No description provided for @entriesForDay.
  ///
  /// In en, this message translates to:
  /// **'Entries for'**
  String get entriesForDay;

  /// No description provided for @manualFullDay.
  ///
  /// In en, this message translates to:
  /// **'Manual / Full Day'**
  String get manualFullDay;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit Entry'**
  String get editEntry;

  /// No description provided for @deleteEntry.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get deleteEntry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @manualEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Time Entry'**
  String get manualEntryTitle;

  /// No description provided for @punchInTime.
  ///
  /// In en, this message translates to:
  /// **'Punch In Time'**
  String get punchInTime;

  /// No description provided for @punchOutTime.
  ///
  /// In en, this message translates to:
  /// **'Punch Out Time'**
  String get punchOutTime;

  /// No description provided for @breakInMinutes.
  ///
  /// In en, this message translates to:
  /// **'Break (minutes)'**
  String get breakInMinutes;

  /// No description provided for @entryType.
  ///
  /// In en, this message translates to:
  /// **'Entry Type'**
  String get entryType;

  /// No description provided for @giftedHours.
  ///
  /// In en, this message translates to:
  /// **'Gifted Hours'**
  String get giftedHours;

  /// No description provided for @errorSelectPunchTimes.
  ///
  /// In en, this message translates to:
  /// **'Please select punch in and out times'**
  String get errorSelectPunchTimes;

  /// No description provided for @errorGiftedHoursRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter gifted hours'**
  String get errorGiftedHoursRequired;

  /// No description provided for @errorOvertimeTakenRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter overtime taken (hours)'**
  String get errorOvertimeTakenRequired;

  /// No description provided for @entryTypeLabelRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get entryTypeLabelRegular;

  /// No description provided for @entryTypeLabelSickDay.
  ///
  /// In en, this message translates to:
  /// **'Sick Day'**
  String get entryTypeLabelSickDay;

  /// No description provided for @entryTypeLabelVacation.
  ///
  /// In en, this message translates to:
  /// **'Vacation'**
  String get entryTypeLabelVacation;

  /// No description provided for @entryTypeLabelGiftedTime.
  ///
  /// In en, this message translates to:
  /// **'Gifted Time'**
  String get entryTypeLabelGiftedTime;

  /// No description provided for @entryTypeLabelPublicHoliday.
  ///
  /// In en, this message translates to:
  /// **'Public Holiday'**
  String get entryTypeLabelPublicHoliday;

  /// No description provided for @entryTypeLabelOvertimeTaken.
  ///
  /// In en, this message translates to:
  /// **'Overtime Taken'**
  String get entryTypeLabelOvertimeTaken;

  /// No description provided for @weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummary;

  /// No description provided for @summaryWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Summary for this week'**
  String get summaryWeekLabel;

  /// No description provided for @summaryExpectedHours.
  ///
  /// In en, this message translates to:
  /// **'Expected Hours: '**
  String get summaryExpectedHours;

  /// No description provided for @summaryActualHours.
  ///
  /// In en, this message translates to:
  /// **'Actual Hours: '**
  String get summaryActualHours;

  /// No description provided for @summaryVacationDays.
  ///
  /// In en, this message translates to:
  /// **'Vacation Days: '**
  String get summaryVacationDays;

  /// No description provided for @summarySickDays.
  ///
  /// In en, this message translates to:
  /// **'Sick Days: '**
  String get summarySickDays;

  /// No description provided for @summaryPublicHolidays.
  ///
  /// In en, this message translates to:
  /// **'Public Holidays: '**
  String get summaryPublicHolidays;

  /// No description provided for @summaryGiftedTime.
  ///
  /// In en, this message translates to:
  /// **'Gifted Time: '**
  String get summaryGiftedTime;

  /// No description provided for @summaryOvertimeWeek.
  ///
  /// In en, this message translates to:
  /// **'Overtime This Week: '**
  String get summaryOvertimeWeek;

  /// No description provided for @summaryOvertimeTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Overtime: '**
  String get summaryOvertimeTotal;

  /// No description provided for @monthlySummary.
  ///
  /// In en, this message translates to:
  /// **'Monthly Summary'**
  String get monthlySummary;

  /// No description provided for @selectMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Select a Month'**
  String get selectMonthLabel;

  /// No description provided for @summaryMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Summary for this month'**
  String get summaryMonthLabel;

  /// No description provided for @summaryOvertimeMonth.
  ///
  /// In en, this message translates to:
  /// **'Overtime This Month: '**
  String get summaryOvertimeMonth;

  /// No description provided for @germanLaborLaw.
  ///
  /// In en, this message translates to:
  /// **'German Labor Law (ArbZG)'**
  String get germanLaborLaw;

  /// No description provided for @germanLaborLawDescription.
  ///
  /// In en, this message translates to:
  /// **'Enforce statutory breaks (>6h: 30m, >9h: 45m)'**
  String get germanLaborLawDescription;

  /// No description provided for @workingDaysPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Working Days per Week'**
  String get workingDaysPerWeek;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
