import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/home_controller.dart';
import 'package:moneyapp/widgets/custom_app_bar.dart';
import 'package:moneyapp/widgets/custom_text.dart';
import 'package:moneyapp/widgets/custom_toggle_switch.dart';

/// Home Screen
/// Main landing screen of the app
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

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
                // Handle investment icon tap
                Get.snackbar('Investment', 'Investment icon tapped');
              },
            ),
            27.verticalSpace,
            Obx(
              () => CustomToggleSwitch(
                option1IconPath: AppIcons.export,
                option1Text: 'Spending',
                option2IconPath: AppIcons.import,
                option2Text: 'Income',
                selectedOption: controller.selectedToggleOption.value,
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
                        controller.isExpenseSelected ? 'spending ' : 'income ',
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
                  _buildAverageContainer(controller.isExpenseSelected),
                  15.verticalSpace,
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 7.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    height: 383.h,
                    child: Center(
                      child: CustomText(
                        'Chart will be displayed here',
                        color: Colors.grey,
                        size: 14.sp,
                      ),
                    ),
                  ),
                  30.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.0.w),
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
                ],
              );
            }),
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
