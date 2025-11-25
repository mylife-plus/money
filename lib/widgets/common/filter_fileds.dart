import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/utils/date_picker_helper.dart';

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
    final picked = await DatePickerHelper.showStyledDatePicker(context);

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
          onTap: isDateField ? () => _pickDate(context, controller2) : null,
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
                  color: controller2.darkMode.value
                      ? Colors.white
                      : Colors.grey,
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
