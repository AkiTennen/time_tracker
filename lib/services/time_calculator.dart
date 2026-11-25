import '../models/time_entry.dart';
import '../models/user_settings.dart';

class TimeCalculator {
  final List<TimeEntry> entries;
  final UserSettings userSettings;

  TimeCalculator({required this.entries, required this.userSettings});

  Duration calculateTotalWorkTime() {
    Duration total = Duration.zero;
    final regularBreak = userSettings.regularBreakMinutes;

    for (final entry in entries) {
      if (entry.entryType == 'Regular') {
        if (entry.punchOut != null) {
          final duration = entry.punchOut!.difference(entry.punchIn);
          final actualWorkedMinutes = duration.inMinutes;
          final actualBreak = entry.breakDeductedInMinutes;
          final breakToApply = (actualBreak < regularBreak)
              ? regularBreak
              : actualBreak;

          total += Duration(minutes: actualWorkedMinutes - breakToApply);
        } else if (entry.manualWorkDurationInMinutes != null) {
          total += Duration(minutes: entry.manualWorkDurationInMinutes!);
        }
      } else if (entry.entryType == 'Gifted Time') {
        total += Duration(minutes: entry.manualWorkDurationInMinutes ?? 0);
      } else if (entry.entryType == 'Overtime Taken') {
        total -= Duration(minutes: entry.manualWorkDurationInMinutes ?? 0);
      } else if ([
            'Sick Day',
            'Vacation',
            'Public Holiday',
          ].contains(entry.entryType) &&
          !entry.entryDate.isAfter(DateTime.now())) {
        final dailyMinutes = (userSettings.requiredWeeklyHours / 5 * 60)
            .round();
        total += Duration(minutes: dailyMinutes);
      }
    }

    return total;
  }

  Duration calculateOvertime() {
    final expectedMinutesPerDay = (userSettings.requiredWeeklyHours / 5 * 60)
        .round();
    final regularBreak = userSettings.regularBreakMinutes;

    int totalWorkedMinutes = 0;
    int totalExpectedMinutes = 0;
    int overtimeTakenMinutes = 0;

    for (final entry in entries) {
      final isPastOrToday = !entry.entryDate.isAfter(DateTime.now());

      switch (entry.entryType) {
        case 'Regular':
          if (entry.punchOut != null) {
            final duration = entry.punchOut!
                .difference(entry.punchIn)
                .inMinutes;
            final actualBreak = entry.breakDeductedInMinutes;
            final breakToApply = (actualBreak < regularBreak)
                ? regularBreak
                : actualBreak;

            totalWorkedMinutes += (duration - breakToApply);
            totalExpectedMinutes += expectedMinutesPerDay;
          } else if (entry.manualWorkDurationInMinutes != null) {
            totalWorkedMinutes += entry.manualWorkDurationInMinutes!;
            totalExpectedMinutes += expectedMinutesPerDay;
          }
          break;

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
