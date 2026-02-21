import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/investment_model.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class AddEditInvestmentDialog extends StatefulWidget {
  final Investment? existingInvestment;

  const AddEditInvestmentDialog({super.key, this.existingInvestment});

  @override
  State<AddEditInvestmentDialog> createState() =>
      _AddEditInvestmentDialogState();
}

class _AddEditInvestmentDialogState extends State<AddEditInvestmentDialog> {
  final InvestmentController investmentController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController tickerController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String? selectedAssetPath;
  File? selectedImageFile;
  Color? selectedColor;

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
      nameController.text = widget.existingInvestment!.name;
      tickerController.text = widget.existingInvestment!.ticker;
      selectedAssetPath = widget.existingInvestment!.imagePath;
      selectedColor = widget.existingInvestment!.color;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    tickerController.dispose();
    super.dispose();
  }

  Future<void> _showIconSelectionDialog() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          selectedImageFile = File(pickedFile.path);
          selectedAssetPath = null; // Clear old asset path
        });
      }
    } catch (e) {
      debugPrint('[AddEditInvestmentDialog] Error picking image: $e');
      _showSnackbar('Error', 'Failed to pick image from gallery');
    }
  }

  Future<void> _showColorSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
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

  /// Copy asset to temp file for use with the Investment model
  Widget _buildImagePreview() {
    if (selectedImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: Image.file(
          selectedImageFile!,
          width: 24.w,
          height: 24.h,
          fit: BoxFit.cover,
        ),
      );
    }

    if (selectedAssetPath != null && selectedAssetPath!.isNotEmpty) {
      // Existing investment with saved image
      final file = File(selectedAssetPath!);
      if (file.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: Image.file(file, width: 24.w, height: 24.h, fit: BoxFit.cover),
        );
      }
    }

    return Icon(Icons.image, size: 24.sp, color: AppColors.greyColor);
  }

  Future<void> _saveInvestment() async {
    if (nameController.text.trim().isEmpty) {
      _showSnackbar('Error', 'Please enter investment name');
      return;
    }

    if (tickerController.text.trim().isEmpty) {
      _showSnackbar('Error', 'Please enter ticker');
      return;
    }

    if (selectedImageFile == null && selectedAssetPath == null) {
      _showSnackbar('Error', 'Please select an image');
      return;
    }

    // Limit ticker to 5 characters
    final ticker = tickerController.text.length > 5
        ? tickerController.text.substring(0, 5).toUpperCase()
        : tickerController.text.toUpperCase();

    final color = selectedColor ?? Colors.grey;

    try {
      if (widget.existingInvestment != null) {
        // Update existing investment
        final success = await investmentController.updateInvestment(
          widget.existingInvestment!.id!,
          name: nameController.text.trim(),
          ticker: ticker,
          color: color,
          newImageFile: selectedImageFile,
        );

        if (success) {
          _showSnackbar(
            'Success',
            'Investment updated successfully',
            isError: false,
          );
          if (mounted) Navigator.pop(context);
        } else {
          _showSnackbar('Error', 'Failed to update investment');
        }
      } else {
        // Add new investment
        if (selectedImageFile == null) {
          _showSnackbar('Error', 'Please select an image');
          return;
        }

        final investment = await investmentController.addInvestment(
          name: nameController.text.trim(),
          ticker: ticker,
          color: color,
          imageFile: selectedImageFile!,
        );

        if (investment != null) {
          _showSnackbar(
            'Success',
            'Investment added successfully',
            isError: false,
          );
          if (mounted) Navigator.pop(context, investment);
        } else {
          _showSnackbar('Error', 'Failed to add investment');
        }
      }
    } catch (e) {
      if (e.toString().contains('TICKER_ALREADY_EXISTS')) {
        _showSnackbar('Error', 'Ticker already exists');
      } else {
        _showSnackbar('Error', 'An error occurred');
      }
    }
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
          'Are you sure you want to delete "${widget.existingInvestment!.name}"? This action cannot be undone.',
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
      try {
        final success = await investmentController.deleteInvestment(
          widget.existingInvestment!.id!,
        );

        if (success) {
          if (mounted) Navigator.pop(context);
          _showSnackbar(
            'Success',
            'Investment deleted successfully',
            isError: false,
          );
        } else {
          _showSnackbar('Error', 'Failed to delete investment');
        }
      } catch (e) {
        if (e.toString().contains('CANNOT_DELETE_INVESTMENT_IN_USE')) {
          _showSnackbar(
            'Cannot Delete',
            'This investment has existing transactions or trades. Delete those activities first.',
          );
        } else if (e.toString().contains(
          'CANNOT_DELETE_INVESTMENT_HAS_SNAPSHOTS',
        )) {
          _showSnackbar(
            'Cannot Delete',
            'This investment has portfolio history. Delete the price snapshots first.',
          );
        } else {
          _showSnackbar('Error', 'Failed to delete investment');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingInvestment != null;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    isEditMode ? 'Edit Investment' : 'Add Investment',
                    size: 18.sp,
                    color: Colors.black,
                  ),
                ],
              ),
              18.verticalSpace,

              // Investment Name Field
              Row(
                children: [
                  InkWell(
                    onTap: _showIconSelectionDialog,
                    child: Container(
                      height: 41.h,
                      width: 43.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: AppColors.greyBorder),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child:
                          selectedImageFile != null ||
                              widget.existingInvestment?.imagePath != null
                          ? _buildImagePreview()
                          : Center(
                              child: Image.asset(
                                AppIcons.addImage,
                                width: 24.r,
                                height: 24.r,
                                color: selectedImageFile == null
                                    ? AppColors.greyColor
                                    : Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                    ),
                  ),
                  5.horizontalSpace,
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
                  ),
                  5.horizontalSpace,
                  InkWell(
                    onTap: _showColorSelectionDialog,
                    child: Container(
                      height: 41.h,
                      width: 43.w,
                      decoration: BoxDecoration(
                        color: selectedColor ?? Colors.white,
                        border: Border.all(color: AppColors.greyBorder),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Center(
                        child: Image.asset(
                          AppIcons.colorPicker,
                          width: 24.r,
                          height: 24.r,
                          color: selectedColor == null
                              ? AppColors.greyColor
                              : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              7.verticalSpace,

              // Ticker Field
              Row(
                children: [
                  48.horizontalSpace,
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
                        controller: tickerController,
                        maxLength: 5,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Ticker (Max 5)',
                          labelText: 'Ticker',
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
                  ),
                  Spacer(),
                  48.horizontalSpace,
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
                    InkWell(
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
                  if (isEditMode) 16.horizontalSpace,
                  InkWell(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
