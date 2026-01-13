import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Large status indicator showing current detection state
class StatusIndicator extends StatelessWidget {
  final bool isFallDetected;
  final double fallProbability;
  final bool isRunning;
  final bool isInitialized;

  const StatusIndicator({
    super.key,
    required this.isFallDetected,
    required this.fallProbability,
    required this.isRunning,
    required this.isInitialized,
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
          colors: _getGradientColors(),
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              _getIcon(),
              key: ValueKey(isFallDetected),
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _getStatusText(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (isRunning) ...[
            Text(
              'Fall Probability: ${(fallProbability * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ] else ...[
            Text(
              _getSubtitleText(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Color> _getGradientColors() {
    if (!isInitialized) {
      return [AppColors.surfaceLight, AppColors.surface];
    }
    if (!isRunning) {
      return [AppColors.primary, AppColors.primaryDark];
    }
    if (isFallDetected) {
      return [AppColors.danger, AppColors.danger.withOpacity(0.8)];
    }
    return [AppColors.safe, AppColors.safe.withOpacity(0.8)];
  }

  Color _getStatusColor() {
    if (!isInitialized || !isRunning) return AppColors.primary;
    if (isFallDetected) return AppColors.danger;
    return AppColors.safe;
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
