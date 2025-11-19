import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

/// Dialog shown when hashtag group cannot be deleted due to existing memories
class CannotDeleteHashtagDialog {
  static void show({
    required String groupName,
    required int memoryCount,
  }) {
    final uiController = Get.find<UiController>();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: uiController.darkMode.value
                ? Colors.grey[900]
                : Colors.white,
            borderRadius: BorderRadius.circular(4.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with icon
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 24.r),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: CustomText(
                      'Cannot Delete Hashtag Group',
                      size: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: uiController.darkMode.value
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Message
              CustomText(
                'The hashtag group "$groupName" cannot be deleted because it is being used by $memoryCount ${memoryCount == 1 ? 'memory' : 'memories'}.',
                size: 16.sp,
                color: uiController.darkMode.value
                    ? Colors.white70
                    : Colors.grey[700],
              ),
              SizedBox(height: 16.h),

              // Info box
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20.r),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: CustomText(
                        'To delete this hashtag group, first remove the hashtags from all memories that use them, or delete those memories.',
                        size: 14.sp,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // OK button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: CustomText(
                    'OK',
                    size: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: uiController.currentMainColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
