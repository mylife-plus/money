import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_colors.dart';
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
            size: 16.sp,
          ),
          8.verticalSpace,

          Row(
            children: [
              Expanded(
                flex: 100,
                child: CustomText(
                  'received',
                  color: Color(0xff00C00D),
                  size: 16.sp,
                ),
              ),

              Expanded(
                flex: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText.richText(
                      textAlign: TextAlign.center,
                      children: [
                        CustomText.span(
                          '$amount ',
                          color: Colors.black,
                          size: 16.sp,
                        ),
                        CustomText.span(
                          symbol,
                          color: AppColors.greyColor,
                          size: 12.sp,
                        ),
                      ],
                    ),
                    CustomText.richText(
                      children: [
                        CustomText.span(
                          '$price ',
                          color: Colors.black,
                          size: 16.sp,
                        ),
                        CustomText.span(
                          priceSymbol,
                          color: AppColors.greyColor,
                          size: 12.sp,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 150,
                child: CustomText.richText(
                  textAlign: TextAlign.end,
                  children: [
                    CustomText.span(
                      '$total ',
                      color: Colors.black,
                      size: 18.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    CustomText.span(
                      totalSymbol,
                      color: AppColors.greyColor,
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
