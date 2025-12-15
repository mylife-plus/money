import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/mcc_controller.dart';
import 'package:moneyapp/controllers/hashtag_groups_controller.dart';
import 'package:moneyapp/models/mcc_model.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/utils/date_picker_helper.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/mcc/mcc_filter_dialog.dart';
import 'package:moneyapp/widgets/hashtag/hashtag_filter_dialog.dart';

class TransactionFilterScreen extends StatefulWidget {
  const TransactionFilterScreen({super.key});

  @override
  State<TransactionFilterScreen> createState() =>
      _TransactionFilterScreenState();
}

class _TransactionFilterScreenState extends State<TransactionFilterScreen> {
  // late final MCCController mccController;
  // late final HashtagGroupsController hashtagController;
  MCCController mccController = Get.put(MCCController());
  HashtagGroupsController hashtagController = Get.put(
    HashtagGroupsController(),
  );

  DateTime? fromDate;
  DateTime? toDate;
  List<MCCItem> selectedMCCs = [];
  List<HashtagGroup> selectedHashtags = [];

  @override
  void initState() {
    super.initState();
    mccController = Get.find<MCCController>();
    hashtagController = Get.find<HashtagGroupsController>();
  }

  @override
  void dispose() {
    super.dispose();
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
      builder: (context) => MCCFilterDialog(
        selectedMCCs: selectedMCCs,
        onSelectionChanged: (selected) {
          setState(() {
            selectedMCCs = selected;
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
  }

  void _applyFilter() {
    // TODO: Implement filter logic
    Get.back();
    Get.snackbar('Success', 'Filter applied successfully');
  }

  void _resetFilter() {
    setState(() {
      fromDate = null;
      toDate = null;
      selectedMCCs.clear();
      selectedHashtags.clear();
    });
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
                    onTap: () => Get.back(),
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
                                  CustomText(mcc.name, size: 14.sp),
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
                              onTap: _applyFilter,
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
