import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/controllers/hashtag_groups_controller.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class HashtagSelectionDialog extends StatefulWidget {
  final Function(HashtagGroup) onSelected;

  const HashtagSelectionDialog({super.key, required this.onSelected});

  @override
  State<HashtagSelectionDialog> createState() => _HashtagSelectionDialogState();
}

class _HashtagSelectionDialogState extends State<HashtagSelectionDialog> {
  final HashtagGroupsController hashtagController =
      Get.find<HashtagGroupsController>();
  final TextEditingController searchController = TextEditingController();
  List<HashtagGroup> filteredHashtags = [];
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _initializeHashtags();
    searchController.addListener(_onSearchChanged);
  }

  void _initializeHashtags() {
    // Get all hashtags (both main groups and subgroups) in a flat list
    final allGroups = hashtagController.allGroups;
    filteredHashtags = [];

    for (final mainGroup in allGroups) {
      // Add the main group itself
      filteredHashtags.add(mainGroup);

      // Add all subgroups
      if (mainGroup.subgroups != null && mainGroup.subgroups!.isNotEmpty) {
        filteredHashtags.addAll(mainGroup.subgroups!);
      }
    }
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
        if (selectedCategoryId != null) {
          // Filter by selected main category
          filteredHashtags = [];
          final mainGroup = hashtagController.allGroups.firstWhereOrNull(
            (g) => g.id == selectedCategoryId,
          );
          if (mainGroup != null) {
            filteredHashtags.add(mainGroup);
            if (mainGroup.subgroups != null) {
              filteredHashtags.addAll(mainGroup.subgroups!);
            }
          }
        } else {
          _initializeHashtags();
        }
      } else {
        // Search through all hashtags
        final searchText = searchController.text.toLowerCase();
        _initializeHashtags();
        filteredHashtags = filteredHashtags.where((hashtag) {
          final matchesSearch = hashtag.name.toLowerCase().contains(searchText);
          final matchesCategory =
              selectedCategoryId == null ||
              hashtag.id == selectedCategoryId ||
              hashtag.parentId == selectedCategoryId;
          return matchesSearch && matchesCategory;
        }).toList();
      }
    });
  }

  String _getCategoryName(HashtagGroup hashtag) {
    if (hashtag.isMainGroup) {
      return 'Main Group';
    } else {
      final mainGroup = hashtagController.allGroups.firstWhereOrNull(
        (g) => g.id == hashtag.parentId,
      );
      return mainGroup?.name ?? 'Unknown';
    }
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
                  'Select Hashtag',
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
                  hintText: 'Search Hashtag',
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
                        'No Hashtags found',
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
                        return InkWell(
                          onTap: () {
                            widget.onSelected(hashtag);
                            Get.back();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 8.w,
                            ),
                            child: Row(
                              children: [
                                // Hashtag symbol
                                CustomText(
                                  '#',
                                  size: 20.sp,
                                  color: const Color(0xff9D9D9D),
                                ),
                                12.horizontalSpace,
                                // Hashtag name
                                Expanded(
                                  child: CustomText(
                                    hashtag.name,
                                    size: 15.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // Category name
                                CustomText(
                                  _getCategoryName(hashtag),
                                  size: 12.sp,
                                  color: const Color(0xff707070),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            12.verticalSpace,

            // Add New Hashtag Button
            InkWell(
              onTap: () {
                Get.back();
                // Navigate to hashtag management screen
                // Adjust the route based on your app's routing
                Get.toNamed(AppRoutes.hashtagGroups.path);
              },
              child: Container(
                height: 44.h,
                decoration: BoxDecoration(
                  color: const Color(0xff0088FF),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20.sp),
                      8.horizontalSpace,
                      CustomText(
                        'Add New Hashtag',
                        size: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
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
