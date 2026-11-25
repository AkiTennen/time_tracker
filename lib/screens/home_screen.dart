import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../models/time_entry.dart';
import 'about_me_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';
import '../services/user_settings_service.dart';
import '../services/time_calculator.dart';
import '../l10n/app_localizations.dart';
import '../screens/weekly_summary_screen.dart';
import '../screens/monthly_summary.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleLocale;

  const HomeScreen({Key? key, required this.onToggleLocale}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<TimeEntry>> _entries = {};
  late Box<TimeEntry> _timeEntryBox;
  UserSettings? _userSettings;
  List<TimeEntry> _allEntries = [];
  Duration _calculatedOvertime = Duration.zero;
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final sign = duration.isNegative ? '-' : '';
    return '$sign${hours.abs().toString().padLeft(2, '0')}:${minutes.abs().toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    _timeEntryBox = Hive.box<TimeEntry>('time_entries');
    _loadEntriesFromHive().then((_) => _loadAndCheckSettings());
    _loadData();
  }

  void _groupEntriesByDate(List<TimeEntry> entries) {
    Map<DateTime, List<TimeEntry>> grouped = {};

    for (var entry in entries) {
      final date = _normalizeDay(entry.entryDate);
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(entry);
    }

    setState(() {
      _entries = grouped;
    });
  }

  Future<void> _loadData() async {
    final settings = await UserSettingsService.loadSettings();
    if (settings == null) return;
    final entries = _timeEntryBox.values.toList();
    final calculator = TimeCalculator(entries: entries, userSettings: settings);

    setState(() {
      _userSettings = settings;
      _allEntries = entries;
      _calculatedOvertime = calculator.calculateOvertime();
    });

    _groupEntriesByDate(
      entries,
    ); // Optional: if you use this to show entries per day
  }

  Future<void> _loadAndCheckSettings() async {
    final settings = await UserSettingsService.loadSettings();
    if (settings != null) {
      setState(() {
        _userSettings = settings;
      });
      final calculator = TimeCalculator(
        entries: _allEntries,
        userSettings: settings,
      );

      final updated = await UserSettingsService.checkAndApplyCarryOver(
        calculator.calculateOvertime().inMinutes,
        calculator.calculateVacationRemaining(),
        existingSettings: settings,
      );

      if (updated != null) {
        setState(() {
          _userSettings = updated;
        });
      }
    }
  }

  DateTime _normalizeDay(DateTime day) {
    return DateTime(day.year, day.month, day.day);
  }

  bool _isToday(DateTime? day) {
    if (day == null) return false;
    final now = DateTime.now();
    return day.year == now.year && day.month == now.month && day.day == now.day;
  }

  Future<void> _loadEntriesFromHive() async {
    final allEntries = _timeEntryBox.values;

    Map<DateTime, List<TimeEntry>> loaded = {};
    List<TimeEntry> flat = [];

    for (var entry in allEntries) {
      final date = _normalizeDay(entry.entryDate);
      flat.add(entry); // collect flat list
      if (!loaded.containsKey(date)) {
        loaded[date] = [];
      }
      loaded[date]!.add(entry);
    }

    setState(() {
      _entries = loaded;
      _allEntries = flat;
    });
  }

  void _handlePunch() {
    final loc = AppLocalizations.of(context)!;
    if (_selectedDay == null) return;

    final today = _normalizeDay(_selectedDay!);
    final now = DateTime.now();
    final dayEntries = _entries[today] ?? [];

    if (dayEntries.isNotEmpty && dayEntries.last.punchOut == null) {
      // Punch out
      final lastEntry = dayEntries.last;
      if (now.isBefore(lastEntry.punchIn)) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.errorPunchOutBeforeIn)));
        return;
      }

      setState(() {
        lastEntry.punchOut = now;
        lastEntry.save(); // Persist update in Hive
      });
      _loadData(); // Refresh overtime
    } else {
      // Punch in
      final newEntry = TimeEntry(punchIn: now, entryDate: today);
      _timeEntryBox.add(newEntry); // Save to Hive
      setState(() {
        dayEntries.add(newEntry);
        _entries[today] = dayEntries;
      });
      _loadData(); // Refresh overtime
    }
  }

  void _showEntriesForDay(DateTime day) {
    final loc = AppLocalizations.of(context)!;
    final normalizedDay = _normalizeDay(day);
    final entries = _entries[normalizedDay] ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C1C1A),
          title: Text(
            '${loc.entriesForDay} ${normalizedDay.toLocal().toString().split(' ')[0]}',
            style: const TextStyle(color: Color(0xFFEFE6D6)),
          ),
          content: entries.isEmpty
              ? Text(loc.noEntries, style: TextStyle(color: Color(0xFFEFE6D6)))
              : SingleChildScrollView(
                  child: Column(
                    children: entries.map((entry) {
                      final type = entry.entryType;
                      final timeRange = (entry.punchOut != null)
                          ? '${entry.punchIn.hour.toString().padLeft(2, '0')}:${entry.punchIn.minute.toString().padLeft(2, '0')} - '
                                '${entry.punchOut!.hour.toString().padLeft(2, '0')}:${entry.punchOut!.minute.toString().padLeft(2, '0')}'
                          : loc.manualFullDay;

                      return ListTile(
                        title: Text(
                          '$type ($timeRange)',
                          style: const TextStyle(color: Color(0xFFEFE6D6)),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFFCBA135),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _openEditEntryDialog(entry);
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () async {
                                await entry.delete();
                                await _loadData();
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                loc.close,
                style: TextStyle(color: Color(0xFFEFE6D6)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openEditEntryDialog(TimeEntry entry) async {
    final loc = AppLocalizations.of(context)!;
    final updatedEntry = await showDialog<TimeEntry>(
      context: context,
      builder: (context) {
        TimeOfDay? newStart = TimeOfDay.fromDateTime(entry.punchIn);
        TimeOfDay? newEnd = entry.punchOut != null
            ? TimeOfDay.fromDateTime(entry.punchOut!)
            : null;

        return AlertDialog(
          title: Text(loc.editEntry),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(loc.startTime),
                subtitle: Text(newStart.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: newStart!,
                  );
                  if (picked != null) {
                    newStart = picked;
                  }
                },
              ),
              ListTile(
                title: Text(loc.endTime),
                subtitle: Text(
                  newEnd != null ? newEnd.format(context) : loc.notSet,
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: newEnd ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    newEnd = picked;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed:
                  (newStart != null &&
                      (entry.punchOut == null || newEnd != null))
                  ? () async {
                      final newStartDate = DateTime(
                        entry.punchIn.year,
                        entry.punchIn.month,
                        entry.punchIn.day,
                        newStart!.hour,
                        newStart!.minute,
                      );

                      final newEndDate = entry.punchOut != null
                          ? DateTime(
                              entry.punchOut!.year,
                              entry.punchOut!.month,
                              entry.punchOut!.day,
                              newEnd!.hour,
                              newEnd!.minute,
                            )
                          : null;

                      // ✅ Validate punch-out is after punch-in
                      if (newEndDate != null &&
                          newEndDate.isBefore(newStartDate)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.errorPunchOutBeforeIn)),
                        );
                        return;
                      }

                      entry.punchIn = newStartDate;
                      entry.punchOut = newEndDate;

                      await entry.save();
                      Navigator.pop(context, entry);
                    }
                  : null,
              child: Text(loc.save),
            ),
          ],
        );
      },
    );

    if (updatedEntry != null) {
      await _loadData(); // Refresh overtime & other summaries
      final dateKey = _normalizeDay(updatedEntry.start);
      final entries = _entries[dateKey] ?? [];
      final index = entries.indexWhere((e) => e.key == entry.key);
      if (index != -1) {
        entries[index] = updatedEntry;
        setState(() {
          _entries[dateKey] = entries;
        });
      }
    }
  }

  void _openManualEntryDialog() async {
    final loc = AppLocalizations.of(context)!;
    final punchInController = TextEditingController();
    final punchOutController = TextEditingController();
    final breakController = TextEditingController();
    final giftedHoursController = TextEditingController();

    final prefs = await SharedPreferences.getInstance();
    final weeklyHours = prefs.getDouble('weeklyRequiredHours') ?? 40.0;
    final defaultDailyMinutes = ((weeklyHours / 5) * 60).round();

    TimeOfDay? selectedPunchIn;
    TimeOfDay? selectedPunchOut;

    showDialog(
      context: context,
      builder: (context) {
        String _selectedEntryType = 'Regular';
        final Map<String, String> localizedEntryTypes = {
          'Regular': loc.entryTypeLabelRegular,
          'Sick Day': loc.entryTypeLabelSickDay,
          'Vacation': loc.entryTypeLabelVacation,
          'Gifted Time': loc.entryTypeLabelGiftedTime,
          'Public Holiday': loc.entryTypeLabelPublicHoliday,
          'Overtime Taken': loc.entryTypeLabelOvertimeTaken,
        };
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C1C1A),
              title: Text(
                loc.manualEntryTitle,
                style: TextStyle(color: Color(0xFFEFE6D6)),
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    if (_selectedEntryType == 'Regular') ...[
                      TextField(
                        controller: punchInController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: loc.punchInTime,
                          labelStyle: TextStyle(color: Color(0xFFEFE6D6)),
                        ),
                        style: const TextStyle(color: Color(0xFFEFE6D6)),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            selectedPunchIn = picked;
                            punchInController.text = picked.format(context);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: punchOutController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: loc.punchOutTime,
                          labelStyle: TextStyle(color: Color(0xFFEFE6D6)),
                        ),
                        style: const TextStyle(color: Color(0xFFEFE6D6)),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            selectedPunchOut = picked;
                            punchOutController.text = picked.format(context);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: breakController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: loc.breakInMinutes,
                          labelStyle: TextStyle(color: Color(0xFFEFE6D6)),
                        ),
                        style: const TextStyle(color: Color(0xFFEFE6D6)),
                      ),
                      const SizedBox(height: 12),
                    ],
                    DropdownButtonFormField<String>(
                      dropdownColor: const Color(0xFF2C1C1A),
                      value: _selectedEntryType,
                      decoration: InputDecoration(
                        labelText: loc.entryType,
                        labelStyle: TextStyle(color: Color(0xFFEFE6D6)),
                      ),
                      items: localizedEntryTypes.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key, // use the internal value!
                          child: Text(
                            entry.value, // localized label
                            style: const TextStyle(color: Color(0xFFEFE6D6)),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedEntryType = value;
                            giftedHoursController.clear();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_selectedEntryType == 'Gifted Time' ||
                        _selectedEntryType == 'Overtime Taken')
                      TextField(
                        controller: giftedHoursController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: loc.giftedHours,
                          labelStyle: TextStyle(color: Color(0xFFEFE6D6)),
                        ),
                        style: const TextStyle(color: Color(0xFFEFE6D6)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    loc.cancel,
                    style: TextStyle(color: Color(0xFFEFE6D6)),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final selectedDay = _normalizeDay(_selectedDay!);
                    int workedMinutes;

                    DateTime? punchIn;
                    DateTime? punchOut;
                    int breakMinutes = 0;

                    if (_selectedEntryType == 'Regular') {
                      if (selectedPunchIn == null || selectedPunchOut == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.errorSelectPunchTimes)),
                        );
                        return;
                      }

                      // Validate punch-out is after punch-in
                      if (selectedPunchOut!.hour < selectedPunchIn!.hour ||
                          (selectedPunchOut!.hour == selectedPunchIn!.hour &&
                              selectedPunchOut!.minute <=
                                  selectedPunchIn!.minute)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.errorPunchOutBeforeIn)),
                        );
                        return;
                      }

                      punchIn = DateTime(
                        selectedDay.year,
                        selectedDay.month,
                        selectedDay.day,
                        selectedPunchIn!.hour,
                        selectedPunchIn!.minute,
                      );
                      punchOut = DateTime(
                        selectedDay.year,
                        selectedDay.month,
                        selectedDay.day,
                        selectedPunchOut!.hour,
                        selectedPunchOut!.minute,
                      );

                      breakMinutes = int.tryParse(breakController.text) ?? 0;
                      workedMinutes =
                          punchOut.difference(punchIn).inMinutes - breakMinutes;
                    } else if (_selectedEntryType == 'Gifted Time' ||
                        _selectedEntryType == 'Overtime Taken') {
                      final giftedHours = double.tryParse(
                        giftedHoursController.text,
                      );
                      if (giftedHours == null || giftedHours <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _selectedEntryType == 'Gifted Time'
                                  ? loc.errorGiftedHoursRequired
                                  : loc.errorOvertimeTakenRequired,
                            ),
                          ),
                        );
                        return;
                      }
                      workedMinutes = (giftedHours * 60).round();
                    } else {
                      // Sick Day, Vacation, Public Holiday
                      workedMinutes = defaultDailyMinutes;
                    }

                    final newEntry = TimeEntry(
                      punchIn: punchIn ?? selectedDay,
                      punchOut: punchOut,
                      breakDeductedInMinutes: breakMinutes,
                      manualWorkDurationInMinutes: workedMinutes,
                      entryDate: selectedDay,
                      entryType: _selectedEntryType,
                    );

                    _timeEntryBox.add(newEntry);

                    setState(() {
                      _entries[selectedDay] = (_entries[selectedDay] ?? [])
                        ..add(newEntry);
                    });

                    Navigator.pop(context);

                    await _loadData(); // ✅ Recalculate overtime and reload UI data
                    setState(() {}); // ✅ Refresh visible screen
                  },
                  child: Text(
                    loc.save,
                    style: TextStyle(color: Color(0xFFCBA135)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _normalizeDay(_selectedDay ?? DateTime.now());
    final selectedEntries = _entries[selected] ?? [];
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF1D1A1A),
      appBar: AppBar(
        title: Text(loc.appTitle),
        backgroundColor: const Color(0xFF2C1C1A),
        centerTitle: true,
        foregroundColor: const Color(0xFFCBA135),
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Toggle Language',
            onPressed: widget.onToggleLocale,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            tooltip: loc.aboutMeTitle,
            onSelected: (value) {
              if (value == 'about') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AboutMeScreen(onReset: _loadEntriesFromHive),
                  ),
                );
              } else if (value == 'weeklySummary') {
                if (_userSettings == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Settings not loaded yet.")),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeeklySummaryScreen(
                      entries: _entries.values.expand((list) => list).toList(),
                      userSettings: _userSettings!,
                    ),
                  ),
                );
              } else if (value == 'monthlySummary') {
                if (_userSettings == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Settings not loaded yet.")),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MonthlySummaryScreen(
                      entries: _entries.values.expand((list) => list).toList(),
                      userSettings: _userSettings!,
                    ),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(value: 'about', child: Text(loc.aboutMeTitle)),
              PopupMenuItem(
                value: 'weeklySummary',
                child: Text(
                  loc.summaryWeekLabel,
                ), // ← Add this to your ARB files!
              ),
              PopupMenuItem(
                value: 'monthlySummary',
                child: Text(loc.summaryMonthLabel),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            if (_userSettings != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  '${loc.overtimeHours}: ${_formatDuration(_calculatedOvertime)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFCBA135), // Burnt gold style
                  ),
                ),
              ),
            TableCalendar(
              locale: Localizations.localeOf(context).languageCode,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                // No dialog on tap!
              },
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF7B1E22),
                  shape: BoxShape.circle,
                ),
                todayDecoration: const BoxDecoration(
                  color: Color(0xFFB84335),
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: const TextStyle(color: Color(0xFFEFE6D6)),
                defaultTextStyle: const TextStyle(color: Color(0xFFEFE6D6)),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Color(0xFFEFE6D6)),
                weekendStyle: TextStyle(color: Color(0xFFEFE6D6)),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: Color(0xFFCBA135),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final normalizedDay = _normalizeDay(day);
                  final entries = _entries[normalizedDay] ?? [];

                  if (entries.isEmpty) return null;

                  // Prioritize types
                  final priority = [
                    'Public Holiday',
                    'Vacation',
                    'Sick Day',
                    'Gifted Time',
                    'Overtime Taken',
                    'Regular',
                  ];

                  entries.sort(
                    (a, b) => priority
                        .indexOf(a.entryType)
                        .compareTo(priority.indexOf(b.entryType)),
                  );
                  final type = entries.first.entryType;

                  Widget dayWidget = Text(
                    '${day.day}',
                    style: const TextStyle(color: Color(0xFFEFE6D6)),
                  );

                  Widget marker;

                  switch (type) {
                    case 'Regular':
                      marker = Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF57C00),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: dayWidget,
                      );
                      break;
                    case 'Vacation':
                      marker = Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/vacation.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          dayWidget,
                        ],
                      );
                      break;
                    case 'Sick Day':
                      marker = Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFFCBA135),
                            width: 1.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: dayWidget,
                      );
                      break;
                    case 'Public Holiday':
                      marker = Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            'assets/images/holiday.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          dayWidget,
                        ],
                      );
                      break;
                    case 'Gifted Time':
                      marker = Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFFF57C00),
                            width: 1.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: dayWidget,
                      );
                      break;
                    case 'Overtime Taken':
                      marker = Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color(0xFF7B1E22),
                            width: 1.5,
                          ),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: dayWidget,
                      );
                      break;
                    default:
                      marker = dayWidget;
                      break;
                  }

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDay = day;
                        _focusedDay = day;
                      });
                    },
                    onLongPress: () {
                      _showEntriesForDay(day);
                    },
                    child: marker,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedDay == null
                  ? loc.selectDayPrompt
                  : '${loc.selectedDate}: ${DateFormat.yMMMd().format(_selectedDay!)}',
              style: const TextStyle(color: Color(0xFFEFE6D6), fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isToday(_selectedDay)
                  ? _handlePunch
                  : _openManualEntryDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B1E22),
                foregroundColor: const Color(0xFFEFE6D6),
              ),
              child: Text(
                _isToday(_selectedDay) ? loc.punchInOut : loc.addManualTime,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: selectedEntries.isEmpty
                  ? Center(
                      child: Text(
                        loc.noEntries,
                        style: TextStyle(color: Color(0xFFEFE6D6)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: selectedEntries.length,
                      itemBuilder: (context, index) {
                        final entry = selectedEntries[index];

                        // Determine worked minutes
                        int workedMinutes;
                        if (entry.entryType == 'Regular') {
                          if (entry.punchOut != null) {
                            final total = entry.punchOut!
                                .difference(entry.punchIn)
                                .inMinutes;
                            workedMinutes =
                                total - entry.breakDeductedInMinutes;
                          } else {
                            workedMinutes = 0;
                          }
                        } else {
                          workedMinutes =
                              entry.manualWorkDurationInMinutes ?? 0;
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C1C1A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.entryType,
                                style: const TextStyle(
                                  color: Color(0xFFEFE6D6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (entry.entryType == 'Regular') ...[
                                Text(
                                  '${loc.inLabel}: ${DateFormat.Hm().format(entry.punchIn)}  —  ${loc.outLabel}: ${entry.punchOut != null ? DateFormat.Hm().format(entry.punchOut!) : "..."}',
                                  style: const TextStyle(
                                    color: Color(0xFFEFE6D6),
                                  ),
                                ),
                                Text(
                                  '${loc.breakLabel}: ${entry.breakDeductedInMinutes} min',
                                  style: const TextStyle(
                                    color: Color(0xFFEFE6D6),
                                  ),
                                ),
                              ],
                              Text(
                                '${loc.workedLabel}: ${(workedMinutes / 60).toStringAsFixed(2)} h',
                                style: const TextStyle(
                                  color: Color(0xFFCBA135),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
