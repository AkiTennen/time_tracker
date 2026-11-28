import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracker_gothic/models/time_entry.dart';
import 'package:time_tracker_gothic/models/user_settings.dart';
import 'package:time_tracker_gothic/services/time_calculator.dart';

void main() {
  group('TimeCalculator Break and Work Calculation Tests', () {
    late UserSettings defaultSettings;

    setUp(() {
      defaultSettings = UserSettings(
        companyName: 'Gothic Corp',
        userName: 'Gothic Worker',
        employerAddress: 'Dark Alley 1',
        weeklyHours: 40, // 8 hours per day (480 mins)
        carriedOverOvertime: 0,
        vacationCarried: 0,
        vacationThisYear: 30,
        vacationTaken: 0,
        vacationPlanned: 0,
        regularBreakMinutes: 30,
        lastCarryOverAppliedYear: 2025,
        useGermanLaborLaw: false,
      );
    });

    test('Single entry: actual break less than regular break enforces regular break', () {
      final entry = TimeEntry(
        punchIn: DateTime(2025, 1, 6, 8, 0),
        punchOut: DateTime(2025, 1, 6, 16, 0), // 8 hours gross (480 mins)
        breakDeductedInMinutes: 10, // less than 30 mins
        entryDate: DateTime(2025, 1, 6),
        entryType: 'Regular',
      );

      final calculator = TimeCalculator(entries: [entry], userSettings: defaultSettings);
      final totalWork = calculator.calculateTotalWorkTime();

      // 480 - max(10, 30) = 480 - 30 = 450 mins
      expect(totalWork.inMinutes, equals(450));
    });

    test('Single entry: actual break greater than regular break uses actual break', () {
      final entry = TimeEntry(
        punchIn: DateTime(2025, 1, 6, 8, 0),
        punchOut: DateTime(2025, 1, 6, 17, 0), // 9 hours gross (540 mins)
        breakDeductedInMinutes: 60, // 60 mins break (> 30 mins)
        entryDate: DateTime(2025, 1, 6),
        entryType: 'Regular',
      );

      final calculator = TimeCalculator(entries: [entry], userSettings: defaultSettings);
      final totalWork = calculator.calculateTotalWorkTime();

      // 540 - 60 = 480 mins
      expect(totalWork.inMinutes, equals(480));
    });

    test('Multiple entries on same day: correctly calculates work and gaps', () {
      // Shift 1: 08:00 - 12:00 (4 hours = 240 mins)
      // Break gap: 12:00 - 13:00 (60 mins gap)
      // Shift 2: 13:00 - 17:00 (4 hours = 240 mins)
      final entry1 = TimeEntry(
        punchIn: DateTime(2025, 1, 6, 8, 0),
        punchOut: DateTime(2025, 1, 6, 12, 0),
        breakDeductedInMinutes: 0,
        entryDate: DateTime(2025, 1, 6),
        entryType: 'Regular',
      );

      final entry2 = TimeEntry(
        punchIn: DateTime(2025, 1, 6, 13, 0),
        punchOut: DateTime(2025, 1, 6, 17, 0),
        breakDeductedInMinutes: 0,
        entryDate: DateTime(2025, 1, 6),
        entryType: 'Regular',
      );

      final calculator = TimeCalculator(entries: [entry1, entry2], userSettings: defaultSettings);
      final totalWork = calculator.calculateTotalWorkTime();

      // Total gross: 240 + 240 = 480 mins
      // Gap between entry1 (out 12:00) and entry2 (in 13:00) = 60 mins.
      // Since gap (60) >= regularBreak (30), total break = 60 mins.
      // Net work: 480 - 60 = 420 mins.
      expect(totalWork.inMinutes, equals(420));
    });

    test('German Labor Law (ArbZG): > 6 hours requires 30 mins statutory break', () {
      final germanSettings = defaultSettings.copyWith(
        regularBreakMinutes: 0, // no company flat break
        useGermanLaborLaw: true,
      );

      // Worked 7 hours gross (08:00 - 15:00), 0 break entered
      final entry = TimeEntry(
        punchIn: DateTime(2025, 1, 6, 8, 0),
        punchOut: DateTime(2025, 1, 6, 15, 0), // 420 mins gross (> 6 hours)
        breakDeductedInMinutes: 0,
        entryDate: DateTime(2025, 1, 6),
        entryType: 'Regular',
      );

      final calculator = TimeCalculator(entries: [entry], userSettings: germanSettings);
      final totalWork = calculator.calculateTotalWorkTime();

      // 420 mins gross - 30 mins statutory break (ArbZG § 4) = 390 mins
      expect(totalWork.inMinutes, equals(390));
    });

    test('German Labor Law (ArbZG): > 9 hours requires 45 mins statutory break', () {
      final germanSettings = defaultSettings.copyWith(
        regularBreakMinutes: 0, // no company flat break
        useGermanLaborLaw: true,
      );

      // Worked 10 hours gross (08:00 - 18:00), 0 break entered
      final entry = TimeEntry(
        punchIn: DateTime(2025, 1, 6, 8, 0),
        punchOut: DateTime(2025, 1, 6, 18, 0), // 600 mins gross (> 9 hours)
        breakDeductedInMinutes: 0,
        entryDate: DateTime(2025, 1, 6),
        entryType: 'Regular',
      );

      final calculator = TimeCalculator(entries: [entry], userSettings: germanSettings);
      final totalWork = calculator.calculateTotalWorkTime();

      // 600 mins gross - 45 mins statutory break (ArbZG § 4) = 555 mins
      expect(totalWork.inMinutes, equals(555));
    });

    test('Special Entry Types (Sick Day, Vacation, Gifted Time, Overtime Taken) calculations', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));

      final sickEntry = TimeEntry(
        punchIn: pastDate,
        entryDate: pastDate,
        entryType: 'Sick Day',
      );

      final giftedEntry = TimeEntry(
        punchIn: pastDate,
        entryDate: pastDate,
        entryType: 'Gifted Time',
        manualWorkDurationInMinutes: 120, // 2 hours gifted
      );

      final overtimeTakenEntry = TimeEntry(
        punchIn: pastDate,
        entryDate: pastDate,
        entryType: 'Overtime Taken',
        manualWorkDurationInMinutes: 60, // 1 hour taken off
      );

      final calculator = TimeCalculator(
        entries: [sickEntry, giftedEntry, overtimeTakenEntry],
        userSettings: defaultSettings,
      );

      // Sick Day adds 480 mins (8 hours)
      // Gifted Time adds 120 mins
      // Overtime Taken subtracts 60 mins
      // Total work time = 480 + 120 - 60 = 540 mins.
      final totalWork = calculator.calculateTotalWorkTime();
      expect(totalWork.inMinutes, equals(540));

      // Overtime calculation:
      // Worked = 480 (sick) + 120 (gifted) = 600 mins.
      // Expected = 1 day * 480 = 480 mins.
      // Overtime taken = 60 mins.
      // Final overtime = (600 - 480) - 60 = 120 - 60 = 60 mins.
      final overtime = calculator.calculateOvertime();
      expect(overtime.inMinutes, equals(60));
    });
  });
}
