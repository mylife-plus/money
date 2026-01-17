import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/home_controller.dart';
import 'package:moneyapp/controllers/mcc_controller.dart';
import 'package:moneyapp/controllers/hashtag_groups_controller.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/models/mcc_model.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/services/database/repositories/utils/date_picker_helper.dart';
import 'package:moneyapp/services/hashtag_group_service.dart';
import 'package:moneyapp/services/hashtag_recent_service.dart';
import 'package:moneyapp/widgets/common/add_edit_group_popup.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/mcc/mcc_selection_dialog.dart';
import 'package:moneyapp/widgets/hashtag/hashtag_filter_dialog.dart';

class TransactionFilterScreen extends StatefulWidget {
  const TransactionFilterScreen({super.key});

  @override
  State<TransactionFilterScreen> createState() =>
      _TransactionFilterScreenState();
}

class _TransactionFilterScreenState extends State<TransactionFilterScreen>
    with WidgetsBindingObserver {
  // late final MCCController mccController;
  // late final HashtagGroupsController hashtagController;
  MCCController mccController = Get.put(MCCController());
  HashtagGroupsController hashtagController = Get.put(
    HashtagGroupsController(),
  );
  late final HomeController homeController;
  final HashtagGroupService _hashtagGroupService = HashtagGroupService();
  final HashtagRecentService _recentService = HashtagRecentService();

  DateTime? fromDate;
  DateTime? toDate;
  List<MCCItem> selectedMCCs = [];
  List<HashtagGroup> selectedHashtags = [];
  late final TextEditingController minAmountController;
  late final TextEditingController maxAmountController;
  Worker? _hashtagGroupsWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    mccController = Get.find<MCCController>();
    hashtagController = Get.find<HashtagGroupsController>();
    homeController = Get.find<HomeController>();

    // Initialize state from existing controller values
    fromDate = homeController.transactionDateStart;
    toDate = homeController.transactionDateEnd;

    selectedMCCs = List.from(homeController.selectedMCCFilters);
    selectedHashtags = List.from(homeController.selectedHashtagFilters);

    // We compare with infinity for max to leave blank if not set
    minAmountController = TextEditingController(
      text: homeController.minAmount.value > 0
          ? homeController.minAmount.value.toStringAsFixed(0)
          : '',
    );
    maxAmountController = TextEditingController(
      text: homeController.maxAmount.value < double.infinity
          ? homeController.maxAmount.value.toStringAsFixed(0)
          : '',
    );

    // Listen for hashtag group updates to refresh selected hashtags
    _hashtagGroupsWorker = ever(hashtagController.allGroups as RxList, (_) {
      if (mounted) {
        _updateSelectedHashtags();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Update hashtags when app resumes
      _updateSelectedHashtags();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update hashtags when screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSelectedHashtags();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hashtagGroupsWorker?.dispose();
    minAmountController.dispose();
    maxAmountController.dispose();
    super.dispose();
  }

  /// Update selected hashtags with latest data from controller
  Future<void> _updateSelectedHashtags() async {
    if (selectedHashtags.isEmpty) return;

    // Force reload hashtag groups to get latest data
    await hashtagController.loadHashtagGroups();

    if (!mounted) return;

    setState(() {
      // Create a new list with updated hashtag data
      final updatedHashtags = <HashtagGroup>[];

      for (final selectedHashtag in selectedHashtags) {
        // Find the updated hashtag from the controller
        HashtagGroup? updatedHashtag;
        for (final mainGroup in hashtagController.allGroups) {
          if (mainGroup.subgroups != null) {
            updatedHashtag = mainGroup.subgroups!.firstWhereOrNull(
              (sg) => sg.id == selectedHashtag.id,
            );
            if (updatedHashtag != null) break;
          }
        }

        // If found, use updated data; otherwise keep the old one
        if (updatedHashtag != null) {
          updatedHashtags.add(updatedHashtag);
        } else {
          updatedHashtags.add(selectedHashtag);
        }
      }

      selectedHashtags = updatedHashtags;
    });
  }

  Future<void> _pickFromDate(BuildContext context) async {
    final picked = await DatePickerHelper.showStyledDatePicker(
      context,
      initialDate: fromDate,
      firstDate: DateTime(1900),
      lastDate: toDate,
    );

    if (picked != null) {
      setState(() {
        fromDate = picked;
      });
    }
  }

  Future<void> _pickToDate(BuildContext context) async {
    final picked = await DatePickerHelper.showStyledDatePicker(
      context,
      initialDate: toDate,
      firstDate: fromDate ?? DateTime(1900),
    );

    if (picked != null) {
      setState(() {
        toDate = picked;
      });
    }
  }

  Future<void> _showMCCFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => MCCSelectionDialog(
        onSelected: (mcc) {
          setState(() {
            // Check if already selected to avoid duplicates
            if (!selectedMCCs.any((item) => item.id == mcc.id)) {
              selectedMCCs.add(mcc);
            }
          });
        },
      ),
    );
  }

  Future<void> _showHashtagFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => HashtagFilterDialog(
        selectedHashtags: selectedHashtags,
        onSelectionChanged: (selected) {
          setState(() {
            selectedHashtags = selected;
          });
        },
      ),
    );

    // Update selected hashtags after dialog closes in case any were edited
    _updateSelectedHashtags();
  }

  void _applyFilter({bool closeScreen = true}) {
    double min =
        double.tryParse(minAmountController.text.replaceAll(',', '.')) ?? 0;
    double max =
        double.tryParse(maxAmountController.text.replaceAll(',', '.')) ??
        double.infinity;

    // Validation
    if (min > max && max != double.infinity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Min amount cannot be greater than max amount',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update Home Controller
    homeController.updateDateRange(fromDate, toDate);
    homeController.updateAmountRange(min, max);
    homeController.updateMCCFilters(selectedMCCs);
    homeController.updateHashtagFilters(selectedHashtags);

    if (closeScreen) {
      Navigator.of(context).pop();
    }
  }

  void _resetFilter() {
    setState(() {
      fromDate = null;
      toDate = null;
      minAmountController.clear();
      maxAmountController.clear();
      selectedMCCs.clear();
      selectedHashtags.clear();
    });
    _applyFilter(closeScreen: false);
  }

  Future<void> _showEditHashtagDialog(HashtagGroup hashtag) async {
    // Ensure UiController is available
    if (!Get.isRegistered<UiController>()) {
      Get.put(UiController());
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
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
                return;
              }

              // Reload hashtag groups
              await hashtagController.loadHashtagGroups();

              // Reload home screen data
              await homeController.loadTransactions();

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
                // Update the selected hashtags list if this hashtag was selected
                final selectedIndex = selectedHashtags.indexWhere(
                  (item) => item.id == hashtag.id,
                );
                if (selectedIndex >= 0) {
                  setState(() {
                    selectedHashtags[selectedIndex] = updatedHashtag!;
                  });
                }
              }
            } catch (e) {
              debugPrint('[TransactionFilterScreen] Error updating hashtag: $e');
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset(
                      AppIcons.backArrow,
                      width: 21.h,
                      height: 21.h,
                    ),
                  ),
                  Image.asset(AppIcons.filter, height: 28.r, width: 28.r),
                  SizedBox(width: 21.w),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 33.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      12.verticalSpace,
                      // Amount Range Filters
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 41.h,
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.greyBorder),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: TextField(
                                controller: minAmountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'min amount',
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,

                                  labelStyle: TextStyle(
                                    color: AppColors.greyColor,
                                    fontSize: 12.sp,
                                  ),
                                  hintStyle: TextStyle(
                                    color: AppColors.greyColor,
                                    fontSize: 16.sp,
                                  ),
                                ),

                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: Container(
                              height: 41.h,
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.greyBorder),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: TextField(
                                controller: maxAmountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'max amount',
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  labelStyle: TextStyle(
                                    color: AppColors.greyColor,
                                    fontSize: 12.sp,
                                  ),
                                  hintStyle: TextStyle(
                                    color: AppColors.greyColor,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      12.verticalSpace,
                      // Date range filters
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 41.h,
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.greyBorder),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    AppIcons.dateIcon,
                                    height: 20.r,
                                    width: 20.r,
                                    color: AppColors.greyColor,
                                  ),
                                  10.horizontalSpace,
                                  Expanded(
                                    child: TextField(
                                      controller: TextEditingController(
                                        text: fromDate != null
                                            ? DateFormat(
                                                'dd.MM.yyyy',
                                              ).format(fromDate!)
                                            : '',
                                      ),
                                      readOnly: true,
                                      onTap: () => _pickFromDate(context),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'from date',
                                        labelText: fromDate != null
                                            ? 'From Date'
                                            : null,
                                        labelStyle: TextStyle(
                                          color: AppColors.greyColor,
                                          fontSize: 12.sp,
                                        ),
                                        hintStyle: TextStyle(
                                          color: AppColors.greyColor,
                                          fontSize: 16.sp,
                                        ),
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: Container(
                              height: 41.h,
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.greyBorder),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    AppIcons.dateIcon,
                                    height: 20.r,
                                    width: 20.r,
                                    color: AppColors.greyColor,
                                  ),
                                  10.horizontalSpace,
                                  Expanded(
                                    child: TextField(
                                      controller: TextEditingController(
                                        text: toDate != null
                                            ? DateFormat(
                                                'dd.MM.yyyy',
                                              ).format(toDate!)
                                            : '',
                                      ),
                                      readOnly: true,
                                      onTap: () => _pickToDate(context),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'to date',
                                        labelText: toDate != null
                                            ? 'To Date'
                                            : null,
                                        labelStyle: TextStyle(
                                          color: AppColors.greyColor,
                                          fontSize: 12.sp,
                                        ),
                                        hintStyle: TextStyle(
                                          color: AppColors.greyColor,
                                          fontSize: 16.sp,
                                        ),
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      7.verticalSpace,

                      // MCC filter (tappable container)
                      InkWell(
                        onTap: _showMCCFilterDialog,
                        child: Container(
                          height: 41.h,
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.greyBorder),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                AppIcons.shopIcon,
                                height: 20.r,
                                width: 20.r,
                                color: AppColors.greyColor,
                              ),
                              11.horizontalSpace,
                              Expanded(
                                child: CustomText(
                                  selectedMCCs.isEmpty
                                      ? 'Merchant Category (MCC)'
                                      : '${selectedMCCs.length} MCC${selectedMCCs.length > 1 ? 's' : ''} selected',
                                  size: 16.sp,
                                  color: selectedMCCs.isEmpty
                                      ? AppColors.greyColor
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Display selected MCCs as chips
                      if (selectedMCCs.isNotEmpty) ...[
                        10.verticalSpace,
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: selectedMCCs.map((mcc) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xffF5F5F5),
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(color: AppColors.greyBorder),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  mcc.getIcon(size: 16.sp),
                                  6.horizontalSpace,
                                  Flexible(
                                    child: CustomText(mcc.name, size: 14.sp),
                                  ),
                                  6.horizontalSpace,
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedMCCs.removeWhere(
                                          (item) => item.id == mcc.id,
                                        );
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 16.sp,
                                      color: AppColors.greyColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      7.verticalSpace,

                      // Hashtag filter (tappable container)
                      InkWell(
                        onTap: _showHashtagFilterDialog,
                        child: Container(
                          height: 41.h,
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.greyBorder),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.tag,
                                size: 20.r,
                                color: AppColors.greyColor,
                              ),
                              11.horizontalSpace,
                              Expanded(
                                child: CustomText(
                                  selectedHashtags.isEmpty
                                      ? 'Filter Hashtags'
                                      : '${selectedHashtags.length} Hashtag${selectedHashtags.length > 1 ? 's' : ''} selected',
                                  size: 16.sp,
                                  color: selectedHashtags.isEmpty
                                      ? AppColors.greyColor
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Display selected hashtags as chips
                      if (selectedHashtags.isNotEmpty) ...[
                        10.verticalSpace,
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: selectedHashtags.map((hashtag) {
                            // Find parent group name if it's a subgroup
                            String? parentName;
                            if (hashtag.isSubgroup) {
                              final parent = hashtagController.allGroups
                                  .firstWhereOrNull(
                                    (g) => g.id == hashtag.parentId,
                                  );
                              parentName = parent?.name;
                            }

                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xffF5F5F5),
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(color: Color(0xffDFDFDF)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomText('#${hashtag.name}', size: 14.sp),
                                  if (parentName != null) ...[
                                    4.horizontalSpace,
                                    CustomText(
                                      '($parentName)',
                                      size: 12.sp,
                                      color: Color(0xff707070),
                                    ),
                                  ],
                                  6.horizontalSpace,
                          
                                  // Close icon
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedHashtags.removeWhere(
                                          (item) => item.id == hashtag.id,
                                        );
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 16.sp,
                                      color: Color(0xff707070),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      25.verticalSpace,
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _resetFilter,
                              child: Container(
                                height: 41.h,
                                width: 144.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(13.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 4.0,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CustomText(
                                    'reset',
                                    size: 16.sp,
                                    color: Color(0xffFF0000),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          22.horizontalSpace,
                          Expanded(
                            child: InkWell(
                              onTap: () => _applyFilter(),
                              child: Container(
                                height: 41.h,
                                width: 144.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(13.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 4.0,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CustomText(
                                    'filter',
                                    size: 16.sp,
                                    color: Color(0xff0071FF),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      25.verticalSpace,
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
