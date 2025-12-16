import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/controllers/hashtag_groups_controller.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/services/hashtag_group_service.dart';
import 'package:moneyapp/widgets/common/add_edit_group_popup.dart';
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
  final HashtagGroupService _hashtagGroupService = HashtagGroupService();
  final TextEditingController searchController = TextEditingController();
  List<HashtagGroup> filteredHashtags = [];
  List<HashtagGroup> allHashtags = [];

  @override
  void initState() {
    super.initState();
    _initializeHashtags();
    searchController.addListener(_onSearchChanged);
  }

  void _initializeHashtags() {
    // Get all subgroups (hashtags) from all main groups
    allHashtags = [];
    for (final mainGroup in hashtagController.allGroups) {
      if (mainGroup.subgroups != null && mainGroup.subgroups!.isNotEmpty) {
        allHashtags.addAll(mainGroup.subgroups!);
      }
    }

    // Initially show only first 5
    setState(() {
      filteredHashtags = allHashtags.take(5).toList();
    });
  }

  void _onSearchChanged() {
    setState(() {
      if (searchController.text.isEmpty) {
        // Show only first 5 when no search
        filteredHashtags = allHashtags.take(5).toList();
      } else {
        // Show all matching results when searching
        final searchText = searchController.text.toLowerCase();
        filteredHashtags = allHashtags.where((hashtag) {
          return hashtag.name.toLowerCase().contains(searchText);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
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

  Future<void> _showAddHashtagDialog() async {
    // Ensure UiController is available
    if (!Get.isRegistered<UiController>()) {
      Get.put(UiController());
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddEditGroupPopup(
          isHashtagMode: true,
          isMainGroup: false,
          groupList: hashtagController.allGroups,
          onSave: (name, parentId) async {
            if (name.isEmpty) {
              Get.snackbar(
                'Invalid Name',
                'Hashtag name cannot be empty',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
              return;
            }

            if (parentId == null) {
              Get.snackbar(
                'Invalid Category',
                'Please select a category',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
              return;
            }

            try {
              final newSubgroup = await _hashtagGroupService.addCustomGroup(
                name,
                parentId: parentId,
              );

              if (newSubgroup == null) {
                Get.snackbar(
                  'Unable to Add',
                  'Unable to add hashtag. Please try again.',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              } else if (newSubgroup.id == -1) {
                Get.snackbar(
                  'Duplicate Hashtag',
                  'Hashtag with this name already exists.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              } else if (newSubgroup.id == -4) {
                Get.snackbar(
                  'Name Conflict',
                  'This name is already used by the parent group.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }

              // Reload hashtag groups
              await hashtagController.loadHashtagGroups();

              // Select the newly created hashtag
              widget.onSelected(newSubgroup);
              Get.back(); // Close the selection dialog
            } catch (e) {
              debugPrint('[HashtagSelectionDialog] Error adding hashtag: $e');
              Get.snackbar(
                'Unable to Add',
                'Unable to add hashtag. Please try again.',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
        );
      },
    );
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
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xffDFDFDF)),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '',
                  labelText: 'Search Hashtag',
                  suffixIcon: Icon(
                    Icons.search,
                    size: 20.sp,
                    color: const Color(0xffB4B4B4),
                  ),
                  suffixIconConstraints: BoxConstraints(
                    minWidth: 24.w,
                    minHeight: 24.h,
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

            // Hashtag List (shows 5 initially, all when searching)
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

            // Bottom buttons row
            Row(
              children: [
                // See List button (left)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.hashtagGroups.path);
                    },
                    child: Container(
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
                          'See List',
                          size: 16.sp,
                          color: const Color(0xff0071FF),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                16.horizontalSpace,
                // Add New Hashtag button (right)
                Expanded(
                  child: InkWell(
                    onTap: _showAddHashtagDialog,
                    child: Container(
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
                          'Add New',
                          size: 16.sp,
                          color: const Color(0xff0071FF),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
