import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

/// Hashtag group item widget
class HashtagGroupItem extends StatelessWidget {
  final HashtagGroup group;
  final VoidCallback onTap;
  final UiController uiController;

  const HashtagGroupItem({
    super.key,
    required this.group,
    required this.onTap,
    required this.uiController,
  });

  @override
  Widget build(BuildContext context) {
    // Check if this is a main category (parentId is null)
    final isMainCategory = group.parentId == null;

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
                group.name,
                size: 18.sp,
                fontWeight: FontWeight.w500,
                color: uiController.darkMode.value
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            // Show folder icon only for main categories (not subcategories)
            if (isMainCategory)
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
