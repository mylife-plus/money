import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/investment_recommendation.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class InvestmentSelectionDialog extends StatefulWidget {
  final Function(InvestmentRecommendation) onSelected;

  const InvestmentSelectionDialog({super.key, required this.onSelected});

  @override
  State<InvestmentSelectionDialog> createState() =>
      _InvestmentSelectionDialogState();
}

class _InvestmentSelectionDialogState extends State<InvestmentSelectionDialog> {
  late final InvestmentController investmentController;
  final TextEditingController searchController = TextEditingController();
  List<InvestmentRecommendation> filteredInvestments = [];

  @override
  void initState() {
    super.initState();
    investmentController = Get.find<InvestmentController>();
    filteredInvestments = investmentController.recommendations;
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
        filteredInvestments = investmentController.recommendations;
      } else {
        filteredInvestments = investmentController.recommendations
            .where(
              (investment) => investment.text.toLowerCase().contains(
                searchController.text.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  Future<void> _editInvestment(InvestmentRecommendation investment) async {
    Get.back();
    final result = await showDialog<InvestmentRecommendation>(
      context: context,
      builder: (context) =>
          AddEditInvestmentDialog(existingInvestment: investment),
    );
    if (result != null) {
      setState(() {
        filteredInvestments = investmentController.recommendations;
        _onSearchChanged();
      });
    }
  }

  Future<void> _deleteInvestment(InvestmentRecommendation investment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        title: CustomText(
          'Delete Investment',
          size: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        content: CustomText(
          'Are you sure you want to delete "${investment.text}"? This action cannot be undone.',
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

    if (confirmed == true) {
      final index = investmentController.recommendations.indexOf(investment);
      if (index != -1) {
        investmentController.removeRecommendation(index);
        setState(() {
          filteredInvestments = investmentController.recommendations;
          _onSearchChanged();
        });
        Get.snackbar(
          'Success',
          'Investment deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
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
                  'Select Investment',
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
                  hintText: 'Search Investment',
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

            // Investment List
            Expanded(
              child: filteredInvestments.isEmpty
                  ? Center(
                      child: CustomText(
                        'No investments found',
                        size: 14.sp,
                        color: const Color(0xffB4B4B4),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredInvestments.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1.h, color: const Color(0xffDFDFDF)),
                      itemBuilder: (context, index) {
                        final investment = filteredInvestments[index];
                        return InkWell(
                          onTap: () {
                            widget.onSelected(investment);
                            Get.back();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 8.w,
                            ),
                            child: Row(
                              children: [
                                // Investment Icon
                                if (investment.isAssetImage)
                                  Image.asset(
                                    investment.assetPath!,
                                    width: 20.w,
                                    height: 20.h,
                                  )
                                else if (investment.isFileImage)
                                  Image.file(
                                    investment.imageFile!,
                                    width: 20.w,
                                    height: 20.h,
                                  ),
                                12.horizontalSpace,
                                // Investment Info
                                Expanded(
                                  child: CustomText(
                                    investment.text,
                                    size: 15.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                // Short text
                                CustomText(
                                  investment.shortText,
                                  size: 12.sp,
                                  color: const Color(0xff707070),
                                ),
                                8.horizontalSpace,
                                // Color indicator
                                Container(
                                  width: 24.w,
                                  height: 24.h,
                                  decoration: BoxDecoration(
                                    color: investment.color ?? Colors.grey[300],
                                    border: Border.all(
                                      color: const Color(0xffDFDFDF),
                                    ),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                                8.horizontalSpace,
                                // Edit button
                                // InkWell(
                                //   onTap: () => _editInvestment(investment),
                                //   child: Container(
                                //     padding: EdgeInsets.all(6.w),
                                //     decoration: BoxDecoration(
                                //       color: const Color(
                                //         0xff0088FF,
                                //       ).withValues(alpha: 0.1),
                                //       borderRadius: BorderRadius.circular(4.r),
                                //     ),
                                //     child: Icon(
                                //       Icons.edit,
                                //       size: 16.sp,
                                //       color: const Color(0xff0088FF),
                                //     ),
                                //   ),
                                // ),
                                // 6.horizontalSpace,
                                // // Delete button
                                // InkWell(
                                //   onTap: () => _deleteInvestment(investment),
                                //   child: Container(
                                //     padding: EdgeInsets.all(6.w),
                                //     decoration: BoxDecoration(
                                //       color: const Color(
                                //         0xffFF0000,
                                //       ).withValues(alpha: 0.1),
                                //       borderRadius: BorderRadius.circular(4.r),
                                //     ),
                                //     child: Icon(
                                //       Icons.delete,
                                //       size: 16.sp,
                                //       color: const Color(0xffFF0000),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            12.verticalSpace,

            // Add New Investment Button
            InkWell(
              onTap: () async {
                Get.back();
                final result = await showDialog<InvestmentRecommendation>(
                  context: context,
                  builder: (context) => AddEditInvestmentDialog(),
                );
                if (result != null) {
                  widget.onSelected(result);
                }
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
                        'Add New Investment',
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

class AddEditInvestmentDialog extends StatefulWidget {
  final InvestmentRecommendation? existingInvestment;

  const AddEditInvestmentDialog({super.key, this.existingInvestment});

  @override
  State<AddEditInvestmentDialog> createState() =>
      _AddEditInvestmentDialogState();
}

class _AddEditInvestmentDialogState extends State<AddEditInvestmentDialog> {
  final InvestmentController investmentController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController shortTextController = TextEditingController();

  String? selectedAssetPath;
  Color? selectedColor;

  // Predefined icons for selection
  final List<String> predefinedIcons = [
    AppIcons.car,
    AppIcons.cart,
    AppIcons.digitalCurrency,
    AppIcons.blackCheck,
    AppIcons.investment,
    AppIcons.car,
    AppIcons.atm,
  ];

  // Predefined colors for selection
  final List<Color> predefinedColors = [
    Color(0xffFFE5E5), // Light pink
    Color(0xffFFD4A3), // Light orange
    Color(0xffFFE5A3), // Light yellow
    Color(0xffE5FFE5), // Light green
    Color(0xffA3D4FF), // Light blue
    Color(0xffD4A3FF), // Light purple
    Color(0xffFFA3D4), // Light magenta
    Color(0xffA3FFD4), // Light cyan
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingInvestment != null) {
      nameController.text = widget.existingInvestment!.text;
      shortTextController.text = widget.existingInvestment!.shortText;
      selectedAssetPath = widget.existingInvestment!.assetPath;
      selectedColor = widget.existingInvestment!.color;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    shortTextController.dispose();
    super.dispose();
  }

  Future<void> _showIconSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                'Select Icon',
                size: 18.sp,
                fontWeight: FontWeight.w600,
              ),
              16.verticalSpace,
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                ),
                itemCount: predefinedIcons.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedAssetPath = predefinedIcons[index];
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedAssetPath == predefinedIcons[index]
                              ? const Color(0xff0088FF)
                              : const Color(0xffDFDFDF),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      padding: EdgeInsets.all(8.w),
                      child: Image.asset(
                        predefinedIcons[index],
                        width: 24.w,
                        height: 24.h,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showColorSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                'Select Color',
                size: 18.sp,
                fontWeight: FontWeight.w600,
              ),
              16.verticalSpace,
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                ),
                itemCount: predefinedColors.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedColor = predefinedColors[index];
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: predefinedColors[index],
                        border: Border.all(
                          color: selectedColor == predefinedColors[index]
                              ? const Color(0xff0088FF)
                              : const Color(0xffDFDFDF),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      height: 40.h,
                      width: 40.w,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveInvestment() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter investment name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (shortTextController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter short text',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedAssetPath == null) {
      Get.snackbar(
        'Error',
        'Please select an icon',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Limit short text to 3 characters
    final shortText = shortTextController.text.length > 3
        ? shortTextController.text.substring(0, 3)
        : shortTextController.text;

    final newInvestment = InvestmentRecommendation.fromAsset(
      assetPath: selectedAssetPath!,
      text: nameController.text.trim(),
      shortText: shortText,
      color: selectedColor,
    );

    if (widget.existingInvestment != null) {
      // Update existing investment
      final index = investmentController.recommendations.indexOf(
        widget.existingInvestment!,
      );
      if (index != -1) {
        investmentController.updateRecommendation(index, newInvestment);
      }
      Get.snackbar(
        'Success',
        'Investment updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      // Add new investment
      investmentController.addRecommendation(newInvestment);
      Get.snackbar(
        'Success',
        'Investment added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    Navigator.pop(context, newInvestment);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    widget.existingInvestment != null
                        ? 'Edit Investment'
                        : 'Add New Investment',
                    size: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 24.sp),
                  ),
                ],
              ),
              20.verticalSpace,

              // Investment Name
              CustomText(
                'Investment Name',
                size: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              8.verticalSpace,
              Container(
                height: 41.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xffDFDFDF)),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter investment name',
                    hintStyle: TextStyle(
                      color: const Color(0xffB4B4B4),
                      fontSize: 14.sp,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),

              16.verticalSpace,

              // Short Text
              CustomText(
                'Short Text (Max 3 characters)',
                size: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              8.verticalSpace,
              Container(
                height: 41.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xffDFDFDF)),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: TextField(
                  controller: shortTextController,
                  maxLength: 3,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'e.g., BTC',
                    hintStyle: TextStyle(
                      color: const Color(0xffB4B4B4),
                      fontSize: 14.sp,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
                  ),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),

              16.verticalSpace,

              // Icon Selection
              CustomText('Icon', size: 14.sp, fontWeight: FontWeight.w500),
              8.verticalSpace,
              InkWell(
                onTap: _showIconSelectionDialog,
                child: Container(
                  height: 60.h,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: const Color(0xffF5F5F5),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Center(
                          child: selectedAssetPath != null
                              ? Image.asset(
                                  selectedAssetPath!,
                                  width: 20.w,
                                  height: 20.h,
                                )
                              : Icon(
                                  Icons.image,
                                  size: 20.sp,
                                  color: const Color(0xffB4B4B4),
                                ),
                        ),
                      ),
                      12.horizontalSpace,
                      CustomText(
                        selectedAssetPath == null
                            ? 'Select an icon'
                            : 'Icon selected',
                        size: 14.sp,
                        color: selectedAssetPath == null
                            ? const Color(0xffB4B4B4)
                            : Colors.black87,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        size: 20.sp,
                        color: const Color(0xffB4B4B4),
                      ),
                    ],
                  ),
                ),
              ),

              16.verticalSpace,

              // Color Selection
              CustomText('Color', size: 14.sp, fontWeight: FontWeight.w500),
              8.verticalSpace,
              InkWell(
                onTap: _showColorSelectionDialog,
                child: Container(
                  height: 60.h,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: selectedColor ?? const Color(0xffF5F5F5),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: const Color(0xffDFDFDF)),
                        ),
                      ),
                      12.horizontalSpace,
                      CustomText(
                        selectedColor == null
                            ? 'Select a color'
                            : 'Color selected',
                        size: 14.sp,
                        color: selectedColor == null
                            ? const Color(0xffB4B4B4)
                            : Colors.black87,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.chevron_right,
                        size: 20.sp,
                        color: const Color(0xffB4B4B4),
                      ),
                    ],
                  ),
                ),
              ),

              30.verticalSpace,

              // Save Button
              Center(
                child: InkWell(
                  onTap: _saveInvestment,
                  child: Container(
                    width: 136.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: const Color(0xff0088FF),
                      borderRadius: BorderRadius.circular(13.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomText(
                        widget.existingInvestment != null ? 'Update' : 'Save',
                        size: 20.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
