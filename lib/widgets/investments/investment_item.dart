import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class InvestmentItem extends StatelessWidget {
  final String image;
  final String name;
  final String amount;
  final String symbol;
  final String unitPrice;
  final String totalValue;
  final Color backgroundColor;

  const InvestmentItem({
    super.key,
    required this.image,
    required this.name,
    required this.amount,
    required this.symbol,
    required this.unitPrice,
    required this.totalValue,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(13.w, 10.h, 10.w, 10.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Color(0xffDFDFDF)),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(image, height: 16.r, width: 16.r),
                2.verticalSpace,
                CustomText(name, color: Colors.black, size: 18.sp),
              ],
            ),
          ),
          Expanded(
            flex: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomText.richText(
                  children: [
                    CustomText.span(
                      '$amount ',
                      color: Colors.black,
                      size: 16.sp,
                    ),
                    CustomText.span(
                      symbol,
                      color: Color(0xff999999),
                      size: 12.sp,
                    ),
                  ],
                ),
                2.verticalSpace,
                CustomText.richText(
                  children: [
                    CustomText.span(
                      '$unitPrice ',
                      color: Colors.black,
                      size: 16.sp,
                    ),
                    CustomText.span(
                      'USD',
                      color: Color(0xff999999),
                      size: 12.sp,
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            flex: 120,
            child: CustomText.richText(
              textAlign: TextAlign.right,
              children: [
                CustomText.span(
                  '$totalValue ',
                  color: Colors.black,
                  size: 20.sp,
                  fontWeight: FontWeight.w500,
                ),
                CustomText.span('USD', color: Color(0xff999999), size: 10.sp),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
