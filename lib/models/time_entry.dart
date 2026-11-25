import 'package:hive/hive.dart';

part 'time_entry.g.dart'; // Needed for code generation

@HiveType(typeId: 0)
class TimeEntry extends HiveObject {
  @HiveField(0)
  DateTime punchIn;

  @HiveField(1)
  DateTime? punchOut;

  @HiveField(2)
  int breakDeductedInMinutes;

  @HiveField(3)
  DateTime entryDate; // The calendar day this entry belongs to

  @HiveField(4)
  String entryType; // e.g., "Regular", "Sick Day", "Vacation", "Gifted Time", "Public Holiday"

  @HiveField(5)
  int? manualWorkDurationInMinutes; // <-- NEW FIELD

  TimeEntry({
    required this.punchIn,
    this.punchOut,
    this.breakDeductedInMinutes = 0,
    required this.entryDate,
    this.entryType = 'Regular', // default value
    this.manualWorkDurationInMinutes, // <-- NEW
  });
  // Add these computed properties for compatibility with editing UI
  DateTime get start => punchIn;
  DateTime? get end => punchOut;

  // Optional: if you want to allow setting via `start = ...`
  set start(DateTime value) => punchIn = value;
  set end(DateTime? value) => punchOut = value;

  // Add this method to allow editing an existing entry
  TimeEntry copyWith({
    DateTime? punchIn,
    DateTime? punchOut,
    int? breakDeductedInMinutes,
    DateTime? entryDate,
    String? entryType,
    int? manualWorkDurationInMinutes,
  }) {
    return TimeEntry(
      punchIn: punchIn ?? this.punchIn,
      punchOut: punchOut ?? this.punchOut,
      breakDeductedInMinutes:
          breakDeductedInMinutes ?? this.breakDeductedInMinutes,
      entryDate: entryDate ?? this.entryDate,
      entryType: entryType ?? this.entryType,
      manualWorkDurationInMinutes:
          manualWorkDurationInMinutes ?? this.manualWorkDurationInMinutes,
    );
  }
}
