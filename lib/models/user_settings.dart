class UserSettings {
  final String companyName;
  final String userName;
  final int weeklyHours;
  final int carriedOverOvertime;
  final int vacationCarried;
  final int vacationThisYear;
  final int vacationTaken;
  final int vacationPlanned;
  final int regularBreakMinutes;
  final String employerAddress;
  final int lastCarryOverAppliedYear;
  int get requiredWeeklyHours => weeklyHours;
  int get carriedOverOvertimeInMinutes => carriedOverOvertime;
  int get carriedOverOvertimeHours => carriedOverOvertime ~/ 60;
  int get carriedOverOvertimeRemainingMinutes => carriedOverOvertime % 60;
  int get vacationLeftAfterTaken =>
      vacationCarried + vacationThisYear - vacationTaken;
  int get vacationLeftAfterPlanned =>
      vacationCarried + vacationThisYear - vacationTaken - vacationPlanned;

  UserSettings({
    required this.companyName,
    required this.userName,
    required this.employerAddress,
    required this.weeklyHours,
    required this.carriedOverOvertime,
    required this.vacationCarried,
    required this.vacationThisYear,
    required this.vacationTaken,
    required this.vacationPlanned,
    required this.regularBreakMinutes,
    required this.lastCarryOverAppliedYear,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'userName': userName,
      'employerAddress': employerAddress,
      'weeklyHours': weeklyHours,
      'carriedOverOvertime': carriedOverOvertime,
      'vacationCarried': vacationCarried,
      'vacationThisYear': vacationThisYear,
      'vacationTaken': vacationTaken,
      'vacationPlanned': vacationPlanned,
      'regularBreakMinutes': regularBreakMinutes,
      'lastCarryOverAppliedYear': lastCarryOverAppliedYear,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      companyName: map['companyName'] ?? '',
      userName: map['userName'] ?? '',
      employerAddress: map['employerAddress'] ?? '',
      weeklyHours: map['weeklyHours'] ?? 0,
      carriedOverOvertime: map['carriedOverOvertime'] ?? 0,
      vacationCarried: map['vacationCarried'] ?? 0,
      vacationThisYear: map['vacationThisYear'] ?? 0,
      vacationTaken: map['vacationTaken'] ?? 0,
      vacationPlanned: map['vacationPlanned'] ?? 0,
      regularBreakMinutes: map['regularBreakMinutes'] ?? 0,
      lastCarryOverAppliedYear: map['lastCarryOverAppliedYear'] ?? 0,
    );
  }
  UserSettings copyWith({
    String? companyName,
    String? userName,
    int? weeklyHours,
    int? carriedOverOvertime,
    int? vacationCarried,
    int? vacationThisYear,
    int? vacationTaken,
    int? vacationPlanned,
    int? regularBreakMinutes,
    String? employerAddress,
    int? lastCarryOverAppliedYear,
  }) {
    return UserSettings(
      companyName: companyName ?? this.companyName,
      userName: userName ?? this.userName,
      employerAddress: employerAddress ?? this.employerAddress,
      weeklyHours: weeklyHours ?? this.weeklyHours,
      carriedOverOvertime: carriedOverOvertime ?? this.carriedOverOvertime,
      vacationCarried: vacationCarried ?? this.vacationCarried,
      vacationThisYear: vacationThisYear ?? this.vacationThisYear,
      vacationTaken: vacationTaken ?? this.vacationTaken,
      vacationPlanned: vacationPlanned ?? this.vacationPlanned,
      regularBreakMinutes: regularBreakMinutes ?? this.regularBreakMinutes,
      lastCarryOverAppliedYear:
          lastCarryOverAppliedYear ?? this.lastCarryOverAppliedYear,
    );
  }
}
