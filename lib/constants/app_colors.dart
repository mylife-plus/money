import 'package:flutter/material.dart';

/// App Color Constants
/// Define all app colors here
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFFFFD000);

  // Accent Colors
  static const Color accent = Color(0xFF03DAC6);
  static const Color accentDark = Color(0xFF018786);

  // Background Colors
  static const Color background = Color(0xFFFFFFE4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F3F3);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color appBarText = Color(0xFFFFCC00);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFB00020);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF2196F3);

  // Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  // Transparent
  static const Color transparent = Colors.transparent;

  // Expense Colors
  static const Color expenseYearBackground = Color(0xFFFF9696);
  static const Color expenseMonthBackground = Color(0xFFFFC8C8);
  static const Color expenseDayBackground = Color(0xFFFFE7E7);
  static const Color expenseYearText = Color(0xFFAB0000);
  static const Color expenseMonthText = Color(0xFFFF0000);
  static const Color expenseDayText = Color(0xFFFF5858);

  // Income Colors
  static const Color incomeYearBackground = Color(0xFF00ED10);
  static const Color incomeMonthBackground = Color(0xFF6CFF75);
  static const Color incomeDayBackground = Color(0xFFC3FFC7);
  static const Color incomeYearText = Color(0xFF006607);
  static const Color incomeMonthText = Color(0xFF00A40B);
  static const Color incomeDayText = Color(0xFF00C60D);
}
