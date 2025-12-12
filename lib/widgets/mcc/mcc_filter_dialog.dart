import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/controllers/mcc_controller.dart';
import 'package:moneyapp/models/mcc_model.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class MCCFilterDialog extends StatefulWidget {
  final List<MCCItem> selectedMCCs;
  final Function(List<MCCItem>) onSelectionChanged;

  const MCCFilterDialog({
    super.key,
    required this.selectedMCCs,
    required this.onSelectionChanged,
  });

  @override
  State<MCCFilterDialog> createState() => _MCCFilterDialogState();
}

class _MCCFilterDialogState extends State<MCCFilterDialog> {
  late final MCCController mccController;
  final TextEditingController searchController = TextEditingController();
  List<MCCItem> filteredMCCs = [];
  List<MCCItem> selectedMCCs = [];

  @override
  void initState() {
    super.initState();
    mccController = Get.find<MCCController>();
    selectedMCCs = List.from(widget.selectedMCCs);
    filteredMCCs = mccController.mccItems;
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
        filteredMCCs = mccController.mccItems;
      } else {
        filteredMCCs = mccController.searchMCCs(searchController.text);
      }
    });
  }

  void _toggleMCC(MCCItem mcc) {
    setState(() {
      final index = selectedMCCs.indexWhere((item) => item.id == mcc.id);
      if (index >= 0) {
        selectedMCCs.removeAt(index);
      } else {
        selectedMCCs.add(mcc);
      }
    });
  }

  bool _isSelected(MCCItem mcc) {
    return selectedMCCs.any((item) => item.id == mcc.id);
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
                  'Select MCC',
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
                  hintText: 'Search MCC',
                  labelText: 'Search MCC',
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

            // MCC List
            Expanded(
              child: filteredMCCs.isEmpty
                  ? Center(
                      child: CustomText(
                        'No MCCs found',
                        size: 14.sp,
                        color: const Color(0xffB4B4B4),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredMCCs.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1.h, color: const Color(0xffDFDFDF)),
                      itemBuilder: (context, index) {
                        final mcc = filteredMCCs[index];
                        final isSelected = _isSelected(mcc);
                        return InkWell(
                          onTap: () => _toggleMCC(mcc),
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
                                // MCC Icon
                                Center(child: mcc.getIcon(size: 20.sp)),
                                12.horizontalSpace,
                                // MCC Info
                                Expanded(
                                  child: CustomText(
                                    mcc.name,
                                    size: 15.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // Category name
                                CustomText(
                                  mcc.categoryName,
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

            // Apply Button
            InkWell(
              onTap: () {
                widget.onSelectionChanged(selectedMCCs);
                Get.back();
              },
              child: Container(
                width: 200.w,
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
                    'Apply (${selectedMCCs.length})',
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
