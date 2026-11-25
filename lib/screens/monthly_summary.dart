import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/time_entry.dart';
import '../models/user_settings.dart';
import '../services/time_calculator.dart';

class MonthlySummaryScreen extends StatefulWidget {
  final List<TimeEntry> entries;
  final UserSettings userSettings;

  const MonthlySummaryScreen({
    Key? key,
    required this.entries,
    required this.userSettings,
  }) : super(key: key);

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  DateTime? _selectedMonth;
  late List<TimeEntry> _filteredEntries;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    _filterEntriesForSelectedMonth();
  }

  void _filterEntriesForSelectedMonth() {
    if (_selectedMonth != null) {
      _filteredEntries = widget.entries.where((entry) {
        return entry.entryDate.year == _selectedMonth!.year &&
            entry.entryDate.month == _selectedMonth!.month;
      }).toList();
    } else {
      _filteredEntries = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final monthLabel = _selectedMonth != null
        ? DateFormat.yMMMM().format(_selectedMonth!)
        : loc.selectMonthLabel;

    final calculator = TimeCalculator(
      entries: _filteredEntries,
      userSettings: widget.userSettings,
    );

    final expectedMinutesPerDay =
        (widget.userSettings.requiredWeeklyHours / 5 * 60).round();
    final expectedHours =
        (_filteredEntries.length * expectedMinutesPerDay) ~/ 60;

    final actualDuration = calculator.calculateTotalWorkTime();
    final actualHours = actualDuration.inHours;
    final actualMinutes = actualDuration.inMinutes.remainder(60);

    final vacationDays = _filteredEntries
        .where((e) => e.entryType == 'Vacation')
        .length;
    final sickDays = _filteredEntries
        .where((e) => e.entryType == 'Sick Day')
        .length;
    final publicHolidays = _filteredEntries
        .where((e) => e.entryType == 'Public Holiday')
        .length;

    final giftedTimeMinutes = _filteredEntries
        .where((e) => e.entryType == 'Gifted Time')
        .fold<int>(0, (sum, e) => sum + (e.manualWorkDurationInMinutes ?? 0));
    final giftedTimeHours = giftedTimeMinutes ~/ 60;
    final giftedTimeRemMin = giftedTimeMinutes % 60;

    final rawMonthlyOvertime =
        actualDuration -
        Duration(minutes: _filteredEntries.length * expectedMinutesPerDay);
    final monthlyOvertimeHours = rawMonthlyOvertime.inHours;
    final monthlyOvertimeMinutes = rawMonthlyOvertime.inMinutes.remainder(60);

    final totalOvertime = calculator.calculateOvertime();
    final totalOvertimeHours = totalOvertime.inHours;
    final totalOvertimeMinutes = totalOvertime.inMinutes.remainder(60);

    return Scaffold(
      backgroundColor: const Color(0xFF1D1A1A),
      appBar: AppBar(
        title: Text(loc.monthlySummary),
        backgroundColor: const Color(0xFF2C1C1A),
        foregroundColor: const Color(0xFFCBA135),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B1E22),
                foregroundColor: const Color(0xFFEFE6D6),
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedMonth ?? DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  builder: (context, child) =>
                      Theme(data: ThemeData.dark(), child: child!),
                );
                if (picked != null) {
                  setState(() {
                    _selectedMonth = DateTime(picked.year, picked.month);
                    _filterEntriesForSelectedMonth();
                  });
                }
              },
              child: Text(loc.selectMonthLabel),
            ),
            const SizedBox(height: 16),
            Text(
              monthLabel,
              style: const TextStyle(color: Color(0xFFCBA135), fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              loc.summaryMonthLabel,
              style: const TextStyle(
                color: Color(0xFFCBA135),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "• ${loc.summaryExpectedHours}: $expectedHours h",
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
            Text(
              "• ${loc.summaryActualHours}: $actualHours h $actualMinutes min",
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
            Text(
              "• ${loc.summaryVacationDays}: $vacationDays",
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
            Text(
              "• ${loc.summarySickDays}: $sickDays",
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
            Text(
              "• ${loc.summaryPublicHolidays}: $publicHolidays",
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
            Text(
              "• ${loc.summaryGiftedTime}: $giftedTimeHours h $giftedTimeRemMin min",
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
            Text(
              "• ${loc.summaryOvertimeMonth}: $monthlyOvertimeHours h $monthlyOvertimeMinutes min",
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
            Text(
              "• ${loc.summaryOvertimeTotal}: $totalOvertimeHours h $totalOvertimeMinutes min",
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
          ],
        ),
      ),
    );
  }
}
