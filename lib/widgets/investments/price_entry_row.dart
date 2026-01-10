import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/services/database/repositories/utils/date_picker_helper.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class PriceEntryRow extends StatefulWidget {
  final DateTime? initialDate;
  final String? initialPrice;
  final bool initialIsEditable;
  final Function(DateTime, String)? onSave;
  final VoidCallback? onDelete;

  const PriceEntryRow({
    super.key,
    this.initialDate,
    this.initialPrice,
    this.initialIsEditable = true,
    this.onSave,
    this.onDelete,
  });

  @override
  State<PriceEntryRow> createState() => _PriceEntryRowState();
}

class _PriceEntryRowState extends State<PriceEntryRow> {
  late DateTime? selectedDate;
  late String? price;
  late bool isEditable;
  late TextEditingController priceController;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    price = widget.initialPrice;
    isEditable = widget.initialIsEditable;
    priceController = TextEditingController(text: price);
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Date Container
        Container(
          height: 30.h,
          width: 90.w,
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xffDFDFDF)),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: isEditable
                ? InkWell(
                    onTap: () async {
                      DateTime? pickedDate = await DatePickerHelper.showStyledDatePicker(
                        context,
                        initialDate: selectedDate,
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: CustomText(
                      selectedDate == null
                          ? 'select Date'
                          : DateFormat('dd.MM.yyyy').format(selectedDate!),
                      size: selectedDate == null ? 12.sp : 16.sp,
                      textAlign: TextAlign.center,
                      color: selectedDate == null
                          ? const Color(0xffB4B4B4)
                          : Colors.black,
                    ),
                  )
                : CustomText(
                    selectedDate == null
                        ? 'select Date'
                        : DateFormat('dd.MM.yyyy').format(selectedDate!),
                    size: selectedDate == null ? 12.sp : 16.sp,
                    textAlign: TextAlign.center,
                    color: selectedDate == null
                        ? const Color(0xffB4B4B4)
                        : Colors.black,
                  ),
          ),
        ),
        7.horizontalSpace,
        // Price Container
        Container(
          height: 30.h,
          width: 98.w,
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xffDFDFDF)),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: isEditable
                ? TextField(
                    textAlign: TextAlign.start,
                    controller: priceController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '120.000',
                      hintStyle: const TextStyle(color: Color(0xffB4B4B4)),
                      isDense: true,
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 0,
                        maxWidth: 4.w,
                        minHeight: 0,
                      ),
                      prefixIcon: CustomText(
                        '\$ ',
                        color: const Color(0xff0088FF),
                        size: 16.sp,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xff0088FF),
                    ),
                    onChanged: (value) {
                      setState(() {
                        price = value;
                      });
                    },
                  )
                : CustomText(
                    price != null ? '\$ $price' : '\$ 0.000',
                    size: 16.sp,
                    textAlign: TextAlign.center,
                    color: Colors.black,
                  ),
          ),
        ),
        isEditable ? 12.horizontalSpace : 15.horizontalSpace,
        // Edit/Save Icon
        InkWell(
          onTap: () {
            if (isEditable) {
              // Save action
              if (selectedDate != null && price != null && price!.isNotEmpty) {
                if (widget.onSave != null) {
                  widget.onSave!(selectedDate!, price!);
                }
                // Optionally switch to non-editable mode after save
                setState(() {
                  isEditable = false;
                });
              }
            } else {
              // Edit action - switch to editable mode
              setState(() {
                isEditable = true;
              });
            }
          },
          child: Image.asset(
            isEditable ? AppIcons.tickCircle : AppIcons.edit,
            width: isEditable ? 25.r : 22.r,
            height: isEditable ? 25.r : 22.r,
          ),
        ),
        // Delete Icon
        if (widget.onDelete != null) ...[
          6.horizontalSpace,
          InkWell(
            onTap: widget.onDelete,
            child: Image.asset(
              AppIcons.delete,
              width: 22.r,
              height: 22.r,
            ),
          ),
        ],
      ],
    );
  }
}
