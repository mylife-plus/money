import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/services/currency_service.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class PriceEntryDialog extends StatefulWidget {
  final DateTime? initialDate;
  final double? initialUnitPrice;
  final String? initialNote;
  final Function(DateTime date, double unitPrice, String? note) onSave;
  final VoidCallback? onDelete;

  const PriceEntryDialog({
    super.key,
    this.initialDate,
    this.initialUnitPrice,
    this.initialNote,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<PriceEntryDialog> createState() => _PriceEntryDialogState();
}

class _PriceEntryDialogState extends State<PriceEntryDialog> {
  late TextEditingController priceController;
  late TextEditingController noteController;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    priceController = TextEditingController(
      text: widget.initialUnitPrice?.toString() ?? '',
    );
    noteController = TextEditingController(text: widget.initialNote ?? '');
    selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    priceController.dispose();
    noteController.dispose();
    super.dispose();
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
      _showSnackbar('Error', 'Please select a date');
      return;
    }

    if (priceController.text.trim().isEmpty) {
      _showSnackbar('Error', 'Please enter a unit price');
      return;
    }

    final unitPrice = double.tryParse(priceController.text.trim());
    if (unitPrice == null || unitPrice <= 0) {
      _showSnackbar('Error', 'Please enter a valid price');
      return;
    }

    Navigator.of(context).pop();
    widget.onSave(
      selectedDate!,
      unitPrice,
      noteController.text.trim().isEmpty ? null : noteController.text.trim(),
    );
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
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.initialDate != null;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),

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
                  onTap: () => Navigator.of(context).pop(),
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
                  hintText: '0.00',
                  labelText: 'Unit Price',
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
                  suffixText: CurrencyService.instance.portfolioCode,
                  suffixStyle: TextStyle(
                    color: AppColors.greyColor,
                    fontSize: 16.sp,
                  ),
                ),
                style: TextStyle(fontSize: 16.sp),
                textAlign: TextAlign.end,
              ),
            ),
            7.verticalSpace,

            // Note Field
            Container(
              height: 41.h,
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.greyBorder),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: TextField(
                controller: noteController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '',
                  labelText: 'Note (optional)',
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
