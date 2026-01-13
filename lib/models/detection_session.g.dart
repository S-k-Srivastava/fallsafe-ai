// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetectionSessionAdapter extends TypeAdapter<DetectionSession> {
  @override
  final int typeId = 0;

  @override
  DetectionSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetectionSession(
      startTime: fields[0] as DateTime,
      endTime: fields[1] as DateTime?,
      fallThreshold: fields[2] as double,
      totalFrames: fields[3] as int,
      totalInferences: fields[4] as int,
      fallsDetected: fields[5] as int,
      maxFallProbability: fields[6] as double?,
      lastActivity: fields[7] as String?,
      events: (fields[8] as List?)?.cast<SessionEvent>(),
    );
  }

  @override
  void write(BinaryWriter writer, DetectionSession obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.endTime)
      ..writeByte(2)
      ..write(obj.fallThreshold)
      ..writeByte(3)
      ..write(obj.totalFrames)
      ..writeByte(4)
      ..write(obj.totalInferences)
      ..writeByte(5)
      ..write(obj.fallsDetected)
      ..writeByte(6)
      ..write(obj.maxFallProbability)
      ..writeByte(7)
      ..write(obj.lastActivity)
      ..writeByte(8)
      ..write(obj.events);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SessionEventAdapter extends TypeAdapter<SessionEvent> {
  @override
  final int typeId = 1;

  @override
  SessionEvent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SessionEvent(
      timestamp: fields[0] as DateTime,
      type: fields[1] as SessionEventType,
      probability: fields[2] as double?,
      activity: fields[3] as String?,
      details: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SessionEvent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.probability)
      ..writeByte(3)
      ..write(obj.activity)
      ..writeByte(4)
      ..write(obj.details);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionEventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SessionEventTypeAdapter extends TypeAdapter<SessionEventType> {
  @override
  final int typeId = 2;

  @override
  SessionEventType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SessionEventType.sessionStart;
      case 1:
        return SessionEventType.sessionEnd;
      case 2:
        return SessionEventType.fallDetected;
      case 3:
        return SessionEventType.activityChanged;
      case 4:
        return SessionEventType.bufferFilled;
      default:
        return SessionEventType.sessionStart;
    }
  }

  @override
  void write(BinaryWriter writer, SessionEventType obj) {
    switch (obj) {
      case SessionEventType.sessionStart:
        writer.writeByte(0);
        break;
      case SessionEventType.sessionEnd:
        writer.writeByte(1);
        break;
      case SessionEventType.fallDetected:
        writer.writeByte(2);
        break;
      case SessionEventType.activityChanged:
        writer.writeByte(3);
        break;
      case SessionEventType.bufferFilled:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionEventTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
