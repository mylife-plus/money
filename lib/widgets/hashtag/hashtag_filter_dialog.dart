import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/controllers/hashtag_groups_controller.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class HashtagFilterDialog extends StatefulWidget {
  final List<HashtagGroup> selectedHashtags;
  final Function(List<HashtagGroup>) onSelectionChanged;

  const HashtagFilterDialog({
    super.key,
    required this.selectedHashtags,
    required this.onSelectionChanged,
  });

  @override
  State<HashtagFilterDialog> createState() => _HashtagFilterDialogState();
}

class _HashtagFilterDialogState extends State<HashtagFilterDialog> {
  late final HashtagGroupsController hashtagController;
  final TextEditingController searchController = TextEditingController();
  List<HashtagGroup> filteredHashtags = [];
  List<HashtagGroup> selectedHashtags = [];

  @override
  void initState() {
    super.initState();
    hashtagController = Get.find<HashtagGroupsController>();
    selectedHashtags = List.from(widget.selectedHashtags);
    filteredHashtags = hashtagController.allGroups;
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      if (searchController.text.isEmpty) {
        filteredHashtags = hashtagController.allGroups;
      } else {
        final query = searchController.text.toLowerCase();
        filteredHashtags = hashtagController.allGroups
            .where((hashtag) => hashtag.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _toggleHashtag(HashtagGroup hashtag) {
    setState(() {
      final index = selectedHashtags.indexWhere(
        (item) => item.id == hashtag.id,
      );
      if (index >= 0) {
        selectedHashtags.removeAt(index);
      } else {
        selectedHashtags.add(hashtag);
      }
    });
  }

  bool _isSelected(HashtagGroup hashtag) {
    return selectedHashtags.any((item) => item.id == hashtag.id);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        width: double.infinity,
        height: 500.h,
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  'Select Hashtags',
                  size: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
                InkWell(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close, size: 24.sp),
                ),
              ],
            ),
            16.verticalSpace,

            // Search field
            Container(
              height: 41.h,
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xffDFDFDF)),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search Hashtags',
                  suffixIcon: Icon(
                    Icons.search,
                    size: 20.sp,
                    color: const Color(0xffB4B4B4),
                  ),
                  labelStyle: TextStyle(
                    color: Color(0xffB4B4B4),
                    fontSize: 16.sp,
                  ),
                  hintStyle: TextStyle(
                    color: Color(0xffB4B4B4),
                    fontSize: 16.sp,
                  ),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
            16.verticalSpace,

            // Hashtag List
            Expanded(
              child: filteredHashtags.isEmpty
                  ? Center(
                      child: CustomText(
                        'No hashtags found',
                        size: 14.sp,
                        color: const Color(0xffB4B4B4),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredHashtags.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1.h, color: const Color(0xffDFDFDF)),
                      itemBuilder: (context, index) {
                        final hashtag = filteredHashtags[index];
                        final isSelected = _isSelected(hashtag);

                        // Find parent group name if it's a subgroup
                        String? parentName;
                        if (hashtag.isSubgroup) {
                          final parent = hashtagController.allGroups
                              .firstWhereOrNull(
                                (g) => g.id == hashtag.parentId,
                              );
                          parentName = parent?.name;
                        }

                        return InkWell(
                          onTap: () => _toggleHashtag(hashtag),
                          child: Container(
                            color: isSelected
                                ? const Color(0xff0088FF).withValues(alpha: 0.1)
                                : Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 8.w,
                            ),
                            child: Row(
                              children: [
                                // Checkbox
                                Container(
                                  width: 20.w,
                                  height: 20.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xff0088FF)
                                          : const Color(0xffDFDFDF),
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(4.r),
                                    color: isSelected
                                        ? const Color(0xff0088FF)
                                        : Colors.white,
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 14.sp,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                12.horizontalSpace,
                                // Hashtag Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        hashtag.name,
                                        size: 15.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      if (parentName != null) ...[
                                        2.verticalSpace,
                                        CustomText(
                                          parentName,
                                          size: 12.sp,
                                          color: const Color(0xff707070),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            12.verticalSpace,

            // Apply Button
            InkWell(
              onTap: () {
                widget.onSelectionChanged(selectedHashtags);
                Get.back();
              },
              child: Container(
                width: double.infinity,
                height: 41.h,
                decoration: BoxDecoration(
                  color: const Color(0xffFFFFFF),
                  borderRadius: BorderRadius.circular(13.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Center(
                  child: CustomText(
                    'Apply (${selectedHashtags.length})',
                    size: 16.sp,
                    color: const Color(0xff0071FF),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
