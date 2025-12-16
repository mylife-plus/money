import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/models/investment_data.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/widgets/common/custom_slider.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/investments/investment_item.dart';
import 'package:moneyapp/widgets/charts/smooth_line_chart.dart';
import 'package:moneyapp/widgets/charts/step_line_chart.dart';

class PortfolioSection extends StatelessWidget {
  final bool isPortfolioSelected;

  const PortfolioSection({super.key, required this.isPortfolioSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        38.verticalSpace,
        Container(
          margin: EdgeInsets.symmetric(horizontal: 7.w),
          padding: EdgeInsets.fromLTRB(5.w, 8.h, 20.w, 5.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Color(0xffE3E3E3)),
            borderRadius: BorderRadius.circular(12.r),
          ),
          height: 227.h,
          child: Column(
            children: [
              Row(
                children: [
                  24.horizontalSpace,
                  Padding(
                    padding: EdgeInsets.only(right: 15.w),
                    child: CustomText(
                      '12.10.2025',
                      size: 14.sp,
                      fontWeight: FontWeight.normal,
                      color: AppColors.greyColor,
                    ),
                  ),

                  Spacer(),
                  CustomText.richText(
                    children: [
                      CustomText.span(
                        '\$ 360,000',
                        size: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),

                      CustomText.span(
                        ' USD',
                        size: 12.sp,
                        color: AppColors.greyColor,
                      ),
                      CustomText.span(
                        '  +410%',
                        size: 14.sp,
                        color: Color(0xff00C00D),
                      ),
                    ],
                  ),
                  Spacer(),
                  70.horizontalSpace,
                ],
              ),
              12.verticalSpace,

              Expanded(
                child: SmoothLineChartWidget(
                  data: [
                    ChartDataPoint(label: '2004', value: 100000),
                    ChartDataPoint(label: '2007', value: 400000),
                    ChartDataPoint(label: '2010', value: 150000),
                    ChartDataPoint(label: '2013', value: 450000),
                    ChartDataPoint(label: '2016', value: 700000),
                    ChartDataPoint(label: '2019', value: 200000),
                    ChartDataPoint(label: '2022', value: 450000),
                    ChartDataPoint(label: '2025', value: 1000000),
                    ChartDataPoint(label: '2028', value: 400000),
                    ChartDataPoint(label: '2031', value: 700000),
                  ],
                  lineColor: const Color(0xff0088FF),
                ),
              ),
            ],
          ),
        ),
        20.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 6.w,
            children: [
              for (var duration in [
                '7d',
                '2w',
                '2m',
                '4m',
                '6m',
                '2y',
                '4y',
                'All',
              ])
                Container(
                  width: 36.w,
                  height: 31.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Center(
                    child: CustomText(
                      duration,
                      size: 16.sp,
                      color: Color(0xff8B8B8B),
                    ),
                  ),
                ),
            ],
          ),
        ),
        20.verticalSpace,

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 9.w),
          child: CustomSlider(
            min: 0,
            max: 10000,
            startValue: 2000,
            endValue: 8000,
            lineColor: const Color(0xff0088FF),
            handleColor: const Color(0xFFFFE478),
            onChanged: (start, end) {
              print('Range: \$${start.toInt()} - \$${end.toInt()}');
            },
          ),
        ),

        16.verticalSpace,
        Padding(
          padding: EdgeInsets.only(left: 9.w, right: 9.w),
          child: Row(
            children: [
              Expanded(
                flex: 100,
                child: CustomText(
                  'Investment',
                  textAlign: TextAlign.center,

                  color: Color(0xffCCCCCC),
                  size: 14.sp,
                ),
              ),
              Expanded(
                flex: 100,
                child: CustomText(
                  textAlign: TextAlign.center,
                  'Amount/Price',
                  color: Color(0xffCCCCCC),
                  size: 14.sp,
                ),
              ),

              Expanded(
                flex: 125,
                child: CustomText(
                  'Total',
                  textAlign: TextAlign.center,
                  color: Color(0xffCCCCCC),
                  size: 14.sp,
                ),
              ),
            ],
          ),
        ),
        11.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 9.0.w),
          child: Column(
            spacing: 3.h,
            children: [
              for (var investment in InvestmentData.getSampleData())
                InkWell(
                  onTap: () {
                    Get.toNamed(AppRoutes.bitcoinPrices.path);
                  },
                  child: InvestmentItem(
                    backgroundColor: investment.backgroundColor,
                    image: investment.image,
                    name: investment.name,
                    amount: investment.amount,
                    symbol: investment.symbol,
                    unitPrice: investment.unitPrice,
                    totalValue: investment.totalValue,
                  ),
                ),
            ],
          ),
        ),
        150.verticalSpace,
      ],
    );
  }
}
