import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/hashtag/hashtag_subgroup_item.dart';

class HashtagGroupExpansionTile extends StatelessWidget {
  final HashtagGroup group;
  final ExpansionTileController controller;
  final bool isExpanded;
  final VoidCallback onExpansionChanged;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onAddSubgroup;
  final Function(HashtagGroup) onSubgroupTap;
  final Function(HashtagGroup) onEditSubgroup;
  final Function(HashtagGroup) onDeleteSubgroup;
  final bool allowMultipleSelection;
  final List<HashtagGroup> selectedGroups;
  final Function(HashtagGroup)? onToggleSelection;
  final Widget? addWidget;

  const HashtagGroupExpansionTile({
    super.key,
    required this.group,
    required this.controller,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.onEdit,
    this.onDelete,
    required this.onAddSubgroup,
    required this.onSubgroupTap,
    required this.onEditSubgroup,
    required this.onDeleteSubgroup,
    this.allowMultipleSelection = false,
    this.selectedGroups = const [],
    this.onToggleSelection,
    this.addWidget,
  });

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UiController>();

    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: uiController.darkMode.value
                  ? const Color(0xff2C2C2C)
                  : const Color(0xffF5F5F5),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: uiController.darkMode.value
                    ? const Color(0xff3C3C3C)
                    : const Color(0xffDFDFDF),
                width: 1,
              ),
            ),
            child: ExpansionTile(
              controller: controller,
              initiallyExpanded: isExpanded,
              onExpansionChanged: (_) => onExpansionChanged(),
              tilePadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              title: CustomText(
                group.name,
                size: 16.sp,
                color: uiController.darkMode.value
                    ? Colors.white
                    : Colors.black,
                fontWeight: FontWeight.w600,
              ),
              trailing: _buildTrailingActions(uiController),
              children: const [],
            ),
          ),
          if (isExpanded) ...[
            ..._buildSubgroupsList(),
            if (addWidget != null) addWidget!,
          ],
        ],
      );
    });
  }

  Widget _buildTrailingActions(UiController uiController) {
    return Row(
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
              child: Image.asset(AppIcons.edit, width: 25.r, height: 25.r),
            ),
            onPressed: onEdit,
            tooltip: 'Edit Hashtag Group',
          ),
          // Delete button (only if no subgroups)
          if (onDelete != null && (group.subgroups?.isEmpty ?? true))
            IconButton(
              icon: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.red,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  AppIcons.closeBold,
                  width: 25.r,
                  height: 25.r,
                ),
              ),
              onPressed: onDelete,
              tooltip: 'Delete Hashtag Group',
            ),
          // Add subgroup button
          IconButton(
            onPressed: onAddSubgroup,
            icon: ColorFiltered(
              colorFilter: ColorFilter.mode(
                uiController.darkMode.value
                    ? Colors.white
                    : uiController.currentMainColor,
                BlendMode.srcIn,
              ),
              child: Image.asset(AppIcons.plus, width: 25.r, height: 25.r),
            ),
            tooltip: 'Add Subgroup',
          ),
        ],
        // Expansion icon
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            uiController.darkMode.value
                ? Colors.white.withValues(alpha: 0.6)
                : Colors.grey[600] ?? Colors.grey,
            BlendMode.srcIn,
          ),
          child: Transform.rotate(
            angle: isExpanded ? 3.14159 : 0, // π radians = 180 degrees
            child: Image.asset(
              AppIcons.edit, // Using edit icon as placeholder for arrow
              width: 25.r,
              height: 25.r,
            ),
          ),
        ),
        SizedBox(width: 15.w),
      ],
    );
  }

  List<Widget> _buildSubgroupsList() {
    if (group.subgroups == null || group.subgroups!.isEmpty) {
      return [];
    }

    return group.subgroups!.map((subgroup) {
      final isSelected =
          allowMultipleSelection &&
          selectedGroups.any((g) => g.id == subgroup.id);

      return HashtagSubgroupItem(
        subgroup: subgroup,
        onTap: () => onSubgroupTap(subgroup),
        onEdit: () => onEditSubgroup(subgroup),
        onDelete: () => onDeleteSubgroup(subgroup),
        isSelected: isSelected,
        allowMultipleSelection: allowMultipleSelection,
        onToggleSelection: onToggleSelection != null
            ? () => onToggleSelection!(subgroup)
            : null,
      );
    }).toList();
  }
}
