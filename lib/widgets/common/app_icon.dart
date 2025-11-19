import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// App Icon Widget
/// Helper widget to display icons with consistent sizing
class AppIcon extends StatelessWidget {
  final String iconPath;
  final double? size;
  final Color? color;
  final BoxFit fit;

  const AppIcon(
    this.iconPath, {
    super.key,
    this.size,
    this.color,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      iconPath,
      width: size?.w ?? 24.w,
      height: size?.h ?? 24.h,
      color: color,
      fit: fit,
    );
  }
}
