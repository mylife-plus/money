import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/widgets/custom_text.dart';

class InvestmentItem extends StatelessWidget {
  final String icon;
  final String name;
  final String amount;
  final String symbol;
  final String unitPrice;
  final String totalValue;

  const InvestmentItem({
    super.key,
    required this.icon,
    required this.name,
    required this.amount,
    required this.symbol,
    required this.unitPrice,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(13.w, 10.h, 10.w, 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Color(0xffDFDFDF)),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 157,
            child: Row(
              children: [
                CustomText(icon, size: 16.sp),
                14.horizontalSpace,
                Expanded(
                  child: CustomText(name, color: Colors.black, size: 14.sp),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 58,
            child: CustomText.richText(
              children: [
                CustomText.span('$amount ', color: Colors.black, size: 14.sp),
                CustomText.span(symbol, color: Color(0xff999999), size: 10.sp),
              ],
            ),
          ),
          Expanded(
            flex: 74,
            child: CustomText(unitPrice, color: Colors.black, size: 14.sp),
          ),
          Expanded(
            flex: 100,
            child: CustomText(totalValue, color: Colors.black, size: 14.sp),
          ),
        ],
      ),
    );
  }
}
