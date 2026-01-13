import 'activity_type.dart';

/// Result from fall detection inference
class InferenceResult {
  final double fallProbability;
  final int activityClass;
  final List<double> activityProbabilities;
  final int inferenceTimeMs;
  final DateTime timestamp;

  const InferenceResult({
    required this.fallProbability,
    required this.activityClass,
    required this.activityProbabilities,
    required this.inferenceTimeMs,
    required this.timestamp,
  });

  /// Whether a fall was detected (probability > 0.5)
  bool get isFallDetected => fallProbability > 0.5;

  /// Get the activity name for display
  String get activityName => getActivityName(activityClass);

  /// Get activity emoji for display
  String get activityEmoji => getActivityEmoji(activityClass);

  /// Get confidence of the detected activity
  double get activityConfidence {
    if (activityProbabilities.isEmpty) return 0.0;
    return activityProbabilities[activityClass];
  }

  /// Check if detected activity is a fall type
  bool get isActivityFall => isFallActivity(activityClass);

  @override
  String toString() =>
      'InferenceResult(fall: ${fallProbability.toStringAsFixed(3)}, '
      'activity: $activityClass ($activityName), time: ${inferenceTimeMs}ms)';
}
