import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_settings.dart';
import 'package:hive/hive.dart';
import '../models/time_entry.dart';

class UserSettingsService {
  static const _key = 'user_settings';

  static Future<void> saveSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(settings.toMap());
    await prefs.setString(_key, json);
  }

  static Future<UserSettings?> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return null;
    final map = jsonDecode(json);

    return UserSettings.fromMap(map);
  }

  static Future<UserSettings?> checkAndApplyCarryOver(
    int currentOvertime,
    int vacationRemaining, {
    UserSettings? existingSettings,
  }) async {
    final settings = existingSettings ?? await loadSettings();
    if (settings == null) return null;

    final now = DateTime.now();

    if (settings.lastCarryOverAppliedYear < now.year) {
      final updatedSettings = UserSettings(
        companyName: settings.companyName,
        userName: settings.userName,
        employerAddress: settings.employerAddress,
        weeklyHours: settings.weeklyHours,
        carriedOverOvertime: settings.carriedOverOvertime + currentOvertime,
        vacationCarried: vacationRemaining,
        vacationThisYear: settings.vacationThisYear,
        vacationTaken: 0,
        vacationPlanned: 0,
        regularBreakMinutes: settings.regularBreakMinutes,
        lastCarryOverAppliedYear: now.year,
      );
      await saveSettings(updatedSettings);
      return updatedSettings;
    }
    return settings;
  }

  static Future<void> checkForCarryOver() async {
    final now = DateTime.now();
    if (now.month == 1 && now.day == 1) {
      final settings = await loadSettings();
      if (settings != null && settings.lastCarryOverAppliedYear < now.year) {
        final lastYear = now.year - 1;

        final actualOvertime = await calculateOvertimeForYear(
          lastYear,
          settings.weeklyHours,
        );
        final vacationRemaining =
            settings.vacationThisYear - settings.vacationTaken;

        await checkAndApplyCarryOver(
          actualOvertime,
          vacationRemaining,
          existingSettings: settings,
        );
      }
    }
  }

  static Future<int> calculateOvertimeForYear(int year, int weeklyHours) async {
    final box = await Hive.openBox<TimeEntry>('time_entries');
    final entries = box.values.where((entry) => entry.entryDate.year == year);

    int totalWorkedMinutes = 0;

    for (final entry in entries) {
      // Skip non-working entries (e.g., Sick Day, Vacation) unless they have manual work duration
      if (entry.entryType != 'Regular' &&
          entry.manualWorkDurationInMinutes == null) {
        continue;
      }

      if (entry.manualWorkDurationInMinutes != null) {
        totalWorkedMinutes += entry.manualWorkDurationInMinutes!;
      } else if (entry.punchOut != null) {
        final duration = entry.punchOut!.difference(entry.punchIn).inMinutes;
        totalWorkedMinutes += (duration - entry.breakDeductedInMinutes);
      }
    }

    final expectedMinutes = (weeklyHours * 60 * 52).toInt();
    final overtime = totalWorkedMinutes - expectedMinutes;

    return overtime;
  }
}
