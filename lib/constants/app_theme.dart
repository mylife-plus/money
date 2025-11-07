import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_constants.dart';

/// App Theme Configuration
/// Contains light and dark theme configurations
class AppTheme {
  AppTheme._();

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.kumbhSansTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(color: AppColors.textWhite),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
        ),
      ),
    );
  }

  /// Dark Theme (for future use)
  /// Uncomment and customize when needed
  // static ThemeData get darkTheme {
  //   return ThemeData(
  //     useMaterial3: true,
  //     colorScheme: ColorScheme.fromSeed(
  //       seedColor: AppColors.primary,
  //       brightness: Brightness.dark,
  //     ),
  //     // Add dark theme customization here
  //   );
  // }
}
