import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/utils/date_picker_helper.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class PriceEntryDialog extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialPrice;
  final Function(DateTime date, String price) onSave;

  const PriceEntryDialog({
    super.key,
    this.initialDate,
    this.initialPrice,
    required this.onSave,
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
    final picked = await DatePickerHelper.showStyledDatePicker(
      context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
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

    widget.onSave(selectedDate!, priceController.text.trim());
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  widget.initialDate == null ? 'Add Price' : 'Edit Price',
                  size: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
                InkWell(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close, size: 24.sp),
                ),
              ],
            ),
            20.verticalSpace,

            // Date Field
            CustomText('Date', size: 14.sp, fontWeight: FontWeight.w500),
            8.verticalSpace,
            InkWell(
              onTap: _pickDate,
              child: Container(
                height: 41.h,
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xffDFDFDF)),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  children: [
                    Image.asset(AppIcons.dateIcon, height: 20.r, width: 20.r),
                    10.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            selectedDate == null
                                ? 'Select date'
                                : DateFormat(
                                    'dd.MM.yyyy',
                                  ).format(selectedDate!),
                            size: 16.sp,
                            color: selectedDate == null
                                ? Color(0xffB4B4B4)
                                : Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            16.verticalSpace,

            // Price Field
            CustomText('Price', size: 14.sp, fontWeight: FontWeight.w500),
            8.verticalSpace,
            Container(
              height: 41.h,
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xffDFDFDF)),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: TextField(
                controller: priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Enter price',
                  labelText: 'Price',
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

            24.verticalSpace,

            // Save Button
            Center(
              child: InkWell(
                onTap: _save,
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
                      'Save',
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
    );
  }
}
