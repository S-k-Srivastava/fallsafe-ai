import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/theme_controller.dart';
import '../controllers/detection_controller.dart';
import '../models/detection_settings.dart';
import '../services/permission_service.dart';
import '../widgets/status_indicator.dart';
import '../widgets/control_button.dart';
import '../widgets/sensor_chart.dart';
import '../widgets/stat_card.dart';
import '../widgets/settings_panel.dart';
import 'history_screen.dart';

/// Main dashboard screen for fall detection
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DetectionController _controller;
  bool _hasPermission = false;
  bool _permissionChecked = false;

  @override
  void initState() {
    super.initState();
    _controller = DetectionController();
    _controller.addListener(_onControllerUpdate);
    _checkPermissionsAndInit();
  }

  Future<void> _checkPermissionsAndInit() async {
    debugPrint("📋 [HOME] Checking permissions...");

    // Check current permission status
    _hasPermission = await PermissionService.hasSensorPermission();
    _permissionChecked = true;
    setState(() {});

    if (_hasPermission) {
      await _controller.initialize();
    }
  }

  Future<void> _requestPermission() async {
    final granted = await PermissionService.requestSensorPermission();
    setState(() => _hasPermission = granted);

    if (granted) {
      await _controller.initialize();
    }
  }

  Future<void> _openSettings() async {
    await PermissionService.openSettings();
    // Re-check after returning from settings
    _hasPermission = await PermissionService.hasSensorPermission();
    setState(() {});
    if (_hasPermission && !_controller.isInitialized) {
      await _controller.initialize();
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    _controller.dispose();
    super.dispose();
  }

  void _toggleDetection() {
    if (_controller.isRunning) {
      _controller.stop();
    } else {
      _showSettingsDialog();
    }
  }

  void _showSettingsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) => _SettingsDialog(
        settings: _controller.settings,
        onSettingsChanged: _controller.updateSettings,
        onStart: () {
          Navigator.pop(context);
          _controller.start();
        },
      ),
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tech logo style
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'F',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'FallSafe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // History button
          IconButton(
            icon: const Icon(Icons.history_rounded),
            color: colorScheme.onSurfaceVariant,
            onPressed: _openHistory,
            tooltip: 'Session History',
          ),
          // Theme toggle
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            color: colorScheme.onSurfaceVariant,
            onPressed: () => ThemeController.of(context).toggleTheme(),
            tooltip: isDarkMode ? 'Light Mode' : 'Dark Mode',
          ),
        ],
      ),
      body: SafeArea(
        child: !_permissionChecked
            ? const Center(child: CircularProgressIndicator())
            : !_hasPermission
            ? _buildPermissionRequest()
            : _buildMainContent(),
      ),
    );
  }

  Widget _buildPermissionRequest() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Icon(
              Icons.sensors_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Sensor Permission Required',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'FallSafe needs access to your device sensors (accelerometer and gyroscope) to detect falls.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _requestPermission,
              child: const Text('Grant Permission'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton(
            onPressed: _openSettings,
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status indicator at top with activity
          StatusIndicator(
            isFallDetected: _controller.isFallConfirmed,
            fallProbability: _controller.latestResult?.fallProbability ?? 0,
            isRunning: _controller.isRunning,
            isInitialized: _controller.isInitialized,
            activityName: _controller.latestResult?.activityName,
            activityEmoji: _controller.latestResult?.activityEmoji,
            maxMagnitude: _controller.isRunning
                ? _controller.lastAccMagnitude
                : null,
          ),
          const SizedBox(height: AppSpacing.md),

          // Control button
          ControlButton(
            isRunning: _controller.isRunning,
            isEnabled: _controller.isInitialized,
            onPressed: _toggleDetection,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Stats row
          StatRow(
            items: [
              StatItem(
                label: 'Frames',
                value: _controller.frameCount.toString(),
              ),
              StatItem(
                label: 'Buffer',
                value: '${_controller.bufferSize}/${_controller.windowSize}',
                valueColor: _controller.bufferSize >= _controller.windowSize
                    ? AppPalette.safe
                    : Theme.of(context).colorScheme.onSurface,
              ),
              StatItem(
                label: 'Inferences',
                value: _controller.inferenceCount.toString(),
                valueColor: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Live sensor values
          if (_controller.latestSensorData != null) ...[
            _buildLiveSensorValues(),
            const SizedBox(height: AppSpacing.md),
          ],

          // Accelerometer chart
          SensorChart(
            title: 'ACCELEROMETER (m/s²)',
            data: _controller.sensorHistory,
            type: SensorChartType.accelerometer,
          ),
          const SizedBox(height: AppSpacing.md),

          // Gyroscope chart
          SensorChart(
            title: 'GYROSCOPE (rad/s)',
            data: _controller.sensorHistory,
            type: SensorChartType.gyroscope,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildLiveSensorValues() {
    final data = _controller.latestSensorData!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LIVE SENSOR VALUES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _SensorValueColumn(
                  title: 'Accelerometer',
                  x: data.accX,
                  y: data.accY,
                  z: data.accZ,
                  magnitude: data.accMagnitude,
                  unit: 'm/s²',
                ),
              ),
              Container(
                width: 1,
                height: 80,
                color: Theme.of(context).dividerColor,
              ),
              Expanded(
                child: _SensorValueColumn(
                  title: 'Gyroscope',
                  x: data.gyroX,
                  y: data.gyroY,
                  z: data.gyroZ,
                  magnitude: data.gyroMagnitude,
                  unit: 'rad/s',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SensorValueColumn extends StatelessWidget {
  final String title;
  final double x, y, z, magnitude;
  final String unit;

  const _SensorValueColumn({
    required this.title,
    required this.x,
    required this.y,
    required this.z,
    required this.magnitude,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ValueRow('X', x, AppPalette.chartX),
          _ValueRow('Y', y, AppPalette.chartY),
          _ValueRow('Z', z, AppPalette.chartZ),
          const Divider(height: AppSpacing.md),
          _ValueRow('Magnitude', magnitude, AppPalette.chartMagnitude),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ValueRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings dialog shown before starting detection
class _SettingsDialog extends StatefulWidget {
  final DetectionSettings settings;
  final ValueChanged<DetectionSettings> onSettingsChanged;
  final VoidCallback onStart;

  const _SettingsDialog({
    required this.settings,
    required this.onSettingsChanged,
    required this.onStart,
  });

  @override
  State<_SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<_SettingsDialog> {
  late DetectionSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.settings;
  }

  void _updateSettings(DetectionSettings newSettings) {
    setState(() => _settings = newSettings);
    widget.onSettingsChanged(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detection Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            // Settings content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SettingsPanel(
                  settings: _settings,
                  onSettingsChanged: _updateSettings,
                  isRunning: false,
                ),
              ),
            ),
            // Start button
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: widget.onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.safe,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 24),
                      const SizedBox(width: AppSpacing.sm),
                      const Text(
                        'Start Detection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
