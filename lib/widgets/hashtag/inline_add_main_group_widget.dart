import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class InlineAddMainGroupWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const InlineAddMainGroupWidget({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UiController>();

    return Obx(() {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: uiController.darkMode.value
              ? const Color(0xff2C2C2C)
              : const Color(0xffF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: uiController.currentMainColor, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              'Add New Hashtag Group',
              size: 14.sp,
              color: uiController.darkMode.value
                  ? Colors.white70
                  : const Color(0xff707070),
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(
                fontSize: 16.sp,
                color: uiController.darkMode.value
                    ? Colors.white
                    : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Enter group name',
                hintStyle: TextStyle(
                  fontSize: 16.sp,
                  color: uiController.darkMode.value
                      ? Colors.white38
                      : const Color(0xffB4B4B4),
                ),
                filled: true,
                fillColor: uiController.darkMode.value
                    ? const Color(0xff1C1C1C)
                    : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: uiController.darkMode.value
                        ? const Color(0xff3C3C3C)
                        : const Color(0xffDFDFDF),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: uiController.darkMode.value
                        ? const Color(0xff3C3C3C)
                        : const Color(0xffDFDFDF),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: uiController.currentMainColor,
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 12.h,
                ),
              ),
              onSubmitted: (_) => onSave(),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: CustomText(
                    'Cancel',
                    size: 14.sp,
                    color: uiController.darkMode.value
                        ? Colors.white70
                        : const Color(0xff707070),
                  ),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: uiController.currentMainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: CustomText(
                    'Save',
                    size: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
