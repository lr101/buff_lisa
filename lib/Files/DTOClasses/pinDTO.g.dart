// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pinDTO.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PinDTOAdapter extends TypeAdapter<PinDTO> {
  @override
  final int typeId = 0;

  @override
  PinDTO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PinDTO(
      latitude: fields[0] as double,
      longitude: fields[1] as double,
      id: fields[2] as int,
      creationDate: fields[3] as DateTime,
      username: fields[4] as String,
      groupId: fields[5] as int,
      image: fields[6] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, PinDTO obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.latitude)
      ..writeByte(1)
      ..write(obj.longitude)
      ..writeByte(2)
      ..write(obj.id)
      ..writeByte(3)
      ..write(obj.creationDate)
      ..writeByte(4)
      ..write(obj.username)
      ..writeByte(5)
      ..write(obj.groupId)
      ..writeByte(6)
      ..write(obj.image);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PinDTOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
