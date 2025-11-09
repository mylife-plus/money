import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/widgets/custom_text.dart';
import 'package:moneyapp/widgets/transaction_item.dart';

class SplitSpendingContent extends StatefulWidget {
  final String label;
  final String title;
  final String category;
  final String amount;

  const SplitSpendingContent({
    super.key,
    required this.label,
    required this.title,
    required this.category,
    required this.amount,
  });

  @override
  State<SplitSpendingContent> createState() => _SplitSpendingContentState();
}

class _SplitSpendingContentState extends State<SplitSpendingContent> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w),
      child: Column(
        children: [
          6.verticalSpace,
          TransactionItem(
            label: widget.label,
            title: widget.title,
            category: widget.category,
            amount: widget.amount,
          ),
          21.verticalSpace,
          Row(
            children: [
              8.horizontalSpace,
              Expanded(child: CustomText('into', size: 16.sp)),
              InkWell(
                child: Image.asset(AppIcons.plus, height: 21.r, width: 21.r),
              ),

              13.horizontalSpace,
            ],
          ),
          19.verticalSpace,

          Row(
            children: [
              InkWell(
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  ).then((pickedDate) {
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),

                  child: CustomText(
                    selectedDate == null
                        ? 'select Date'
                        : DateFormat('dd/MM/yyyy').format(selectedDate!),
                    size: 16.sp,
                    color: selectedDate == null
                        ? Color(0xffB4B4B4)
                        : Colors.black,
                  ),
                ),
              ),
              7.horizontalSpace,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xffDFDFDF)),
                  borderRadius: BorderRadius.circular(6.r),
                ),

                child: Row(
                  children: [
                    CustomText('0', size: 16.sp, color: Color(0xff0088FF)),
                    CustomText(' #', size: 16.sp, color: Color(0xffA0A0A0)),
                  ],
                ),
              ),
            ],
          ),
          7.verticalSpace,
          Row(
            children: [
              Container(
                height: 41.h,
                width: 41.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xffDFDFDF)),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Center(
                  child: Image.asset(
                    AppIcons.plus,
                    height: 21.r,
                    width: 21.r,
                    color: const Color(0xffA0A0A0),
                  ),
                ),
              ),
              7.horizontalSpace,

              Expanded(
                flex: 2,
                child: Container(
                  height: 41.h,

                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    // vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Description',
                        hintStyle: TextStyle(color: Color(0xffB4B4B4)),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                ),
              ),
              6.horizontalSpace,
              Expanded(
                child: Container(
                  height: 41.h,
                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    // vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText('Amount', size: 10.sp),
                      TextField(
                        cursorHeight: 15.r,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '€ 0,00',
                          hintStyle: TextStyle(color: Color(0xffB4B4B4)),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 16.sp),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          24.verticalSpace,
          // Add more content here as you build the design
        ],
      ),
    );
  }
}
