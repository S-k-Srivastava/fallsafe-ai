import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/inference_result.dart';
import '../models/activity_type.dart';

/// Widget displaying detected activity with confidence bar
class ActivityDisplay extends StatelessWidget {
  final InferenceResult? result;

  const ActivityDisplay({super.key, this.result});

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
          const Text(
            'DETECTED ACTIVITY',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (result == null)
            const _EmptyState()
          else
            _ActivityContent(result: result!),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Text(
          'Waiting for inference...',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      ),
    );
  }
}

class _ActivityContent extends StatelessWidget {
  final InferenceResult result;

  const _ActivityContent({required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main activity
        Row(
          children: [
            Text(result.activityEmoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.activityName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: result.isActivityFall
                          ? AppColors.danger
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Confidence: ${(result.activityConfidence * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${result.inferenceTimeMs}ms',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        // Activity probabilities bar chart
        _ActivityBars(probabilities: result.activityProbabilities),
      ],
    );
  }
}

class _ActivityBars extends StatelessWidget {
  final List<double> probabilities;

  const _ActivityBars({required this.probabilities});

  @override
  Widget build(BuildContext context) {
    // Show top 5 activities
    final indexed = probabilities.asMap().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = indexed.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Activities',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...top5.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: _ActivityBar(index: entry.key, probability: entry.value),
          ),
        ),
      ],
    );
  }
}

class _ActivityBar extends StatelessWidget {
  final int index;
  final double probability;

  const _ActivityBar({required this.index, required this.probability});

  @override
  Widget build(BuildContext context) {
    final isFall = isFallActivity(index);
    final color = isFall ? AppColors.danger : AppColors.primary;
    final name = activityMap[index] ?? 'Unknown';

    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: probability.clamp(0, 1),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 36,
          child: Text(
            '${(probability * 100).toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
