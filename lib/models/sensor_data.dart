import 'dart:math';

/// Represents a single sensor reading with accelerometer and gyroscope data
class SensorData {
  final double accX;
  final double accY;
  final double accZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final DateTime timestamp;

  const SensorData({
    required this.accX,
    required this.accY,
    required this.accZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.timestamp,
  });

  /// Accelerometer magnitude (useful for detecting sudden movements)
  double get accMagnitude => sqrt(accX * accX + accY * accY + accZ * accZ);

  /// Gyroscope magnitude (useful for detecting rotation)
  double get gyroMagnitude =>
      sqrt(gyroX * gyroX + gyroY * gyroY + gyroZ * gyroZ);

  /// Convert to list format for model input [accX, accY, accZ, gyroX, gyroY, gyroZ, 0, 0, 0]
  List<double> toModelInput() => [
    accX,
    accY,
    accZ,
    gyroX,
    gyroY,
    gyroZ,
    0.0,
    0.0,
    0.0,
  ];

  @override
  String toString() =>
      'SensorData(acc: [${accX.toStringAsFixed(2)}, ${accY.toStringAsFixed(2)}, ${accZ.toStringAsFixed(2)}], '
      'gyro: [${gyroX.toStringAsFixed(2)}, ${gyroY.toStringAsFixed(2)}, ${gyroZ.toStringAsFixed(2)}])';
}
