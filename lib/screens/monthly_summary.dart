import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/time_entry.dart';
import '../models/user_settings.dart';
import '../services/time_calculator.dart';
import '../services/pdf_report_service.dart';

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
  List<TimeEntry> _filteredEntries = [];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _filterEntriesForSelectedMonth();
  }

  void _filterEntriesForSelectedMonth() {
    if (_selectedMonth != null) {
      final startDate = widget.userSettings.employmentStartDate;
      _filteredEntries = widget.entries.where((entry) {
        if (entry.entryDate.year != _selectedMonth!.year ||
            entry.entryDate.month != _selectedMonth!.month) {
          return false;
        }
        if (startDate != null && entry.entryDate.isBefore(DateTime(startDate.year, startDate.month, startDate.day))) {
          return false;
        }
        return true;
      }).toList();
    } else {
      _filteredEntries = [];
    }
  }

  int _getWorkingDaysInMonth(DateTime month) {
    int weekdayCount = 0;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startDate = widget.userSettings.employmentStartDate;

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);

      if (startDate != null && date.isBefore(DateTime(startDate.year, startDate.month, startDate.day))) {
        continue;
      }
      if (date.isAfter(DateTime.now())) {
        continue;
      }

      if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
        weekdayCount++;
      }
    }
    return ((weekdayCount * widget.userSettings.workingDaysPerWeek) / 5).round();
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
        (widget.userSettings.requiredWeeklyHours / widget.userSettings.workingDaysPerWeek * 60).round();
    final workingDays = _selectedMonth != null ? _getWorkingDaysInMonth(_selectedMonth!) : 20;
    final expectedTotalMinutes = workingDays * expectedMinutesPerDay;
    final expectedHours = expectedTotalMinutes ~/ 60;

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

    final rawMonthlyOvertime = actualDuration.inMinutes - expectedTotalMinutes;
    final monthlyOvertimeHours = rawMonthlyOvertime ~/ 60;
    final monthlyOvertimeMinutes = rawMonthlyOvertime.remainder(60);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: loc.exportPdf,
            onPressed: () async {
              if (_selectedMonth == null) return;
              try {
                final path = await PdfReportService.generateMonthlyPdf(
                  month: _selectedMonth!,
                  entries: _filteredEntries,
                  userSettings: widget.userSettings,
                  loc: loc,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${loc.pdfSavedSuccessfully}\n$path")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error generating PDF: $e")),
                );
              }
            },
          ),
        ],
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
