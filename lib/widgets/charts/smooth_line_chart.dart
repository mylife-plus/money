import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/models/chart_data_point.dart';
import 'package:moneyapp/utils/number_format_helper.dart';

class SmoothLineChartWidget extends StatelessWidget {
  final List<ChartDataPoint> data;
  final Color lineColor;
  final double lineWidth;
  final bool showDots;
  final bool showEndDot;
  final Color? tooltipAmountColor;
  final String? locale;
  final bool showFourLabels;

  const SmoothLineChartWidget({
    super.key,
    required this.data,
    this.lineColor = const Color(0xff0088FF),
    this.lineWidth = 3,
    this.showDots = false,
    this.showEndDot = true,
    this.tooltipAmountColor,
    this.locale,
    this.showFourLabels = false,
  });

  List<FlSpot> _getSpots() {
    return List.generate(
      data.length,
      (index) => FlSpot(index.toDouble(), data[index].value),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final spots = _getSpots();
    final minY = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    final maxY = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final range = (maxY - minY).abs();
    final padding = range > 0 ? range * 0.1 : 1.0;

    final chartMin = minY - padding;
    final chartMax = maxY + padding;
    final totalRange = chartMax - chartMin;
    final horizontalInterval = totalRange > 0 ? totalRange / 3 : 1.0;

    final amountColor = tooltipAmountColor ?? const Color(0xff0088FF);

    return LineChart(
      LineChartData(
        minY: minY - padding,
        maxY: maxY + padding,
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: horizontalInterval,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45.w,
              minIncluded: true,
              maxIncluded: true,
              interval: horizontalInterval,
              getTitlesWidget: (value, meta) {
                if (value < 0) return const SizedBox.shrink();
                return Text(
                  _formatYAxisLabel(value),
                  style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30.h,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox.shrink();
                }
                final maxIdx = data.length - 1;
                if (maxIdx <= 3) {
                  return Padding(
                    padding: EdgeInsets.only(top: 14.h),
                    child: Text(
                      data[index].label,
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                  );
                }
                final labelCount = showFourLabels ? 4 : 3;
                final step = maxIdx / (labelCount - 1).toDouble();
                final positions = List.generate(labelCount, (i) => (step * i).round()).toSet();
                if (positions.contains(index)) {
                  return Padding(
                    padding: EdgeInsets.only(top: 14.h),
                    child: Text(
                      data[index].label,
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
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
            top: BorderSide(
              color: Colors.grey.withValues(alpha: 0.3),
              width: 1,
            ),
            right: BorderSide.none,
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: lineColor,
            barWidth: lineWidth,
            dotData: FlDotData(
              show: showDots,
              getDotPainter: (spot, percent, barData, index) {
                // Show dot only at the end if showEndDot is true
                if (showEndDot && index == spots.length - 1) {
                  return FlDotCirclePainter(
                    radius: 6.r,
                    color: lineColor,
                    strokeWidth: 3,
                    strokeColor: Colors.white,
                  );
                }
                return FlDotCirclePainter(radius: 0, color: Colors.transparent);
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.white,
            tooltipBorder: BorderSide(color: Colors.grey.shade300),
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final parts = data[spot.x.toInt()].tooltipLabel.split('\n');
                final amount = parts.isNotEmpty ? parts[0] : '';
                final date = parts.length > 1 ? parts[1] : '';
                return LineTooltipItem(
                  amount,
                  TextStyle(
                    color: amountColor,
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
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  String _formatYAxisLabel(double value) {
    return NumberFormatHelper.formatYAxisLabel(value, locale: locale);
  }
}
