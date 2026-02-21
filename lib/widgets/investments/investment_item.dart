import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/services/currency_service.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class InvestmentItem extends StatelessWidget {
  final String? image; // Asset path (optional if imageWidget provided)
  final Widget? imageWidget; // Custom image widget (takes precedence)
  final String name;
  final String amount;
  final String symbol;
  final String unitPrice;
  final String totalValue;
  final Color backgroundColor;

  const InvestmentItem({
    super.key,
    this.image,
    this.imageWidget,
    required this.name,
    required this.amount,
    required this.symbol,
    required this.unitPrice,
    required this.totalValue,
    required this.backgroundColor,
  });

  Widget _buildImage() {
    if (imageWidget != null) {
      return imageWidget!;
    }
    if (image != null && image!.isNotEmpty) {
      if (image!.startsWith('assets/')) {
        return Image.asset(image!, height: 23.r, width: 23.r);
      } else {
        final file = File(image!);
        if (file.existsSync()) {
          return Image.file(file, height: 23.r, width: 23.r, fit: BoxFit.cover);
        }
      }
    }
    return Icon(Icons.image, size: 23.r, color: AppColors.greyColor);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: Color(0xffDFDFDF)),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        23.horizontalSpace,
                        Expanded(
                          child: CustomText.richText(
                            overflow: TextOverflow.ellipsis,
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
                        ),
                      ],
                    ),
                    CustomText(
                      name,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      size: 18.sp,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(CurrencyService.instance.portfolioCode, color: Color(0xff999999), size: 12.sp),
                    CustomText(
                      unitPrice,
                      color: Colors.black,
                      size: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
              10.horizontalSpace,

              Expanded(
                flex: 140,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomText(
                      CurrencyService.instance.portfolioCode,
                      textAlign: TextAlign.right,
                      color: Color(0xff999999),
                      size: 10.sp,
                    ),
                    CustomText(
                      totalValue,
                      textAlign: TextAlign.right,
                      color: Colors.black,
                      size: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            height: 23.r,
            width: 23.r,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.r),
              border: Border.all(color: Colors.white),
            ),
            child: _buildImage(),
          ),
        ),
      ],
    );
  }
}
