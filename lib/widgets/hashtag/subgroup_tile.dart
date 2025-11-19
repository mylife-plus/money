import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

/// Subgroup tile widget for displaying individual hashtags within a group
class SubgroupTile extends StatelessWidget {
  final HashtagGroup subgroup;
  final UiController uiController;
  final bool isSelected;
  final bool allowMultipleSelection;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SubgroupTile({
    super.key,
    required this.subgroup,
    required this.uiController,
    required this.isSelected,
    required this.allowMultipleSelection,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: uiController.darkMode.value
            ? Colors.grey[900]
            : const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(2.r),
        border: isSelected
            ? Border.all(color: uiController.currentMainColor, width: 2.w)
            : null,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 5.w),
        dense: true,
        title: CustomText.richText(
          children: [
            CustomText.span(
              '#  ',
              size: 20.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: Colors.grey[400],
            ),
            CustomText.span(
              subgroup.name,
              size: 18.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: uiController.darkMode.value
                  ? Colors.white
                  : Colors.black,
            ),
          ],
        ),
        trailing: allowMultipleSelection
            ? null // Hide edit/delete buttons in filter mode
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit button
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          uiController.darkMode.value
                              ? Colors.white70
                              : Colors.black54,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          AppIcons.edit,
                          width: 20.w,
                          height: 20.h,
                        ),
                      ),
                      tooltip: 'Edit',
                      padding: EdgeInsets.all(4.r),
                      constraints: BoxConstraints(
                        minWidth: 28.w,
                        minHeight: 28.h,
                      ),
                    ),
                  // Delete button
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.red.withValues(alpha: 0.7),
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          AppIcons.closeBold,
                          width: 20.w,
                          height: 20.h,
                        ),
                      ),
                      tooltip: 'Delete',
                      padding: EdgeInsets.all(4.r),
                      constraints: BoxConstraints(
                        minWidth: 28.w,
                        minHeight: 28.h,
                      ),
                    ),
                ],
              ),
        onTap: onTap,
      ),
    );
  }
}
