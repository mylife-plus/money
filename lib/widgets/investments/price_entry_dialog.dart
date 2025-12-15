import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class PriceEntryDialog extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialPrice;
  final Function(DateTime date, String price) onSave;
  final VoidCallback? onDelete;

  const PriceEntryDialog({
    super.key,
    this.initialDate,
    this.initialPrice,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<PriceEntryDialog> createState() => _PriceEntryDialogState();
}

class _PriceEntryDialogState extends State<PriceEntryDialog> {
  late TextEditingController priceController;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    priceController = TextEditingController(text: widget.initialPrice ?? '');
    selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.black,
              surface: AppColors.background,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _save() {
    if (selectedDate == null) {
      Get.snackbar(
        'Error',
        'Please select a date',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (priceController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a price',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.back();
    widget.onSave(selectedDate!, priceController.text.trim());
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        title: CustomText(
          'Delete Price Entry',
          size: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        content: CustomText(
          'Are you sure you want to delete this price entry? This action cannot be undone.',
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

    if (!mounted) return;

    if (confirmed == true && widget.onDelete != null) {
      widget.onDelete!();
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.initialDate != null;

    return Dialog(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  isEditMode ? 'Edit Price' : 'Add Price',
                  size: 18.sp,
                  color: Colors.black,
                ),
                InkWell(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close, size: 24.sp),
                ),
              ],
            ),
            18.verticalSpace,
            // Date Field
            Container(
              height: 41.h,
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.greyBorder),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: TextField(
                controller: TextEditingController(
                  text: selectedDate != null
                      ? DateFormat('dd.MM.yyyy').format(selectedDate!)
                      : '',
                ),
                readOnly: true,
                onTap: _pickDate,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Select Date',
                  labelText: 'Date',
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
                textAlign: TextAlign.end,
              ),
            ),
            7.verticalSpace,

            // Price Field
            Container(
              height: 41.h,
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.greyBorder),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: TextField(
                controller: priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  labelText: 'Price',
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
                  suffixText: 'EUR',
                  suffixStyle: TextStyle(
                    color: AppColors.greyColor,
                    fontSize: 16.sp,
                  ),
                ),
                style: TextStyle(fontSize: 16.sp),
                textAlign: TextAlign.end,
              ),
            ),

            23.verticalSpace,

            // Buttons
            Row(
              mainAxisAlignment: isEditMode
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                if (isEditMode && widget.onDelete != null)
                  Expanded(
                    child: InkWell(
                      onTap: _delete,
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
                if (isEditMode && widget.onDelete != null) 16.horizontalSpace,
                Expanded(
                  child: InkWell(
                    onTap: _save,
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
    );
  }
}
