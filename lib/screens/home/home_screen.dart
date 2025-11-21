import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/home_controller.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/widgets/charts/step_line_chart.dart';
import 'package:moneyapp/widgets/common/custom_app_bar.dart';
import 'package:moneyapp/widgets/common/custom_slider.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/common/custom_toggle_switch.dart';
import 'package:moneyapp/widgets/common/custom_toggle_switch_small.dart';
import 'package:moneyapp/widgets/common/filter_top_sheet.dart';
import 'package:moneyapp/widgets/transactions/new_transaction_content.dart';
import 'package:moneyapp/widgets/transactions/top_transaction_sheet.dart';
import 'package:moneyapp/widgets/transactions/transaction_item.dart';

/// Home Screen
/// Main landing screen of the app
class HomeScreen extends GetView<HomeController> {
  HomeScreen({super.key});
  List<String> selectedIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Transactions',
              leadingIconPath: AppIcons.transaction,
              actionIconPath: AppIcons.investment,
              onActionIconTap: () {
                Get.offNamed(AppRoutes.investment.path);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        27.verticalSpace,
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

                        Obx(() {
                          return Column(
                            children: [
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
                                        ? Color(0xffFF0000)
                                        : Color(0xff00C00D),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  CustomText.span(
                                    'per',
                                    size: 14.sp,
                                    color: Color(0xffA5A5A5),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ],
                              ),
                              15.verticalSpace,
                              _buildAverageContainer(
                                controller.isExpenseSelected,
                              ),
                              15.verticalSpace,
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 7.w),
                                padding: EdgeInsets.fromLTRB(13, 8, 0, 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Color(0xffE3E3E3)),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                height: 227.h,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                          AppIcons.refresh,
                                          height: 21.r,
                                          width: 21.r,
                                        ),

                                        CustomToggleSwitchSmall(
                                          option1Text: 'year',
                                          option2Text: 'month',
                                          backgroundColor:
                                              controller.isExpenseSelected
                                              ? Color(0xffFFB2B2)
                                              : Color(0xffB1FFB6),
                                          selectedOption: controller
                                              .selectedChartDurationOption
                                              .value,
                                          onOption1Tap: controller.selectYear,
                                          onOption2Tap: controller.selectMonth,
                                        ),
                                        CustomText(
                                          '\$ 2,720',
                                          size: 20.sp,
                                          fontWeight: FontWeight.bold,
                                          color: controller.isExpenseSelected
                                              ? Color(0xffFF0000)
                                              : Color(0xff00C00D),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(right: 15.w),
                                          child: CustomText(
                                            'Dez 2025',
                                            size: 14.sp,
                                            fontWeight: FontWeight.normal,
                                            color: controller.isExpenseSelected
                                                ? Color(0xffFF0000)
                                                : Color(0xff00C00D),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Expanded(
                                      child: StepLineChartWidget(
                                        data: [
                                          ChartDataPoint(
                                            label: '2004',
                                            value: 2400,
                                          ),
                                          ChartDataPoint(
                                            label: '2007',
                                            value: 1800,
                                          ),
                                          ChartDataPoint(
                                            label: '2010',
                                            value: 1300,
                                          ),
                                          ChartDataPoint(
                                            label: '2013',
                                            value: 2100,
                                          ),
                                          ChartDataPoint(
                                            label: '2016',
                                            value: 2400,
                                          ),
                                          ChartDataPoint(
                                            label: '2019',
                                            value: 1700,
                                          ),
                                          ChartDataPoint(
                                            label: '2022',
                                            value: 2000,
                                          ),
                                          ChartDataPoint(
                                            label: '2025',
                                            value: 2700,
                                          ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    for (var duration in [
                                      '1m',
                                      '2m',
                                      '4m',
                                      '6m',
                                      '1y',
                                      '2y',
                                      '4y',
                                    ])
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10.w,
                                          vertical: 5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Color(0xffDFDFDF),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                        ),
                                        child: CustomText(
                                          duration,
                                          size: 16.sp,
                                          color: Color(0xff8B8B8B),
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
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18.0.w,
                                ),
                                child: Row(
                                  children: [
                                    InkWell(
                                      child: Image.asset(
                                        AppIcons.sort,
                                        height: 24.r,
                                        width: 24.r,
                                      ),
                                    ),
                                    40.horizontalSpace,
                                    InkWell(
                                      onTap: () {
                                        FilterTopSheet.show(
                                          context: context,
                                          isOpenedFromMap: false,
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
                                      child: Image.asset(
                                        AppIcons.search,
                                        height: 24.r,
                                        width: 24.r,
                                      ),
                                    ),
                                    Spacer(),
                                    InkWell(
                                      onTap: () {
                                        TopTransactionSheet.show(
                                          context: context,
                                          title: 'new Transaction',
                                          child: NewTransactionContent(
                                            isExpenseSelected:
                                                controller.isExpenseSelected,
                                          ),
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
                              25.verticalSpace,
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      child: Row(
                                        children: [
                                          CustomText(
                                            '2024',
                                            color: Color(0xff707070),
                                            size: 16.sp,
                                          ),
                                          5.horizontalSpace,
                                          Icon(
                                            Icons.arrow_drop_down_rounded,
                                            size: 32.r,
                                            color: Color(0xff707070),
                                          ),
                                        ],
                                      ),
                                    ),
                                    CustomText(
                                      '€ 12.000,23',
                                      color: Color(0xffFF0000),
                                    ),
                                  ],
                                ),
                              ),
                              18.verticalSpace,
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      child: Row(
                                        children: [
                                          CustomText(
                                            'Dezember',
                                            color: Color(0xff707070),
                                            size: 16.sp,
                                          ),
                                          5.horizontalSpace,
                                          Icon(
                                            Icons.arrow_drop_down_rounded,
                                            size: 32.r,
                                            color: Color(0xff707070),
                                          ),
                                        ],
                                      ),
                                    ),
                                    CustomText(
                                      '€ 1.220,33',
                                      color: Color(0xffFF0000),
                                    ),
                                  ],
                                ),
                              ),
                              13.verticalSpace,
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                child: Column(
                                  spacing: 4.h,
                                  children: [
                                    for (List<dynamic> entries in [
                                      ['1', '12.', '🏧 ATM', 2, '400,00'],
                                      ['2', '12.', '🏧 ATM', 1, '400,00'],
                                      ['3', '11.', '🛒 Aldi', 1, '400,00'],
                                    ])
                                      TransactionItem(
                                        id: entries[0],
                                        label: entries[1],
                                        title: entries[2],
                                        category: '${entries[3]}',
                                        isSelected: selectedIds.contains(
                                          entries[0],
                                        ),
                                        amount: entries[4],

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
                                  ],
                                ),
                              ),
                              if (selectedIds.isNotEmpty) ...[
                                56.verticalSpace,
                                CustomText(
                                  '${selectedIds.length} Selected',
                                  size: 20.sp,
                                  color: Color(0xff0088FF),
                                ),
                                16.verticalSpace,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.w,
                                      ),
                                      height: 44.h,

                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xffCFCFCF),
                                        ),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          13.r,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.25,
                                            ),
                                            blurRadius: 4.0,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: CustomText(
                                          'add #',
                                          size: 20.sp,
                                          color: Color(0xff0088FF),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.w,
                                      ),
                                      height: 44.h,

                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xffCFCFCF),
                                        ),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          13.r,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.25,
                                            ),
                                            blurRadius: 4.0,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: CustomText(
                                          'edit category',
                                          size: 20.sp,
                                          color: Color(0xff0071FF),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 14.w,
                                      ),
                                      height: 44.h,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Color(0xffCFCFCF),
                                        ),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          13.r,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.25,
                                            ),
                                            blurRadius: 4.0,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: CustomText(
                                          'delete',
                                          size: 20.sp,
                                          color: Color(0xffFF0000),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              150.verticalSpace,
                            ],
                          );
                        }),
                      ],
                    );
                  },
                ),
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
        color: Color(0xffdfdfdf),
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
