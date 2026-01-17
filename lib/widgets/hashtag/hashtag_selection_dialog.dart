import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/controllers/hashtag_groups_controller.dart';
import 'package:moneyapp/controllers/home_controller.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/services/hashtag_group_service.dart';
import 'package:moneyapp/services/hashtag_recent_service.dart';
import 'package:moneyapp/widgets/common/add_edit_group_popup.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class HashtagSelectionDialog extends StatefulWidget {
  final Function(HashtagGroup)? onSelected;
  final bool isFilterMode;

  const HashtagSelectionDialog({
    super.key,
    this.onSelected,
    this.isFilterMode = false,
  });

  @override
  State<HashtagSelectionDialog> createState() => _HashtagSelectionDialogState();
}

class _HashtagSelectionDialogState extends State<HashtagSelectionDialog> {
  final HashtagGroupsController hashtagController = Get.put(
    HashtagGroupsController(),
  );
  final HashtagGroupService _hashtagGroupService = HashtagGroupService();
  final TextEditingController searchController = TextEditingController();
  final HashtagRecentService _recentService = HashtagRecentService();
  List<HashtagGroup> filteredHashtags = [];
  List<HashtagGroup> allHashtags = [];
  List<HashtagGroup> recentHashtags = [];
  bool isSearching = false;

  Worker? _groupsWorker;

  @override
  void initState() {
    super.initState();

    _initializeHashtags();

    // Listen for updates from controller (in case data loads after dialog opens)
    _groupsWorker = ever(hashtagController.allGroups as RxList, (_) {
      if (mounted) {
        setState(() {
          // Refresh list of all hashtags
          _initializeHashtags();
          // If searching, re-run search with new data
          if (isSearching) {
            _onSearchChanged();
          }
        });
      }
    });

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

    _loadRecentHashtags();
  }

  Future<void> _loadRecentHashtags() async {
    final recentData = await _recentService.loadRecentItems();
    // Filter to get only actual existing hashtag groups (subgroups) that match the names
    final validRecentHashtags = allHashtags.where((hashtag) {
      return recentData.recentItems.contains(hashtag.name);
    }).toList();

    // Sort them based on the order in recentItems
    validRecentHashtags.sort((a, b) {
      final indexA = recentData.recentItems.indexOf(a.name);
      final indexB = recentData.recentItems.indexOf(b.name);
      return indexA.compareTo(indexB);
    });

    if (mounted) {
      setState(() {
        recentHashtags = validRecentHashtags;
        // Initially show recent hashtags instead of just first 5
        // But ONLY if we are not currently searching
        if (!isSearching) {
          if (widget.isFilterMode) {
            // In filter mode, show recent hashtags if available, otherwise show all
            if (recentHashtags.isNotEmpty) {
              filteredHashtags = recentHashtags;
            } else {
              filteredHashtags = allHashtags;
            }
          } else {
            // In normal mode, show recent hashtags
            if (recentHashtags.isNotEmpty) {
              filteredHashtags = recentHashtags;
            } else {
              filteredHashtags = [];
            }
          }
        }
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      if (searchController.text.isEmpty) {
        isSearching = false;
        // Show recent when no search
        if (recentHashtags.isNotEmpty) {
          filteredHashtags = recentHashtags;
        } else {
          // If no recents, show all in filter mode, empty in normal mode
          if (widget.isFilterMode) {
            filteredHashtags = allHashtags;
          } else {
            filteredHashtags = [];
          }
        }
      } else {
        isSearching = true;
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
    _groupsWorker?.dispose();
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
          showDropdown: true,
          groupList: hashtagController.allGroups,
          onSave: (name, parentId, {newCategoryName}) async {
            if (name.isEmpty) {
              _showLocalSnackbar(
                'Invalid Name',
                'Hashtag name cannot be empty',
                isError: true,
              );
              return;
            }

            // Case 1: Creating a new main category AND a subgroup
            if (newCategoryName != null && newCategoryName.isNotEmpty) {
              try {
                // 1. Create the new main category group
                final newMainGroup = await _hashtagGroupService.addCustomGroup(
                  newCategoryName,
                );

                if (newMainGroup == null) {
                  _showLocalSnackbar(
                    'Error',
                    'Could not create new category.',
                    isError: true,
                  );
                  return;
                } else if (newMainGroup.id == -1) {
                  _showLocalSnackbar(
                    'Duplicate Category',
                    'Category "$newCategoryName" already exists.',
                    isError: true,
                  );
                  return;
                }

                // 2. Create the subgroup under this new main group
                final newSubgroup = await _hashtagGroupService.addCustomGroup(
                  name,
                  parentId: newMainGroup.id,
                );

                if (newSubgroup != null && newSubgroup.id != -1) {
                  // Reload and select
                  await hashtagController.loadHashtagGroups();

                  // Save to recents
                  await _recentService.saveRecentHashtag(newSubgroup.name);
                  await _recentService.saveRecentHashtagGroup(newSubgroup);

                  widget.onSelected?.call(newSubgroup);
                  if (mounted) Navigator.of(this.context).pop();
                } else {
                  _showLocalSnackbar(
                    'Error',
                    'Category created, but failed to create hashtag.',
                    isError: true,
                  );
                }
              } catch (e) {
                _showLocalSnackbar(
                  'Error',
                  'Failed to create new category and hashtag: $e',
                  isError: true,
                );
              }
              return;
            }

            // Case 2: Existing logic (Regular add to existing parent or no parent)
            if (parentId == null) {
              _showLocalSnackbar(
                'Invalid Category',
                'Please select a category',
                isError: true,
              );
              return;
            }

            try {
              final newSubgroup = await _hashtagGroupService.addCustomGroup(
                name,
                parentId: parentId,
              );

              if (newSubgroup == null) {
                _showLocalSnackbar(
                  'Unable to Add',
                  'Unable to add hashtag. Please try again.',
                  isError: true,
                );
                return;
              } else if (newSubgroup.id == -1) {
                _showLocalSnackbar(
                  'Duplicate Hashtag',
                  'Hashtag with this name already exists.',
                  isError: true,
                );
                return;
              } else if (newSubgroup.id == -4) {
                _showLocalSnackbar(
                  'Name Conflict',
                  'This name is already used by the parent group.',
                  isError: true,
                );
                return;
              }

              // Reload hashtag groups
              await hashtagController.loadHashtagGroups();

              // Save to recents
              await _recentService.saveRecentHashtag(newSubgroup.name);
              await _recentService.saveRecentHashtagGroup(newSubgroup);

              widget.onSelected?.call(newSubgroup);
              if (mounted) Navigator.of(this.context).pop();
            } catch (e) {
              debugPrint('[HashtagSelectionDialog] Error adding hashtag: $e');
              _showLocalSnackbar(
                'Unable to Add',
                'Unable to add hashtag. Please try again.',
                isError: true,
              );
            }
          },
        );
      },
    );
  }

  Future<void> _showEditHashtagDialog(HashtagGroup hashtag) async {
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
          showDropdown: true,
          groupList: hashtagController.allGroups,
          initialName: hashtag.name,
          editItemId: hashtag.id,
          parentId: hashtag.parentId,
          onSave: (name, parentId, {newCategoryName}) async {
            if (name.isEmpty) {
              _showLocalSnackbar(
                'Invalid Name',
                'Hashtag name cannot be empty',
                isError: true,
              );
              return;
            }

            try {
              // Update the hashtag
              final success = await _hashtagGroupService.updateGroup(
                hashtag.id!,
                name,
                newParentId: parentId,
              );

              if (!success) {
                _showLocalSnackbar(
                  'Unable to Update',
                  'Unable to update hashtag. Please try again.',
                  isError: true,
                );
                return;
              }

              // Reload hashtag groups
              await hashtagController.loadHashtagGroups();

              // Reload home screen data if HomeController is registered
              if (Get.isRegistered<HomeController>()) {
                await Get.find<HomeController>().loadTransactions();
              }

              // Update in recents
              await _recentService.updateHashtagGroupInRecents(
                hashtag.id!,
                name,
              );

              // Find the updated hashtag from the reloaded data
              HashtagGroup? updatedHashtag;
              for (final mainGroup in hashtagController.allGroups) {
                if (mainGroup.subgroups != null) {
                  updatedHashtag = mainGroup.subgroups!.firstWhereOrNull(
                    (sg) => sg.id == hashtag.id,
                  );
                  if (updatedHashtag != null) break;
                }
              }

              if (updatedHashtag != null) {
                // Save to recents
                await _recentService.saveRecentHashtag(updatedHashtag.name);
                await _recentService.saveRecentHashtagGroup(updatedHashtag);

                // Select the updated hashtag
                widget.onSelected?.call(updatedHashtag);
                if (mounted) Navigator.of(this.context).pop();
              }
            } catch (e) {
              debugPrint('[HashtagSelectionDialog] Error updating hashtag: $e');
              String errorMessage = 'Unable to update hashtag. Please try again.';

              if (e.toString().contains('DUPLICATE_HASHTAG_NAME')) {
                errorMessage = 'Hashtag with this name already exists.';
              } else if (e.toString().contains('SUBGROUP_CONFLICTS_WITH_PARENT')) {
                errorMessage = 'This name is already used by the parent group.';
              }

              _showLocalSnackbar(
                'Unable to Update',
                errorMessage,
                isError: true,
              );
            }
          },
        );
      },
    );
  }

  void _showLocalSnackbar(String title, String message, {bool isError = true}) {
    // Since we are inside a dialog context, we might need to find the specific Scaffold or use Overlay
    // Using simple dialog or toast might be safer if Scaffold is covered, but ScaffoldMessenger usually works on top
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(message),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
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
                  widget.isFilterMode ? 'Select Hashtags' : 'Select Hashtag',
                  size: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
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
            // Recent Label or Search Result Label
            if (filteredHashtags.isNotEmpty && !widget.isFilterMode)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CustomText(
                    isSearching ? 'Search Results' : 'Recent Hashtags',
                    size: 13.sp,
                    color: const Color(0xff707070),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            Expanded(
              child: filteredHashtags.isEmpty
                  ? Center(
                      child: CustomText(
                        isSearching
                            ? 'No Hashtags found'
                            : 'No recently used hashtags',
                        size: 14.sp,
                        color: const Color(0xffB4B4B4),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: filteredHashtags.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1.h, color: const Color(0xffDFDFDF)),
                      itemBuilder: (context, index) {
                        final hashtag = filteredHashtags[index];

                        return Padding(
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
                              // Hashtag name - Expanded and tappable
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final navigator = Navigator.of(context);
                                    // Save to recents
                                    await _recentService.saveRecentHashtag(
                                      hashtag.name,
                                    );
                                    // Also save group info if needed, though service mainly tracks by name/id
                                    await _recentService.saveRecentHashtagGroup(
                                      hashtag,
                                    );

                                    if (mounted) {
                                      widget.onSelected!(hashtag);
                                      navigator.pop();
                                    }
                                  },
                                  child: CustomText(
                                    hashtag.name,
                                    size: 15.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              8.horizontalSpace,
                              // Category name
                              CustomText(
                                _getCategoryName(hashtag),
                                size: 12.sp,
                                color: const Color(0xff707070),
                              ),
                              if (!widget.isFilterMode) ...[
                                8.horizontalSpace,
                                // Edit icon (only in normal mode)
                                InkWell(
                                  onTap: () => _showEditHashtagDialog(hashtag),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0, right: 0, top: 2, bottom: 2),
                                    child: Image.asset(
                                      AppIcons.editV2,
                                      width: 22.r,
                                      height: 22.r,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),

            12.verticalSpace,

            // Bottom buttons row
            if (widget.isFilterMode)
              // See List button only for filter mode
              InkWell(
                onTap: () async {
                  final navigator = Navigator.of(context);
                  final recentService = HashtagRecentService();
                  navigator.pop();
                  final result = await navigator.pushNamed(
                    AppRoutes.hashtagGroups.path,
                    arguments: {'fromSettings': false},
                  );

                  if (result != null && result is HashtagGroup) {
                    try {
                      await recentService.saveRecentHashtag(result.name);
                      await recentService.saveRecentHashtagGroup(result);
                    } catch (e) {
                      debugPrint('Error saving recent from list: $e');
                    }
                    widget.onSelected!(result);
                  }
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
                      'See List',
                      size: 16.sp,
                      color: const Color(0xff0071FF),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              )
            else
              // See List and Add New buttons for normal mode
              Row(
                children: [
                  // See List button (left)
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        final recentService = HashtagRecentService();
                        navigator.pop();
                        final result = await navigator.pushNamed(
                          AppRoutes.hashtagGroups.path,
                          arguments: {'fromSettings': false},
                        );

                        if (result != null && result is HashtagGroup) {
                          try {
                            await recentService.saveRecentHashtag(result.name);
                            await recentService.saveRecentHashtagGroup(result);
                          } catch (e) {
                            debugPrint('Error saving recent from list: $e');
                          }
                          widget.onSelected!(result);
                        }
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
