// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventListAdapter extends TypeAdapter<EventList> {
  @override
  final int typeId = 2;

  @override
  EventList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventList(
      name: fields[0] as String,
      items: (fields[1] as List).cast<Item>(),
    );
  }

  @override
  void write(BinaryWriter writer, EventList obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
