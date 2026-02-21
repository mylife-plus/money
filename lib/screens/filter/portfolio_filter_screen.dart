import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/investment_model.dart';
import 'package:moneyapp/screens/home/investment_list_screen.dart';
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
  String selectedActivityType = 'Trades & Transaction'; // Default value
  List<Investment> selectedInvestments = [];
  late final InvestmentController controller;
  final TextEditingController minAmountController = TextEditingController();
  final TextEditingController maxAmountController = TextEditingController();

  // Dropdown options for activity types
  final List<String> activityTypeOptions = [
    'Trades & Transaction',
    'Trade',
    'Transaction',
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.find<InvestmentController>();

    // Load current filter state from controller
    fromDate = controller.filterFromDate.value;
    toDate = controller.filterToDate.value;
    selectedActivityType = controller.filterActivityType.value;

    // Load selected investments
    if (controller.filterInvestmentIds.isNotEmpty) {
      selectedInvestments = controller.investments
          .where(
            (inv) =>
                inv.id != null &&
                controller.filterInvestmentIds.contains(inv.id),
          )
          .toList();
    }

    // Load min/max amount
    if (controller.filterMinAmount.value != null) {
      minAmountController.text = controller.filterMinAmount.value.toString();
    }
    if (controller.filterMaxAmount.value != null) {
      maxAmountController.text = controller.filterMaxAmount.value.toString();
    }
  }

  @override
  void dispose() {
    minAmountController.dispose();
    maxAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickFromDate(BuildContext context) async {
    final picked = await DatePickerHelper.showStyledDatePicker(
      context,
      initialDate: fromDate,
      firstDate: DateTime(1900),
      lastDate: toDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        fromDate = picked;
        // Validate: if toDate is before fromDate, reset toDate
        if (toDate != null && toDate!.isBefore(picked)) {
          toDate = null;
        }
      });
    }
  }

  Future<void> _pickToDate(BuildContext context) async {
    final picked = await DatePickerHelper.showStyledDatePicker(
      context,
      initialDate: toDate,
      firstDate: fromDate ?? DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        toDate = picked;
      });
    }
  }

  Future<void> _navigateToInvestmentScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InvestmentListScreen()),
    );

    if (result != null && result is Investment) {
      setState(() {
        // Add investment if not already selected
        if (!selectedInvestments.any((inv) => inv.id == result.id)) {
          selectedInvestments.add(result);
        }
      });
    }
  }

  void _applyFilter() {
    // Validate dates
    if (fromDate != null && toDate != null && toDate!.isBefore(fromDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"To Date" cannot be before "From Date"'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Parse and validate amounts (handle both . and , as decimal separator)
    double? minAmount;
    double? maxAmount;

    if (minAmountController.text.trim().isNotEmpty) {
      minAmount = double.tryParse(
        minAmountController.text.trim().replaceAll(',', '.'),
      );
      if (minAmount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid min amount'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    if (maxAmountController.text.trim().isNotEmpty) {
      maxAmount = double.tryParse(
        maxAmountController.text.trim().replaceAll(',', '.'),
      );
      if (maxAmount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid max amount'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    // Validate amount range
    if (minAmount != null && maxAmount != null && maxAmount < minAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Max amount cannot be less than min amount'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Debug: Print filter values
    debugPrint('[PortfolioFilter] Applying filter:');
    debugPrint('  fromDate: $fromDate');
    debugPrint('  toDate: $toDate');
    debugPrint('  activityType: $selectedActivityType');
    debugPrint('  investmentIds: ${selectedInvestments.map((inv) => inv.id).toList()}');
    debugPrint('  minAmount: $minAmount');
    debugPrint('  maxAmount: $maxAmount');

    // Apply filter to controller
    controller.applyFilter(
      fromDate: fromDate,
      toDate: toDate,
      activityType: selectedActivityType,
      investmentIds: selectedInvestments.map((inv) => inv.id!).toList(),
      minAmount: minAmount,
      maxAmount: maxAmount,
    );

    // Manually trigger update of visible activities immediately
    controller.forceUpdateVisibleActivities();

    // Navigate back
    Navigator.of(context).pop();

    // Show success message (this will appear on the previous screen)
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
      selectedActivityType = 'Trades & Transaction';
      selectedInvestments.clear();
      minAmountController.clear();
      maxAmountController.clear();
    });

    // Reset controller filters
    controller.resetFilters();
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
                                  value: selectedActivityType,
                                  isExpanded: true,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.black,
                                  ),
                                  items: activityTypeOptions.map((
                                    String value,
                                  ) {
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
                                        selectedActivityType = newValue;
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
                                  if (investment.imagePath.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(2.r),
                                      child: Image.file(
                                        File(investment.imagePath),
                                        width: 16.r,
                                        height: 16.r,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                width: 16.r,
                                                height: 16.r,
                                                color: investment.color,
                                              );
                                            },
                                      ),
                                    ),
                                  6.horizontalSpace,
                                  CustomText(investment.ticker, size: 14.sp),
                                  6.horizontalSpace,
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectedInvestments.removeWhere(
                                          (item) => item.id == investment.id,
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

                      7.verticalSpace,

                      // Min and Max amount filters
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
                              child: TextField(
                                controller: minAmountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'min amount',
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 20.w,
                                    minHeight: 20.h,
                                  ),
                                  prefixIcon: Image.asset(
                                    AppIcons.receipt,
                                    height: 20.r,
                                    width: 20.r,
                                    color: AppColors.greyColor,
                                  ),
                                  labelStyle: TextStyle(
                                    color: AppColors.greyColor,
                                    fontSize: 16.sp,
                                  ),
                                  hintStyle: TextStyle(
                                    color: AppColors.greyColor,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black,
                                ),
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
                              child: TextField(
                                controller: maxAmountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  prefixIconConstraints: BoxConstraints(
                                    minWidth: 20.w,
                                    minHeight: 20.h,
                                  ),
                                  prefixIcon: Image.asset(
                                    AppIcons.receipt,
                                    height: 20.r,
                                    width: 20.r,
                                    color: AppColors.greyColor,
                                  ),
                                  border: InputBorder.none,
                                  labelText: 'max amount',
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  labelStyle: TextStyle(
                                    color: AppColors.greyColor,
                                    fontSize: 16.sp,
                                  ),
                                  hintStyle: TextStyle(
                                    color: AppColors.greyColor,
                                    fontSize: 16.sp,
                                  ),
                                ),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

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
