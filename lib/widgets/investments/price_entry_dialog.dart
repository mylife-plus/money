import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/services/currency_service.dart';
import 'package:moneyapp/utils/number_format_helper.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class PriceEntryDialog extends StatefulWidget {
  final DateTime? initialDate;
  final double? initialUnitPrice;
  final Function(DateTime date, double unitPrice) onSave;
  final VoidCallback? onDelete;

  const PriceEntryDialog({
    super.key,
    this.initialDate,
    this.initialUnitPrice,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<PriceEntryDialog> createState() => _PriceEntryDialogState();
}

class _PriceEntryDialogState extends State<PriceEntryDialog> {
  late TextEditingController priceController;
  DateTime? selectedDate;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    priceController = TextEditingController(
      text: widget.initialUnitPrice?.toString() ?? '',
    );
    selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  void _setError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = selectedDate != null && selectedDate!.isAfter(now)
        ? now
        : (selectedDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: now,
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

    if (picked != null && mounted) {
      final timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
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

      setState(() {
        if (timePicked != null) {
          selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        } else {
          selectedDate = picked;
        }
      });
    }
  }

  void _save() {
    if (selectedDate == null) {
      _setError('Please select a date');
      return;
    }

    if (priceController.text.trim().isEmpty) {
      _setError('Please enter a unit price');
      return;
    }

    final unitPrice = double.tryParse(priceController.text.trim());
    if (unitPrice == null || unitPrice <= 0) {
      _setError('Please enter a valid price');
      return;
    }

    _clearError();
    Navigator.of(context).pop();
    widget.onSave(selectedDate!, unitPrice);
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
    final isEditMode = widget.onDelete != null;

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
                inputFormatters: [
                  ThousandsSeparatorFormatter(
                    locale: CurrencyService.instance.portfolioLocale,
                  ),
                ],
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
            if (_errorMessage != null) ...[
              8.verticalSpace,
              CustomText(
                _errorMessage!,
                size: 12.sp,
                color: Colors.red,
              ),
            ],
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
