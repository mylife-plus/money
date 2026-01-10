import 'package:moneyapp/models/home_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/home_controller.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/screens/filter/transaction_filter_screen.dart';
import 'package:moneyapp/screens/transactions/transaction_search_screen.dart';
import 'package:moneyapp/widgets/charts/step_line_chart.dart';

import 'package:moneyapp/widgets/common/custom_app_bar.dart';
import 'package:moneyapp/widgets/common/custom_slider.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/common/custom_toggle_switch.dart';

import 'package:moneyapp/widgets/common/selection_app_bar.dart';
import 'package:moneyapp/widgets/hashtag/hashtag_selection_dialog.dart';
import 'package:moneyapp/widgets/mcc/mcc_selection_dialog.dart';
import 'package:moneyapp/widgets/transactions/transaction_item.dart';
import 'package:moneyapp/widgets/transactions/top_sort_sheet.dart';

/// Home Screen
/// Main landing screen of the app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _lastScrollOffset = 0;
  bool _isAppBarVisible = true;
  List<int> selectedIds = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final currentScrollOffset = _scrollController.offset;
    final scrollDelta = currentScrollOffset - _lastScrollOffset;

    // Scrolling down
    if (scrollDelta > 0 && _isAppBarVisible && currentScrollOffset > 50) {
      setState(() {
        _isAppBarVisible = false;
      });
      _animationController.reverse();
    }
    // Scrolling up
    else if (scrollDelta < 0 && !_isAppBarVisible) {
      setState(() {
        _isAppBarVisible = true;
      });
      _animationController.forward();
    }

    _lastScrollOffset = currentScrollOffset;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Show selection app bar or regular app bar based on selection mode
            if (selectedIds.isNotEmpty)
              SelectionAppBar(
                selectedCount: selectedIds.length,
                onCancel: () {
                  setState(() {
                    selectedIds.clear();
                  });
                },
                onAddHashtag: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => HashtagSelectionDialog(
                      onSelected: (hashtag) {
                        controller.updateTransactionsHashtag(
                          List.from(selectedIds),
                          hashtag,
                        );
                      },
                    ),
                  );
                },
                onEditMCC: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => MCCSelectionDialog(
                      onSelected: (item) {
                        controller.updateTransactionsMCC(
                          List.from(selectedIds),
                          item.id ?? 0,
                        );
                        setState(() {
                          selectedIds.clear();
                        });
                      },
                    ),
                  );
                },
                onDelete: () {
                  // TODO: Implement delete for selected transactions
                  controller.deleteTransactions(List.from(selectedIds));
                  setState(() {
                    selectedIds.clear();
                  });
                },
              )
            else
              SizeTransition(
                sizeFactor: _animation,
                child: FadeTransition(
                  opacity: _animation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomAppBar(
                        title: 'Cashflow',
                        leadingIconPath: AppIcons.transaction,
                        actionIconPath: AppIcons.investment,
                        onActionIconTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.investment.path,
                          );
                        },
                      ),
                      4.verticalSpace,
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.transactions.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          if (selectedIds.isEmpty) ...[
                            20.verticalSpace,
                            Obx(
                              () => CustomToggleSwitch(
                                option1IconPath: AppIcons.export,
                                option1Text: 'Spending',
                                option2IconPath: AppIcons.import,
                                option2Text: 'Income',
                                selectedOption:
                                    controller.selectedToggleOption.value,
                                onOption1Tap: controller.selectSpending,
                                onOption2Tap: controller.selectIncome,
                              ),
                            ),
                            26.verticalSpace,
                            CustomText.richText(
                              children: [
                                CustomText.span(
                                  'Average ',
                                  size: 14.sp,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w400,
                                ),
                                CustomText.span(
                                  controller.isExpenseSelected
                                      ? 'spending '
                                      : 'income ',
                                  size: 14.sp,
                                  color: controller.isExpenseSelected
                                      ? const Color(0xffFF0000)
                                      : const Color(0xff00C00D),
                                  fontWeight: FontWeight.w500,
                                ),
                                CustomText.span(
                                  'per',
                                  size: 14.sp,
                                  color: AppColors.greyColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ],
                            ),
                            15.verticalSpace,
                            _buildAverageContainer(controller),
                            15.verticalSpace,
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 7.w),
                              padding: EdgeInsets.fromLTRB(5.w, 8.h, 13.w, 0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xffE3E3E3),
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              height: 227.h,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: StepLineChartWidget(
                                      data: controller.chartData,
                                      lineColor: controller.isExpenseSelected
                                          ? const Color(0xffFF0000)
                                          : const Color(0xff00C00D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            20.verticalSpace,
                            Obx(
                              () => Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 7.w,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        for (var duration in [
                                          '1d',
                                          '2d',
                                          '3m',
                                          '1y',
                                          '5y',
                                          'All',
                                        ])
                                          InkWell(
                                            onTap: () => controller
                                                .updateDurationTab(duration),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10.w,
                                                vertical: 5.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                    controller
                                                            .selectedDurationTab
                                                            .value ==
                                                        duration
                                                    ? (controller
                                                              .isExpenseSelected
                                                          ? const Color(
                                                              0xffFF0000,
                                                            )
                                                          : const Color(
                                                              0xff00C00D,
                                                            ))
                                                    : Colors.white,
                                                border: Border.all(
                                                  color:
                                                      controller
                                                              .selectedDurationTab
                                                              .value ==
                                                          duration
                                                      ? Colors.transparent
                                                      : AppColors.greyColor,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                              ),
                                              child: CustomText(
                                                duration,
                                                size: 16.sp,
                                                color:
                                                    controller
                                                            .selectedDurationTab
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
                                  20.verticalSpace,
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                    ),
                                    child: Column(
                                      children: [
                                        CustomSlider(
                                          min: controller
                                              .sliderMinDate
                                              .millisecondsSinceEpoch
                                              .toDouble(),
                                          max: controller
                                              .sliderMaxDate
                                              .millisecondsSinceEpoch
                                              .toDouble(),
                                          startValue: controller
                                              .transactionDateStart
                                              .millisecondsSinceEpoch
                                              .toDouble(),
                                          endValue: controller
                                              .transactionDateEnd
                                              .millisecondsSinceEpoch
                                              .toDouble(),
                                          lineColor:
                                              controller.isExpenseSelected
                                              ? const Color(0xffFF9494)
                                              : const Color(0xff9DFFA3),
                                          handleColor: const Color(0xFFFFE478),
                                          onChanged: (start, end) {
                                            controller.updateDateRange(
                                              DateTime.fromMillisecondsSinceEpoch(
                                                start.toInt(),
                                              ),
                                              DateTime.fromMillisecondsSinceEpoch(
                                                end.toInt(),
                                              ),
                                            );
                                          },
                                        ),
                                        8.verticalSpace,
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomText(
                                              DateFormat('dd MMM yyyy').format(
                                                controller.transactionDateStart,
                                              ),
                                              size: 12.sp,
                                              color: AppColors.greyColor,
                                            ),
                                            CustomText(
                                              DateFormat('dd MMM yyyy').format(
                                                controller.transactionDateEnd,
                                              ),
                                              size: 12.sp,
                                              color: AppColors.greyColor,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            30.verticalSpace,
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.0.w),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      final result = await TopSortSheet.show(
                                        context: context,
                                        title: 'Sorting',
                                        selectedOption:
                                            controller.selectedSortOption.value,
                                      );
                                      if (result != null) {
                                        controller.updateSortOption(result);
                                      }
                                    },
                                    child: Image.asset(
                                      AppIcons.sort,
                                      height: 24.r,
                                      width: 24.r,
                                    ),
                                  ),
                                  40.horizontalSpace,
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const TransactionFilterScreen(),
                                          fullscreenDialog: true,
                                        ),
                                      );
                                    },
                                    child: Obx(
                                      () => Badge(
                                        isLabelVisible:
                                            controller.activeFilterCount > 0,
                                        label: Text(
                                          controller.activeFilterCount
                                              .toString(),
                                        ),
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
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const TransactionSearchScreen(),
                                        ),
                                      );
                                    },
                                    child: Image.asset(
                                      AppIcons.search,
                                      height: 24.r,
                                      width: 24.r,
                                    ),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.newTransaction.path,
                                        arguments: {
                                          'isExpenseSelected':
                                              controller.isExpenseSelected,
                                        },
                                      );
                                    },
                                    child: Image.asset(
                                      AppIcons.plus,
                                      height: 21.r,
                                      width: 21.r,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          25.verticalSpace,
                        ],
                      ),
                    ),
                    if (controller.visibleItems.length <= 1)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_rounded,
                              size: 64.r,
                              color: AppColors.greyColor.withValues(alpha: 0.5),
                            ),
                            16.verticalSpace,
                            CustomText(
                              'No transactions found',
                              size: 16.sp,
                              color: AppColors.greyColor,
                              fontWeight: FontWeight.w500,
                            ),
                            50.verticalSpace, // Visual balance
                          ],
                        ),
                      )
                    else
                      SliverList.builder(
                        itemCount: controller.visibleItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.visibleItems[index];

                          if (item is YearHeaderItem) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: InkWell(
                                onTap: () =>
                                    controller.toggleYearExpansion(item.year),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CustomText(
                                          item.year.toString(),
                                          color: AppColors.greyColor,
                                          size: 16.sp,
                                        ),
                                        5.horizontalSpace,
                                        Icon(
                                          item.isExpanded
                                              ? Icons.arrow_drop_down_rounded
                                              : Icons.arrow_drop_up_rounded,
                                          size: 32.r,
                                          color: AppColors.greyColor,
                                        ),
                                      ],
                                    ),
                                    CustomText(
                                      '€ ${item.totalAmount.abs().toStringAsFixed(2).replaceAll('.', ',')}',
                                      color: controller.isExpenseSelected
                                          ? const Color(0xffFF0000)
                                          : const Color(0xff00A40B),
                                      size: 16.sp,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (item is MonthHeaderItem) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: InkWell(
                                onTap: () => controller.toggleMonthExpansion(
                                  item.year,
                                  item.month,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CustomText(
                                          item.monthName,
                                          color: AppColors.greyColor,
                                          size: 16.sp,
                                        ),
                                        5.horizontalSpace,
                                        Icon(
                                          item.isExpanded
                                              ? Icons.arrow_drop_down_rounded
                                              : Icons.arrow_drop_up_rounded,
                                          size: 32.r,
                                          color: AppColors.greyColor,
                                        ),
                                      ],
                                    ),
                                    CustomText(
                                      '€ ${item.totalAmount.abs().toStringAsFixed(2).replaceAll('.', ',')}',
                                      color: controller.isExpenseSelected
                                          ? const Color(0xffFF0000)
                                          : const Color(0xff00A40B),
                                      size: 16.sp,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (item is TransactionListItem) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              child: TransactionItem(
                                transaction: item.transaction,
                                isSelected: selectedIds.contains(
                                  item.transaction.id,
                                ),
                                onSelect: (id) {
                                  setState(() {
                                    if (selectedIds.contains(id)) {
                                      selectedIds.remove(id);
                                    } else {
                                      selectedIds.add(id);
                                    }
                                  });
                                },
                                isSelectionMode: selectedIds.isNotEmpty,
                              ),
                            );
                          } else if (item is SpacerItem) {
                            return SizedBox(height: item.height);
                          }

                          return const SizedBox.shrink();
                        },
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageContainer(HomeController controller) {
    final isExpense = controller.isExpenseSelected;
    String format(double val) =>
        val.abs().toStringAsFixed(2).replaceAll('.', ',');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w),
      padding: EdgeInsets.all(2.r),
      height: 56.h,
      decoration: BoxDecoration(
        color: const Color(0xffdfdfdf),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isExpense
                    ? AppColors.expenseYearBackground
                    : AppColors.incomeYearBackground,
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(4.r),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomText(
                    'Year',
                    color: isExpense
                        ? AppColors.expenseYearText
                        : AppColors.incomeYearText,
                    size: 14.sp,
                  ),
                  CustomText.richText(
                    children: [
                      CustomText.span(
                        format(controller.averageYearly.value),
                        color: Colors.black,
                        size: 16.sp,
                      ),
                      CustomText.span(' '),
                      CustomText.span('EUR', color: Colors.black, size: 10.sp),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              decoration: BoxDecoration(
                color: isExpense
                    ? AppColors.expenseMonthBackground
                    : AppColors.incomeMonthBackground,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomText(
                    'Month',
                    color: isExpense
                        ? AppColors.expenseMonthText
                        : AppColors.incomeMonthText,
                    size: 14.sp,
                  ),
                  CustomText.richText(
                    children: [
                      CustomText.span(
                        format(controller.averageMonthly.value),
                        color: Colors.black,
                        size: 16.sp,
                      ),
                      CustomText.span(' '),
                      CustomText.span('EUR', color: Colors.black, size: 10.sp),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isExpense
                    ? AppColors.expenseDayBackground
                    : AppColors.incomeDayBackground,
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(4.r),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomText(
                    'Day',
                    color: isExpense
                        ? AppColors.expenseDayText
                        : AppColors.incomeDayText,
                    size: 14.sp,
                  ),
                  CustomText.richText(
                    children: [
                      CustomText.span(
                        format(controller.averageDaily.value),
                        color: Colors.black,
                        size: 16.sp,
                      ),
                      CustomText.span(' '),
                      CustomText.span('EUR', color: Colors.black, size: 10.sp),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
