import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../controllers/detection_controller.dart';
import '../models/detection_settings.dart';
import '../services/permission_service.dart';
import '../widgets/status_indicator.dart';
import '../widgets/control_button.dart';
import '../widgets/sensor_chart.dart';
import '../widgets/stat_card.dart';
import '../widgets/activity_display.dart';
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
      backgroundColor: AppColors.surface,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('FallSafe'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          // History button
          IconButton(
            icon: const Icon(Icons.history_rounded),
            color: AppColors.textSecondary,
            onPressed: _openHistory,
            tooltip: 'Session History',
          ),
          if (_controller.isRunning)
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.md),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.safe.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.safe,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.safe,
                    ),
                  ),
                ],
              ),
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
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: const Icon(
              Icons.sensors_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Sensor Permission Required',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'FallSafe needs access to your device sensors (accelerometer and gyroscope) to detect falls.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
          // Status indicator at top
          StatusIndicator(
            isFallDetected: _controller.isFallDetected,
            fallProbability: _controller.latestResult?.fallProbability ?? 0,
            isRunning: _controller.isRunning,
            isInitialized: _controller.isInitialized,
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
                    ? AppColors.safe
                    : AppColors.textPrimary,
              ),
              StatItem(
                label: 'Inferences',
                value: _controller.inferenceCount.toString(),
                valueColor: AppColors.primary,
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
          const SizedBox(height: AppSpacing.md),

          // Activity display
          ActivityDisplay(result: _controller.latestResult),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LIVE SENSOR VALUES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
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
              Container(width: 1, height: 80, color: AppColors.surfaceBorder),
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
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ValueRow('X', x, AppColors.chartX),
          _ValueRow('Y', y, AppColors.chartY),
          _ValueRow('Z', z, AppColors.chartZ),
          const Divider(height: AppSpacing.md),
          _ValueRow('Mag', magnitude, AppColors.chartMagnitude),
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
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            value.toStringAsFixed(2),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
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
                color: AppColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detection Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.surfaceBorder),
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
                    backgroundColor: AppColors.safe,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 24),
                      SizedBox(width: AppSpacing.sm),
                      Text(
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
