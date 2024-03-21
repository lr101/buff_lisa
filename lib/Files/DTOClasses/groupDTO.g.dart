// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'groupDTO.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroupDTOAdapter extends TypeAdapter<GroupDTO> {
  @override
  final int typeId = 1;

  @override
  GroupDTO read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupDTO(
      groupId: fields[0] as int,
      name: fields[1] as String,
      visibility: fields[2] as int,
      inviteUrl: fields[3] as String?,
      groupAdmin: fields[4] as String?,
      description: fields[5] as String?,
      profileImage: fields[6] as Uint8List?,
      pinImage: fields[7] as Uint8List?,
      lastUpdated: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, GroupDTO obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.groupId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.visibility)
      ..writeByte(3)
      ..write(obj.inviteUrl)
      ..writeByte(4)
      ..write(obj.groupAdmin)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.profileImage)
      ..writeByte(7)
      ..write(obj.pinImage)
      ..writeByte(8)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupDTOAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
