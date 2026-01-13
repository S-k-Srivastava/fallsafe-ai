import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/detection_session.dart';
import '../services/storage_service.dart';

/// Screen showing history of detection sessions
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Session History'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            onSelected: (value) async {
              if (value == 'clear') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text('Clear All Sessions?'),
                    content: const Text('This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.danger,
                        ),
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await StorageService.clearAllSessions();
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      color: AppColors.danger,
                      size: 20,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text('Clear All'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<DetectionSession>>(
        valueListenable: StorageService.sessionsListenable,
        builder: (context, box, _) {
          final sessions = StorageService.getAllSessions();

          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'No Sessions Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Start a detection session to see history here',
                    style: TextStyle(fontSize: 14, color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _SessionCard(
                session: session,
                onTap: () => _showSessionDetails(context, session),
                onDelete: () => _confirmDelete(context, session),
              );
            },
          );
        },
      ),
    );
  }

  void _showSessionDetails(BuildContext context, DetectionSession session) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (context) => _SessionDetailsSheet(session: session),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DetectionSession session,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Session?'),
        content: Text('Session from ${_formatDateTime(session.startTime)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await StorageService.deleteSession(session);
    }
  }
}

class _SessionCard extends StatelessWidget {
  final DetectionSession session;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionCard({
    required this.session,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasFalls = session.fallsDetected > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: hasFalls
                ? AppColors.danger.withValues(alpha: 0.5)
                : AppColors.surfaceBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status icon
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: (hasFalls ? AppColors.danger : AppColors.safe)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    hasFalls
                        ? Icons.warning_rounded
                        : Icons.check_circle_outline,
                    color: hasFalls ? AppColors.danger : AppColors.safe,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Session info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDateTime(session.startTime),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Duration: ${session.durationString}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: AppColors.textMuted,
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Stats row
            Row(
              children: [
                _StatChip(
                  icon: Icons.sensors,
                  label: '${session.totalFrames} frames',
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatChip(
                  icon: Icons.psychology,
                  label: '${session.totalInferences} inferences',
                ),
                const SizedBox(width: AppSpacing.sm),
                _StatChip(
                  icon: Icons.warning_amber,
                  label: '${session.fallsDetected} falls',
                  isAlert: hasFalls,
                ),
              ],
            ),
            if (session.lastActivity != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Last activity: ${session.lastActivity}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isAlert;

  const _StatChip({
    required this.icon,
    required this.label,
    this.isAlert = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isAlert ? AppColors.danger : AppColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

class _SessionDetailsSheet extends StatelessWidget {
  final DetectionSession session;

  const _SessionDetailsSheet({required this.session});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
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
                children: [
                  const Icon(Icons.history, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Session Details',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.surfaceBorder),
            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Summary card
                  _buildSummaryCard(),
                  const SizedBox(height: AppSpacing.md),
                  // Events list
                  const Text(
                    'EVENTS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (session.events.isEmpty)
                    const Text(
                      'No events recorded',
                      style: TextStyle(color: AppColors.textMuted),
                    )
                  else
                    ...session.events.reversed.map(_buildEventTile),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          _SummaryRow('Start Time', _formatDateTime(session.startTime)),
          if (session.endTime != null)
            _SummaryRow('End Time', _formatDateTime(session.endTime!)),
          _SummaryRow('Duration', session.durationString),
          _SummaryRow('Threshold', '${(session.fallThreshold * 100).toInt()}%'),
          _SummaryRow('Total Frames', session.totalFrames.toString()),
          _SummaryRow('Total Inferences', session.totalInferences.toString()),
          _SummaryRow(
            'Falls Detected',
            session.fallsDetected.toString(),
            highlight: session.fallsDetected > 0,
          ),
          if (session.maxFallProbability != null)
            _SummaryRow(
              'Max Fall Prob',
              '${(session.maxFallProbability! * 100).toStringAsFixed(1)}%',
            ),
          if (session.lastActivity != null)
            _SummaryRow('Last Activity', session.lastActivity!),
        ],
      ),
    );
  }

  Widget _buildEventTile(SessionEvent event) {
    IconData icon;
    Color color;
    String title;

    switch (event.type) {
      case SessionEventType.sessionStart:
        icon = Icons.play_circle_outline;
        color = AppColors.safe;
        title = 'Session Started';
        break;
      case SessionEventType.sessionEnd:
        icon = Icons.stop_circle_outlined;
        color = AppColors.primary;
        title = 'Session Ended';
        break;
      case SessionEventType.fallDetected:
        icon = Icons.warning_rounded;
        color = AppColors.danger;
        title = 'Fall Detected';
        break;
      case SessionEventType.activityChanged:
        icon = Icons.directions_walk;
        color = AppColors.primaryLight;
        title = 'Activity: ${event.activity ?? "Unknown"}';
        break;
      case SessionEventType.bufferFilled:
        icon = Icons.check_circle_outline;
        color = AppColors.safe;
        title = 'Buffer Ready';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (event.details != null)
                  Text(
                    event.details!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                Text(
                  _formatTime(event.timestamp),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (event.probability != null)
            Text(
              '${(event.probability! * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _SummaryRow(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: highlight ? AppColors.danger : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(dt.year, dt.month, dt.day);

  String dateStr;
  if (date == today) {
    dateStr = 'Today';
  } else if (date == today.subtract(const Duration(days: 1))) {
    dateStr = 'Yesterday';
  } else {
    dateStr = '${dt.day}/${dt.month}/${dt.year}';
  }

  return '$dateStr at ${_formatTime(dt)}';
}

String _formatTime(DateTime dt) {
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
}
