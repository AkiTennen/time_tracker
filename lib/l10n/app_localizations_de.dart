// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Zeit-Tracker Gothic';

  @override
  String get homeTitle => 'Startseite';

  @override
  String get aboutMeTitle => 'Über mich';

  @override
  String get save => 'Speichern';

  @override
  String get resetEverything => 'Alles zurücksetzen';

  @override
  String get companyName => 'Firmenname';

  @override
  String get employerAddress => 'Arbeitgeberadresse';

  @override
  String get userName => 'Dein Name';

  @override
  String get requiredWeeklyHours => 'Erforderliche Wochenstunden';

  @override
  String get overtimeHours => 'Überstunden (Stunden)';

  @override
  String get overtimeMinutes => 'Überstunden (Minuten)';

  @override
  String get vacationCarried => 'Resturlaub vom Vorjahr';

  @override
  String get vacationThisYear => 'Urlaub dieses Jahr';

  @override
  String get vacationTaken => 'Bereits genommener Urlaub';

  @override
  String get vacationPlanned => 'Geplanter Urlaub';

  @override
  String get regularBreakDuration => 'Reguläre Pausenzeit (Minuten)';

  @override
  String get vacationLeftAfterTaken => 'Resturlaub nach genommenem Urlaub';

  @override
  String get vacationLeftAfterPlanned => 'Resturlaub nach geplantem Urlaub';

  @override
  String get confirmResetTitle => 'Zurücksetzen bestätigen';

  @override
  String get confirmResetMessage =>
      'Dies wird ALLE deine Daten löschen, einschließlich Arbeitszeiten und Einstellungen. Bist du sicher?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get deleteEverything => 'Alles löschen';

  @override
  String get requiredField => 'Erforderlich';

  @override
  String get mustBeNumber => 'Muss eine Zahl sein';

  @override
  String get dataSaved => 'Daten gespeichert';

  @override
  String get allDataReset => 'Alle Daten wurden zurückgesetzt';

  @override
  String get selectDayPrompt => 'Wählen Sie einen Tag zum Starten';

  @override
  String get selectedDate => 'Ausgewählt';

  @override
  String get punchInOut => 'Kommen / Gehen';

  @override
  String get addManualTime => 'Manuellen Eintrag hinzufügen';

  @override
  String get noEntries => 'Keine Einträge für diesen Tag.';

  @override
  String get inLabel => 'Kommen';

  @override
  String get outLabel => 'Gehen';

  @override
  String get breakLabel => 'Pause';

  @override
  String get workedLabel => 'Geleistet';

  @override
  String get errorPunchOutBeforeIn =>
      'Gehen-Zeit muss nach der Kommen-Zeit liegen';

  @override
  String get entriesForDay => 'Einträge für';

  @override
  String get manualFullDay => 'Manuell / Ganztägig';

  @override
  String get editEntry => 'Eintrag bearbeiten';

  @override
  String get deleteEntry => 'Eintrag löschen';

  @override
  String get close => 'Schließen';

  @override
  String get startTime => 'Startzeit';

  @override
  String get endTime => 'Endzeit';

  @override
  String get notSet => 'Nicht festgelegt';

  @override
  String get manualEntryTitle => 'Manueller Eintrag';

  @override
  String get punchInTime => 'Kommen-Zeit';

  @override
  String get punchOutTime => 'Gehen-Zeit';

  @override
  String get breakInMinutes => 'Pause (Minuten)';

  @override
  String get entryType => 'Eintragstyp';

  @override
  String get giftedHours => 'Geschenkte Stunden';

  @override
  String get errorSelectPunchTimes => 'Bitte Kommen- und Gehen-Zeit auswählen';

  @override
  String get errorGiftedHoursRequired => 'Bitte geschenkte Stunden angeben';

  @override
  String get errorOvertimeTakenRequired =>
      'Bitte genommene Überstunden (in Stunden) angeben';

  @override
  String get entryTypeLabelRegular => 'Regulär';

  @override
  String get entryTypeLabelSickDay => 'Krankheitstag';

  @override
  String get entryTypeLabelVacation => 'Urlaub';

  @override
  String get entryTypeLabelGiftedTime => 'Geschenkte Zeit';

  @override
  String get entryTypeLabelPublicHoliday => 'Feiertag';

  @override
  String get entryTypeLabelOvertimeTaken => 'Überstunden genommen';

  @override
  String get weeklySummary => 'Wöchentliche Übersicht';

  @override
  String get summaryWeekLabel => 'Übersicht für diese Woche';

  @override
  String get summaryExpectedHours => 'Erwartete Stunden: ';

  @override
  String get summaryActualHours => 'Tatsächliche Stunden: ';

  @override
  String get summaryVacationDays => 'Urlaubstage: ';

  @override
  String get summarySickDays => 'Krankheitstage: ';

  @override
  String get summaryPublicHolidays => 'Feiertage: ';

  @override
  String get summaryGiftedTime => 'Geschenkte Zeit: ';

  @override
  String get summaryOvertimeWeek => 'Überstunden diese Woche: ';

  @override
  String get summaryOvertimeTotal => 'Gesamtüberstunden: ';

  @override
  String get monthlySummary => 'Monatsübersicht';

  @override
  String get selectMonthLabel => 'Monat auswählen';

  @override
  String get summaryMonthLabel => 'Übersicht für diesen Monat';

  @override
  String get summaryOvertimeMonth => 'Überstunden diesen MOnat: ';
}
