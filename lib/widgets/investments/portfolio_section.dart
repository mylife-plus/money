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

              bool hadNewPrice = false;
              while (priceIdx < sortedPricePoints.length &&
                  sortedPricePoints[priceIdx].key.millisecondsSinceEpoch <=
                      windowEndMs) {
                carryPrices.addAll(sortedPricePoints[priceIdx].value);
                priceIdx++;
                hadNewPrice = true;
              }

              if (carryPrices.isEmpty) continue;

              // Stop after the last slot that had actual price data —
              // no data should be shown beyond the last entry.
              if (!hadNewPrice && priceIdx >= sortedPricePoints.length) break;

              final holdingsAtSlot = holdingsTimeline[midpoint] ?? {};
              double totalValue = 0;
              for (var entry in carryPrices.entries) {
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
            // Group prices by day for > 2 days, keeping latest datetime per investment
            if (dateInvestmentPrices.isNotEmpty) {
              Map<DateTime, Map<int, double>> groupedPrices = {};
              Map<DateTime, Map<int, DateTime>> groupedPriceDates = {};
              dateInvestmentPrices.forEach((date, prices) {
                final dayKey = DateTime(date.year, date.month, date.day);
                groupedPrices[dayKey] ??= {};
                groupedPriceDates[dayKey] ??= {};
                prices.forEach((investmentId, price) {
                  final existingDate =
                      groupedPriceDates[dayKey]![investmentId];
                  if (existingDate == null || date.isAfter(existingDate)) {
                    groupedPrices[dayKey]![investmentId] = price;
                    groupedPriceDates[dayKey]![investmentId] = date;
                  }
                });
              });
              dateInvestmentPrices = groupedPrices;
            }

            if (dateInvestmentPrices.isNotEmpty) {
              final holdingsTimeline = controller.buildHoldingsTimeline(
                dateInvestmentPrices.keys.toList(),
              );

              final sortedDates = dateInvestmentPrices.keys.toList()
                ..sort();

              Map<int, double> carryPrices = Map.of(
                controller.getLatestPricesBeforeDate(sortedDates.first),
              );

              Map<DateTime, double> dateValues = {};
              for (final date in sortedDates) {
                carryPrices.addAll(dateInvestmentPrices[date]!);
                double totalValue = 0;
                final holdingsAtDate = holdingsTimeline[date] ?? {};
                for (var entry in carryPrices.entries) {
                  final holdings = holdingsAtDate[entry.key] ?? 0;
                  if (holdings > 0) totalValue += holdings * entry.value;
                }
                dateValues[date] = totalValue;
              }

              var sortedEntries = dateValues.entries.toList()
                ..sort((a, b) => a.key.compareTo(b.key));

              for (var entry in sortedEntries) {
                final date = entry.key;
                final value = entry.value;
                String label;
                String tooltipLabel;
                if (durationInDays <= 90) {
                  label = DateFormat('dd.MM.yyyy').format(date);
                  tooltipLabel =
                      '$currencySymbol${_formatCurrency(value)}\n'
                      '${DateFormat('dd.MM.yyyy').format(date)}';
                } else if (durationInDays <= 365 * 2 + 10) {
                  label = DateFormat('MMM yyyy').format(date);
                  tooltipLabel =
                      '$currencySymbol${_formatCurrency(value)}\n'
                      '${DateFormat('dd.MM.yyyy').format(date)}';
                } else {
                  label = DateFormat('yyyy').format(date);
                  tooltipLabel =
                      '$currencySymbol${_formatCurrency(value)}\n'
                      '${DateFormat('dd.MM.yyyy').format(date)}';
                }
                chartData.add(ChartDataPoint(
                  label: label,
                  value: value,
                  tooltipLabel: tooltipLabel,
                  xValue: date.millisecondsSinceEpoch.toDouble(),
                ));
              }
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
                      child: Padding(
                        padding: const EdgeInsets.only(right: 35.0),
                        child: SmoothLineChartWidget(
                          data: chartData,
                          lineColor: const Color(0xff0088FF),
                        ),
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
                            150.verticalSpace,
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
