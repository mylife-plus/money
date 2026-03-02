import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/investment_model.dart';
import 'package:moneyapp/widgets/common/custom_slider.dart';
import 'package:moneyapp/services/currency_service.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/charts/smooth_line_chart.dart';
import 'package:moneyapp/models/chart_data_point.dart';
import 'package:moneyapp/utils/number_format_helper.dart';

class PortfolioSection extends StatelessWidget {
  final bool isPortfolioSelected;

  const PortfolioSection({super.key, required this.isPortfolioSelected});

  String _formatCurrency(double value) {
    return NumberFormatHelper.formatCurrencyCompact(value, locale: CurrencyService.instance.portfolioLocale);
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

          final filteredInvestmentIds = enrichedData
              .map((d) => (d['investment'] as Investment).id)
              .whereType<int>()
              .toSet();

          // Build chart data from all price points (manual snapshots + activities)
          List<ChartDataPoint> chartData = [];

          int durationInDays = controller.portfolioDateEnd.value
              .difference(controller.portfolioDateStart.value)
              .inDays;
          if (durationInDays < 1) durationInDays = 1;

          Map<DateTime, Map<int, double>> dateInvestmentPrices =
              controller.getAllPricePointsForGraph();

          final currencySymbol = CurrencyService.instance.portfolioSymbol;

          if (durationInDays <= 2) {
            // Time-based hourly slots (like spending graph)
            final int targetPoints = 24 * durationInDays;
            final startMs =
                controller.portfolioDateStart.value.millisecondsSinceEpoch;
            final endMs =
                controller.portfolioDateEnd.value.millisecondsSinceEpoch;
            final windowSizeMs = (endMs - startMs) / targetPoints;

            final sortedPricePoints = dateInvestmentPrices.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key));

            Map<int, double> carryPrices = Map.of(
              controller.getLatestPricesBeforeDate(
                controller.portfolioDateStart.value,
              ),
            );
            int priceIdx = 0;

            final slotMidpoints = List.generate(targetPoints, (i) {
              final ms = (startMs + (i + 0.5) * windowSizeMs).round();
              return DateTime.fromMillisecondsSinceEpoch(ms);
            });

            final holdingsTimeline =
                controller.buildHoldingsTimeline(slotMidpoints);

            for (int i = 0; i < targetPoints; i++) {
              final windowEndMs =
                  (startMs + (i + 1) * windowSizeMs).round();
              final midpoint = slotMidpoints[i];

              while (priceIdx < sortedPricePoints.length &&
                  sortedPricePoints[priceIdx].key.millisecondsSinceEpoch <=
                      windowEndMs) {
                carryPrices.addAll(sortedPricePoints[priceIdx].value);
                priceIdx++;
              }

              if (carryPrices.isEmpty) continue;



              final holdingsAtSlot = holdingsTimeline[midpoint] ?? {};
              double totalValue = 0;
              for (var entry in carryPrices.entries) {
                if (filteredInvestmentIds.isNotEmpty &&
                    !filteredInvestmentIds.contains(entry.key)) {
                  continue;
                }
                final holdings = holdingsAtSlot[entry.key] ?? 0;
                if (holdings > 0) totalValue += holdings * entry.value;
              }

              chartData.add(ChartDataPoint(
                label: DateFormat('HH:mm').format(midpoint),
                value: totalValue,
                tooltipLabel:
                    '$currencySymbol${_formatCurrency(totalValue)}\n'
                    '${DateFormat('HH:mm dd.MM.yyyy').format(midpoint)}',
                xValue: i.toDouble(),
              ));
            }
          } else {
            int targetPoints;
            if (durationInDays < 90) {
              targetPoints = durationInDays.ceil();
            } else {
              targetPoints = 90;
            }

            final startMs =
                controller.portfolioDateStart.value.millisecondsSinceEpoch;
            final endMs =
                controller.portfolioDateEnd.value.millisecondsSinceEpoch;
            final windowSizeMs = (endMs - startMs) / targetPoints;

            final slotMidpoints = List.generate(targetPoints, (i) {
              final ms = (startMs + (i + 0.5) * windowSizeMs).round();
              return DateTime.fromMillisecondsSinceEpoch(ms);
            });

            final holdingsTimeline =
                controller.buildHoldingsTimeline(slotMidpoints);

            final sortedPricePoints = dateInvestmentPrices.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key));

            Map<int, double> carryPrices = Map.of(
              controller.getLatestPricesBeforeDate(
                controller.portfolioDateStart.value,
              ),
            );

            int priceIdx = 0;

            for (int i = 0; i < targetPoints; i++) {
              final windowEndMs =
                  (startMs + (i + 1) * windowSizeMs).round();
              final midpoint = slotMidpoints[i];

              Map<int, double> windowPrices = {};
              Map<int, DateTime> windowPriceDates = {};

              while (priceIdx < sortedPricePoints.length &&
                  sortedPricePoints[priceIdx].key.millisecondsSinceEpoch <=
                      windowEndMs) {
                final pointDate = sortedPricePoints[priceIdx].key;
                sortedPricePoints[priceIdx].value.forEach((investmentId, price) {
                  final existing = windowPriceDates[investmentId];
                  if (existing == null || pointDate.isAfter(existing)) {
                    windowPrices[investmentId] = price;
                    windowPriceDates[investmentId] = pointDate;
                  }
                });
                priceIdx++;
              }

              if (windowPrices.isNotEmpty) {
                carryPrices.addAll(windowPrices);
              }

              if (carryPrices.isEmpty) continue;


              final holdingsAtSlot = holdingsTimeline[midpoint] ?? {};
              double totalValue = 0;
              for (var entry in carryPrices.entries) {
                if (filteredInvestmentIds.isNotEmpty &&
                    !filteredInvestmentIds.contains(entry.key)) {
                  continue;
                }
                final holdings = holdingsAtSlot[entry.key] ?? 0;
                if (holdings > 0) totalValue += holdings * entry.value;
              }

              String label;
              String tooltipLabel;
              if (durationInDays < 90) {
                label = DateFormat('dd.MM.yyyy').format(midpoint);
                tooltipLabel =
                    '$currencySymbol${_formatCurrency(totalValue)}\n'
                    '${DateFormat('dd.MM.yyyy').format(midpoint)}';
              } else if (durationInDays <= 365 * 2 + 10) {
                label = DateFormat('MMM yyyy').format(midpoint);
                tooltipLabel =
                    '$currencySymbol${_formatCurrency(totalValue)}\n'
                    '${DateFormat('dd.MM.yyyy').format(midpoint)}';
              } else {
                label = DateFormat('yyyy').format(midpoint);
                tooltipLabel =
                    '$currencySymbol${_formatCurrency(totalValue)}\n'
                    '${DateFormat('dd.MM.yyyy').format(midpoint)}';
              }

              chartData.add(ChartDataPoint(
                label: label,
                value: totalValue,
                tooltipLabel: tooltipLabel,
                xValue: i.toDouble(),
              ));
            }
          }

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

          // If no chart data, show placeholder
          if (chartData.isEmpty) {
            chartData = [
              ChartDataPoint(
                label: '2024',
                value: 0,
                tooltipLabel: '0\n2024',
                xValue: DateTime.now().millisecondsSinceEpoch.toDouble(),
              ),
              ChartDataPoint(
                label: '2025',
                value: 0,
                tooltipLabel: '0\n2025',
                xValue: DateTime.now()
                    .add(const Duration(days: 365))
                    .millisecondsSinceEpoch
                    .toDouble(),
              ),
            ];
          }

          return Column(
            children: [
              16.verticalSpace,
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                padding: EdgeInsets.fromLTRB(5.w, 8.h, 10.w, 5.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xffE3E3E3)),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                height: 227.h,
                child: controller.uniqueDataDaysCount >= 2
                    ? Column(
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
                                    '  ${percentChange >= 0 ? '+' : ''}${NumberFormat('0.0', CurrencyService.instance.portfolioLocale).format(percentChange)}%',
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
                            child: Padding(
                              padding: const EdgeInsets.only(right: 35.0),
                              child: SmoothLineChartWidget(
                                data: chartData,
                                lineColor: const Color(0xff0088FF),
                                locale: CurrencyService.instance.portfolioLocale,
                                showFourLabels: durationInDays > 30,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: CustomText(
                            'Your portfolio 📈 graph will appear here once you have at least 2 days of data.',
                            size: 20.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                            textAlign: TextAlign.center,
                          ),
                        ),
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

                    ],
                  ),
                ),
              ),
              20.verticalSpace,
            ],
          );
        },
      );
    });
  }
}
