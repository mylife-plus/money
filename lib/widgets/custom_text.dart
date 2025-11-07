import 'package:flutter/material.dart';
import 'package:moneyapp/constants/app_text_styles.dart';

/// Custom Text Widget with predefined variations
/// Use this widget throughout the app for consistent typography
class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final double? letterSpacing;
  final double? height;
  final FontWeight? fontWeight;
  final double? size; // <-- Added

  const CustomText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.letterSpacing,
    this.height,
    this.fontWeight,
    this.size, // <-- Added
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: (style ?? AppTextStyles.bodyMedium).copyWith(
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        fontWeight: fontWeight,
        fontSize: size, // <-- Added
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }

  // ... rest of the code unchanged ...
}
