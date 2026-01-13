import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

/// Service for handling runtime permissions
class PermissionService {
  /// Check if sensor permissions are granted
  /// Note: Accelerometer and Gyroscope don't require runtime permission on most Android versions
  /// BODY_SENSORS permission is for heart rate, step counter etc. (not acc/gyro)
  static Future<bool> hasSensorPermission() async {
    // On iOS, motion sensors don't require permission
    if (Platform.isIOS) {
      debugPrint("📋 [PERMISSION] iOS: Sensors don't require permission");
      return true;
    }

    // On Android, accelerometer and gyroscope are non-dangerous sensors
    // They don't require runtime permission, only manifest declaration
    // BODY_SENSORS is for heart rate, step counter, etc. which we don't use
    debugPrint(
      "📋 [PERMISSION] Android: Basic sensors don't require runtime permission",
    );
    return true;
  }

  /// Request sensor permissions - for sensors_plus, this is typically not needed
  static Future<bool> requestSensorPermission() async {
    debugPrint("📋 [PERMISSION] Sensor permission not required for acc/gyro");
    return true;
  }

  /// For Android 10+ ACTIVITY_RECOGNITION permission (optional, for activity detection)
  static Future<bool> hasActivityRecognitionPermission() async {
    if (Platform.isIOS) return true;

    final status = await Permission.activityRecognition.status;
    debugPrint("📋 [PERMISSION] Activity recognition status: $status");
    return status.isGranted || status.isLimited;
  }

  /// Request activity recognition permission
  static Future<bool> requestActivityRecognitionPermission() async {
    if (Platform.isIOS) return true;

    debugPrint("📋 [PERMISSION] Requesting activity recognition permission...");
    final status = await Permission.activityRecognition.request();
    debugPrint("📋 [PERMISSION] Activity recognition result: $status");
    return status.isGranted || status.isLimited;
  }

  /// Open app settings for manual permission grant
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Get permission status info for display
  static Future<PermissionInfo> getPermissionInfo() async {
    // For basic sensors, always granted
    return const PermissionInfo(
      isGranted: true,
      isPermanentlyDenied: false,
      statusText: 'Granted',
    );
  }
}

class PermissionInfo {
  final bool isGranted;
  final bool isPermanentlyDenied;
  final String statusText;

  const PermissionInfo({
    required this.isGranted,
    required this.isPermanentlyDenied,
    required this.statusText,
  });
}
