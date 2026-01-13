import 'package:flutter/material.dart';
import '../core/theme/app_spacing.dart';

/// Reusable stat card widget - theme-aware
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool compact;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: compact ? AppSpacing.iconSm : AppSpacing.iconMd,
                  color: theme.hintColor,
                ),
                SizedBox(width: compact ? AppSpacing.xs : AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: compact ? 10 : 12,
                    fontWeight: FontWeight.w500,
                    color: theme.hintColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? AppSpacing.xs : AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: compact ? 16 : 20,
              fontWeight: FontWeight.w700,
              color: valueColor ?? colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal stat display for compact layout - theme-aware
class StatRow extends StatelessWidget {
  final List<StatItem> items;

  const StatRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) => _buildItem(context, item)).toList(),
      ),
    );
  }

  Widget _buildItem(BuildContext context, StatItem item) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: item.valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          item.label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: theme.hintColor,
          ),
        ),
      ],
    );
  }
}

class StatItem {
  final String label;
  final String value;
  final Color? valueColor;

  const StatItem({required this.label, required this.value, this.valueColor});
}
