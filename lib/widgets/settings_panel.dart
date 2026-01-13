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
  late bool _showDebugLogs;

  @override
  void initState() {
    super.initState();
    _fallThreshold = widget.settings.fallThreshold;
    _showDebugLogs = widget.settings.showDebugLogs;
  }

  void _updateSettings() {
    widget.onSettingsChanged(
      widget.settings.copyWith(
        fallThreshold: _fallThreshold,
        showDebugLogs: _showDebugLogs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              if (widget.isRunning)
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
          const SizedBox(height: AppSpacing.lg),

          // Fall threshold slider
          _buildSliderSetting(
            label: 'Fall Detection Threshold',
            value: _fallThreshold,
            min: 0.1,
            max: 0.9,
            divisions: 8,
            displayValue: '${(_fallThreshold * 100).toInt()}%',
            description:
                'Higher = fewer false positives, lower = more sensitive',
            onChanged: widget.isRunning
                ? null
                : (value) {
                    setState(() => _fallThreshold = value);
                    _updateSettings();
                  },
          ),
          const SizedBox(height: AppSpacing.md),

          // Debug logs toggle
          _buildSwitchSetting(
            label: 'Debug Logs',
            value: _showDebugLogs,
            description: 'Show detailed logs in console',
            onChanged: widget.isRunning
                ? null
                : (value) {
                    setState(() => _showDebugLogs = value);
                    _updateSettings();
                  },
          ),
          const SizedBox(height: AppSpacing.md),

          // Model info (read-only)
          _buildInfoRow('Window Size', '${widget.settings.windowSize} frames'),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(
            'Chart History',
            '${widget.settings.chartHistorySize} samples',
          ),
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
    required ValueChanged<double>? onChanged,
  }) {
    final isDisabled = onChanged == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDisabled ? AppColors.textMuted : AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                displayValue,
                style: const TextStyle(
                  fontSize: 12,
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
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        Text(
          description,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildSwitchSetting({
    required String label,
    required bool value,
    required String description,
    required ValueChanged<bool>? onChanged,
  }) {
    final isDisabled = onChanged == null;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDisabled
                      ? AppColors.textMuted
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          inactiveTrackColor: AppColors.surfaceLight,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
