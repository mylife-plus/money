import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/models/chart_data_point.dart';

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
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: LineChart(
        LineChartData(
          // Tooltip settings
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final index = barSpot.x.toInt();
                  if (index >= 0 && index < data.length) {
                    return LineTooltipItem(
                      data[index].tooltipLabel,
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    );
                  }
                  // Fallback (should not happen)
                  return LineTooltipItem(
                    barSpot.y.toStringAsFixed(2).replaceAll('.', ','),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
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
                reservedSize: 24.h,
                // Fixed: Show exactly 4 labels on X-axis
                interval: data.length > 4
                    ? (data.length / 3)
                          .ceilToDouble() // Divide by 3 to get 4 ticks (0, 0.33, 0.66, 1.0)
                    : 1,
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
                reservedSize: 30,
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

          // Smooth Curved Line Data
          lineBarsData: [
            LineChartBarData(
              spots: _getSpots(),
              
              // Enable smooth curve
              isCurved: true,
              curveSmoothness: 1.0, // 0.0 = sharp corners, 1.0 = very smooth
              preventCurveOverShooting: true, // Prevents curve from going too far
              // Line styling
              color: lineColor,
              barWidth: lineWidth,
              // isStrokeCapRound: true, // Rounded line caps
              dotData: FlDotData(
                show: showDot,
                getDotPainter: (spot, percent, barData, index) {
                  // Show circle only on last point
                  // if (index == data.length - 1) {
                  //   return FlDotCirclePainter(
                  //     radius: 6,
                  //     color: lineColor,
                  //     strokeWidth: 3,
                  //     strokeColor: Colors.white,
                  //   );
                  // }
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
        .map((point) => FlSpot(point.xValue, point.value))
        .toList();
  }

  double _getMaxY() {
    if (data.isEmpty) return 100; // Default low value if empty

    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    if (maxValue <= 0) return 100; // Default if all values are 0

    // Adaptive rounding based on magnitude
    if (maxValue <= 100) {
      // Round up to nearest 10 (e.g., 45 -> 50)
      return ((maxValue / 10).ceil() * 10).toDouble();
    } else if (maxValue <= 1000) {
      // Round up to nearest 100 (e.g., 250 -> 300)
      return ((maxValue / 100).ceil() * 100).toDouble();
    } else {
      // Round up to nearest 1000 (e.g., 1200 -> 2000)
      return ((maxValue / 1000).ceil() * 1000).toDouble();
    }
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
        return '${kValue.toStringAsFixed(1).replaceAll('.', ',')}k';
      }
    }
    return value.toInt().toString();
  }


}
