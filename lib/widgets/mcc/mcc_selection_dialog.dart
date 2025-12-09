import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/controllers/mcc_controller.dart';
import 'package:moneyapp/models/mcc_model.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class MCCSelectionDialog extends StatefulWidget {
  final Function(MCCItem) onSelected;

  const MCCSelectionDialog({super.key, required this.onSelected});

  @override
  State<MCCSelectionDialog> createState() => _MCCSelectionDialogState();
}

class _MCCSelectionDialogState extends State<MCCSelectionDialog> {
  late final MCCController mccController;
  final TextEditingController searchController = TextEditingController();
  List<MCCItem> filteredMCCs = [];
  int? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    mccController = Get.find<MCCController>();
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
        if (selectedCategoryId != null) {
          filteredMCCs = mccController.getMCCsByCategory(selectedCategoryId!);
        } else {
          filteredMCCs = mccController.mccItems;
        }
      } else {
        filteredMCCs = mccController.searchMCCs(searchController.text);
        if (selectedCategoryId != null) {
          filteredMCCs = filteredMCCs
              .where((mcc) => mcc.categoryId == selectedCategoryId)
              .toList();
        }
      }
    });
  }

  Future<void> _editMCC(MCCItem mcc) async {
    Get.back();
    await Get.toNamed(AppRoutes.addMCC.path, arguments: mcc);
    // Refresh the list after editing
    setState(() {
      filteredMCCs = mccController.mccItems;
      _onSearchChanged();
    });
  }

  Future<void> _deleteMCC(MCCItem mcc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        title: CustomText(
          'Delete MCC',
          size: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        content: CustomText(
          'Are you sure you want to delete "${mcc.name}"? This action cannot be undone.',
          size: 14.sp,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: CustomText(
              'Cancel',
              size: 14.sp,
              color: const Color(0xff707070),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: CustomText(
              'Delete',
              size: 14.sp,
              color: const Color(0xffFF0000),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mcc.id != null) {
      mccController.deleteMCCItem(mcc.id!);
      setState(() {
        filteredMCCs = mccController.mccItems;
        _onSearchChanged();
      });
      Get.snackbar(
        'Success',
        'MCC deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
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
                  hintText: 'Search MCC',
                  suffixIcon: Icon(
                    Icons.search,
                    size: 20.sp,
                    color: const Color(0xffB4B4B4),
                  ),
                  // labelText: 'Search MCC',
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
                        return InkWell(
                          onTap: () {
                            widget.onSelected(mcc);
                            Get.back();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 8.w,
                            ),
                            child: Row(
                              children: [
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
                                8.horizontalSpace,
                                // Edit button
                                InkWell(
                                  onTap: () => _editMCC(mcc),
                                  child: Container(
                                    padding: EdgeInsets.all(6.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff0088FF)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      size: 16.sp,
                                      color: const Color(0xff0088FF),
                                    ),
                                  ),
                                ),
                                6.horizontalSpace,
                                // Delete button
                                InkWell(
                                  onTap: () => _deleteMCC(mcc),
                                  child: Container(
                                    padding: EdgeInsets.all(6.w),
                                    decoration: BoxDecoration(
                                      color: const Color(0xffFF0000)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Icon(
                                      Icons.delete,
                                      size: 16.sp,
                                      color: const Color(0xffFF0000),
                                    ),
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

            // Add New MCC Button
            InkWell(
              onTap: () {
                Get.back();
                Get.toNamed(AppRoutes.addMCC.path);
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
                        'Add New MCC',
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
