import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_fonts.dart';
import 'package:moneyapp/controllers/ui_controller.dart';

/// Search field widget for hashtag searching
class HashtagSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final UiController uiController;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const HashtagSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.uiController,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20.h,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: AppFonts.medium(
          16.sp,
          color: uiController.darkMode.value ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppFonts.regular(
            16.sp,
            color: uiController.darkMode.value
                ? Colors.grey[600]!
                : Color(0xff9D9D9D),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 2.h),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: onClear,
                  child: Icon(
                    Icons.clear,
                    size: 18.r,
                    color: uiController.darkMode.value
                        ? Colors.white54
                        : Colors.grey[600],
                  ),
                )
              : null,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
