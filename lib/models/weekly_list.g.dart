// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeeklyListAdapter extends TypeAdapter<WeeklyList> {
  @override
  final int typeId = 1;

  @override
  WeeklyList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyList(
      name: fields[0] as String,
      items: (fields[1] as List).cast<Item>(),
      weekNumber: fields[2] as int,
      year: fields[3] as int,
      status: fields[4] as String,
      startDate: fields[5] as DateTime,
      endDate: fields[6] as DateTime,
      familyGroupId: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WeeklyList obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.items)
      ..writeByte(2)
      ..write(obj.weekNumber)
      ..writeByte(3)
      ..write(obj.year)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.endDate)
      ..writeByte(7)
      ..write(obj.familyGroupId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
