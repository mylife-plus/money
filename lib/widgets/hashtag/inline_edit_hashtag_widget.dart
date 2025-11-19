import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/controllers/ui_controller.dart';

/// Inline edit widget for editing hashtag names
class InlineEditHashtagWidget extends StatelessWidget {
  final TextEditingController controller;
  final UiController uiController;
  final String hintText;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const InlineEditHashtagWidget({
    super.key,
    required this.controller,
    required this.uiController,
    required this.hintText,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: uiController.darkMode.value
            ? Colors.black
            : uiController.currentMainColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextSelectionTheme(
                  data: TextSelectionThemeData(
                    cursorColor: uiController.currentMainColor,
                    selectionColor: uiController.currentMainColor.withValues(
                      alpha: 0.3,
                    ),
                    selectionHandleColor: uiController.currentMainColor,
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        fontFamily: 'KumbhSans',
                        color: uiController.darkMode.value
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.grey[500],
                        fontSize: 18.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                    ),
                    style: TextStyle(
                      fontFamily: 'KumbhSans',
                      color: uiController.darkMode.value
                          ? Colors.white
                          : Colors.black,
                      fontSize: 18.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Save button
              IconButton(
                onPressed: onSave,
                icon: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.green,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/images/ic_tick.png',
                    width: 20.w,
                    height: 20.h,
                  ),
                ),
                tooltip: 'Save',
                padding: EdgeInsets.all(4.r),
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
              ),
              // Cancel button
              IconButton(
                onPressed: onCancel,
                icon: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.red,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/images/ic_cross.png',
                    width: 20.w,
                    height: 20.h,
                  ),
                ),
                tooltip: 'Cancel',
                padding: EdgeInsets.all(4.r),
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
