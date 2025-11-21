import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyapp/controllers/ui_controller.dart';

class MemoriesFilterTextFieldRow extends StatefulWidget {
  final String imagePath;
  final String hint;

  const MemoriesFilterTextFieldRow({
    super.key,
    required this.imagePath,
    required this.hint,
  });

  @override
  State<MemoriesFilterTextFieldRow> createState() =>
      _MemoriesFilterTextFieldRowState();
}

class _MemoriesFilterTextFieldRowState
    extends State<MemoriesFilterTextFieldRow> {
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get isDateField => widget.hint.toLowerCase().contains('date');
  bool get isLocationField =>
      widget.hint.toLowerCase().contains('location') &&
      !widget.hint.toLowerCase().contains('radius');
  bool get isRadiusField => widget.hint.toLowerCase().contains('radius');

  void _handleTextChanged(String value, dynamic controller) {
    if (value.contains('@') || value.contains('#')) {
      controller.onTextChanged(widget.hint, value);
    } else {
      controller.onTextChanged(widget.hint, value);
    }
  }

  Future<void> _pickDate(BuildContext context, dynamic controller) async {
    var uiController = Get.find<UiController>();

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            useMaterial3: true,
            colorScheme: uiController.darkMode.value
                ? ColorScheme.dark(
                    primary: uiController
                        .currentMainColor, // Header background and selected elements
                    onPrimary: Colors.white, // Header text color
                    surface: const Color(
                      0xFF1E1E1E,
                    ), // Calendar background color (dark)
                    onSurface: Colors
                        .white, // Calendar text color (white for dark mode)
                    secondary:
                        uiController.currentMainColor, // Secondary elements
                    onSecondary: Colors.white,
                    outline: Colors
                        .grey[600]!, // Border colors (darker for dark mode)
                    surfaceContainerHighest: const Color(
                      0xFF2E2E2E,
                    ), // Today's date background (dark)
                    onSurfaceVariant:
                        Colors.white, // Today's date text (light for dark mode)
                    surfaceTint: Colors.transparent, // Remove any surface tint
                  )
                : ColorScheme.light(
                    primary: uiController
                        .currentMainColor, // Header background and selected elements
                    onPrimary: Colors.white, // Header text color
                    surface: Colors.white, // Calendar background color
                    onSurface: Colors.black, // Calendar text color
                    secondary:
                        uiController.currentMainColor, // Secondary elements
                    onSecondary: Colors.white,
                    outline: Colors.grey[300]!, // Border colors
                    surfaceContainerHighest:
                        Colors.white, // Today's date background
                    onSurfaceVariant: Colors.black, // Today's date text
                    surfaceTint: Colors.transparent, // Remove any surface tint
                  ),
            dialogTheme: DialogThemeData(
              backgroundColor: uiController.darkMode.value
                  ? const Color(0xFF1E1E1E) // Dark mode dialog background
                  : Colors.white, // Light mode dialog background
              surfaceTintColor: Colors.transparent, // Remove surface tint
              shadowColor: Colors.transparent,
            ),

            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    uiController.currentMainColor, // Button text color
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: uiController.darkMode.value
                  ? const Color(0xFF1E1E1E) // Dark mode date picker background
                  : Colors.white, // Light mode date picker background
              surfaceTintColor: Colors.transparent, // Remove surface tint
              shadowColor: Colors.transparent, // Remove shadow tint
              headerBackgroundColor:
                  uiController.currentMainColor, // Header background
              headerForegroundColor: Colors.white, // Header text color
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white; // Selected date text color
                }
                if (states.contains(WidgetState.disabled)) {
                  return uiController.darkMode.value
                      ? Colors
                            .grey[600] // Light grey for dark mode disabled dates
                      : Colors.grey[400]; // Grey for light mode disabled dates
                }
                return uiController.darkMode.value
                    ? Colors.white
                    : Colors.black; // Regular date text color
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return uiController
                      .currentMainColor; // Selected date background
                }
                return Colors.transparent; // Regular date background
              }),
              todayForegroundColor: WidgetStateProperty.all(
                uiController.currentMainColor,
              ), // Today's date text
              todayBackgroundColor: WidgetStateProperty.all(
                Colors.transparent,
              ), // Today's date background
              yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white; // Selected year text color
                }
                return uiController.darkMode.value
                    ? Colors.white
                    : Colors.black; // Regular year text color
              }),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              // // color: uiController.darkMode.value
              //     ? const Color(0xFF1E1E1E) // Dark mode container background
              //     : Colors.white, // Light mode container background
              borderRadius: BorderRadius.circular(12),
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        final formatted = DateFormat('dd/MM/yyyy').format(picked);
        _textController.text = formatted;
      });
      // If you have a controller with setFilterDate method, uncomment this:
      // controller.setFilterDate(widget.hint, formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller2 = Get.find<UiController>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Obx(() {
        return InkWell(
          onTap: isDateField
              ? () => _pickDate(context, controller2)
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: controller2.darkMode.value
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Image.asset(
                  widget.imagePath,
                  width: 22,
                  height: 22,
                  color: controller2.darkMode.value ? Colors.white : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _textController.text.isEmpty
                        ? widget.hint
                        : _textController.text,
                    style: GoogleFonts.kumbhSans(
                      fontSize: 14,
                      color: _textController.text.isEmpty
                          ? (controller2.darkMode.value
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.grey)
                          : (controller2.darkMode.value
                              ? Colors.white
                              : Colors.black),
                      fontWeight: _textController.text.isEmpty
                          ? FontWeight.w400
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
