import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
import 'package:moneyapp/widgets/common/custom_toggle_switch_small.dart';
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
  SortOption _selectedSortOption = SortOption.mostRecent;

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
                        setState(() {
                          Get.back();
                        });
                      },
                    ),
                  );
                },
                onEditMCC: () async {
                  await showDialog(
                    context: context,
                    builder: (context) => MCCSelectionDialog(
                      onSelected: (item) {
                        setState(() {
                          Get.back();
                        });
                      },
                    ),
                  );
                },
                onDelete: () {
                  // TODO: Implement delete for selected transactions
                  controller.deleteTransactions(selectedIds);
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
                        title: 'Transactions',
                        leadingIconPath: AppIcons.transaction,
                        actionIconPath: AppIcons.investment,
                        onActionIconTap: () {
                          Get.offNamed(AppRoutes.investment.path);
                        },
                      ),
                      4.verticalSpace,
                    ],
                  ),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Obx(() {
                  return Column(
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
                        _buildAverageContainer(controller.isExpenseSelected),
                        15.verticalSpace,
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 7.w),
                          padding: EdgeInsets.fromLTRB(5.w, 8.h, 13.w, 0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xffE3E3E3)),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          height: 227.h,
                          child: Column(
                            children: [
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceBetween,
                              //   children: [
                              //     Image.asset(
                              //       AppIcons.refresh,
                              //       height: 21.r,
                              //       width: 21.r,
                              //     ),

                              //     CustomToggleSwitchSmall(
                              //       option1Text: 'year',
                              //       option2Text: 'month',
                              //       backgroundColor:
                              //           controller.isExpenseSelected
                              //           ? const Color(0xffFFB2B2)
                              //           : const Color(0xffB1FFB6),
                              //       selectedOption: controller
                              //           .selectedChartDurationOption
                              //           .value,
                              //       onOption1Tap: controller.selectYear,
                              //       onOption2Tap: controller.selectMonth,
                              //     ),
                              //     CustomText(
                              //       '\$ 2,720',
                              //       size: 20.sp,
                              //       fontWeight: FontWeight.bold,
                              //       color: controller.isExpenseSelected
                              //           ? const Color(0xffFF0000)
                              //           : const Color(0xff00C00D),
                              //     ),
                              //     Padding(
                              //       padding: EdgeInsets.only(right: 15.w),
                              //       child: CustomText(
                              //         'Dez 2025',
                              //         size: 14.sp,
                              //         fontWeight: FontWeight.normal,
                              //         color: controller.isExpenseSelected
                              //             ? const Color(0xffFF0000)
                              //             : const Color(0xff00C00D),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              Expanded(
                                child: StepLineChartWidget(
                                  data: [
                                    ChartDataPoint(label: '2004', value: 2400),
                                    ChartDataPoint(label: '2007', value: 1800),
                                    ChartDataPoint(label: '2010', value: 1300),
                                    ChartDataPoint(label: '2013', value: 2100),
                                    ChartDataPoint(label: '2016', value: 2400),
                                    ChartDataPoint(label: '2019', value: 1700),
                                    ChartDataPoint(label: '2022', value: 2000),
                                    ChartDataPoint(label: '2025', value: 2700),
                                  ],
                                  lineColor: controller.isExpenseSelected
                                      ? const Color(0xffFF0000)
                                      : const Color(0xff00C00D),
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
                            children: [
                              for (var duration in [
                                '1m',
                                '2m',
                                '4m',
                                '6m',
                                '1y',
                                '2y',
                                'All',
                              ])
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: AppColors.greyColor,
                                    ),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: CustomText(
                                    duration,
                                    size: 16.sp,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        20.verticalSpace,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: CustomSlider(
                            min: 0,
                            max: 10000,
                            startValue: 2000,
                            endValue: 8000,
                            lineColor: controller.isExpenseSelected
                                ? const Color(0xffFF9494)
                                : const Color(0xff9DFFA3),
                            handleColor: const Color(0xFFFFE478),
                            onChanged: (start, end) {
                              print(
                                'Range: \$${start.toInt()} - \$${end.toInt()}',
                              );
                            },
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
                                    selectedOption: _selectedSortOption,
                                  );
                                  if (result != null) {
                                    setState(() {
                                      _selectedSortOption = result;
                                    });
                                    // TODO: Apply sorting logic
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
                                  Get.to(
                                    () => TransactionFilterScreen(),
                                    transition: Transition.upToDown,
                                  );
                                },
                                child: Image.asset(
                                  AppIcons.filter,
                                  height: 24.r,
                                  width: 24.r,
                                ),
                              ),
                              40.horizontalSpace,
                              InkWell(
                                onTap: () {
                                  Get.to(() => const TransactionSearchScreen());
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
                                  Get.toNamed(
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
                      // Hierarchical Year/Month/Transaction structure
                      Obx(() {
                        final years = controller.sortedYears;
                        return Column(
                          children: [
                            for (var year in years) ...[
                              // Year Row
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: InkWell(
                                  onTap: () =>
                                      controller.toggleYearExpansion(year),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
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
                                      CustomText(
                                        '€ ${controller.calculateYearTotal(year).abs().toStringAsFixed(2).replaceAll('.', ',')}',
                                        color: controller.isExpenseSelected
                                            ? const Color(0xffFF0000)
                                            : const Color(0xff00A40B),
                                        size: 16.sp,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Months (shown when year is expanded)
                              if (controller.isYearExpanded(year)) ...[
                                18.verticalSpace,
                                for (var month in controller.getSortedMonths(
                                  year,
                                )) ...[
                                  // Month Row
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15.w,
                                    ),
                                    child: InkWell(
                                      onTap: () => controller
                                          .toggleMonthExpansion(year, month),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CustomText(
                                                controller.getMonthName(month),
                                                color: AppColors.greyColor,
                                                size: 16.sp,
                                              ),
                                              5.horizontalSpace,
                                              Icon(
                                                controller.isMonthExpanded(
                                                      year,
                                                      month,
                                                    )
                                                    ? Icons
                                                          .arrow_drop_down_rounded
                                                    : Icons
                                                          .arrow_drop_up_rounded,
                                                size: 32.r,
                                                color: AppColors.greyColor,
                                              ),
                                            ],
                                          ),
                                          CustomText(
                                            '€ ${controller.calculateMonthTotal(year, month).abs().toStringAsFixed(2).replaceAll('.', ',')}',
                                            color: controller.isExpenseSelected
                                                ? const Color(0xffFF0000)
                                                : const Color(0xff00A40B),
                                            size: 16.sp,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Transactions (shown when month is expanded)
                                  if (controller.isMonthExpanded(
                                    year,
                                    month,
                                  )) ...[
                                    13.verticalSpace,
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                      ),
                                      child: Column(
                                        spacing: 4.h,
                                        children: [
                                          for (var transaction
                                              in controller
                                                  .getTransactionsForMonth(
                                                    year,
                                                    month,
                                                  ))
                                            if (transaction.id != null)
                                              TransactionItem(
                                                transaction: transaction,
                                                isSelected: selectedIds
                                                    .contains(transaction.id),
                                                onSelect: (id) {
                                                  setState(() {
                                                    if (selectedIds.contains(
                                                      id,
                                                    )) {
                                                      selectedIds.remove(id);
                                                    } else {
                                                      selectedIds.add(id);
                                                    }
                                                  });
                                                },
                                                isSelectionMode:
                                                    selectedIds.isNotEmpty,
                                              ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  18.verticalSpace,
                                ],
                              ],

                              if (year != years.last) 18.verticalSpace,
                            ],
                          ],
                        );
                      }),
                      150.verticalSpace,
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageContainer(bool isExpense) {
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
                        '12,000',
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
                        '1,000',
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
                      CustomText.span('30', color: Colors.black, size: 16.sp),
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
