import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class ReceivedTradeItem extends StatelessWidget {
  final String title;
  final String amount;
  final String symbol;
  final String price;
  final String priceSymbol;
  final String total;
  final String totalSymbol;

  const ReceivedTradeItem({
    super.key,
    required this.title,
    required this.amount,
    required this.symbol,
    required this.price,
    required this.priceSymbol,
    required this.total,
    required this.totalSymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Color(0xffD1FFD4),
        border: Border.all(color: Color(0xffDFDFDF)),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,
            textAlign: TextAlign.start,
            color: Colors.black,
            size: 15.sp,
          ),
          8.verticalSpace,

          Row(
            children: [
              Expanded(
                flex: 66,
                child: CustomText(
                  'received',
                  color: Color(0xff00C00D),
                  size: 15.sp,
                ),
              ),
              Expanded(
                flex: 98,
                child: CustomText.richText(
                  textAlign: TextAlign.center,
                  children: [
                    CustomText.span(
                      '$amount ',
                      color: Colors.black,
                      size: 16.sp,
                    ),
                    CustomText.span(
                      symbol,
                      color: Color(0xff929292),
                      size: 12.sp,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 102,
                child: CustomText.richText(
                  children: [
                    CustomText.span(
                      '$price ',
                      color: Colors.black,
                      size: 16.sp,
                    ),
                    CustomText.span(
                      priceSymbol,
                      color: Color(0xff929292),
                      size: 12.sp,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 87,
                child: CustomText.richText(
                  children: [
                    CustomText.span(
                      '$total ',
                      color: Colors.black,
                      size: 16.sp,
                    ),
                    CustomText.span(
                      totalSymbol,
                      color: Color(0xff929292),
                      size: 12.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
