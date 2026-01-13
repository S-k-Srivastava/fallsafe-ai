import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/detection_settings.dart';

/// Settings panel widget for configuring detection parameters
class SettingsPanel extends StatefulWidget {
  final DetectionSettings settings;
  final ValueChanged<DetectionSettings> onSettingsChanged;
  final bool isRunning;

  const SettingsPanel({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.isRunning,
  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late double _fallThreshold;
  late double _confirmationThreshold;
  late int _confirmationFrames;
  late int _cooldownSeconds;
  late int _inferenceSkipFrames;
  late bool _enableImpactGate;
  late double _impactThreshold;
  late bool _showDebugLogs;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    _fallThreshold = widget.settings.fallThreshold;
    _confirmationThreshold = widget.settings.confirmationThreshold;
    _confirmationFrames = widget.settings.confirmationFrames;
    _cooldownSeconds = widget.settings.cooldownSeconds;
    _inferenceSkipFrames = widget.settings.inferenceSkipFrames;
    _enableImpactGate = widget.settings.enableImpactGate;
    _impactThreshold = widget.settings.impactThreshold;
    _showDebugLogs = widget.settings.showDebugLogs;
  }

  void _updateSettings() {
    widget.onSettingsChanged(
      widget.settings.copyWith(
        fallThreshold: _fallThreshold,
        confirmationThreshold: _confirmationThreshold,
        confirmationFrames: _confirmationFrames,
        cooldownSeconds: _cooldownSeconds,
        inferenceSkipFrames: _inferenceSkipFrames,
        enableImpactGate: _enableImpactGate,
        impactThreshold: _impactThreshold,
        showDebugLogs: _showDebugLogs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.isRunning;

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DETECTION SETTINGS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
              if (isDisabled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Text(
                    'Locked while running',
                    style: TextStyle(fontSize: 10, color: AppColors.warning),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // === BASIC THRESHOLD ===
          _buildSliderSetting(
            label: 'Fall Threshold (Display)',
            value: _fallThreshold,
            min: 0.1,
            max: 0.9,
            divisions: 8,
            displayValue: '${(_fallThreshold * 100).toInt()}%',
            description: 'Base probability threshold for UI display',
            isDisabled: isDisabled,
            onChanged: (v) {
              setState(() => _fallThreshold = v);
              _updateSettings();
            },
          ),
          const Divider(height: AppSpacing.lg, color: AppColors.surfaceBorder),

          // === TEMPORAL CONFIRMATION ===
          const Text(
            'TEMPORAL CONFIRMATION',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          _buildSliderSetting(
            label: 'Confirmation Threshold',
            value: _confirmationThreshold,
            min: 0.5,
            max: 0.95,
            divisions: 9,
            displayValue: '${(_confirmationThreshold * 100).toInt()}%',
            description: 'Required probability for confirmation frames',
            isDisabled: isDisabled,
            onChanged: (v) {
              setState(() => _confirmationThreshold = v);
              _updateSettings();
            },
          ),

          _buildIntSliderSetting(
            label: 'Confirmation Frames',
            value: _confirmationFrames,
            min: 1,
            max: 10,
            displayValue: '$_confirmationFrames frames',
            description: 'Consecutive frames required to confirm fall',
            isDisabled: isDisabled,
            onChanged: (v) {
              setState(() => _confirmationFrames = v);
              _updateSettings();
            },
          ),
          const Divider(height: AppSpacing.lg, color: AppColors.surfaceBorder),

          // === COOLDOWN ===
          const Text(
            'COOLDOWN PERIOD',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          _buildIntSliderSetting(
            label: 'Cooldown Duration',
            value: _cooldownSeconds,
            min: 5,
            max: 120,
            displayValue: '${_cooldownSeconds}s',
            description: 'Block detection after confirmed fall',
            isDisabled: isDisabled,
            onChanged: (v) {
              setState(() => _cooldownSeconds = v);
              _updateSettings();
            },
          ),
          const Divider(height: AppSpacing.lg, color: AppColors.surfaceBorder),

          // === INFERENCE FREQUENCY ===
          const Text(
            'INFERENCE FREQUENCY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          _buildIntSliderSetting(
            label: 'Inference Every N Frames',
            value: _inferenceSkipFrames,
            min: 1,
            max: 20,
            displayValue: '1/$_inferenceSkipFrames',
            description: 'Run ML inference every N sensor frames',
            isDisabled: isDisabled,
            onChanged: (v) {
              setState(() => _inferenceSkipFrames = v);
              _updateSettings();
            },
          ),
          const Divider(height: AppSpacing.lg, color: AppColors.surfaceBorder),

          // === IMPACT GATE ===
          const Text(
            'IMPACT GATE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          _buildSwitchSetting(
            label: 'Enable Impact Gate',
            value: _enableImpactGate,
            description: 'Require acceleration impact before detection',
            isDisabled: isDisabled,
            onChanged: (v) {
              setState(() => _enableImpactGate = v);
              _updateSettings();
            },
          ),

          if (_enableImpactGate) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildSliderSetting(
              label: 'Impact Threshold',
              value: _impactThreshold,
              min: 5.0,
              max: 30.0,
              divisions: 25,
              displayValue: '${_impactThreshold.toInt()} m/s²',
              description: 'Minimum acceleration magnitude',
              isDisabled: isDisabled,
              onChanged: (v) {
                setState(() => _impactThreshold = v);
                _updateSettings();
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String displayValue,
    required String description,
    required bool isDisabled,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDisabled
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: isDisabled
                  ? AppColors.textMuted
                  : AppColors.primary,
              inactiveTrackColor: AppColors.surfaceLight,
              thumbColor: isDisabled ? AppColors.textMuted : AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: isDisabled ? null : onChanged,
            ),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildIntSliderSetting({
    required String label,
    required int value,
    required int min,
    required int max,
    required String displayValue,
    required String description,
    required bool isDisabled,
    required ValueChanged<int> onChanged,
  }) {
    return _buildSliderSetting(
      label: label,
      value: value.toDouble(),
      min: min.toDouble(),
      max: max.toDouble(),
      divisions: max - min,
      displayValue: displayValue,
      description: description,
      isDisabled: isDisabled,
      onChanged: (v) => onChanged(v.round()),
    );
  }

  Widget _buildSwitchSetting({
    required String label,
    required bool value,
    required String description,
    required bool isDisabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDisabled
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: isDisabled ? null : onChanged,
            activeColor: AppColors.primary,
            inactiveTrackColor: AppColors.surfaceLight,
          ),
        ],
      ),
    );
  }
}
