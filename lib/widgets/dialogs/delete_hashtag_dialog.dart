import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

/// Delete confirmation dialog for hashtag groups
class DeleteHashtagDialog {
  static void show({
    required HashtagGroup hashtagGroup,
    required VoidCallback onConfirm,
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
              // Title
              CustomText(
                'Delete Hashtag Group',
                size: 18.sp,
                fontWeight: FontWeight.bold,
                color: uiController.darkMode.value
                    ? Colors.white
                    : Colors.black,
              ),
              SizedBox(height: 16.h),

              // Message
              CustomText(
                'Are you sure you want to delete "${hashtagGroup.name}"?',
                size: 16.sp,
                color: uiController.darkMode.value
                    ? Colors.white70
                    : Colors.grey[700],
              ),
              SizedBox(height: 16.h),

              // Warning box
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
                    Icon(Icons.warning, color: Colors.orange, size: 20.r),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: CustomText(
                        'This action cannot be undone.',
                        size: 14.sp,
                        color: Colors.orange[700],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: CustomText(
                      'Cancel',
                      size: 16.sp,
                      color: uiController.darkMode.value
                          ? Colors.white70
                          : Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    child: CustomText(
                      'Delete',
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
