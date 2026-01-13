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

    _accSubscription = accelerometerEventStream().listen((event) {
      _latestAccX = event.x;
      _latestAccY = event.y;
      _latestAccZ = event.z;
      _emitSensorData();
    });

    _gyroSubscription = gyroscopeEventStream().listen((event) {
      _latestGyroX = event.x;
      _latestGyroY = event.y;
      _latestGyroZ = event.z;
    });

    debugPrint("✅ [SENSOR_SERVICE] Sensors started");
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
      debugPrint("📡 [SENSOR_SERVICE] Sample #$_sampleCount: $data");
    }
  }

  /// Dispose resources
  void dispose() {
    stop();
    _sensorController.close();
    debugPrint("🗑️ [SENSOR_SERVICE] Disposed");
  }
}
