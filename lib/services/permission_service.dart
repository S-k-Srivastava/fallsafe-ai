import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for handling runtime permissions
class PermissionService {
  /// Check if sensor permissions are granted
  static Future<bool> hasSensorPermission() async {
    // On Android 13+, body sensors need explicit permission
    final status = await Permission.sensors.status;
    debugPrint("📋 [PERMISSION] Sensor status: $status");
    return status.isGranted || status.isLimited;
  }

  /// Request sensor permissions
  static Future<bool> requestSensorPermission() async {
    debugPrint("📋 [PERMISSION] Requesting sensor permission...");

    final status = await Permission.sensors.request();
    debugPrint("📋 [PERMISSION] Request result: $status");

    if (status.isPermanentlyDenied) {
      debugPrint("📋 [PERMISSION] Permanently denied - need to open settings");
      return false;
    }

    return status.isGranted || status.isLimited;
  }

  /// Open app settings for manual permission grant
  static Future<bool> openSettings() async {
    return await openAppSettings();
  }

  /// Get permission status info for display
  static Future<PermissionInfo> getPermissionInfo() async {
    final status = await Permission.sensors.status;

    return PermissionInfo(
      isGranted: status.isGranted || status.isLimited,
      isPermanentlyDenied: status.isPermanentlyDenied,
      statusText: _getStatusText(status),
    );
  }

  static String _getStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return 'Limited';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.provisional:
        return 'Provisional';
    }
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
