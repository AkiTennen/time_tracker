import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import '../models/time_entry.dart';
import '../services/user_settings_service.dart';
import '../models/user_settings.dart';
import '../l10n/app_localizations.dart';

class AboutMeScreen extends StatefulWidget {
  final VoidCallback? onReset;

  const AboutMeScreen({Key? key, this.onReset}) : super(key: key);

  @override
  State<AboutMeScreen> createState() => _AboutMeScreenState();
}

class _AboutMeScreenState extends State<AboutMeScreen> {
  final _formKey = GlobalKey<FormState>();
  UserSettings? _userSettings;

  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weeklyHoursController = TextEditingController();
  final TextEditingController _vacationCarriedController =
      TextEditingController();
  final TextEditingController _vacationThisYearController =
      TextEditingController();
  final TextEditingController _vacationTakenController =
      TextEditingController();
  final TextEditingController _vacationPlannedController =
      TextEditingController();
  final TextEditingController _regularBreakController = TextEditingController();
  final TextEditingController _employerAddressController =
      TextEditingController();
  final TextEditingController _overtimeHoursController =
      TextEditingController();
  final TextEditingController _overtimeMinutesController =
      TextEditingController();
  final TextEditingController _workingDaysController = TextEditingController();

  int vacationTaken = 0;
  int vacationPlanned = 0;
  bool _useGermanLaborLaw = false;
  DateTime? _employmentStartDate;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await UserSettingsService.checkForCarryOver();
    await _loadData();
    setState(() {});
  }

  Future<void> _loadData() async {
    _userSettings = await UserSettingsService.loadSettings();

    if (_userSettings == null) {
      _companyController.text = '';
      _nameController.text = '';
      _weeklyHoursController.text = '';
      _overtimeHoursController.text = '0';
      _overtimeMinutesController.text = '0';
      _vacationCarriedController.text = '0';
      _vacationThisYearController.text = '0';
      _vacationTakenController.text = '0';
      _vacationPlannedController.text = '0';
      _regularBreakController.text = '0';
      _employerAddressController.text = '';
      _workingDaysController.text = '5';
      _employmentStartDate = null;
    } else {
      final allEntries = Hive.box<TimeEntry>('time_entries').values;
      final now = DateTime.now();

      vacationTaken = allEntries
          .where((e) => e.entryType == 'Vacation' && !e.entryDate.isAfter(now))
          .length;
      vacationPlanned = allEntries
          .where((e) => e.entryType == 'Vacation' && e.entryDate.isAfter(now))
          .length;

      _companyController.text = _userSettings!.companyName;
      _nameController.text = _userSettings!.userName;
      _weeklyHoursController.text = _userSettings!.weeklyHours.toString();
      _overtimeHoursController.text = _userSettings!.carriedOverOvertimeHours
          .toString();
      _overtimeMinutesController.text = _userSettings!
          .carriedOverOvertimeRemainingMinutes
          .toString();
      _vacationCarriedController.text = _userSettings!.vacationCarried
          .toString();
      _vacationThisYearController.text = _userSettings!.vacationThisYear
          .toString();
      _vacationTakenController.text = vacationTaken.toString();
      _vacationPlannedController.text = vacationPlanned.toString();
      _regularBreakController.text = _userSettings!.regularBreakMinutes
          .toString();
      _employerAddressController.text = _userSettings!.employerAddress;
      _useGermanLaborLaw = _userSettings!.useGermanLaborLaw;
      _workingDaysController.text = _userSettings!.workingDaysPerWeek.toString();
      _employmentStartDate = _userSettings!.employmentStartDate;

      _userSettings = _userSettings!.copyWith(
        vacationTaken: vacationTaken,
        vacationPlanned: vacationPlanned,
      );
    }
  }

  Future<void> _saveData() async {
    final loc = AppLocalizations.of(context)!;
    final overtimeHours = int.tryParse(_overtimeHoursController.text) ?? 0;
    final overtimeMinutes = int.tryParse(_overtimeMinutesController.text) ?? 0;
    final totalOvertimeMinutes = overtimeHours * 60 + overtimeMinutes;

    final settings = UserSettings(
      companyName: _companyController.text,
      userName: _nameController.text,
      weeklyHours: int.tryParse(_weeklyHoursController.text) ?? 0,
      carriedOverOvertime: totalOvertimeMinutes,
      vacationCarried: int.tryParse(_vacationCarriedController.text) ?? 0,
      vacationThisYear: int.tryParse(_vacationThisYearController.text) ?? 0,
      vacationTaken: vacationTaken,
      vacationPlanned: vacationPlanned,
      regularBreakMinutes: int.tryParse(_regularBreakController.text) ?? 0,
      employerAddress: _employerAddressController.text,
      lastCarryOverAppliedYear: DateTime.now().year,
      useGermanLaborLaw: _useGermanLaborLaw,
      workingDaysPerWeek: int.tryParse(_workingDaysController.text) ?? 5,
      employmentStartDate: _employmentStartDate,
    );

    await UserSettingsService.saveSettings(settings);

    _userSettings = settings;
    await _loadData();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.dataSaved)));
  }

  Future<void> _resetEverything() async {
    final loc = AppLocalizations.of(context)!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Clear Hive time entries
    final timeBox = await Hive.openBox<TimeEntry>('time_entries');
    await timeBox.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(loc.allDataReset)));
    setState(() {
      _companyController.clear();
      _nameController.clear();
      _weeklyHoursController.clear();
      _overtimeHoursController.clear();
      _overtimeMinutesController.clear();
      _vacationCarriedController.clear();
      _vacationThisYearController.clear();
      _vacationTakenController.clear();
      _vacationPlannedController.clear();
      _regularBreakController.clear();
      _employerAddressController.clear();
      _workingDaysController.text = '5';
      _useGermanLaborLaw = false;
      _employmentStartDate = null;
    });
    if (widget.onReset != null) {
      widget.onReset!(); // Call the callback after reset
    }
  }

  void _confirmReset() async {
    final loc = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.confirmResetTitle),
        content: Text(loc.confirmResetMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              loc.deleteEverything,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _resetEverything();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF1D1A1A),
      appBar: AppBar(
        title: Text(loc.aboutMeTitle),
        backgroundColor: const Color(0xFF2C1C1A),
        foregroundColor: const Color(0xFFCBA135),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                "\u{1F3E2} ${loc.companyName}",
                style: const TextStyle(
                  color: Color(0xFFCBA135),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildTextField(_companyController, loc.companyName),
              _buildTextField(_employerAddressController, loc.employerAddress),

              const SizedBox(height: 16),
              Text(
                "\u{1F464} ${loc.userName}",
                style: const TextStyle(
                  color: Color(0xFFCBA135),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildTextField(_nameController, loc.userName),

              const SizedBox(height: 16),
              Text(
                "\u{23F0} ${loc.requiredWeeklyHours}",
                style: const TextStyle(
                  color: Color(0xFFCBA135),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildNumberField(
                _weeklyHoursController,
                loc.requiredWeeklyHours,
              ),
              _buildNumberField(
                _regularBreakController,
                loc.regularBreakDuration,
              ),
              _buildNumberField(
                _workingDaysController,
                loc.workingDaysPerWeek,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(loc.employmentStartDate, style: const TextStyle(color: Color(0xFFCBA135))),
                subtitle: Text(
                  _employmentStartDate != null ? DateFormat.yMMMd().format(_employmentStartDate!) : loc.notSet,
                  style: const TextStyle(color: Color(0xFFEFE6D6)),
                ),
                trailing: const Icon(Icons.calendar_today, color: Color(0xFFCBA135)),
                tileColor: const Color(0xFF2C1C1A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFCBA135)),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _employmentStartDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
                  );
                  if (picked != null) {
                    setState(() {
                      _employmentStartDate = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(loc.germanLaborLaw, style: const TextStyle(color: Color(0xFFEFE6D6))),
                subtitle: Text(loc.germanLaborLawDescription, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                value: _useGermanLaborLaw,
                activeThumbColor: const Color(0xFFCBA135),
                inactiveTrackColor: const Color(0xFF2C1C1A),
                tileColor: const Color(0xFF2C1C1A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFCBA135)),
                ),
                onChanged: (val) {
                  setState(() {
                    _useGermanLaborLaw = val;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                "\u{1F334} ${loc.vacationThisYear}",
                style: const TextStyle(
                  color: Color(0xFFCBA135),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildNumberField(
                _vacationCarriedController,
                loc.vacationCarried,
              ),
              _buildNumberField(
                _vacationThisYearController,
                loc.vacationThisYear,
              ),
              _buildNumberField(_vacationTakenController, loc.vacationTaken),
              _buildNumberField(
                _vacationPlannedController,
                loc.vacationPlanned,
              ),

              const SizedBox(height: 16),
              Text(
                "\u{23F1}\u{FE0F} ${loc.overtimeHours}",
                style: const TextStyle(
                  color: Color(0xFFCBA135),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      _overtimeHoursController,
                      loc.overtimeHours,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberField(
                      _overtimeMinutesController,
                      loc.overtimeMinutes,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(
                "\u{1F4CA} ${loc.vacationLeftAfterTaken}",
                style: const TextStyle(
                  color: Color(0xFFCBA135),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C1C1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFCBA135)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReadOnlyRow(
                      loc.vacationLeftAfterTaken,
                      '${_userSettings?.vacationLeftAfterTaken ?? 0} days',
                    ),
                    _buildReadOnlyRow(
                      loc.vacationLeftAfterPlanned,
                      '${_userSettings?.vacationLeftAfterPlanned ?? 0} days',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveData();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B1E22),
                  foregroundColor: const Color(0xFFEFE6D6),
                ),
                child: Text(loc.save),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _confirmReset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade900,
                  foregroundColor: Colors.white,
                ),
                child: Text(loc.resetEverything),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Color(0xFFEFE6D6)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFCBA135)),
          filled: true,
          fillColor: const Color(0xFF2C1C1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? loc.requiredField : null,
      ),
    );
  }

  Widget _buildNumberField(TextEditingController controller, String label) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Color(0xFFEFE6D6)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFCBA135)),
          filled: true,
          fillColor: const Color(0xFF2C1C1A),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return loc.requiredField;
          if (int.tryParse(value) == null) return loc.mustBeNumber;
          return null;
        },
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFCBA135))),
          Text(value, style: const TextStyle(color: Color(0xFFEFE6D6))),
        ],
      ),
    );
  }
}
