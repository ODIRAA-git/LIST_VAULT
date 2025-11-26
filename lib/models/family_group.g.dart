// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_group.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FamilyGroupAdapter extends TypeAdapter<FamilyGroup> {
  @override
  final int typeId = 5;

  @override
  FamilyGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FamilyGroup(
      groupId: fields[0] as String,
      groupName: fields[1] as String,
      memberIds: (fields[2] as List).cast<String>(),
      createdBy: fields[3] as String,
      createdDate: fields[4] as DateTime,
      maxMembers: fields[5] as int,
      joinCode: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FamilyGroup obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.groupId)
      ..writeByte(1)
      ..write(obj.groupName)
      ..writeByte(2)
      ..write(obj.memberIds)
      ..writeByte(3)
      ..write(obj.createdBy)
      ..writeByte(4)
      ..write(obj.createdDate)
      ..writeByte(5)
      ..write(obj.maxMembers)
      ..writeByte(6)
      ..write(obj.joinCode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FamilyGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
