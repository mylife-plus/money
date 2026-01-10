import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/investment_recommendation.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

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

  void _showSnackbar(String title, String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(message, style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _saveInvestment() {
    if (nameController.text.trim().isEmpty) {
      _showSnackbar('Error', 'Please enter investment name');
      return;
    }

    if (shortTextController.text.trim().isEmpty) {
      _showSnackbar('Error', 'Please enter short text');
      return;
    }

    if (selectedAssetPath == null) {
      _showSnackbar('Error', 'Please select an icon');
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
      _showSnackbar(
        'Success',
        'Investment updated successfully',
        isError: false,
      );
    } else {
      // Add new investment
      investmentController.addRecommendation(newInvestment);
      _showSnackbar('Success', 'Investment added successfully', isError: false);
    }

    Navigator.pop(context, newInvestment);
  }

  Future<void> _deleteInvestment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        title: CustomText(
          'Delete Investment',
          size: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        content: CustomText(
          'Are you sure you want to delete "${widget.existingInvestment!.text}"? This action cannot be undone.',
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
          SizedBox(width: 12.w),

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

    if (!mounted) return;

    if (confirmed == true) {
      final index = investmentController.recommendations.indexOf(
        widget.existingInvestment!,
      );
      if (index != -1) {
        investmentController.removeRecommendation(index);
        Navigator.pop(context);
        _showSnackbar(
          'Success',
          'Investment deleted successfully',
          isError: false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingInvestment != null;

    return Dialog(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
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
                    isEditMode ? 'Edit Investment' : 'Add New Investment',
                    size: 18.sp,
                    color: Colors.black,
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 24.sp),
                  ),
                ],
              ),
              18.verticalSpace,

              // Investment Name Field
              Container(
                height: 41.h,
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.greyBorder),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Investment Name',
                    labelText: 'Investment Name',
                    labelStyle: TextStyle(
                      color: AppColors.greyColor,
                      fontSize: 16.sp,
                    ),
                    hintStyle: TextStyle(
                      color: AppColors.greyColor,
                      fontSize: 16.sp,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              7.verticalSpace,

              // Short Text Field
              Container(
                height: 41.h,
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.greyBorder),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: TextField(
                  controller: shortTextController,
                  maxLength: 3,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Short Text (Max 3)',
                    labelText: 'Short Text',
                    labelStyle: TextStyle(
                      color: AppColors.greyColor,
                      fontSize: 16.sp,
                    ),
                    hintStyle: TextStyle(
                      color: AppColors.greyColor,
                      fontSize: 16.sp,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
              7.verticalSpace,

              // Icon and Color Selection Row
              Row(
                children: [
                  // Icon Selection
                  Expanded(
                    child: InkWell(
                      onTap: _showIconSelectionDialog,
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
                            CustomText(
                              'Icon',
                              size: 16.sp,
                              color: AppColors.greyColor,
                            ),
                            const Spacer(),
                            if (selectedAssetPath != null)
                              Image.asset(
                                selectedAssetPath!,
                                width: 20.w,
                                height: 20.h,
                              )
                            else
                              Icon(
                                Icons.image,
                                size: 20.sp,
                                color: AppColors.greyColor,
                              ),
                            4.horizontalSpace,
                            Icon(
                              Icons.arrow_drop_down,
                              size: 20.sp,
                              color: AppColors.greyColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  8.horizontalSpace,

                  // Color Selection
                  InkWell(
                    onTap: _showColorSelectionDialog,
                    child: Container(
                      height: 41.h,
                      width: 60.w,
                      decoration: BoxDecoration(
                        color: selectedColor ?? Colors.white,
                        border: Border.all(color: AppColors.greyBorder),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.color_lens,
                          size: 20.sp,
                          color: selectedColor == null
                              ? AppColors.greyColor
                              : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              23.verticalSpace,

              // Buttons
              Row(
                mainAxisAlignment: isEditMode
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [
                  if (isEditMode)
                    Expanded(
                      child: InkWell(
                        onTap: _deleteInvestment,
                        child: Container(
                          width: 120.w,
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
                              'Delete',
                              size: 16.sp,
                              color: const Color(0xffFF0000),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (isEditMode) 16.horizontalSpace,
                  Expanded(
                    child: InkWell(
                      onTap: _saveInvestment,
                      child: Container(
                        width: 120.w,
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
                            isEditMode ? 'Save' : 'Add',
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
      ),
    );
  }
}
