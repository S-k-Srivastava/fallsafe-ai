import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Large status indicator showing current detection state and activity
class StatusIndicator extends StatelessWidget {
  final bool isFallDetected;
  final double fallProbability;
  final bool isRunning;
  final bool isInitialized;
  final String? activityName;
  final String? activityEmoji;
  final double? maxMagnitude;

  const StatusIndicator({
    super.key,
    required this.isFallDetected,
    required this.fallProbability,
    required this.isRunning,
    required this.isInitialized,
    this.activityName,
    this.activityEmoji,
    this.maxMagnitude,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getGradientColors(context),
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(context).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status row with icon and text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _getIcon(),
                  key: ValueKey(isFallDetected),
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                _getStatusText(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Activity, probability, and magnitude row
          if (isRunning) ...[
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                // Activity display
                if (activityName != null)
                  _buildInfoChip(
                    icon: activityEmoji ?? '🏃',
                    label: activityName!,
                    isEmoji: true,
                  ),
                // Fall probability
                _buildInfoChip(
                  icon: '📊',
                  label: 'Fall: ${(fallProbability * 100).toStringAsFixed(1)}%',
                  isEmoji: true,
                ),
                // Max magnitude
                if (maxMagnitude != null)
                  _buildInfoChip(
                    icon: '⚡',
                    label: 'Max: ${maxMagnitude!.toStringAsFixed(1)} m/s²',
                    isEmoji: true,
                  ),
              ],
            ),
          ] else ...[
            Text(
              _getSubtitleText(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String icon,
    required String label,
    bool isEmoji = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEmoji)
            Text(icon, style: const TextStyle(fontSize: 14))
          else
            const Icon(Icons.speed, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getGradientColors(BuildContext context) {
    if (!isInitialized) {
      return [
        Theme.of(context).colorScheme.surface,
        Theme.of(context).colorScheme.surfaceContainerHighest,
      ];
    }
    if (!isRunning) {
      return [
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primaryFixedDim,
      ];
    }
    if (isFallDetected) {
      return [AppPalette.danger, AppPalette.danger.withOpacity(0.8)];
    }
    return [AppPalette.safe, AppPalette.safe.withOpacity(0.8)];
  }

  Color _getStatusColor(BuildContext context) {
    if (!isInitialized || !isRunning)
      return Theme.of(context).colorScheme.primary;
    if (isFallDetected) return AppPalette.danger;
    return AppPalette.safe;
  }

  IconData _getIcon() {
    if (!isInitialized) return Icons.hourglass_empty_rounded;
    if (!isRunning) return Icons.play_circle_outline_rounded;
    if (isFallDetected) return Icons.warning_rounded;
    return Icons.check_circle_outline_rounded;
  }

  String _getStatusText() {
    if (!isInitialized) return 'Loading...';
    if (!isRunning) return 'Ready';
    if (isFallDetected) return 'Fall Detected!';
    return 'Safe';
  }

  String _getSubtitleText() {
    if (!isInitialized) return 'Initializing model...';
    return 'Tap Start to begin monitoring';
  }
}
