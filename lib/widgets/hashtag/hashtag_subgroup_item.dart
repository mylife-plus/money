import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class HashtagSubgroupItem extends StatelessWidget {
  final HashtagGroup subgroup;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isSelected;
  final bool allowMultipleSelection;
  final VoidCallback? onToggleSelection;

  const HashtagSubgroupItem({
    super.key,
    required this.subgroup,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.isSelected = false,
    this.allowMultipleSelection = false,
    this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UiController>();

    return Obx(() {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: uiController.darkMode.value
              ? const Color(0xff2C2C2C)
              : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: uiController.darkMode.value
                ? const Color(0xff3C3C3C)
                : const Color(0xffDFDFDF),
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          leading: Padding(
            padding: EdgeInsets.only(left: 20.w),
            child: CustomText(
              '#${subgroup.name}',
              size: 16.sp,
              color: uiController.darkMode.value
                  ? Colors.white70
                  : const Color(0xff707070),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!allowMultipleSelection) ...[
                // Edit button
                IconButton(
                  icon: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      uiController.darkMode.value
                          ? Colors.white.withValues(alpha: 0.6)
                          : Colors.grey[500] ?? Colors.grey,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      AppIcons.edit,
                      width: 20.r,
                      height: 20.r,
                    ),
                  ),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                ),
                // Delete button
                IconButton(
                  icon: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.red,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      AppIcons.closeBold,
                      width: 20.r,
                      height: 20.r,
                    ),
                  ),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              ] else ...[
                // Selection checkbox in filter mode
                GestureDetector(
                  onTap: onToggleSelection,
                  child: Container(
                    width: 24.r,
                    height: 24.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? uiController.currentMainColor
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? uiController.currentMainColor
                            : (uiController.darkMode.value
                                  ? Colors.white54
                                  : const Color(0xffA0A0A0)),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(Icons.check, size: 16.r, color: Colors.white)
                        : null,
                  ),
                ),
              ],
            ],
          ),
          onTap: onTap,
        ),
      );
    });
  }
}
