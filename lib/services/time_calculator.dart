import '../models/time_entry.dart';
import '../models/user_settings.dart';
import 'dart:math';

class TimeCalculator {
  final List<TimeEntry> entries;
  final UserSettings userSettings;

  TimeCalculator({required this.entries, required this.userSettings});

  int _getRequiredBreakMinutes(int grossWorkedMinutes) {
    int statutoryBreak = 0;
    if (userSettings.useGermanLaborLaw) {
      if (grossWorkedMinutes > 9 * 60) {
        statutoryBreak = 45;
      } else if (grossWorkedMinutes > 6 * 60) {
        statutoryBreak = 30;
      }
    }
    return max(statutoryBreak, userSettings.regularBreakMinutes);
  }

  Map<DateTime, List<TimeEntry>> _groupEntriesByDay(List<TimeEntry> entries) {
    final Map<DateTime, List<TimeEntry>> grouped = {};
    for (final entry in entries) {
      final day = DateTime(
        entry.entryDate.year,
        entry.entryDate.month,
        entry.entryDate.day,
      );
      grouped.putIfAbsent(day, () => []).add(entry);
    }
    return grouped;
  }

  List<TimeEntry> _getValidEntries() {
    final startDate = userSettings.employmentStartDate != null
        ? DateTime(
            userSettings.employmentStartDate!.year,
            userSettings.employmentStartDate!.month,
            userSettings.employmentStartDate!.day,
          )
        : null;

    return entries.where((entry) {
      if (startDate != null && entry.entryDate.isBefore(startDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  Duration calculateTotalWorkTime() {
    Duration total = Duration.zero;
    final validEntries = _getValidEntries();
    final groupedEntries = _groupEntriesByDay(validEntries);

    for (final dayEntries in groupedEntries.values) {
      final regularEntries = dayEntries
          .where((e) => e.entryType == 'Regular')
          .toList()
        ..sort((a, b) => a.punchIn.compareTo(b.punchIn));

      if (regularEntries.isNotEmpty) {
        int grossWorkedMinutes = 0;
        int totalActualBreak = 0;

        for (int i = 0; i < regularEntries.length; i++) {
          final entry = regularEntries[i];
          if (entry.punchOut != null) {
            grossWorkedMinutes += entry.punchOut!.difference(entry.punchIn).inMinutes;
            totalActualBreak += entry.breakDeductedInMinutes;
          } else if (entry.manualWorkDurationInMinutes != null) {
            grossWorkedMinutes += entry.manualWorkDurationInMinutes!;
          }

          if (i > 0) {
            final prev = regularEntries[i - 1];
            if (prev.punchOut != null) {
              final gap = entry.punchIn.difference(prev.punchOut!).inMinutes;
              if (gap > 0) {
                totalActualBreak += gap;
              }
            }
          }
        }

        final requiredBreak = _getRequiredBreakMinutes(grossWorkedMinutes);
        final breakToApply = max(totalActualBreak, requiredBreak);

        total += Duration(minutes: max(0, grossWorkedMinutes - breakToApply));
      }

      for (final entry in dayEntries) {
        if (entry.entryType == 'Gifted Time') {
          total += Duration(minutes: entry.manualWorkDurationInMinutes ?? 0);
        } else if (entry.entryType == 'Overtime Taken') {
          total -= Duration(minutes: entry.manualWorkDurationInMinutes ?? 0);
        } else if ([
              'Sick Day',
              'Vacation',
              'Public Holiday',
            ].contains(entry.entryType) &&
            !entry.entryDate.isAfter(DateTime.now())) {
          final dailyMinutes = (userSettings.requiredWeeklyHours / userSettings.workingDaysPerWeek * 60).round();
          total += Duration(minutes: dailyMinutes);
        }
      }
    }

    return total;
  }

  Duration calculateOvertime() {
    final expectedMinutesPerDay = (userSettings.requiredWeeklyHours / userSettings.workingDaysPerWeek * 60).round();
    int totalWorkedMinutes = 0;
    int totalExpectedMinutes = 0;
    int overtimeTakenMinutes = 0;

    final startDate = userSettings.employmentStartDate != null
        ? DateTime(
            userSettings.employmentStartDate!.year,
            userSettings.employmentStartDate!.month,
            userSettings.employmentStartDate!.day,
          )
        : (entries.isNotEmpty
            ? entries.map((e) => e.entryDate).reduce((a, b) => a.isBefore(b) ? a : b)
            : DateTime(DateTime.now().year, 1, 1));

    final endDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // 1. Calculate total expected minutes across all working days from start date up to today
    if (!startDate.isAfter(endDate)) {
      DateTime current = startDate;
      while (!current.isAfter(endDate)) {
        final isWeekday = current.weekday != DateTime.saturday && current.weekday != DateTime.sunday;
        if (isWeekday) {
          totalExpectedMinutes += expectedMinutesPerDay;
        }
        current = current.add(const Duration(days: 1));
      }
    }

    // 2. Calculate actual worked minutes and adjustments from valid entries
    final validEntries = _getValidEntries();
    final groupedEntries = _groupEntriesByDay(validEntries);

    for (final entryGroup in groupedEntries.entries) {
      final date = entryGroup.key;
      final dayEntries = entryGroup.value;
      final isPastOrToday = !date.isAfter(DateTime.now());

      final regularEntries = dayEntries
          .where((e) => e.entryType == 'Regular')
          .toList()
        ..sort((a, b) => a.punchIn.compareTo(b.punchIn));

      if (regularEntries.isNotEmpty) {
        int grossWorkedMinutes = 0;
        int totalActualBreak = 0;

        for (int i = 0; i < regularEntries.length; i++) {
          final entry = regularEntries[i];
          if (entry.punchOut != null) {
            grossWorkedMinutes += entry.punchOut!.difference(entry.punchIn).inMinutes;
            totalActualBreak += entry.breakDeductedInMinutes;
          } else if (entry.manualWorkDurationInMinutes != null) {
            grossWorkedMinutes += entry.manualWorkDurationInMinutes!;
          }

          if (i > 0) {
            final prev = regularEntries[i - 1];
            if (prev.punchOut != null) {
              final gap = entry.punchIn.difference(prev.punchOut!).inMinutes;
              if (gap > 0) {
                totalActualBreak += gap;
              }
            }
          }
        }

        final requiredBreak = _getRequiredBreakMinutes(grossWorkedMinutes);
        final breakToApply = max(totalActualBreak, requiredBreak);

        totalWorkedMinutes += max(0, grossWorkedMinutes - breakToApply);
      }

      for (final entry in dayEntries) {
        switch (entry.entryType) {
          case 'Sick Day':
          case 'Vacation':
          case 'Public Holiday':
            if (isPastOrToday) {
              totalWorkedMinutes += expectedMinutesPerDay;
            }
            break;
          case 'Gifted Time':
            if (isPastOrToday) {
              final gifted = entry.manualWorkDurationInMinutes ?? expectedMinutesPerDay;
              totalWorkedMinutes += gifted;
            }
            break;
          case 'Overtime Taken':
            if (isPastOrToday) {
              final taken = entry.manualWorkDurationInMinutes ?? 0;
              overtimeTakenMinutes += taken;
            }
            break;
        }
      }
    }

    final rawOvertime = totalWorkedMinutes - totalExpectedMinutes;
    final finalOvertime = rawOvertime - overtimeTakenMinutes;

    return Duration(
      minutes: finalOvertime + userSettings.carriedOverOvertimeInMinutes,
    );
  }

  int calculateVacationRemaining() {
    return userSettings.vacationCarried +
        userSettings.vacationThisYear -
        userSettings.vacationTaken -
        userSettings.vacationPlanned;
  }
}
