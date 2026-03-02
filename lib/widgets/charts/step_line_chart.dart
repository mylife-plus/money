import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/models/chart_data_point.dart';
import 'package:moneyapp/utils/number_format_helper.dart';

/// Step Line Chart Widget
/// Creates a beautiful step line chart matching the design
class StepLineChartWidget extends StatelessWidget {
  final List<ChartDataPoint> data;
  final Color lineColor;
  final double lineWidth;
  final bool showDot;
  final Color? tooltipAmountColor;
  final String? locale;
  final bool showFourLabels;

  const StepLineChartWidget({
    super.key,
    required this.data,
    this.lineColor = const Color(0xFF4CAF50),
    this.lineWidth = 3,
    this.showDot = true,
    this.tooltipAmountColor,
    this.locale,
    this.showFourLabels = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.h,
      padding: EdgeInsets.only(left: 5.w, top: 5.w, bottom: 5.w, right: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: LineChart(
        LineChartData(
          // Tooltip settings
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.white,
              tooltipBorder: BorderSide(color: Colors.grey.shade300),
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final point = _getDataPointByXValue(barSpot.x.toInt());
                  if (point != null) {
                    final parts = point.tooltipLabel.split('\n');
                    final amount = parts.isNotEmpty ? parts[0] : '';
                    final date = parts.length > 1 ? parts[1] : '';
                    return LineTooltipItem(
                      amount,
                      TextStyle(
                        color: tooltipAmountColor ?? lineColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                      children: [
                        if (date.isNotEmpty)
                          TextSpan(
                            text: '\n$date',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontSize: 11.sp,
                            ),
                          ),
                      ],
                      textAlign: TextAlign.center,
                    );
                  }
                  // Fallback (should not happen)
                  return LineTooltipItem(
                    NumberFormatHelper.formatCurrency(
                      barSpot.y,
                      locale: locale,
                    ),
                    TextStyle(
                      color: tooltipAmountColor ?? lineColor,
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
                reservedSize: 30.h,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  final point = _getDataPointByXValue(index);
                  if (point == null) return const SizedBox.shrink();
                  final maxX = _getMaxX().toInt();
                  if (maxX <= 3) {
                    return Padding(
                      padding: EdgeInsets.only(top: 14.h),
                      child: Text(
                        point.label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    );
                  }
                  final labelCount = showFourLabels ? 4 : 3;
                  final step = maxX / (labelCount - 1).toDouble();
                  final positions = List.generate(labelCount, (i) => (step * i).round());
                  if (positions.contains(index)) {
                    return Padding(
                      padding: EdgeInsets.only(top: 14.h),
                      child: Text(
                        point.label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: const Color(0xFF666666),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            // Left titles (Y-axis values)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: _getHorizontalInterval(),
                getTitlesWidget: (value, meta) {
                  final step = _getHorizontalInterval();
                  final maxY = _getMaxY();
                  final targets = [0.0, step, step * 2, maxY];
                  final isTarget = targets.any((t) => (value - t).abs() < step * 0.01);
                  if (!isTarget) return const SizedBox.shrink();
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
          maxX: _getMaxX(),
          minY: 0,
          maxY: _getMaxY(),

          // Smooth Curved Line Data
          lineBarsData: [
            LineChartBarData(
              spots: _getSpots(),

              // Step line chart
              isCurved: false,
              isStepLineChart: true,
              lineChartStepData: LineChartStepData(
                stepDirection: LineChartStepData.stepDirectionForward,
              ),
              // Line styling
              color: lineColor,
              barWidth: lineWidth,
              dotData: FlDotData(
                show: showDot,
                getDotPainter: (spot, percent, barData, index) {
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
    // Deduplicate: keep only the last point per xValue
    // (step-line data may have duplicate x positions for transitions)
    final Map<int, FlSpot> uniqueSpots = {};
    for (final point in data) {
      uniqueSpots[point.xValue.toInt()] = FlSpot(point.xValue, point.value);
    }
    final spots = uniqueSpots.values.toList()
      ..sort((a, b) => a.x.compareTo(b.x));
    return spots;
  }

  double _getMaxX() {
    if (data.isEmpty) return 0;
    return data.map((e) => e.xValue).reduce((a, b) => a > b ? a : b);
  }

  ChartDataPoint? _getDataPointByXValue(int windowIndex) {
    final matches = data.where((p) => p.xValue.toInt() == windowIndex).toList();
    return matches.isNotEmpty ? matches.last : null;
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
    return NumberFormatHelper.formatYAxisLabel(value, locale: locale);
  }
}
