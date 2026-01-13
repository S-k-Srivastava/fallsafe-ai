import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/detection_session.dart';
import '../models/detection_settings.dart';

/// Service for managing session storage with Hive
class StorageService {
  static const String _sessionsBoxName = 'detection_sessions';
  static Box<DetectionSession>? _sessionsBox;

  /// Initialize Hive and open boxes
  static Future<void> init() async {
    debugPrint("💾 [STORAGE] Initializing Hive...");
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DetectionSessionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SessionEventAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SessionEventTypeAdapter());
    }

    // Open boxes
    _sessionsBox = await Hive.openBox<DetectionSession>(_sessionsBoxName);
    await _initSettings();
    debugPrint(
      "✅ [STORAGE] Hive initialized. Sessions: ${_sessionsBox!.length}",
    );
  }

  /// Get sessions box
  static Box<DetectionSession> get sessionsBox {
    if (_sessionsBox == null) {
      throw StateError('StorageService not initialized. Call init() first.');
    }
    return _sessionsBox!;
  }

  /// Get all sessions, sorted by start time (newest first)
  static List<DetectionSession> getAllSessions() {
    final sessions = sessionsBox.values.toList();
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  /// Create a new session with full settings
  static Future<DetectionSession> createSession({
    required DetectionSettings settings,
  }) async {
    final session = DetectionSession(
      startTime: DateTime.now(),
      fallThreshold: settings.fallThreshold,
      confirmationThreshold: settings.confirmationThreshold,
      confirmationFrames: settings.confirmationFrames,
      cooldownSeconds: settings.cooldownSeconds,
      inferenceSkipFrames: settings.inferenceSkipFrames,
      enableImpactGate: settings.enableImpactGate,
      impactThreshold: settings.impactThreshold,
    );

    // Add start event with full settings details
    session.events.add(
      SessionEvent(
        timestamp: DateTime.now(),
        type: SessionEventType.sessionStart,
        details: 'Settings: ${settings.summary}',
      ),
    );

    await sessionsBox.add(session);
    debugPrint(
      "💾 [STORAGE] Created session with settings: ${settings.summary}",
    );
    return session;
  }

  /// Delete a session
  static Future<void> deleteSession(DetectionSession session) async {
    debugPrint("🗑️ [STORAGE] Deleting session from ${session.startTime}");
    await session.delete();
  }

  /// Delete all sessions
  static Future<void> clearAllSessions() async {
    debugPrint("🗑️ [STORAGE] Clearing all sessions...");
    await sessionsBox.clear();
    debugPrint("✅ [STORAGE] All sessions cleared");
  }

  /// Get session count
  static int get sessionCount => sessionsBox.length;

  /// Listen to sessions changes
  static ValueListenable<Box<DetectionSession>> get sessionsListenable =>
      sessionsBox.listenable();

  // Settings Box
  static const String _settingsBoxName = 'app_settings';
  static Box? _settingsBox;

  static Box get _settings => _settingsBox!;

  static Future<void> _initSettings() async {
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    await _settings.put('theme_mode', mode.toString());
  }

  static ThemeMode getThemeMode() {
    final saved = _settings.get('theme_mode');
    if (saved == null) return ThemeMode.system;
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == saved,
      orElse: () => ThemeMode.system,
    );
  }
}
