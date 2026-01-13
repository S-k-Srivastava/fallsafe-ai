import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/sensor_data.dart';

/// Service for managing sensor data streams
class SensorService {
  StreamSubscription? _accSubscription;
  StreamSubscription? _gyroSubscription;

  final _sensorController = StreamController<SensorData>.broadcast();

  double _latestAccX = 0;
  double _latestAccY = 0;
  double _latestAccZ = 0;
  double _latestGyroX = 0;
  double _latestGyroY = 0;
  double _latestGyroZ = 0;

  bool _isRunning = false;
  int _sampleCount = 0;
  bool _accReceived = false;
  bool _gyroReceived = false;

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

    // Subscribe to accelerometer
    try {
      _accSubscription =
          accelerometerEventStream(
            samplingPeriod: SensorInterval.gameInterval,
          ).listen(
            (event) {
              _latestAccX = event.x;
              _latestAccY = event.y;
              _latestAccZ = event.z;
              if (!_accReceived) {
                _accReceived = true;
                debugPrint(
                  "✅ [SENSOR_SERVICE] First accelerometer data received",
                );
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

    // Subscribe to gyroscope
    try {
      _gyroSubscription =
          gyroscopeEventStream(
            samplingPeriod: SensorInterval.gameInterval,
          ).listen(
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

    debugPrint("✅ [SENSOR_SERVICE] Sensor subscriptions initiated");
  }

  /// Stop collecting sensor data
  void stop() {
    if (!_isRunning) return;

    debugPrint("🛑 [SENSOR_SERVICE] Stopping sensors...");
    _accSubscription?.cancel();
    _gyroSubscription?.cancel();
    _accSubscription = null;
    _gyroSubscription = null;
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
      timestamp: DateTime.now(),
    );
    _sensorController.add(data);

    if (_sampleCount % 100 == 0) {
      debugPrint(
        "📡 [SENSOR_SERVICE] Sample #$_sampleCount: acc(${_latestAccX.toStringAsFixed(2)}, ${_latestAccY.toStringAsFixed(2)}, ${_latestAccZ.toStringAsFixed(2)})",
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
