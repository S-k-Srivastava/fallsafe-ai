import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/sensor_data.dart';

/// Service for managing sensor data streams including orientation
class SensorService {
  StreamSubscription? _accSubscription;
  StreamSubscription? _gyroSubscription;
  StreamSubscription? _magnetometerSubscription;

  final _sensorController = StreamController<SensorData>.broadcast();

  // Accelerometer values
  double _latestAccX = 0;
  double _latestAccY = 0;
  double _latestAccZ = 0;

  // Gyroscope values
  double _latestGyroX = 0;
  double _latestGyroY = 0;
  double _latestGyroZ = 0;

  // Orientation values (Euler angles in radians)
  double _oriX = 0; // pitch
  double _oriY = 0; // roll
  double _oriZ = 0; // yaw

  bool _isRunning = false;
  int _sampleCount = 0;
  bool _accReceived = false;
  bool _gyroReceived = false;
  bool _orientationComputed = false;

  /// Stream of sensor data readings
  Stream<SensorData> get sensorStream => _sensorController.stream;

  /// Whether sensors are currently active
  bool get isRunning => _isRunning;

  /// Total samples collected
  int get sampleCount => _sampleCount;

  /// Start collecting sensor data
  void start() {
    if (_isRunning) return;

    debugPrint("📡 [SENSOR_SERVICE] Starting sensor streams...");
    _isRunning = true;
    _sampleCount = 0;
    _accReceived = false;
    _gyroReceived = false;
    _orientationComputed = false;

    // Subscribe to accelerometer (use default sampling rate ~20Hz)
    try {
      _accSubscription = accelerometerEventStream().listen(
        (event) {
          _latestAccX = event.x;
          _latestAccY = event.y;
          _latestAccZ = event.z;

          // Compute orientation from accelerometer (fallback method)
          // This gives us pitch and roll, yaw will be 0
          _computeOrientationFromAccelerometer();

          if (!_accReceived) {
            _accReceived = true;
            debugPrint("✅ [SENSOR_SERVICE] First accelerometer data received");
          }
          _emitSensorData();
        },
        onError: (error) {
          debugPrint("❌ [SENSOR_SERVICE] Accelerometer error: $error");
        },
        cancelOnError: false,
      );
      debugPrint("📡 [SENSOR_SERVICE] Accelerometer stream subscribed");
    } catch (e) {
      debugPrint("❌ [SENSOR_SERVICE] Failed to subscribe to accelerometer: $e");
    }

    // Subscribe to gyroscope (use default sampling rate)
    try {
      _gyroSubscription = gyroscopeEventStream().listen(
        (event) {
          _latestGyroX = event.x;
          _latestGyroY = event.y;
          _latestGyroZ = event.z;
          if (!_gyroReceived) {
            _gyroReceived = true;
            debugPrint("✅ [SENSOR_SERVICE] First gyroscope data received");
          }
        },
        onError: (error) {
          debugPrint("❌ [SENSOR_SERVICE] Gyroscope error: $error");
        },
        cancelOnError: false,
      );
      debugPrint("📡 [SENSOR_SERVICE] Gyroscope stream subscribed");
    } catch (e) {
      debugPrint("❌ [SENSOR_SERVICE] Failed to subscribe to gyroscope: $e");
    }

    // Try to subscribe to magnetometer for better yaw estimation
    try {
      _magnetometerSubscription = magnetometerEventStream().listen(
        (event) {
          // Use magnetometer to compute yaw (azimuth)
          _computeYawFromMagnetometer(event.x, event.y);
        },
        onError: (error) {
          debugPrint("⚠️ [SENSOR_SERVICE] Magnetometer not available: $error");
        },
        cancelOnError: false,
      );
      debugPrint(
        "📡 [SENSOR_SERVICE] Magnetometer stream subscribed (for yaw)",
      );
    } catch (e) {
      debugPrint("⚠️ [SENSOR_SERVICE] Magnetometer not available: $e");
    }

    debugPrint("✅ [SENSOR_SERVICE] Sensor subscriptions initiated");
  }

  /// Compute pitch and roll from accelerometer data
  void _computeOrientationFromAccelerometer() {
    // Pitch: rotation around X-axis (radians)
    _oriX = atan2(
      _latestAccY,
      sqrt(_latestAccX * _latestAccX + _latestAccZ * _latestAccZ),
    );
    // Roll: rotation around Y-axis (radians)
    _oriY = atan2(-_latestAccX, _latestAccZ);

    if (!_orientationComputed) {
      _orientationComputed = true;
      debugPrint("✅ [SENSOR_SERVICE] Orientation computed from accelerometer");
    }
  }

  /// Compute yaw from magnetometer (if available)
  void _computeYawFromMagnetometer(double mx, double my) {
    // Simple yaw calculation from magnetometer X and Y
    _oriZ = atan2(my, mx);
  }

  /// Stop collecting sensor data
  void stop() {
    if (!_isRunning) return;

    debugPrint("🛑 [SENSOR_SERVICE] Stopping sensors...");
    _accSubscription?.cancel();
    _gyroSubscription?.cancel();
    _magnetometerSubscription?.cancel();
    _accSubscription = null;
    _gyroSubscription = null;
    _magnetometerSubscription = null;
    _isRunning = false;
    debugPrint(
      "✅ [SENSOR_SERVICE] Sensors stopped. Total samples: $_sampleCount",
    );
  }

  void _emitSensorData() {
    _sampleCount++;
    final data = SensorData(
      accX: _latestAccX,
      accY: _latestAccY,
      accZ: _latestAccZ,
      gyroX: _latestGyroX,
      gyroY: _latestGyroY,
      gyroZ: _latestGyroZ,
      oriX: _oriX,
      oriY: _oriY,
      oriZ: _oriZ,
      timestamp: DateTime.now(),
    );
    _sensorController.add(data);

    if (_sampleCount % 100 == 0) {
      debugPrint(
        "📡 [SENSOR_SERVICE] Sample #$_sampleCount: "
        "acc(${_latestAccX.toStringAsFixed(2)}, ${_latestAccY.toStringAsFixed(2)}, ${_latestAccZ.toStringAsFixed(2)}) "
        "ori(${_oriX.toStringAsFixed(2)}, ${_oriY.toStringAsFixed(2)}, ${_oriZ.toStringAsFixed(2)})",
      );
    }
  }

  /// Dispose resources
  void dispose() {
    stop();
    _sensorController.close();
    debugPrint("🗑️ [SENSOR_SERVICE] Disposed");
  }
}
