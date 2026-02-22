import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/investment_model.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/widgets/common/custom_slider.dart';
import 'package:moneyapp/services/currency_service.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/investments/investment_item.dart';
import 'package:moneyapp/widgets/charts/smooth_line_chart.dart';
import 'package:moneyapp/models/chart_data_point.dart';

class PortfolioSection extends StatelessWidget {
  final bool isPortfolioSelected;

  const PortfolioSection({super.key, required this.isPortfolioSelected});

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(2);
  }

  String _formatAmount(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  Widget _buildInvestmentImage(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('assets/')) {
        return Image.asset(imagePath, height: 16.r, width: 16.r);
      } else {
        final file = File(imagePath);
        if (file.existsSync()) {
          return Image.file(file, height: 16.r, width: 16.r, fit: BoxFit.cover);
        }
      }
    }
    return Icon(Icons.image, size: 16.r, color: AppColors.greyColor);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InvestmentController>();

    return Obx(() {
      return FutureBuilder<List<Map<String, dynamic>>>(
        future: controller.filteredEnrichedInvestmentData,
        builder: (context, snapshot) {
          final enrichedData = snapshot.data ?? [];

          // Calculate total portfolio value from enriched data
          double currentValue = 0;
          for (final data in enrichedData) {
            currentValue += (data['totalValue'] as double?) ?? 0.0;
          }

          double percentChange = 0;

          // Build chart data from filtered portfolio snapshots
          final filteredSnapshots = controller.filteredPortfolioHistory;
          List<ChartDataPoint> chartData = [];

          if (filteredSnapshots.isNotEmpty) {
            // Group snapshots by date and investment, then calculate total portfolio value per date
            Map<DateTime, Map<int, double>> dateInvestmentPrices = {};

            for (var snapshot in filteredSnapshots) {
              DateTime dateOnly = DateTime(
                snapshot.date.year,
                snapshot.date.month,
                snapshot.date.day,
              );
              dateInvestmentPrices[dateOnly] ??= {};
              dateInvestmentPrices[dateOnly]![snapshot.investmentId] =
                  snapshot.unitPrice;
            }

            // For each date, calculate total portfolio value
            // We need to multiply unit prices by holdings at that date
            // For now, we'll show the sum of latest unit prices (simplified)
            Map<String, double> dateValues = {};

            dateInvestmentPrices.forEach((date, investmentPrices) {
              double totalValue = 0;
              // Get holdings for each investment and multiply by price
              for (var entry in investmentPrices.entries) {
                int investmentId = entry.key;
                double unitPrice = entry.value;

                // Find holdings at this date from enriched data
                final investmentData = enrichedData.firstWhere(
                  (data) => data['investment'].id == investmentId,
                  orElse: () => <String, dynamic>{},
                );

                if (investmentData.isNotEmpty) {
                  double holdings =
                      (investmentData['holdings'] as double?) ?? 0;
                  totalValue += holdings * unitPrice;
                }
              }

              String dateKey = DateFormat('dd.MM.yyyy').format(date);
              dateValues[dateKey] = totalValue;
            });

            // Convert to chart data points
            var sortedEntries = dateValues.entries.toList()
              ..sort((a, b) {
                var dateA = DateFormat('dd.MM.yyyy').parse(a.key);
                var dateB = DateFormat('dd.MM.yyyy').parse(b.key);
                return dateA.compareTo(dateB);
              });

            for (var entry in sortedEntries) {
              chartData.add(
                ChartDataPoint(
                  label: entry.key,
                  value: entry.value,
                  tooltipLabel:
                      '${CurrencyService.instance.portfolioSymbol}${_formatCurrency(entry.value)}\n${entry.key}',
                ),
              );
            }

            // Calculate percent change from filtered data
            if (chartData.length >= 2) {
              double firstValue = chartData.first.value;
              double lastValue = chartData.last.value;
              if (firstValue > 0) {
                percentChange = ((lastValue - firstValue) / firstValue) * 100;
              }
              currentValue = lastValue;
            } else if (chartData.length == 1) {
              currentValue = chartData.first.value;
            }
          }

          // If no chart data, show placeholder
          if (chartData.isEmpty) {
            chartData = [
              ChartDataPoint(label: '2024', value: 0, tooltipLabel: '0\n2024'),
              ChartDataPoint(label: '2025', value: 0, tooltipLabel: '0\n2025'),
            ];
          }

          return Column(
            children: [
              16.verticalSpace,
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
                    Center(
                      child: CustomText(
                        enrichedData.isEmpty
                            ? 'N/A  -  N/A'
                            : '${DateFormat('dd.MM.yyyy').format(controller.portfolioDateStart.value)}  -  ${DateFormat('dd.MM.yyyy').format(controller.portfolioDateEnd.value)}',
                        size: 14.sp,
                        color: AppColors.greyColor,
                      ),
                    ),
                    if (enrichedData.isNotEmpty)
                      Center(
                        child: CustomText.richText(
                          children: [
                            CustomText.span(
                              '${CurrencyService.instance.portfolioSymbol} ${_formatCurrency(currentValue)}',
                              size: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            CustomText.span(
                              ' ${CurrencyService.instance.portfolioCode}',
                              size: 12.sp,
                              color: AppColors.greyColor,
                            ),
                            CustomText.span(
                              '  ${percentChange >= 0 ? '+' : ''}${percentChange.toStringAsFixed(1)}%',
                              size: 14.sp,
                              color: percentChange >= 0
                                  ? Color(0xff00C00D)
                                  : Color(0xffFF0000),
                            ),
                          ],
                        ),
                      )
                    else
                      Center(
                        child: CustomText(
                          '0',
                          size: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    Expanded(
                      child: SmoothLineChartWidget(
                        data: chartData,
                        lineColor: const Color(0xff0088FF),
                      ),
                    ),
                  ],
                ),
              ),
              7.verticalSpace,
              // Duration tabs
              Obx(
                () => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 7.w),
                  child: Row(
                    mainAxisAlignment:
                        controller.availablePortfolioDurationTabs.length <= 1
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: [
                            for (final duration
                                in controller.availablePortfolioDurationTabs)
                              InkWell(
                                onTap: () => controller
                                    .updatePortfolioDurationTab(duration),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        controller
                                                .selectedPortfolioDurationTab
                                                .value ==
                                            duration
                                        ? const Color(0xff0088FF)
                                        : Colors.white,
                                    border: Border.all(
                                      color:
                                          controller
                                                  .selectedPortfolioDurationTab
                                                  .value ==
                                              duration
                                          ? Colors.transparent
                                          : AppColors.greyColor,
                                    ),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: CustomText(
                                    duration,
                                    size: 16.sp,
                                    color:
                                        controller
                                                .selectedPortfolioDurationTab
                                                .value ==
                                            duration
                                        ? Colors.white
                                        : AppColors.greyColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              20.verticalSpace,
              // Date range slider
              Obx(
                () => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    children: [
                      CustomSlider(
                        min: controller
                            .portfolioSliderMinDate
                            .value
                            .millisecondsSinceEpoch
                            .toDouble(),
                        max: controller
                            .portfolioSliderMaxDate
                            .value
                            .millisecondsSinceEpoch
                            .toDouble(),
                        startValue: controller
                            .portfolioDateStart
                            .value
                            .millisecondsSinceEpoch
                            .toDouble(),
                        endValue: controller
                            .portfolioDateEnd
                            .value
                            .millisecondsSinceEpoch
                            .toDouble(),
                        onChanged: (start, end) {
                          controller.updatePortfolioDateRange(
                            DateTime.fromMillisecondsSinceEpoch(start.toInt()),
                            DateTime.fromMillisecondsSinceEpoch(end.toInt()),
                          );
                        },
                        lineColor: const Color(0xff0088FF),
                        handleColor: const Color(0xff0088FF),
                      ),
                      10.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            DateFormat(
                              'dd.MM.yyyy',
                            ).format(controller.portfolioDateStart.value),
                            size: 12.sp,
                            color: AppColors.greyColor,
                          ),
                          CustomText(
                            DateFormat(
                              'dd.MM.yyyy',
                            ).format(controller.portfolioDateEnd.value),
                            size: 12.sp,
                            color: AppColors.greyColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              20.verticalSpace,
              if (enrichedData.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 9.w, right: 9.w),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 140,
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
                          'Price',
                          color: Color(0xffCCCCCC),
                          size: 14.sp,
                        ),
                      ),
                      10.horizontalSpace,
                      Expanded(
                        flex: 140,
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
                    if (enrichedData.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 23.0.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomText(
                              'you have no 📈Investments',
                              size: 20.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                            33.verticalSpace, // Visual balance
                            CustomText(
                              'start by making your initial deposit by clicking ➕ or add multiple Trades/Transactions via ⚙️Settings → ⬆️ Upload 📈Investments ',
                              size: 20.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w400,
                            ),
                            // 60.horizontalSpace,
                          ],
                        ),
                      )
                    else
                      for (var data in enrichedData)
                        InkWell(
                          onTap: () {
                            final investment = data['investment'] as Investment;
                            Get.toNamed(
                              AppRoutes.investmentValueHistory.path,
                              arguments: investment,
                            );
                          },
                          child: InvestmentItem(
                            backgroundColor:
                                (data['investment'] as Investment).color,
                            imageWidget: _buildInvestmentImage(
                              (data['investment'] as Investment).imagePath,
                            ),
                            name: (data['investment'] as Investment).name,
                            amount: _formatAmount(data['amount'] as double),
                            symbol: (data['investment'] as Investment).ticker,
                            unitPrice: (data['hasPrice'] as bool)
                                ? '${CurrencyService.instance.portfolioSymbol}${NumberFormat('#,##0.00').format(data['latestPrice'] as double)}'
                                : 'No price data',
                            totalValue: (data['hasPrice'] as bool)
                                ? '${CurrencyService.instance.portfolioSymbol}${NumberFormat('#,##0.00').format(data['totalValue'] as double)}'
                                : '---',
                          ),
                        ),
                  ],
                ),
              ),
              150.verticalSpace,
            ],
          );
        },
      );
    });
  }
}
