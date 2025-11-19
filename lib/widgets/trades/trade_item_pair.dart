import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class TradeItemPair extends StatelessWidget {
  final String soldAmount;
  final String soldSymbol;
  final String soldPrice;
  final String soldPriceSymbol;
  final String soldTotal;
  final String soldTotalSymbol;
  final String boughtAmount;
  final String boughtSymbol;
  final String boughtPrice;
  final String boughtPriceSymbol;
  final String boughtTotal;
  final String boughtTotalSymbol;

  const TradeItemPair({
    super.key,
    required this.soldAmount,
    required this.soldSymbol,
    required this.soldPrice,
    required this.soldPriceSymbol,
    required this.soldTotal,
    required this.soldTotalSymbol,
    required this.boughtAmount,
    required this.boughtSymbol,
    required this.boughtPrice,
    required this.boughtPriceSymbol,
    required this.boughtTotal,
    required this.boughtTotalSymbol,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sold item
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Color(0xffFFEFEF),
            border: Border.all(color: Color(0xffDFDFDF)),
            borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 65,
                child: CustomText(
                  'sold',
                  color: Color(0xffFF0000),
                  size: 16.sp,
                ),
              ),
              Expanded(
                flex: 99,
                child: CustomText.richText(
                  textAlign: TextAlign.center,
                  children: [
                    CustomText.span(
                      '$soldAmount ',
                      color: Colors.black,
                      size: 16.sp,
                    ),
                    CustomText.span(
                      soldSymbol,
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
                      '$soldPrice ',
                      color: Colors.black,
                      size: 16.sp,
                    ),
                    CustomText.span(
                      soldPriceSymbol,
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
                      '$soldTotal ',
                      color: Colors.black,
                      size: 16.sp,
                    ),
                    CustomText.span(
                      soldTotalSymbol,
                      color: Color(0xff929292),
                      size: 12.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Bought item
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Color(0xffD1FFD4),
            border: Border.all(color: Color(0xffDFDFDF)),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.r)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 65,
                child: CustomText(
                  'bought',
                  color: Color(0xff00C00D),
                  size: 16.sp,
                ),
              ),
              Expanded(
                flex: 99,
                child: CustomText.richText(
                  textAlign: TextAlign.center,
                  children: [
                    CustomText.span(
                      '$boughtAmount ',
                      color: Colors.black,
                      size: 16.sp,
                    ),
                    CustomText.span(
                      boughtSymbol,
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
                      '$boughtPrice ',
                      color: Colors.black,
                      size: 16.sp,
                    ),
                    CustomText.span(
                      boughtPriceSymbol,
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
                      '$boughtTotal ',
                      color: Colors.black,
                      size: 16.sp,
                    ),
                    CustomText.span(
                      boughtTotalSymbol,
                      color: Color(0xff929292),
                      size: 12.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
