import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Step Line Chart Widget
/// Creates a beautiful step line chart matching the design
class StepLineChartWidget extends StatelessWidget {
  final List<ChartDataPoint> data;
  final Color lineColor;
  final double lineWidth;
  final bool showDot;

  const StepLineChartWidget({
    super.key,
    required this.data,
    this.lineColor = const Color(0xFF4CAF50),
    this.lineWidth = 3,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: LineChart(
        LineChartData(
          // Grid settings
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: _getHorizontalInterval(),
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.15),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.15),
                strokeWidth: 1,
              );
            },
          ),

          // Title settings
          titlesData: FlTitlesData(
            // Bottom titles (X-axis labels)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        data[index].label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            // Left titles (Y-axis values)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 45,
                interval: _getHorizontalInterval(),
                getTitlesWidget: (value, meta) {
                  return Text(
                    _formatYAxisLabel(value),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF666666),
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),

          // Border settings - show left and bottom borders
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
              bottom: BorderSide(
                color: Colors.grey.withValues(alpha: 0.3),
                width: 1,
              ),
              top: BorderSide.none,
              right: BorderSide.none,
            ),
          ),

          // Min/Max values
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: 0,
          maxY: _getMaxY(),

          // Step Line Data
          lineBarsData: [
            LineChartBarData(
              spots: _getSpots(),
              // Enable step line
              isStepLineChart: true,
              lineChartStepData: LineChartStepData(
                stepDirection: _getStepDirection(),
              ),
              // Line styling
              color: lineColor,
              barWidth: lineWidth,
              isStrokeCapRound: false,
              dotData: FlDotData(
                show: showDot,
                getDotPainter: (spot, percent, barData, index) {
                  // Show circle only on last point
                  if (index == data.length - 1) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: lineColor,
                      strokeWidth: 3,
                      strokeColor: Colors.white,
                    );
                  }
                  return FlDotCirclePainter(
                    radius: 0,
                    color: Colors.transparent,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSpots() {
    return data
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        .toList();
  }

  double _getMaxY() {
    if (data.isEmpty) return 3000;
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    // Round up to nearest 1000
    return ((maxValue / 1000).ceil() * 1000).toDouble();
  }

  double _getHorizontalInterval() {
    final maxY = _getMaxY();
    return maxY / 4; // 4 intervals
  }

  String _formatYAxisLabel(double value) {
    if (value >= 1000) {
      final kValue = value / 1000;
      if (kValue % 1 == 0) {
        return '${kValue.toInt()}k';
      } else {
        return '${kValue.toStringAsFixed(1)}k';
      }
    }
    return value.toInt().toString();
  }

  double _getStepDirection() {
    // 0 = middle, 1 = forward (right then up), 2 = backward (up then right)
    return 1.0; // Forward direction for step line
  }
}

/// Data point for the chart
class ChartDataPoint {
  final String label;
  final double value;

  ChartDataPoint({
    required this.label,
    required this.value,
  });
}
