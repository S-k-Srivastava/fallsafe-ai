import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/sensor_data.dart';
import '../models/inference_result.dart';
import '../models/detection_settings.dart';
import '../models/detection_session.dart';
import '../services/sensor_service.dart';
import '../services/inference_service.dart';
import '../services/storage_service.dart';

/// Controller for managing fall detection state with advanced detection logic
class DetectionController extends ChangeNotifier {
  final SensorService _sensorService = SensorService();
  final InferenceService _inferenceService = InferenceService();

  StreamSubscription? _sensorSubscription;

  // Settings
  DetectionSettings _settings = DetectionSettings.defaults;

  // Current session
  DetectionSession? _currentSession;

  // Buffer for inference
  final List<SensorData> _buffer = [];

  // History for charts (last N samples)
  final Queue<SensorData> _sensorHistory = Queue();

  // Results history
  static const int resultsHistorySize = 20;
  final Queue<InferenceResult> _resultsHistory = Queue();

  // State
  bool _isInitialized = false;
  bool _isRunning = false;
  String? _error;

  // Stats
  int _frameCount = 0;
  int _inferenceCount = 0;
  int _fallsDetected = 0;
  double _maxFallProb = 0;
  String? _lastActivity;
  bool _bufferFilledLogged = false;

  // === ADVANCED FALL DETECTION STATE ===
  int _fallCounter = 0; // Consecutive high-prob frames
  DateTime? _lastFallTime; // For cooldown tracking
  int _framesSinceLastInference = 0; // For inference throttling
  double _lastAccMagnitude = 0; // Last acceleration magnitude

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isRunning => _isRunning;
  bool get isModelLoaded => _inferenceService.isLoaded;
  String? get error => _error;
  DetectionSettings get settings => _settings;
  DetectionSession? get currentSession => _currentSession;

  int get frameCount => _frameCount;
  int get inferenceCount => _inferenceCount;
  int get fallsDetected => _fallsDetected;
  int get bufferSize => _buffer.length;
  int get windowSize => _settings.windowSize;
  double get bufferProgress => _buffer.length / _settings.windowSize;
  int get fallCounter => _fallCounter;
  double get lastAccMagnitude => _lastAccMagnitude;

  // Cooldown state
  bool get isInCooldown {
    if (_lastFallTime == null) return false;
    final elapsed = DateTime.now().difference(_lastFallTime!);
    return elapsed.inSeconds < _settings.cooldownSeconds;
  }

  int get cooldownRemaining {
    if (_lastFallTime == null) return 0;
    final elapsed = DateTime.now().difference(_lastFallTime!);
    final remaining = _settings.cooldownSeconds - elapsed.inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  List<SensorData> get sensorHistory => _sensorHistory.toList();
  SensorData? get latestSensorData =>
      _sensorHistory.isNotEmpty ? _sensorHistory.last : null;

  List<InferenceResult> get resultsHistory => _resultsHistory.toList();
  InferenceResult? get latestResult =>
      _resultsHistory.isNotEmpty ? _resultsHistory.last : null;

  /// Check if fall is detected based on current threshold (for UI display only)
  bool get isFallDetected {
    final result = latestResult;
    if (result == null) return false;
    return result.fallProbability > _settings.fallThreshold;
  }

  /// Update settings (only when not running)
  void updateSettings(DetectionSettings newSettings) {
    if (_isRunning) {
      debugPrint("⚠️ [CONTROLLER] Cannot update settings while running");
      return;
    }
    _settings = newSettings;
    if (_settings.showDebugLogs) {
      debugPrint("⚙️ [CONTROLLER] Settings updated: ${_settings.summary}");
    }
    notifyListeners();
  }

  /// Initialize the controller (load model)
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint("🎮 [CONTROLLER] Initializing...");
    try {
      await _inferenceService.loadModel();
      _isInitialized = true;
      _error = null;
      debugPrint("✅ [CONTROLLER] Initialized");
      notifyListeners();
    } catch (e) {
      _error = "Failed to load model: $e";
      debugPrint("❌ [CONTROLLER] Init error: $e");
      notifyListeners();
    }
  }

  /// Start detection
  Future<void> start() async {
    if (!_isInitialized) {
      debugPrint("⚠️ [CONTROLLER] Cannot start - not initialized");
      return;
    }
    if (_isRunning) return;

    debugPrint("▶️ [CONTROLLER] Starting detection...");
    debugPrint("⚙️ [CONTROLLER] Settings: ${_settings.summary}");
    _reset();

    // Create new session with full settings
    _currentSession = await StorageService.createSession(settings: _settings);

    _isRunning = true;
    _sensorService.start();

    _sensorSubscription = _sensorService.sensorStream.listen(_onSensorData);
    notifyListeners();
  }

  /// Stop detection
  void stop() {
    if (!_isRunning) return;

    debugPrint("⏹️ [CONTROLLER] Stopping detection...");
    _sensorSubscription?.cancel();
    _sensorSubscription = null;
    _sensorService.stop();
    _isRunning = false;

    // End session
    if (_currentSession != null) {
      _currentSession!.addEvent(
        SessionEvent(
          timestamp: DateTime.now(),
          type: SessionEventType.sessionEnd,
          details:
              'Frames: $_frameCount, Inferences: $_inferenceCount, Falls: $_fallsDetected',
        ),
      );

      _currentSession!.end(
        frames: _frameCount,
        inferences: _inferenceCount,
        falls: _fallsDetected,
        maxProb: _maxFallProb > 0 ? _maxFallProb : null,
        activity: _lastActivity,
      );

      debugPrint(
        "💾 [CONTROLLER] Session saved: ${_currentSession!.durationString}",
      );
      _currentSession = null;
    }

    debugPrint(
      "✅ [CONTROLLER] Stopped. Frames: $_frameCount, Inferences: $_inferenceCount, Falls: $_fallsDetected",
    );
    notifyListeners();
  }

  /// Reset state
  void _reset() {
    _buffer.clear();
    _sensorHistory.clear();
    _resultsHistory.clear();
    _frameCount = 0;
    _inferenceCount = 0;
    _fallsDetected = 0;
    _maxFallProb = 0;
    _lastActivity = null;
    _bufferFilledLogged = false;
    // Reset advanced detection state
    _fallCounter = 0;
    _lastFallTime = null;
    _framesSinceLastInference = 0;
    _lastAccMagnitude = 0;
  }

  void _onSensorData(SensorData data) {
    _frameCount++;
    _framesSinceLastInference++;

    // Calculate acceleration magnitude for impact gate
    _lastAccMagnitude = data.accMagnitude;

    // Add to history (for charts)
    _sensorHistory.add(data);
    if (_sensorHistory.length > _settings.chartHistorySize) {
      _sensorHistory.removeFirst();
    }

    // Add to buffer (for inference)
    _buffer.add(data);
    if (_buffer.length > _settings.windowSize) {
      _buffer.removeAt(0);
    }

    // === INFERENCE THROTTLING ===
    // Only run inference every N frames (setting: inferenceSkipFrames)
    if (_buffer.length < _settings.windowSize) {
      // Buffer not full yet
      if (_frameCount % 3 == 0) notifyListeners();
      return;
    }

    if (_framesSinceLastInference < _settings.inferenceSkipFrames) {
      // Skip this frame for inference
      if (_frameCount % 3 == 0) notifyListeners();
      return;
    }

    // Log buffer filled event (once per session)
    if (!_bufferFilledLogged && _currentSession != null) {
      _bufferFilledLogged = true;
      _currentSession!.addEvent(
        SessionEvent(
          timestamp: DateTime.now(),
          type: SessionEventType.bufferFilled,
          details: 'Buffer ready with ${_settings.windowSize} frames',
        ),
      );
    }

    // Reset inference frame counter
    _framesSinceLastInference = 0;

    // Run inference
    final result = _inferenceService.runInference(_buffer);
    if (result == null) {
      if (_frameCount % 3 == 0) notifyListeners();
      return;
    }

    _inferenceCount++;
    _resultsHistory.add(result);
    if (_resultsHistory.length > resultsHistorySize) {
      _resultsHistory.removeFirst();
    }

    // Track max fall probability
    if (result.fallProbability > _maxFallProb) {
      _maxFallProb = result.fallProbability;
    }

    // Track last activity
    _lastActivity = result.activityName;

    // === ADVANCED FALL DETECTION LOGIC ===
    _processFallDetection(result);

    // Throttle notifications to ~30fps for UI updates
    if (_frameCount % 3 == 0) {
      notifyListeners();
    }
  }

  void _processFallDetection(InferenceResult result) {
    // === 1. IMPACT GATE ===
    // If enabled, require acceleration magnitude > threshold
    if (_settings.enableImpactGate) {
      if (_lastAccMagnitude < _settings.impactThreshold) {
        // No significant impact, reset fall counter
        _fallCounter = 0;
        if (_settings.showDebugLogs &&
            result.fallProbability > _settings.fallThreshold) {
          debugPrint(
            "🛡️ [CONTROLLER] Impact gate blocked: mag=${_lastAccMagnitude.toStringAsFixed(1)} < ${_settings.impactThreshold}",
          );
        }
        return;
      }
    }

    // === 2. COOLDOWN CHECK ===
    // If we recently detected a fall, don't detect another
    if (isInCooldown) {
      _fallCounter = 0;
      if (_settings.showDebugLogs &&
          result.fallProbability > _settings.fallThreshold) {
        debugPrint(
          "⏳ [CONTROLLER] Cooldown active: ${cooldownRemaining}s remaining",
        );
      }
      return;
    }

    // === 3. TEMPORAL CONFIRMATION ===
    // Require N consecutive frames with probability > confirmation threshold
    if (result.fallProbability > _settings.confirmationThreshold) {
      _fallCounter++;
      if (_settings.showDebugLogs) {
        debugPrint(
          "📈 [CONTROLLER] Fall counter: $_fallCounter/${_settings.confirmationFrames} (prob=${result.fallProbability.toStringAsFixed(3)})",
        );
      }
    } else {
      // Reset counter if probability drops below confirmation threshold
      if (_fallCounter > 0 && _settings.showDebugLogs) {
        debugPrint(
          "📉 [CONTROLLER] Fall counter reset (prob=${result.fallProbability.toStringAsFixed(3)} < ${_settings.confirmationThreshold})",
        );
      }
      _fallCounter = 0;
    }

    // === 4. TRIGGER FALL DETECTION ===
    if (_fallCounter >= _settings.confirmationFrames) {
      _triggerFallDetection(result);
    }
  }

  void _triggerFallDetection(InferenceResult result) {
    _fallsDetected++;
    _lastFallTime = DateTime.now();
    _fallCounter = 0; // Reset after trigger

    debugPrint(
      "🚨🚨🚨 [CONTROLLER] FALL CONFIRMED! prob=${result.fallProbability.toStringAsFixed(3)}, "
      "activity=${result.activityName}, cooldown=${_settings.cooldownSeconds}s 🚨🚨🚨",
    );

    // Add fall event to session
    if (_currentSession != null) {
      _currentSession!.addEvent(
        SessionEvent(
          timestamp: DateTime.now(),
          type: SessionEventType.fallDetected,
          probability: result.fallProbability,
          activity: result.activityName,
          details:
              'Confirmed after ${_settings.confirmationFrames} frames, '
              'magnitude: ${_lastAccMagnitude.toStringAsFixed(1)} m/s²',
        ),
      );
    }

    // Force UI update
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint("🗑️ [CONTROLLER] Disposing...");
    stop();
    _sensorService.dispose();
    _inferenceService.dispose();
    super.dispose();
  }
}
