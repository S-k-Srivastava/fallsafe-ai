import 'package:hive/hive.dart';

part 'detection_session.g.dart';

/// A recorded detection session
@HiveType(typeId: 0)
class DetectionSession extends HiveObject {
  @HiveField(0)
  final DateTime startTime;

  @HiveField(1)
  DateTime? endTime;

  @HiveField(2)
  final double fallThreshold;

  @HiveField(3)
  int totalFrames;

  @HiveField(4)
  int totalInferences;

  @HiveField(5)
  int fallsDetected;

  @HiveField(6)
  double? maxFallProbability;

  @HiveField(7)
  String? lastActivity;

  @HiveField(8)
  List<SessionEvent> events;

  DetectionSession({
    required this.startTime,
    this.endTime,
    required this.fallThreshold,
    this.totalFrames = 0,
    this.totalInferences = 0,
    this.fallsDetected = 0,
    this.maxFallProbability,
    this.lastActivity,
    List<SessionEvent>? events,
  }) : events = events ?? [];

  /// Duration of the session
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Whether session is still running
  bool get isActive => endTime == null;

  /// Format duration for display
  String get durationString {
    final d = duration;
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    } else if (d.inMinutes > 0) {
      return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    } else {
      return '${d.inSeconds}s';
    }
  }

  /// Add an event to the session
  void addEvent(SessionEvent event) {
    events.add(event);
    save();
  }

  /// End the session
  void end({
    required int frames,
    required int inferences,
    required int falls,
    double? maxProb,
    String? activity,
  }) {
    endTime = DateTime.now();
    totalFrames = frames;
    totalInferences = inferences;
    fallsDetected = falls;
    maxFallProbability = maxProb;
    lastActivity = activity;
    save();
  }
}

/// An event within a session (like a fall detection)
@HiveType(typeId: 1)
class SessionEvent {
  @HiveField(0)
  final DateTime timestamp;

  @HiveField(1)
  final SessionEventType type;

  @HiveField(2)
  final double? probability;

  @HiveField(3)
  final String? activity;

  @HiveField(4)
  final String? details;

  SessionEvent({
    required this.timestamp,
    required this.type,
    this.probability,
    this.activity,
    this.details,
  });
}

/// Types of session events
@HiveType(typeId: 2)
enum SessionEventType {
  @HiveField(0)
  sessionStart,

  @HiveField(1)
  sessionEnd,

  @HiveField(2)
  fallDetected,

  @HiveField(3)
  activityChanged,

  @HiveField(4)
  bufferFilled,
}
