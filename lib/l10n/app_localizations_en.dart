// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Time Tracker Gothic';

  @override
  String get homeTitle => 'Home';

  @override
  String get aboutMeTitle => 'About Me';

  @override
  String get save => 'Save';

  @override
  String get resetEverything => 'Reset Everything';

  @override
  String get companyName => 'Company Name';

  @override
  String get employerAddress => 'Employer Address';

  @override
  String get userName => 'Your Name';

  @override
  String get requiredWeeklyHours => 'Required Weekly Hours';

  @override
  String get overtimeHours => 'Overtime Hours';

  @override
  String get overtimeMinutes => 'Overtime Minutes';

  @override
  String get vacationCarried => 'Vacation Carried from Last Year';

  @override
  String get vacationThisYear => 'Vacation for This Year';

  @override
  String get vacationTaken => 'Vacation Already Taken';

  @override
  String get vacationPlanned => 'Vacation Planned';

  @override
  String get regularBreakDuration => 'Regular Break Duration (minutes)';

  @override
  String get vacationLeftAfterTaken => 'Vacation left after taken';

  @override
  String get vacationLeftAfterPlanned => 'Vacation left after taken & planned';

  @override
  String get confirmResetTitle => 'Confirm Reset';

  @override
  String get confirmResetMessage =>
      'This will delete ALL your data including punch times and settings. Are you sure?';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteEverything => 'Delete Everything';

  @override
  String get requiredField => 'Required';

  @override
  String get mustBeNumber => 'Must be a number';

  @override
  String get dataSaved => 'Data saved';

  @override
  String get allDataReset => 'All data reset';

  @override
  String get selectDayPrompt => 'Select a day to begin';

  @override
  String get selectedDate => 'Selected';

  @override
  String get punchInOut => 'Punch In / Out';

  @override
  String get addManualTime => 'Add Manual Time';

  @override
  String get noEntries => 'No entries for this day.';

  @override
  String get inLabel => 'In';

  @override
  String get outLabel => 'Out';

  @override
  String get breakLabel => 'Break';

  @override
  String get workedLabel => 'Worked';

  @override
  String get errorPunchOutBeforeIn => 'Punch out must be after punch in';

  @override
  String get entriesForDay => 'Entries for';

  @override
  String get manualFullDay => 'Manual / Full Day';

  @override
  String get editEntry => 'Edit Entry';

  @override
  String get deleteEntry => 'Delete Entry';

  @override
  String get close => 'Close';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get notSet => 'Not set';

  @override
  String get manualEntryTitle => 'Manual Time Entry';

  @override
  String get punchInTime => 'Punch In Time';

  @override
  String get punchOutTime => 'Punch Out Time';

  @override
  String get breakInMinutes => 'Break (minutes)';

  @override
  String get entryType => 'Entry Type';

  @override
  String get giftedHours => 'Gifted Hours';

  @override
  String get errorSelectPunchTimes => 'Please select punch in and out times';

  @override
  String get errorGiftedHoursRequired => 'Please enter gifted hours';

  @override
  String get errorOvertimeTakenRequired =>
      'Please enter overtime taken (hours)';

  @override
  String get entryTypeLabelRegular => 'Regular';

  @override
  String get entryTypeLabelSickDay => 'Sick Day';

  @override
  String get entryTypeLabelVacation => 'Vacation';

  @override
  String get entryTypeLabelGiftedTime => 'Gifted Time';

  @override
  String get entryTypeLabelPublicHoliday => 'Public Holiday';

  @override
  String get entryTypeLabelOvertimeTaken => 'Overtime Taken';

  @override
  String get weeklySummary => 'Weekly Summary';

  @override
  String get summaryWeekLabel => 'Summary for this week';

  @override
  String get summaryExpectedHours => 'Expected Hours: ';

  @override
  String get summaryActualHours => 'Actual Hours: ';

  @override
  String get summaryVacationDays => 'Vacation Days: ';

  @override
  String get summarySickDays => 'Sick Days: ';

  @override
  String get summaryPublicHolidays => 'Public Holidays: ';

  @override
  String get summaryGiftedTime => 'Gifted Time: ';

  @override
  String get summaryOvertimeWeek => 'Overtime This Week: ';

  @override
  String get summaryOvertimeTotal => 'Total Overtime: ';

  @override
  String get monthlySummary => 'Monthly Summary';

  @override
  String get selectMonthLabel => 'Select a Month';

  @override
  String get summaryMonthLabel => 'Summary for this month';

  @override
  String get summaryOvertimeMonth => 'Overtime This Month: ';

  @override
  String get germanLaborLaw => 'German Labor Law (ArbZG)';

  @override
  String get germanLaborLawDescription =>
      'Enforce statutory breaks (>6h: 30m, >9h: 45m)';

  @override
  String get workingDaysPerWeek => 'Working Days per Week';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get pdfSavedSuccessfully => 'PDF saved successfully to:';

  @override
  String get timesheetReport => 'Timesheet Report';

  @override
  String get employee => 'Employee';

  @override
  String get period => 'Period';

  @override
  String get signatureEmployee => 'Employee Signature & Date';

  @override
  String get signatureManager => 'Manager Signature & Date';
}
