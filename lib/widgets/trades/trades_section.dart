import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/trades/trade_item_pair.dart';

class TradesSection extends StatelessWidget {
  const TradesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InvestmentController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        40.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.0.w),
          child: Row(
            children: [
              InkWell(
                child: Image.asset(AppIcons.sort, height: 24.r, width: 24.r),
              ),
              40.horizontalSpace,
              InkWell(
                child: Image.asset(AppIcons.filter, height: 24.r, width: 24.r),
              ),
              40.horizontalSpace,
              InkWell(
                child: Image.asset(AppIcons.search, height: 24.r, width: 24.r),
              ),
              Spacer(),
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.newPortfolioChange.path);
                },
                child: Image.asset(AppIcons.plus, height: 21.r, width: 21.r),
              ),
            ],
          ),
        ),
        16.verticalSpace,

        // Dynamic year/month/day/trade hierarchy
        Obx(() {
          final years = controller.sortedYears;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var year in years) ...[
                // Year Row
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: InkWell(
                    onTap: () => controller.toggleYearExpansion(year),
                    child: Row(
                      children: [
                        CustomText(
                          year.toString(),
                          color: AppColors.greyColor,
                          size: 16.sp,
                        ),
                        5.horizontalSpace,
                        Icon(
                          controller.isYearExpanded(year)
                              ? Icons.arrow_drop_up_rounded
                              : Icons.arrow_drop_down_rounded,
                          size: 32.r,
                          color: AppColors.greyColor,
                        ),
                      ],
                    ),
                  ),
                ),

                // Months (when year expanded)
                if (controller.isYearExpanded(year)) ...[
                  18.verticalSpace,
                  for (var month in controller.getSortedMonths(year)) ...[
                    // Month Row
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: InkWell(
                        onTap: () =>
                            controller.toggleMonthExpansion(year, month),
                        child: Row(
                          children: [
                            CustomText(
                              controller.getMonthName(month),
                              color: AppColors.greyColor,
                              size: 16.sp,
                            ),
                            5.horizontalSpace,
                            Icon(
                              controller.isMonthExpanded(year, month)
                                  ? Icons.arrow_drop_up_rounded
                                  : Icons.arrow_drop_down_rounded,
                              size: 32.r,
                              color: AppColors.greyColor,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Days (when month expanded)
                    if (controller.isMonthExpanded(year, month)) ...[
                      13.verticalSpace,
                      for (var day in controller.getSortedDays(
                        year,
                        month,
                      )) ...[
                        // Day label (non-collapsible)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Row(
                            children: [
                              8.horizontalSpace,
                              Expanded(
                                flex: 100,

                                child: CustomText(
                                  '$day. ${controller.getMonthName(month).substring(0, 3)}.',
                                  textAlign: TextAlign.start,
                                  color: Color(0xffCCCCCC),
                                  size: 14.sp,
                                ),
                              ),

                              // Show "Amount/Price" and "Total" headers only for first day of month
                              if (day ==
                                  controller
                                      .getSortedDays(year, month)
                                      .first) ...[
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
                                  flex: 150,
                                  child: CustomText(
                                    'Total',
                                    textAlign: TextAlign.center,
                                    color: Color(0xffCCCCCC),
                                    size: 14.sp,
                                  ),
                                ),
                              ] else ...[
                                // Add spacer with same flex values to maintain alignment
                                Expanded(flex: 100, child: SizedBox()),
                                Expanded(flex: 150, child: SizedBox()),
                              ],
                            ],
                          ),
                        ),
                        9.verticalSpace,

                        // Trades for this day
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Column(
                            spacing: 10.h,
                            children: [
                              for (var trade in controller.getTradesForDay(
                                year,
                                month,
                                day,
                              ))
                                TradeItemPair(
                                  soldAmount: trade.soldAmount,
                                  soldSymbol: trade.soldSymbol,
                                  soldPrice: trade.soldPrice,
                                  soldPriceSymbol: trade.soldPriceSymbol,
                                  soldTotal: trade.soldTotal,
                                  soldTotalSymbol: trade.soldTotalSymbol,
                                  boughtAmount: trade.boughtAmount,
                                  boughtSymbol: trade.boughtSymbol,
                                  boughtPrice: trade.boughtPrice,
                                  boughtPriceSymbol: trade.boughtPriceSymbol,
                                  boughtTotal: trade.boughtTotal,
                                  boughtTotalSymbol: trade.boughtTotalSymbol,
                                ),
                            ],
                          ),
                        ),

                        if (day != controller.getSortedDays(year, month).last)
                          22.verticalSpace,
                      ],
                    ],

                    18.verticalSpace,
                  ],
                ],

                if (year != years.last) 18.verticalSpace,
              ],
            ],
          );
        }),

        9.verticalSpace,
      ],
    );
  }
}
