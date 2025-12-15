import 'package:flutter/material.dart';
import 'package:moneyapp/constants/app_colors.dart';

/// A helper class for showing date pickers with consistent theming across the app
class DatePickerHelper {
  /// Shows a date picker with the app's standard theme
  ///
  /// [context] - The build context
  /// [initialDate] - The initially selected date (defaults to today)
  /// [firstDate] - The earliest selectable date (defaults to year 2000)
  /// [lastDate] - The latest selectable date (defaults to today)
  ///
  /// Returns a [Future] that completes with the selected [DateTime] or null if cancelled
  static Future<DateTime?> showStyledDatePicker(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: AppColors.background,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.black, // sets Cancel/OK text color
              ),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
