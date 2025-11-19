import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

/// Inline add widget for adding new hashtags
class InlineAddHashtagWidget extends StatelessWidget {
  final TextEditingController controller;
  final UiController uiController;
  final String hintText;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final bool isSubgroup;

  const InlineAddHashtagWidget({
    super.key,
    required this.controller,
    required this.uiController,
    required this.hintText,
    required this.onSave,
    required this.onCancel,
    this.isSubgroup = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isSubgroup) {
      // Subgroup style (matches ListTile with hash symbol)
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: uiController.darkMode.value
              ? Colors.grey[900]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(2.r),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 5.w),
          dense: true,
          title: Row(
            children: [
              // Hash symbol
              CustomText(
                '#  ',
                size: 20.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[400],
              ),
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
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontFamily: 'KumbhSans',
                      color: uiController.darkMode.value
                          ? Colors.white
                          : Colors.black,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.h),
              ),
              // Cancel button
              IconButton(
                onPressed: onCancel,
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.red.withValues(alpha: 0.7),
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
                constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.h),
              ),
            ],
          ),
        ),
      );
    }

    // Main group style
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: uiController.darkMode.value ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(2.r),
        border: Border.all(
          color: uiController.darkMode.value
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.grey.shade300,
        ),
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
                        fontSize: 16.sp,
                      ),
                      filled: true,
                      fillColor: uiController.darkMode.value
                          ? Colors.grey[700]
                          : Colors.white,
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
                      fontSize: 16.sp,
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
