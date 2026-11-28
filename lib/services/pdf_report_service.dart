import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/time_entry.dart';
import '../models/user_settings.dart';
import '../services/time_calculator.dart';
import '../l10n/app_localizations.dart';

class PdfReportService {
  static Future<String> generateDailyPdf({
    required DateTime date,
    required List<TimeEntry> entries,
    required UserSettings userSettings,
    required AppLocalizations loc,
  }) async {
    final pdf = pw.Document();
    final formattedDate = DateFormat.yMMMd().format(date);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(userSettings, "${loc.timesheetReport} - $formattedDate"),
              pw.SizedBox(height: 20),
              _buildInfoBox(userSettings, "${loc.period}: $formattedDate", loc),
              pw.SizedBox(height: 20),
              _buildEntriesTable(entries, userSettings, loc),
              pw.Spacer(),
              _buildSignatureBlock(loc),
            ],
          );
        },
      ),
    );

    return await _savePdf(pdf, "Daily_Timesheet_${DateFormat('yyyy-MM-dd').format(date)}_${loc.localeName}.pdf");
  }

  static Future<String> generateWeeklyPdf({
    required DateTime weekStart,
    required DateTime weekEnd,
    required List<TimeEntry> entries,
    required UserSettings userSettings,
    required AppLocalizations loc,
  }) async {
    final pdf = pw.Document();
    final periodStr = "${DateFormat.yMMMd().format(weekStart)} - ${DateFormat.yMMMd().format(weekEnd)}";

    final calculator = TimeCalculator(entries: entries, userSettings: userSettings);
    final expectedMinutes = userSettings.requiredWeeklyHours * 60;
    final actualDuration = calculator.calculateTotalWorkTime();
    final weeklyNetMinutes = actualDuration.inMinutes - expectedMinutes;
    final weeklyOvertime = Duration(minutes: weeklyNetMinutes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(userSettings, "${loc.weeklySummary} Report"),
              pw.SizedBox(height: 16),
              _buildInfoBox(userSettings, "${loc.period}: $periodStr", loc),
              pw.SizedBox(height: 12),
              _buildSummaryStats(
                expectedMinutes: expectedMinutes,
                actualDuration: actualDuration,
                overtime: weeklyOvertime,
                entries: entries,
                loc: loc,
              ),
              pw.SizedBox(height: 16),
              _buildEntriesTable(entries, userSettings, loc),
              pw.Spacer(),
              _buildSignatureBlock(loc),
            ],
          );
        },
      ),
    );

    return await _savePdf(pdf, "Weekly_Timesheet_${DateFormat('yyyy-MM-dd').format(weekStart)}_${loc.localeName}.pdf");
  }

  static Future<String> generateMonthlyPdf({
    required DateTime month,
    required List<TimeEntry> entries,
    required UserSettings userSettings,
    required AppLocalizations loc,
  }) async {
    final pdf = pw.Document();
    final monthStr = DateFormat.yMMMM().format(month);

    final calculator = TimeCalculator(entries: entries, userSettings: userSettings);

    int workingDays = 0;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    for (int day = 1; day <= daysInMonth; day++) {
      final d = DateTime(month.year, month.month, day);
      if (d.weekday != DateTime.saturday && d.weekday != DateTime.sunday) {
        workingDays++;
      }
    }
    final workingDaysScaled = ((workingDays * userSettings.workingDaysPerWeek) / 5).round();
    final expectedMinutesPerDay = (userSettings.requiredWeeklyHours / userSettings.workingDaysPerWeek * 60).round();
    final expectedTotalMinutes = workingDaysScaled * expectedMinutesPerDay;

    final actualDuration = calculator.calculateTotalWorkTime();
    final monthlyNetMinutes = actualDuration.inMinutes - expectedTotalMinutes;
    final monthlyOvertime = Duration(minutes: monthlyNetMinutes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(userSettings, "${loc.monthlySummary} Report"),
              pw.SizedBox(height: 16),
              _buildInfoBox(userSettings, "${loc.period}: $monthStr", loc),
              pw.SizedBox(height: 12),
              _buildSummaryStats(
                expectedMinutes: expectedTotalMinutes,
                actualDuration: actualDuration,
                overtime: monthlyOvertime,
                entries: entries,
                loc: loc,
              ),
              pw.SizedBox(height: 16),
              _buildEntriesTable(entries, userSettings, loc),
              pw.Spacer(),
              _buildSignatureBlock(loc),
            ],
          );
        },
      ),
    );

    return await _savePdf(pdf, "Monthly_Timesheet_${DateFormat('yyyy-MM').format(month)}_${loc.localeName}.pdf");
  }

  static pw.Widget _buildHeader(UserSettings settings, String title) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(settings.companyName.isNotEmpty ? settings.companyName : "Time Tracker Gothic",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.brown900)),
            if (settings.employerAddress.isNotEmpty)
              pw.Text(settings.employerAddress, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(title, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.brown800)),
            pw.SizedBox(height: 4),
            pw.Text("Generated: ${DateFormat.yMMMd().format(DateTime.now())}", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInfoBox(UserSettings settings, String periodText, AppLocalizations loc) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.brown300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("${loc.employee}: ${settings.userName.isNotEmpty ? settings.userName : 'N/A'}",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(periodText, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryStats({
    required int expectedMinutes,
    required Duration actualDuration,
    required Duration overtime,
    required List<TimeEntry> entries,
    required AppLocalizations loc,
  }) {
    final sickDays = entries.where((e) => e.entryType == 'Sick Day').length;
    final vacationDays = entries.where((e) => e.entryType == 'Vacation').length;
    final publicHolidays = entries.where((e) => e.entryType == 'Public Holiday').length;

    final otMins = overtime.inMinutes;
    final otStr = (otMins < 0 ? "-" : "") + "${otMins.abs() ~/ 60}h ${otMins.abs() % 60}m";

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _statItem(loc.summaryExpectedHours, "${expectedMinutes ~/ 60}h ${expectedMinutes % 60}m"),
          _statItem(loc.summaryActualHours, "${actualDuration.inHours}h ${actualDuration.inMinutes % 60}m"),
          _statItem(loc.summaryOvertimeTotal, otStr),
          _statItem(loc.summaryVacationDays, "$vacationDays"),
          _statItem(loc.summarySickDays, "$sickDays"),
          _statItem(loc.summaryPublicHolidays, "$publicHolidays"),
        ],
      ),
    );
  }

  static pw.Widget _statItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        pw.SizedBox(height: 2),
        pw.Text(value, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  static pw.Widget _buildEntriesTable(List<TimeEntry> entries, UserSettings userSettings, AppLocalizations loc) {
    final sortedEntries = List<TimeEntry>.from(entries)..sort((a, b) => a.entryDate.compareTo(b.entryDate));
    final expectedMinutesPerDay = (userSettings.requiredWeeklyHours / userSettings.workingDaysPerWeek * 60).round();

    return pw.TableHelper.fromTextArray(
      headers: [
        "Date",
        loc.entryType,
        loc.inLabel,
        loc.outLabel,
        loc.breakLabel,
        loc.workedLabel,
        loc.overtimeHours,
      ],
      data: sortedEntries.map((e) {
        final dateStr = DateFormat('yyyy-MM-dd').format(e.entryDate);
        final inStr = e.punchOut != null ? DateFormat('HH:mm').format(e.punchIn) : '-';
        final outStr = e.punchOut != null ? DateFormat('HH:mm').format(e.punchOut!) : '-';
        final breakStr = e.breakDeductedInMinutes > 0 ? "${e.breakDeductedInMinutes}m" : "-";

        int netWorkedMins = 0;
        String workedStr = "-";

        if (e.punchOut != null) {
          netWorkedMins = e.punchOut!.difference(e.punchIn).inMinutes - e.breakDeductedInMinutes;
          workedStr = "${netWorkedMins ~/ 60}h ${netWorkedMins % 60}m";
        } else if (e.manualWorkDurationInMinutes != null) {
          netWorkedMins = e.manualWorkDurationInMinutes!;
          workedStr = "${netWorkedMins ~/ 60}h ${netWorkedMins % 60}m";
        } else if (['Sick Day', 'Vacation', 'Public Holiday'].contains(e.entryType)) {
          netWorkedMins = expectedMinutesPerDay;
          workedStr = "${expectedMinutesPerDay ~/ 60}h ${expectedMinutesPerDay % 60}m";
        }

        final dailyOtMins = netWorkedMins - expectedMinutesPerDay;
        final otStr = _formatOt(dailyOtMins);

        return [dateStr, e.entryType, inStr, outStr, breakStr, workedStr, otStr];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.brown800),
      rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    );
  }

  static String _formatOt(int minutes) {
    if (minutes == 0) return "0m";
    final sign = minutes > 0 ? "+" : "-";
    final absMins = minutes.abs();
    final h = absMins ~/ 60;
    final m = absMins % 60;
    if (h == 0) return "$sign${m}m";
    if (m == 0) return "$sign${h}h";
    return "$sign${h}h ${m}m";
  }

  static pw.Widget _buildSignatureBlock(AppLocalizations loc) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(width: 200, child: pw.Divider(color: PdfColors.black, thickness: 1)),
            pw.SizedBox(height: 4),
            pw.Text(loc.signatureEmployee, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(width: 200, child: pw.Divider(color: PdfColors.black, thickness: 1)),
            pw.SizedBox(height: 4),
            pw.Text(loc.signatureManager, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ],
        ),
      ],
    );
  }

  static Future<String> _savePdf(pw.Document pdf, String filename) async {
    final output = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    final file = File("${output.path}/$filename");
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}
