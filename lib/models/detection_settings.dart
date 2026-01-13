/// Detection settings model with advanced fall detection parameters
class DetectionSettings {
  // Basic settings
  final double fallThreshold;
  final int windowSize;
  final int chartHistorySize;
  final bool showDebugLogs;

  // Advanced fall detection settings (NEW)
  final double
  confirmationThreshold; // Probability threshold for confirmation (0.8)
  final int confirmationFrames; // Required consecutive frames (3)
  final int cooldownSeconds; // Cooldown after fall detection (30s)
  final int inferenceSkipFrames; // Run inference every N frames (5)
  final bool enableImpactGate; // Require impact before detection
  final double impactThreshold; // Acceleration magnitude threshold (15.0)

  const DetectionSettings({
    this.fallThreshold = 0.5,
    this.windowSize = 200,
    this.chartHistorySize = 100,
    this.showDebugLogs = false,
    // Advanced defaults
    this.confirmationThreshold = 0.8,
    this.confirmationFrames = 3,
    this.cooldownSeconds = 30,
    this.inferenceSkipFrames = 5,
    this.enableImpactGate = true,
    this.impactThreshold = 15.0,
  });

  DetectionSettings copyWith({
    double? fallThreshold,
    int? windowSize,
    int? chartHistorySize,
    bool? showDebugLogs,
    double? confirmationThreshold,
    int? confirmationFrames,
    int? cooldownSeconds,
    int? inferenceSkipFrames,
    bool? enableImpactGate,
    double? impactThreshold,
  }) {
    return DetectionSettings(
      fallThreshold: fallThreshold ?? this.fallThreshold,
      windowSize: windowSize ?? this.windowSize,
      chartHistorySize: chartHistorySize ?? this.chartHistorySize,
      showDebugLogs: showDebugLogs ?? this.showDebugLogs,
      confirmationThreshold:
          confirmationThreshold ?? this.confirmationThreshold,
      confirmationFrames: confirmationFrames ?? this.confirmationFrames,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      inferenceSkipFrames: inferenceSkipFrames ?? this.inferenceSkipFrames,
      enableImpactGate: enableImpactGate ?? this.enableImpactGate,
      impactThreshold: impactThreshold ?? this.impactThreshold,
    );
  }

  /// Convert to map for logging/display
  Map<String, dynamic> toMap() {
    return {
      'fallThreshold': fallThreshold,
      'confirmationThreshold': confirmationThreshold,
      'confirmationFrames': confirmationFrames,
      'cooldownSeconds': cooldownSeconds,
      'inferenceSkipFrames': inferenceSkipFrames,
      'enableImpactGate': enableImpactGate,
      'impactThreshold': impactThreshold,
    };
  }

  /// Display-friendly summary
  String get summary =>
      'Threshold: ${(fallThreshold * 100).toInt()}%, '
      'Confirm: ${(confirmationThreshold * 100).toInt()}% x $confirmationFrames frames, '
      'Cooldown: ${cooldownSeconds}s, '
      'Inference: 1/$inferenceSkipFrames frames, '
      'Impact: ${enableImpactGate ? "${impactThreshold.toInt()} m/s²" : "OFF"}';

  /// Default settings
  static const DetectionSettings defaults = DetectionSettings();
}
