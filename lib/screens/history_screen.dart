import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/theme/app_colors.dart'; // Contains AppPalette
import '../core/theme/app_spacing.dart';
import '../models/detection_session.dart';
import '../services/storage_service.dart';

/// Screen showing history of detection sessions
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Session History'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.hintColor),
            onSelected: (value) async {
              if (value == 'clear') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: colorScheme.surface,
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
                          foregroundColor: AppPalette.danger,
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
                      color: AppPalette.danger,
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
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No Sessions Yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Start a detection session to see history here',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Delete Session?'),
        content: Text('Session from ${_formatDateTime(session.startTime)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppPalette.danger),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasFalls = session.fallsDetected > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: hasFalls
                ? AppPalette.danger.withOpacity(0.5)
                : theme.dividerColor,
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
                    color: (hasFalls ? AppPalette.danger : AppPalette.safe)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    hasFalls
                        ? Icons.warning_rounded
                        : Icons.check_circle_outline,
                    color: hasFalls ? AppPalette.danger : AppPalette.safe,
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
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Duration: ${session.durationString}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: colorScheme.onSurfaceVariant,
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
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
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
    final theme = Theme.of(context);
    final color = isAlert ? AppPalette.danger : theme.hintColor;
    final bgColor = theme.brightness == Brightness.dark
        ? AppPalette.surfaceLightDark
        : const Color(0xFFF0F0F0);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.history, color: colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Session Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor),
            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Summary card
                  _buildSummaryCard(context),
                  const SizedBox(height: AppSpacing.md),
                  // Events list
                  Text(
                    'EVENTS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (session.events.isEmpty)
                    Text(
                      'No events recorded',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    )
                  else
                    ...session.events.reversed.map(
                      (e) => _buildEventTile(e, context),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Session info
          Text(
            'SESSION INFO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            'Start Time',
            _formatDateTime(session.startTime),
            context: context,
          ),
          if (session.endTime != null)
            _SummaryRow(
              'End Time',
              _formatDateTime(session.endTime!),
              context: context,
            ),
          _SummaryRow('Duration', session.durationString, context: context),

          Divider(height: AppSpacing.lg, color: theme.dividerColor),

          // Results
          Text(
            'RESULTS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            'Total Frames',
            session.totalFrames.toString(),
            context: context,
          ),
          _SummaryRow(
            'Total Inferences',
            session.totalInferences.toString(),
            context: context,
          ),
          _SummaryRow(
            'Falls Detected',
            session.fallsDetected.toString(),
            highlight: session.fallsDetected > 0,
            context: context,
          ),
          if (session.maxFallProbability != null)
            _SummaryRow(
              'Max Fall Prob',
              '${(session.maxFallProbability! * 100).toStringAsFixed(1)}%',
              context: context,
            ),
          if (session.lastActivity != null)
            _SummaryRow(
              'Last Activity',
              session.lastActivity!,
              context: context,
            ),

          Divider(height: AppSpacing.lg, color: theme.dividerColor),

          // Detection settings used
          Text(
            'DETECTION SETTINGS',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            'Fall Threshold',
            '${(session.fallThreshold * 100).toInt()}%',
            context: context,
          ),
          _SummaryRow(
            'Confirm Threshold',
            '${(session.confirmationThreshold * 100).toInt()}%',
            context: context,
          ),
          _SummaryRow(
            'Confirm Frames',
            '${session.confirmationFrames} frames',
            context: context,
          ),
          _SummaryRow(
            'Cooldown',
            '${session.cooldownSeconds} seconds',
            context: context,
          ),
          _SummaryRow(
            'Inference Rate',
            '1/${session.inferenceSkipFrames} frames',
            context: context,
          ),
          _SummaryRow(
            'Impact Gate',
            session.enableImpactGate ? 'ON' : 'OFF',
            context: context,
          ),
          if (session.enableImpactGate)
            _SummaryRow(
              'Impact Threshold',
              '${session.impactThreshold.toInt()} m/s²',
              context: context,
            ),
        ],
      ),
    );
  }

  Widget _buildEventTile(SessionEvent event, BuildContext context) {
    IconData icon;
    Color color;
    String title;

    switch (event.type) {
      case SessionEventType.sessionStart:
        icon = Icons.play_circle_outline;
        color = AppPalette.safe;
        title = 'Session Started';
        break;
      case SessionEventType.sessionEnd:
        icon = Icons.stop_circle_outlined;
        color = Theme.of(context).colorScheme.primary;
        title = 'Session Ended';
        break;
      case SessionEventType.fallDetected:
        icon = Icons.warning_rounded;
        color = AppPalette.danger;
        title = 'Fall Confirmed';
        break;
      case SessionEventType.activityChanged:
        icon = Icons.directions_walk;
        color = AppPalette.primaryLight;
        title = 'Activity: ${event.activity ?? "Unknown"}';
        break;
      case SessionEventType.bufferFilled:
        icon = Icons.check_circle_outline;
        color = AppPalette.safe;
        title = 'Buffer Ready';
        break;
      case SessionEventType.impactDetected:
        icon = Icons.speed;
        color = AppPalette.warning;
        title = 'Impact Detected';
        break;
      case SessionEventType.cooldownActive:
        icon = Icons.timer;
        color = Theme.of(context).colorScheme.onSurfaceVariant;
        title = 'Cooldown Active';
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (event.details != null)
                  Text(
                    event.details!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                  ),
                Text(
                  _formatTime(event.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
  final BuildContext? context; // Pass context if needed, or lookup

  const _SummaryRow(
    this.label,
    this.value, {
    this.highlight = false,
    this.context,
  });

  @override
  Widget build(BuildContext context) {
    // If context was passed in props use it, otherwise use local context (preferred)
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: highlight
                  ? AppPalette.danger
                  : theme.colorScheme.onSurface,
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

  // 12-hour format with AM/PM applied here
  return '$dateStr at ${_formatTime(dt)}';
}

String _formatTime(DateTime dt) {
  // 12-hour format with AM/PM
  final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final minute = dt.minute.toString().padLeft(2, '0');
  final second = dt.second.toString().padLeft(2, '0');
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute:$second $period';
}
