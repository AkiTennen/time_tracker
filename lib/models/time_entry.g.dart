// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimeEntryAdapter extends TypeAdapter<TimeEntry> {
  @override
  final int typeId = 0;

  @override
  TimeEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimeEntry(
      punchIn: fields[0] as DateTime,
      punchOut: fields[1] as DateTime?,
      breakDeductedInMinutes: fields[2] as int,
      entryDate: fields[3] as DateTime,
      entryType: fields[4] as String,
      manualWorkDurationInMinutes: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TimeEntry obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.punchIn)
      ..writeByte(1)
      ..write(obj.punchOut)
      ..writeByte(2)
      ..write(obj.breakDeductedInMinutes)
      ..writeByte(3)
      ..write(obj.entryDate)
      ..writeByte(4)
      ..write(obj.entryType)
      ..writeByte(5)
      ..write(obj.manualWorkDurationInMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
