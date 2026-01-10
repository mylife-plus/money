import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/models/investment_recommendation.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/services/database/repositories/utils/date_picker_helper.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class PortfolioFilterScreen extends StatefulWidget {
  const PortfolioFilterScreen({super.key});

  @override
  State<PortfolioFilterScreen> createState() => _PortfolioFilterScreenState();
}

class _PortfolioFilterScreenState extends State<PortfolioFilterScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  String selectedTradeType = 'Trades & Transaction'; // Default value
  List<InvestmentRecommendation> selectedInvestments = [];

  // Dropdown options for trades/transactions
  final List<String> tradeTypeOptions = [
    'Trades & Transaction',
    'Trade',
    'Transaction',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickFromDate(BuildContext context) async {
    final picked = await DatePickerHelper.showStyledDatePicker(
      context,
      initialDate: fromDate,
      firstDate: DateTime(1900),
      lastDate: toDate,
    );

    if (picked != null) {
      setState(() {
        fromDate = picked;
      });
    }
  }

  Future<void> _pickToDate(BuildContext context) async {
    final picked = await DatePickerHelper.showStyledDatePicker(
      context,
      initialDate: toDate,
      firstDate: fromDate ?? DateTime(1900),
    );

    if (picked != null) {
      setState(() {
        toDate = picked;
      });
    }
  }

  Future<void> _navigateToInvestmentScreen() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.investmentList.path,
    );

    if (result != null && result is InvestmentRecommendation) {
      setState(() {
        if (!selectedInvestments.any((inv) => inv.text == result.text)) {
          selectedInvestments.add(result);
        }
      });
    }
  }

  void _applyFilter() {
    // TODO: Implement filter logic
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Success',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'Filter applied successfully',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _resetFilter() {
    setState(() {
      fromDate = null;
      toDate = null;
      selectedTradeType = 'Trades & Transaction';
      selectedInvestments.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset(
                      AppIcons.backArrow,
                      width: 21.h,
                      height: 21.h,
                    ),
                  ),
                  Image.asset(AppIcons.filter, height: 28.r, width: 28.r),
                  SizedBox(width: 21.w),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 33.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      12.verticalSpace,
                      // Date range filters
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 41.h,
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.greyBorder),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    AppIcons.dateIcon,
                                    height: 20.r,
                                    width: 20.r,
                                    color: AppColors.greyColor,
                                  ),
                                  10.horizontalSpace,
                                  Expanded(
                                    child: TextField(
                                      controller: TextEditingController(
                                        text: fromDate != null
                                            ? DateFormat(
                                                'dd.MM.yyyy',
                                              ).format(fromDate!)
                                            : '',
                                      ),
                                      readOnly: true,
                                      onTap: () => _pickFromDate(context),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'from date',
                                        labelText: fromDate != null
                                            ? 'From Date'
                                            : null,
                                        labelStyle: TextStyle(
                                          color: AppColors.greyColor,
                                          fontSize: 12.sp,
                                        ),
                                        hintStyle: TextStyle(
                                          color: AppColors.greyColor,
                                          fontSize: 16.sp,
                                        ),
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: Container(
                              height: 41.h,
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.greyBorder),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    AppIcons.dateIcon,
                                    height: 20.r,
                                    width: 20.r,
                                    color: AppColors.greyColor,
                                  ),
                                  10.horizontalSpace,
                                  Expanded(
                                    child: TextField(
                                      controller: TextEditingController(
                                        text: toDate != null
                                            ? DateFormat(
                                                'dd.MM.yyyy',
                                              ).format(toDate!)
                                            : '',
                                      ),
                                      readOnly: true,
                                      onTap: () => _pickToDate(context),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'to date',
                                        labelText: toDate != null
                                            ? 'To Date'
                                            : null,
                                        labelStyle: TextStyle(
                                          color: AppColors.greyColor,
                                          fontSize: 12.sp,
                                        ),
                                        hintStyle: TextStyle(
                                          color: AppColors.greyColor,
                                          fontSize: 16.sp,
                                        ),
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      7.verticalSpace,

                      // Trades & Transactions dropdown
                      Container(
                        height: 41.h,
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.greyBorder),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              AppIcons.bitcoinConvert,
                              height: 20.r,
                              width: 20.r,
                              color: AppColors.greyColor,
                            ),
                            11.horizontalSpace,
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedTradeType,
                                  isExpanded: true,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.black,
                                  ),
                                  items: tradeTypeOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: CustomText(
                                        value,
                                        size: 16.sp,
                                        color: Colors.black,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedTradeType = newValue;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      7.verticalSpace,

                      // Investments section (Navigate to investment screen)
                      InkWell(
                        onTap: _navigateToInvestmentScreen,
                        child: Container(
                          height: 41.h,
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.greyBorder),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                AppIcons.investment,
                                height: 20.r,
                                width: 20.r,
                              ),
                              11.horizontalSpace,
                              Expanded(
                                child: CustomText(
                                  selectedInvestments.isEmpty
                                      ? 'Investments'
                                      : '${selectedInvestments.length} Investment${selectedInvestments.length > 1 ? 's' : ''} selected',
                                  size: 16.sp,
                                  color: selectedInvestments.isEmpty
                                      ? AppColors.greyColor
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Display selected investments as chips
                      if (selectedInvestments.isNotEmpty) ...[
                        10.verticalSpace,
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: selectedInvestments.map((investment) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xffF5F5F5),
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(color: Color(0xffDFDFDF)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (investment.assetPath != null)
                                    Image.asset(
                                      investment.assetPath!,
                                      width: 16.r,
                                      height: 16.r,
                                    ),
                                  6.horizontalSpace,
                                  CustomText(investment.text, size: 14.sp),
                                  6.horizontalSpace,
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedInvestments.removeWhere(
                                          (item) =>
                                              item.text == investment.text,
                                        );
                                      });
                                    },
                                    child: Icon(
                                      Icons.close,
                                      size: 16.sp,
                                      color: Color(0xff707070),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      25.verticalSpace,
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _resetFilter,
                              child: Container(
                                height: 41.h,
                                width: 144.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(13.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 4.0,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CustomText(
                                    'reset',
                                    size: 16.sp,
                                    color: Color(0xffFF0000),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          22.horizontalSpace,
                          Expanded(
                            child: InkWell(
                              onTap: _applyFilter,
                              child: Container(
                                height: 41.h,
                                width: 144.w,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(13.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 4.0,
                                      offset: Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: CustomText(
                                    'filter',
                                    size: 16.sp,
                                    color: Color(0xff0071FF),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      25.verticalSpace,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
