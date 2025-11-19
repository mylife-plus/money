import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class HashtagSelectionIndicator extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onDone;

  const HashtagSelectionIndicator({
    super.key,
    required this.selectedCount,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UiController>();

    if (selectedCount == 0) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: uiController.currentMainColor.withValues(alpha: 0.1),
          border: Border(
            bottom: BorderSide(
              color: uiController.currentMainColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              '$selectedCount ${selectedCount == 1 ? 'hashtag' : 'hashtags'} selected',
              size: 16.sp,
              color: uiController.darkMode.value
                  ? Colors.white
                  : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            TextButton(
              onPressed: onDone,
              style: TextButton.styleFrom(
                backgroundColor: uiController.currentMainColor,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: CustomText(
                'Done',
                size: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    });
  }
}
