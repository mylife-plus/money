/// Data point for the chart
class ChartDataPoint {
  final String label;
  final double value;
  final String tooltipLabel;
  final double xValue; // X-axis position for step-line effect

  ChartDataPoint({
    required this.label,
    required this.value,
    required this.tooltipLabel,
    required this.xValue,
  });
}
