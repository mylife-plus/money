import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/widgets/custom_popup.dart';
import 'package:moneyapp/widgets/custom_text.dart';

class TransactionContent extends StatelessWidget {
  final String label;
  final String title;
  final String category;
  final String amount;
  final Color? labelColor;
  final Color? titleColor;
  final Color? categoryColor;
  final Color? amountColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  const TransactionContent({
    super.key,
    required this.label,
    required this.title,
    required this.category,
    required this.amount,
    this.labelColor = const Color(0xff707070),
    this.titleColor = Colors.black,
    this.categoryColor = const Color(0xff0088FF),
    this.amountColor = const Color(0xffFF0000),
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xffDFDFDF),
    this.borderWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 7.r, horizontal: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        color: backgroundColor,
        border: Border.all(color: borderColor!, width: borderWidth),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 220,
            child: Row(
              children: [
                CustomText(label, size: 16.sp, color: labelColor),
                7.horizontalSpace,
                CustomText(title, size: 16.sp, color: titleColor),
              ],
            ),
          ),
          CustomPopup(
            position: PopupPosition.bottom,
            backgroundColor: Colors.transparent,
            showArrow: false,
            contentPadding: EdgeInsets.zero,
            contentBorderRadius: BorderRadius.circular(4.r),
            barrierColor: Colors.black.withOpacity(0.1),
            // alignment: Alignment.bottomCenter,
            offset: Offset(0, 9.h),
            contentDecoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(4.r),
            ),
            animationDuration: Duration.zero,
            content: Container(
              decoration: BoxDecoration(
                color: Color(0xff82C5FF),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(7.r),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.r, 5.r, 5.r, 3.r),
                child: Row(
                  spacing: 5.w,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var category in ['Travel', 'Repair'])
                      Container(
                        padding: EdgeInsets.fromLTRB(8.r, 8.r, 11.r, 7.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7.r),
                          border: Border.all(color: Color(0xffDFDFDF)),
                        ),
                        child: CustomText.richText(
                          children: [
                            CustomText.span(
                              '# ',
                              size: 16.sp,
                              color: const Color(0xffA0A0A0),
                            ),
                            CustomText.span(
                              category,
                              size: 16.sp,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            child: CustomText.richText(
              children: [
                CustomText.span(category, size: 16.sp, color: categoryColor),
                CustomText.span(
                  ' #',
                  size: 16.sp,
                  color: const Color(0xff707070),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 116,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomText('€ $amount', size: 16.sp, color: amountColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
