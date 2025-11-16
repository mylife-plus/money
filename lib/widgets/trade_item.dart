import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/widgets/custom_text.dart';

class TradeItem extends StatelessWidget {
  final String type; // 'sold' or 'bought'
  final String amount;
  final String symbol;
  final String price;
  final String priceSymbol;
  final String total;
  final String totalSymbol;
  final bool isFirst;
  final bool isLast;

  const TradeItem({
    super.key,
    required this.type,
    required this.amount,
    required this.symbol,
    required this.price,
    required this.priceSymbol,
    required this.total,
    required this.totalSymbol,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final isSold = type.toLowerCase() == 'sold';
    final backgroundColor = isSold ? Color(0xffFFEFEF) : Color(0xffD1FFD4);
    final textColor = isSold ? Color(0xffFF0000) : Color(0xff00C00D);

    BorderRadius borderRadius;
    if (isFirst && isLast) {
      borderRadius = BorderRadius.circular(4.r);
    } else if (isFirst) {
      borderRadius = BorderRadius.vertical(top: Radius.circular(4.r));
    } else if (isLast) {
      borderRadius = BorderRadius.vertical(bottom: Radius.circular(4.r));
    } else {
      borderRadius = BorderRadius.zero;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Color(0xffDFDFDF)),
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 65,
            child: CustomText(
              type,
              color: textColor,
              size: 16.sp,
            ),
          ),
          Expanded(
            flex: 99,
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
    );
  }
}
