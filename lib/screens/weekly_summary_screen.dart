import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/time_entry.dart';
import '../models/user_settings.dart';
import '../services/time_calculator.dart';
import '../l10n/app_localizations.dart';

class WeeklySummaryScreen extends StatefulWidget {
  final List<TimeEntry> entries;
  final UserSettings userSettings;

  const WeeklySummaryScreen({
    super.key,
    required this.entries,
    required this.userSettings,
  });

  @override
  State<WeeklySummaryScreen> createState() => _WeeklySummaryScreenState();
}

class _WeeklySummaryScreenState extends State<WeeklySummaryScreen> {
  DateTime? _selectedWeekStart;
  DateTime? _selectedWeekEnd;
  List<TimeEntry> _filteredEntries = [];

  void _pickWeek() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
    );

    if (picked != null) {
      final weekStart = picked.subtract(Duration(days: picked.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      setState(() {
        _selectedWeekStart = weekStart;
        _selectedWeekEnd = weekEnd;
        _filteredEntries = widget.entries.where((entry) {
          final date = entry.entryDate;
          return !date.isBefore(weekStart) && !date.isAfter(weekEnd);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final calculator = TimeCalculator(
      entries: _filteredEntries,
      userSettings: widget.userSettings,
    );

    final expectedMinutes =
        (_filteredEntries.length /
                5 *
                widget.userSettings.requiredWeeklyHours *
                60)
            .round();
    final actualDuration = calculator.calculateTotalWorkTime();
    final giftedMinutes = _filteredEntries
        .where((e) => e.entryType == 'Gifted Time')
        .fold<int>(0, (sum, e) => sum + (e.manualWorkDurationInMinutes ?? 0));
    final overtimeThisWeek = actualDuration.inMinutes - expectedMinutes;

    final sickDays = _filteredEntries
        .where((e) => e.entryType == 'Sick Day')
        .length;
    final vacationDays = _filteredEntries
        .where((e) => e.entryType == 'Vacation')
        .length;
    final publicHolidays = _filteredEntries
        .where((e) => e.entryType == 'Public Holiday')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFF1D1A1A),
      appBar: AppBar(
        title: Text(loc.weeklySummary),
        backgroundColor: const Color(0xFF2C1C1A),
        foregroundColor: const Color(0xFFCBA135),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _pickWeek,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B1E22),
                foregroundColor: const Color(0xFFEFE6D6),
              ),
              child: Text(loc.summaryWeekLabel),
            ),
            const SizedBox(height: 16),
            if (_selectedWeekStart != null)
              Text(
                '${DateFormat.yMMMd().format(_selectedWeekStart!)} – ${DateFormat.yMMMd().format(_selectedWeekEnd!)}',
                style: const TextStyle(color: Color(0xFFCBA135), fontSize: 16),
              ),
            const SizedBox(height: 16),
            Text(
              loc.summaryWeekLabel,
              style: const TextStyle(
                color: Color(0xFFCBA135),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '• ${loc.summaryExpectedHours}: ${(expectedMinutes / 60).floor()}h ${(expectedMinutes % 60)}m',
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
            Text(
              '• ${loc.summaryActualHours}: ${actualDuration.inHours}h ${actualDuration.inMinutes % 60}m',
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
            Text(
              '• ${loc.summaryVacationDays}: $vacationDays',
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
            Text(
              '• ${loc.summarySickDays}: $sickDays',
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
            Text(
              '• ${loc.summaryPublicHolidays}: $publicHolidays',
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
            Text(
              '• ${loc.summaryGiftedTime}: ${giftedMinutes ~/ 60}h ${giftedMinutes % 60}m',
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
            Text(
              '• ${loc.summaryOvertimeWeek}: ${overtimeThisWeek ~/ 60}h ${overtimeThisWeek % 60}m',
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
            Text(
              '• ${loc.summaryOvertimeTotal}: ${calculator.calculateOvertime().inHours}h ${calculator.calculateOvertime().inMinutes % 60}m',
              style: const TextStyle(color: Color(0xFFEFE6D6)),
            ),
          ],
        ),
      ),
    );
  }
}
