import 'dart:math';

/// Represents a single sensor reading with accelerometer, gyroscope, and orientation data
class SensorData {
  final double accX;
  final double accY;
  final double accZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  // Orientation (Euler angles in radians)
  final double oriX; // pitch
  final double oriY; // roll
  final double oriZ; // yaw (azimuth)
  final DateTime timestamp;

  const SensorData({
    required this.accX,
    required this.accY,
    required this.accZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    this.oriX = 0.0,
    this.oriY = 0.0,
    this.oriZ = 0.0,
    required this.timestamp,
  });

  /// Accelerometer magnitude (useful for detecting sudden movements)
  double get accMagnitude => sqrt(accX * accX + accY * accY + accZ * accZ);

  /// Gyroscope magnitude (useful for detecting rotation)
  double get gyroMagnitude =>
      sqrt(gyroX * gyroX + gyroY * gyroY + gyroZ * gyroZ);

  /// Convert to list format for model input [accX, accY, accZ, gyroX, gyroY, gyroZ, oriX, oriY, oriZ]
  List<double> toModelInput() => [
    accX,
    accY,
    accZ,
    gyroX,
    gyroY,
    gyroZ,
    oriX,
    oriY,
    oriZ,
  ];

  /// Compute orientation (pitch/roll) from accelerometer as fallback
  /// Returns [pitch, roll, yaw=0] in radians
  static List<double> computeOrientationFromAccel(
    double ax,
    double ay,
    double az,
  ) {
    // Pitch: rotation around X-axis
    final pitch = atan2(ay, sqrt(ax * ax + az * az));
    // Roll: rotation around Y-axis
    final roll = atan2(-ax, az);
    // Yaw: cannot be computed from accelerometer alone, set to 0
    const yaw = 0.0;
    return [pitch, roll, yaw];
  }

  @override
  String toString() =>
      'SensorData(acc: [${accX.toStringAsFixed(2)}, ${accY.toStringAsFixed(2)}, ${accZ.toStringAsFixed(2)}], '
      'gyro: [${gyroX.toStringAsFixed(2)}, ${gyroY.toStringAsFixed(2)}, ${gyroZ.toStringAsFixed(2)}], '
      'ori: [${oriX.toStringAsFixed(2)}, ${oriY.toStringAsFixed(2)}, ${oriZ.toStringAsFixed(2)}])';
}
