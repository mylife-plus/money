import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyapp/constants/app_colors.dart';

/// App Text Style Constants
/// Define all text styles here using Kumbh Sans font
class AppTextStyles {
  AppTextStyles._();

  // Base text style with Kumbh Sans
  static TextStyle get _baseTextStyle => GoogleFonts.kumbhSans();

  // Headings
  static TextStyle get h1 => _baseTextStyle.copyWith(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get h2 => _baseTextStyle.copyWith(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => _baseTextStyle.copyWith(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get h4 => _baseTextStyle.copyWith(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get h5 => _baseTextStyle.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get h6 => _baseTextStyle.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  // Body Text
  static TextStyle get bodyLarge => _baseTextStyle.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => _baseTextStyle.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => _baseTextStyle.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  // Labels
  static TextStyle get labelLarge => _baseTextStyle.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => _baseTextStyle.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelSmall => _baseTextStyle.copyWith(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
      );

  // Caption
  static TextStyle get caption => _baseTextStyle.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  // Button
  static TextStyle get button => _baseTextStyle.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textWhite,
      );
}
