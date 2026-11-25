import '../models/time_entry.dart';
import '../models/user_settings.dart';

class TimeCalculator {
  final List<TimeEntry> entries;
  final UserSettings userSettings;

  TimeCalculator({required this.entries, required this.userSettings});

  Duration calculateTotalWorkTime() {
    Duration total = Duration.zero;
    final regularBreak = userSettings.regularBreakMinutes;

    final Map<DateTime, List<TimeEntry>> groupedEntries = _groupEntriesByDay(
      entries,
    );

    for (final dailyEntries in groupedEntries.values) {
      final regularEntries =
          dailyEntries
              .where((e) => e.entryType == 'Regular' && e.punchOut != null)
              .toList()
            ..sort((a, b) => a.punchIn.compareTo(b.punchIn));

      if (regularEntries.isNotEmpty) {
        Duration workDuration = Duration.zero;
        Duration totalBreaks = Duration.zero;

        for (int i = 0; i < regularEntries.length; i++) {
          final entry = regularEntries[i];
          workDuration += entry.punchOut!.difference(entry.punchIn);

          if (i > 0) {
            final prev = regularEntries[i - 1];
            final gap = entry.punchIn.difference(prev.punchOut!);
            if (gap.inMinutes < regularBreak) {
              totalBreaks += Duration(minutes: regularBreak);
            } else {
              totalBreaks += gap;
            }
          }
        }
        total += workDuration - totalBreaks;
      }

      for (final entry in dailyEntries) {
        if (entry.entryType != 'Regular') {
          total += _calculateSpecialEntryWork(entry);
        }
      }
    }

    return total;
  }

  Duration calculateOvertime() {
    final expectedMinutesPerDay = (userSettings.requiredWeeklyHours / 5 * 60)
        .round();
    int totalWorkedMinutes = 0;
    int totalExpectedMinutes = 0;
    int overtimeTakenMinutes = 0;

    final Map<DateTime, List<TimeEntry>> groupedEntries = _groupEntriesByDay(
      entries,
    );

    for (final entryGroup in groupedEntries.entries) {
      final date = entryGroup.key;
      final dayEntries = entryGroup.value;

      final isPastOrToday = !date.isAfter(DateTime.now());
      final regularEntries =
          dayEntries
              .where((e) => e.entryType == 'Regular' && e.punchOut != null)
              .toList()
            ..sort((a, b) => a.punchIn.compareTo(b.punchIn));

      if (regularEntries.isNotEmpty) {
        int dailyMinutes = 0;
        int totalBreaks = 0;

        for (int i = 0; i < regularEntries.length; i++) {
          final entry = regularEntries[i];
          dailyMinutes += entry.punchOut!.difference(entry.punchIn).inMinutes;

          if (i > 0) {
            final prev = regularEntries[i - 1];
            final gap = entry.punchIn.difference(prev.punchOut!).inMinutes;
            totalBreaks += gap < userSettings.regularBreakMinutes
                ? userSettings.regularBreakMinutes
                : gap;
          }
        }
        totalWorkedMinutes += dailyMinutes - totalBreaks;
        totalExpectedMinutes += expectedMinutesPerDay;
      }

      for (final entry in dayEntries) {
        switch (entry.entryType) {
          case 'Sick Day':
          case 'Vacation':
          case 'Public Holiday':
            if (isPastOrToday) {
              totalWorkedMinutes += expectedMinutesPerDay;
              totalExpectedMinutes += expectedMinutesPerDay;
            }
            break;
          case 'Gifted Time':
            if (isPastOrToday) {
              final gifted =
                  entry.manualWorkDurationInMinutes ?? expectedMinutesPerDay;
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

  Duration _calculateSpecialEntryWork(TimeEntry entry) {
    if (entry.entryType == 'Gifted Time') {
      return Duration(minutes: entry.manualWorkDurationInMinutes ?? 0);
    } else if (entry.entryType == 'Overtime Taken') {
      return Duration(minutes: -(entry.manualWorkDurationInMinutes ?? 0));
    } else if ([
          "Sick Day",
          "Vacation",
          "Public Holiday",
        ].contains(entry.entryType) &&
        !entry.entryDate.isAfter(DateTime.now())) {
      final dailyMinutes = (userSettings.requiredWeeklyHours / 5 * 60).round();
      return Duration(minutes: dailyMinutes);
    }
    return Duration.zero;
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
}
