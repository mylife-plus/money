import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

/// Selection Mode App Bar
/// Displayed when transactions are selected for batch operations
class SelectionAppBar extends StatelessWidget {
  /// Number of selected items
  final int selectedCount;

  /// Callback when cancel/close is tapped
  final VoidCallback onCancel;

  /// Callback when add hashtag is tapped
  final VoidCallback onAddHashtag;

  /// Callback when edit MCC is tapped
  final VoidCallback onEditMCC;

  /// Callback when delete is tapped
  final VoidCallback onDelete;

  const SelectionAppBar({
    super.key,
    required this.selectedCount,
    required this.onCancel,
    required this.onAddHashtag,
    required this.onEditMCC,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.lightTheme.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row with count and cancel
          Padding(
            padding: EdgeInsets.fromLTRB(21.w, 11.h, 21.w, 10.h),
            child: Row(
              children: [
                Image.asset(AppIcons.transaction, height: 32.r, width: 32.r),
                5.horizontalSpace,
                CustomText(
                  '$selectedCount Selected',
                  color: const Color(0xff0088FF),
                  size: 18.sp,
                  fontWeight: FontWeight.w500,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.greyBorder),
                    ),
                    child: CustomText(
                      'Cancel',
                      size: 16.sp,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons row
          Container(
            padding: EdgeInsets.fromLTRB(21.w, 0, 21.w, 15.h),
            child: Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'add #',
                    color: const Color(0xff0088FF),
                    onTap: onAddHashtag,
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: _ActionButton(
                    label: 'edit MCC',
                    color: const Color(0xff0071FF),
                    onTap: onEditMCC,
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: _ActionButton(
                    label: 'delete',
                    color: const Color(0xffFF0000),
                    onTap: onDelete,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 41.h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.greyBorder),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: CustomText(
            label,
            size: 16.sp,
            fontWeight: FontWeight.w400,
            color: color,
          ),
        ),
      ),
    );
  }
}
