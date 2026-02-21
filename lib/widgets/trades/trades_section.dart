import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/investment_list_item.dart';
import 'package:moneyapp/screens/filter/portfolio_filter_screen.dart';
import 'package:moneyapp/screens/investments/trade_search_screen.dart';
import 'package:moneyapp/services/currency_service.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/common/selection_app_bar.dart';
import 'package:moneyapp/widgets/trades/trade_item_pair.dart';
import 'package:moneyapp/widgets/trades/transaction_item.dart';
import 'package:moneyapp/widgets/transactions/top_sort_sheet.dart';
import 'package:moneyapp/widgets/common/slide_from_top_route.dart';
import 'package:moneyapp/screens/investments/new_portfolio_change_screen.dart';

class TradesSection extends StatefulWidget {
  final Function(bool)? onSelectionModeChanged;

  const TradesSection({super.key, this.onSelectionModeChanged});

  @override
  State<TradesSection> createState() => _TradesSectionState();
}

class _TradesSectionState extends State<TradesSection> {
  List<int> selectedIds = [];

  void _updateSelectionMode(bool isSelectionMode) {
    if (widget.onSelectionModeChanged != null) {
      widget.onSelectionModeChanged!(isSelectionMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InvestmentController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show selection app bar or regular controls based on selection mode
        if (selectedIds.isNotEmpty)
          SelectionAppBar(
            selectedCount: selectedIds.length,
            onCancel: () {
              setState(() {
                selectedIds.clear();
                _updateSelectionMode(false);
              });
            },
            onDelete: () async {
              await controller.deleteTrades(selectedIds);
              setState(() {
                selectedIds.clear();
                _updateSelectionMode(false);
              });
            },
          )
        else ...[
          40.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0.w),
            child: Row(
              children: [
                InkWell(
                  onTap: () async {
                    await TopSortSheet.show(
                      context: context,
                      title: 'Sorting',
                      selectedOption: controller.selectedSortOption.value,
                      selectedDirection: controller.selectedSortDirection.value,
                      onOptionSelected: (option, direction) {
                        controller.updateSortOption(option, direction);
                      },
                    );
                  },
                  child: Image.asset(AppIcons.sort, height: 24.r, width: 24.r),
                ),
                40.horizontalSpace,
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      SlideFromTopRoute(page: const PortfolioFilterScreen()),
                    );
                  },
                  child: Obx(
                    () => Badge(
                      isLabelVisible: controller.activeFilterCount > 0,
                      label: Text(controller.activeFilterCount.toString()),
                      child: Image.asset(
                        AppIcons.filter,
                        height: 24.r,
                        width: 24.r,
                      ),
                    ),
                  ),
                ),
                40.horizontalSpace,
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      SlideFromTopRoute(page: const TradeSearchScreen()),
                    );
                  },
                  child: Image.asset(
                    AppIcons.search,
                    height: 24.r,
                    width: 24.r,
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
          16.verticalSpace,
        ],

        // High-performance list with ListView.builder
        Obx(() {
          final items = controller.visibleActivities;

          return ListView.separated(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Let parent handle scrolling
            addAutomaticKeepAlives: false, // Reduce memory overhead
            addRepaintBoundaries: true, // Optimize repaints
            itemCount: items.length,
            separatorBuilder: (context, index) {
              final item = items[index];
              final nextItem = index < items.length - 1
                  ? items[index + 1]
                  : null;

              // Add spacing between activity items
              if (item is InvestmentActivityItem) {
                if (nextItem is InvestmentActivityItem) {
                  return SizedBox(height: 10.h);
                } else if (nextItem is InvestmentDayHeaderItem) {
                  return SizedBox(height: 22.h);
                } else {
                  return SizedBox(height: 9.h);
                }
              } else if (item is InvestmentDayHeaderItem) {
                return SizedBox(height: 9.h);
              } else if (item is InvestmentMonthHeaderItem) {
                return SizedBox(height: 13.h);
              } else if (item is InvestmentYearHeaderItem &&
                  nextItem is InvestmentMonthHeaderItem) {
                return SizedBox(height: 18.h);
              }

              return const SizedBox.shrink();
            },
            itemBuilder: (context, index) {
              final item = items[index];

              return switch (item) {
                InvestmentYearHeaderItem(:final year) => Padding(
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
                              ? Icons.arrow_drop_down_rounded
                              : Icons.arrow_drop_up_rounded,
                          size: 32.r,
                          color: AppColors.greyColor,
                        ),
                      ],
                    ),
                  ),
                ),

                InvestmentMonthHeaderItem(
                  :final year,
                  :final month,
                  :final monthName,
                ) =>
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: InkWell(
                      onTap: () => controller.toggleMonthExpansion(year, month),
                      child: Row(
                        children: [
                          CustomText(
                            monthName,
                            color: AppColors.greyColor,
                            size: 16.sp,
                          ),
                          5.horizontalSpace,
                          Icon(
                            controller.isMonthExpanded(year, month)
                                ? Icons.arrow_drop_down_rounded
                                : Icons.arrow_drop_up_rounded,
                            size: 32.r,
                            color: AppColors.greyColor,
                          ),
                        ],
                      ),
                    ),
                  ),

                InvestmentDayHeaderItem(
                  :final day,
                  :final monthAbbr,
                  :final showHeaders,
                ) =>
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Row(
                      children: [
                        8.horizontalSpace,
                        Expanded(
                          flex: 100,
                          child: CustomText(
                            '$day. $monthAbbr.',
                            textAlign: TextAlign.start,
                            color: Color(0xffCCCCCC),
                            size: 14.sp,
                          ),
                        ),
                        if (showHeaders) ...[
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
                          Expanded(flex: 100, child: SizedBox()),
                          Expanded(flex: 150, child: SizedBox()),
                        ],
                      ],
                    ),
                  ),

                InvestmentActivityItem(:final activity) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: activity.isTrade
                      ? TradeItemPair(
                          tradeId: activity.id,
                          soldAmount: item.soldAmount ?? '',
                          soldSymbol: item.soldSymbol ?? '???',
                          soldPrice: item.soldPrice ?? '',
                          soldPriceSymbol: CurrencyService.instance.portfolioCode,
                          soldTotal: item.soldTotal ?? '',
                          soldTotalSymbol: CurrencyService.instance.portfolioCode,
                          boughtAmount: item.boughtAmount ?? '',
                          boughtSymbol: item.boughtSymbol ?? '???',
                          boughtPrice: item.boughtPrice ?? '',
                          boughtPriceSymbol: CurrencyService.instance.portfolioCode,
                          boughtTotal: item.boughtTotal ?? '',
                          boughtTotalSymbol: CurrencyService.instance.portfolioCode,
                          isSelected: selectedIds.contains(activity.id),
                          onSelect: (id) {
                            setState(() {
                              if (selectedIds.contains(id)) {
                                selectedIds.remove(id);
                              } else {
                                selectedIds.add(id);
                              }
                              _updateSelectionMode(selectedIds.isNotEmpty);
                            });
                          },
                          onDelete: (id) {
                            controller.deleteTrades([id]);
                          },
                          isSelectionMode: selectedIds.isNotEmpty,
                        )
                      : TransactionItem(
                          activity: activity,
                          symbol: item.transactionSymbol ?? '???',
                          isSelected: selectedIds.contains(activity.id),
                          onSelect: (id) {
                            setState(() {
                              if (selectedIds.contains(id)) {
                                selectedIds.remove(id);
                              } else {
                                selectedIds.add(id);
                              }
                              _updateSelectionMode(selectedIds.isNotEmpty);
                            });
                          },
                          onDelete: (id) {
                            controller.deleteTrades([id]);
                          },
                          isSelectionMode: selectedIds.isNotEmpty,
                        ),
                ),

                InvestmentSpacerItem() => const SizedBox.shrink(),
              };
            },
          );
        }),
      ],
    );
  }
}
