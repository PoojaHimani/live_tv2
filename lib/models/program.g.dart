// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgramAdapter extends TypeAdapter<Program> {
  @override
  final int typeId = 2;

  @override
  Program read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Program(
      id: fields[0] as String,
      title: fields[1] as String,
      channelId: fields[2] as String,
      startTime: fields[3] as DateTime,
      endTime: fields[4] as DateTime,
      durationSeconds: fields[5] as int,
      videoUrl: fields[6] as String,
      videoType: fields[7] as VideoType,
      episodeInfo: fields[8] as String?,
      isNew: fields[9] as bool,
      thumbnailUrl: fields[10] as String?,
      description: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Program obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.channelId)
      ..writeByte(3)
      ..write(obj.startTime)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.durationSeconds)
      ..writeByte(6)
      ..write(obj.videoUrl)
      ..writeByte(7)
      ..write(obj.videoType)
      ..writeByte(8)
      ..write(obj.episodeInfo)
      ..writeByte(9)
      ..write(obj.isNew)
      ..writeByte(10)
      ..write(obj.thumbnailUrl)
      ..writeByte(11)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VideoTypeAdapter extends TypeAdapter<VideoType> {
  @override
  final int typeId = 1;

  @override
  VideoType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VideoType.mp4;
      case 1:
        return VideoType.youtube;
      case 2:
        return VideoType.hls;
      case 3:
        return VideoType.dash;
      default:
        return VideoType.mp4;
    }
  }

  @override
  void write(BinaryWriter writer, VideoType obj) {
    switch (obj) {
      case VideoType.mp4:
        writer.writeByte(0);
        break;
      case VideoType.youtube:
        writer.writeByte(1);
        break;
      case VideoType.hls:
        writer.writeByte(2);
        break;
      case VideoType.dash:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
