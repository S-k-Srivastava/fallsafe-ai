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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              _buildLegend(),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: height,
            child: data.isEmpty ? _buildEmptyState() : _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _legendDot(AppColors.chartX, 'X'),
        const SizedBox(width: AppSpacing.sm),
        _legendDot(AppColors.chartY, 'Y'),
        const SizedBox(width: AppSpacing.sm),
        _legendDot(AppColors.chartZ, 'Z'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
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
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Waiting for data...',
        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
      ),
    );
  }

  Widget _buildChart() {
    final spots = _generateSpots();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getInterval(),
          getDrawingHorizontalLine: (value) =>
              FlLine(color: AppColors.surfaceBorder, strokeWidth: 1),
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
                  style: const TextStyle(
                    color: AppColors.textMuted,
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
      _createLine(xSpots, AppColors.chartX),
      _createLine(ySpots, AppColors.chartY),
      _createLine(zSpots, AppColors.chartZ),
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
