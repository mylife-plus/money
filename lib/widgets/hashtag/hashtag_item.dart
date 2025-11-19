import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

/// Individual hashtag item widget
class HashtagItem extends StatelessWidget {
  final String hashtag;
  final VoidCallback onTap;
  final UiController uiController;
  final bool showFolderIcon;

  const HashtagItem({
    super.key,
    required this.hashtag,
    required this.onTap,
    required this.uiController,
    this.showFolderIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: [
            CustomText(
              '#',
              size: 16.sp,
              fontWeight: FontWeight.bold,
              color: uiController.darkMode.value
                  ? Colors.white
                  : Colors.grey[600],
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: CustomText(
                hashtag,
                size: 18.sp,
                fontWeight: FontWeight.w500,
                color: uiController.darkMode.value
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            // Show folder icon if specified
            if (showFolderIcon)
              Icon(
                Icons.folder_outlined,
                size: 18.r,
                color: uiController.darkMode.value
                    ? Colors.white54
                    : Colors.grey[600],
              ),
          ],
        ),
      ),
    );
  }
}
