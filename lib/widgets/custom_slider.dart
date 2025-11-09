import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Custom Slider Widget using Flutter's built-in RangeSlider
/// A slider with circular handles on both ends and a connecting line
class CustomSlider extends StatefulWidget {
  /// Minimum value
  final double min;

  /// Maximum value
  final double max;

  /// Current start value (left handle)
  final double startValue;

  /// Current end value (right handle)
  final double endValue;

  /// Callback when values change
  final Function(double start, double end)? onChanged;

  /// Line color
  final Color lineColor;

  /// Handle (circle) color
  final Color handleColor;

  /// Line height/thickness
  final double lineHeight;

  /// Handle (circle) radius
  final double handleRadius;

  const CustomSlider({
    super.key,
    this.min = 0,
    this.max = 100,
    required this.startValue,
    required this.endValue,
    this.onChanged,
    this.lineColor = const Color(0xFF4CAF50),
    this.handleColor = const Color(0xFFFFD700),
    this.lineHeight = 9,
    this.handleRadius = 11,
  });

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  late RangeValues _currentRangeValues;

  @override
  void initState() {
    super.initState();
    _currentRangeValues = RangeValues(widget.startValue, widget.endValue);
  }

  @override
  void didUpdateWidget(CustomSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startValue != widget.startValue ||
        oldWidget.endValue != widget.endValue) {
      _currentRangeValues = RangeValues(widget.startValue, widget.endValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        // Track (line) styling
        activeTrackColor: widget.lineColor,
        inactiveTrackColor: widget.lineColor.withValues(alpha: 0.2),
        trackHeight: widget.lineHeight.h,

        // Thumb (handle/circle) styling
        thumbColor: widget.handleColor,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: widget.handleRadius.r,
          elevation: 2,
          pressedElevation: 4,
        ),

        // Overlay (touch area) styling
        overlayColor: widget.handleColor.withValues(alpha: 0.2),
        overlayShape: RoundSliderOverlayShape(
          overlayRadius: (widget.handleRadius * 1.5).r,
        ),

        // Range slider specific
        rangeThumbShape: RoundRangeSliderThumbShape(
          enabledThumbRadius: widget.handleRadius.r,
          elevation: 2,
          pressedElevation: 4,
        ),
        rangeTrackShape: const RoundedRectRangeSliderTrackShape(),

        // Value indicator (optional - shows value on drag)
        valueIndicatorColor: widget.lineColor,
        valueIndicatorTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
        ),
      ),
      child: RangeSlider(
        values: _currentRangeValues,
        min: widget.min,
        max: widget.max,
        onChanged: (RangeValues values) {
          setState(() {
            _currentRangeValues = values;
          });
          widget.onChanged?.call(values.start, values.end);
        },
      ),
    );
  }
}
