import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom Text Widget with GoogleFonts support
/// Use this widget throughout the app for consistent typography with proper font weight loading
class CustomText extends StatelessWidget {
  final String text;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final double? letterSpacing;
  final double? height;
  final FontWeight? fontWeight;
  final double? size;

  const CustomText(
    this.text, {
    super.key,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.letterSpacing,
    this.height,
    this.fontWeight,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.kumbhSans(
        color: color,
        letterSpacing: letterSpacing,
        height: height,
        fontWeight: fontWeight,
        fontSize: size,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }

  /// Rich Text variation with multiple text spans
  /// Use this when you need text with different styles (e.g., bold + regular)
  static Widget richText({
    required List<TextSpan> children,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
  }) {
    return RichText(
      text: TextSpan(children: children),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      softWrap: softWrap ?? true,
    );
  }

  /// Helper method to create a TextSpan with Kumbh Sans font
  static TextSpan span(
    String text, {
    Color? color,
    double? size,
    FontWeight? fontWeight,
    double? letterSpacing,
    double? height,
  }) {
    return TextSpan(
      text: text,
      style: GoogleFonts.kumbhSans(
        color: color,
        fontSize: size,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
      ),
    );
  }
}
