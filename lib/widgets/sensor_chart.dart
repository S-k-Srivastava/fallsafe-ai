import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../models/sensor_data.dart';

/// Real-time line chart for sensor data
class SensorChart extends StatelessWidget {
  final String title;
  final List<SensorData> data;
  final SensorChartType type;
  final double height;

  const SensorChart({
    super.key,
    required this.title,
    required this.data,
    required this.type,
    this.height = AppSpacing.chartHeight,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              _buildLegend(context),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: height,
            child: data.isEmpty
                ? _buildEmptyState(context)
                : _buildChart(context),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _legendDot(AppPalette.chartX, 'X', context: context),
        const SizedBox(width: AppSpacing.sm),
        _legendDot(AppPalette.chartY, 'Y', context: context),
        const SizedBox(width: AppSpacing.sm),
        _legendDot(AppPalette.chartZ, 'Z', context: context),
      ],
    );
  }

  Widget _legendDot(
    Color color,
    String label, {
    required BuildContext context,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Text(
        'Waiting for data...',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final spots = _generateSpots();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getInterval(),
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Theme.of(context).dividerColor, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: _getInterval(),
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble().clamp(0, 99),
        minY: _getMinY(),
        maxY: _getMaxY(),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: spots,
      ),
    );
  }

  List<LineChartBarData> _generateSpots() {
    final xSpots = <FlSpot>[];
    final ySpots = <FlSpot>[];
    final zSpots = <FlSpot>[];

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      if (type == SensorChartType.accelerometer) {
        xSpots.add(FlSpot(i.toDouble(), d.accX));
        ySpots.add(FlSpot(i.toDouble(), d.accY));
        zSpots.add(FlSpot(i.toDouble(), d.accZ));
      } else {
        xSpots.add(FlSpot(i.toDouble(), d.gyroX));
        ySpots.add(FlSpot(i.toDouble(), d.gyroY));
        zSpots.add(FlSpot(i.toDouble(), d.gyroZ));
      }
    }

    return [
      _createLine(xSpots, AppPalette.chartX),
      _createLine(ySpots, AppPalette.chartY),
      _createLine(zSpots, AppPalette.chartZ),
    ];
  }

  LineChartBarData _createLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.2,
      color: color,
      barWidth: 1.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }

  double _getMinY() {
    return type == SensorChartType.accelerometer ? -20 : -10;
  }

  double _getMaxY() {
    return type == SensorChartType.accelerometer ? 20 : 10;
  }

  double _getInterval() {
    return type == SensorChartType.accelerometer ? 10 : 5;
  }
}

enum SensorChartType { accelerometer, gyroscope }
