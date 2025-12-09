import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/utils/date_picker_helper.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/investments/investment_selector_button.dart';
import 'package:moneyapp/widgets/trades/trade_transaction_toggle_switch_.dart';

class NewPortfolioChangeScreen extends StatefulWidget {
  const NewPortfolioChangeScreen({super.key});

  @override
  State<NewPortfolioChangeScreen> createState() =>
      _NewPortfolioChangeScreenState();
}

class _NewPortfolioChangeScreenState extends State<NewPortfolioChangeScreen> {
  DateTime? selectedDate;
  int selectedOption = 1; // 1 = Trade, 2 = Transaction

  // Trade controllers
  final TextEditingController _soldInvestmentController =
      TextEditingController();
  final TextEditingController _boughtInvestmentController =
      TextEditingController();
  final TextEditingController _soldAmountController = TextEditingController();
  final TextEditingController _boughtAmountController = TextEditingController();
  final TextEditingController _soldPriceController = TextEditingController();
  final TextEditingController _boughtPriceController = TextEditingController();
  final TextEditingController _soldTotalController = TextEditingController();
  final TextEditingController _boughtTotalController = TextEditingController();

  // Transaction controllers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _transactionInvestmentController =
      TextEditingController();

  bool isAddingInvestment = true; // For transaction type

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _soldInvestmentController.dispose();
    _boughtInvestmentController.dispose();
    _soldAmountController.dispose();
    _boughtAmountController.dispose();
    _soldPriceController.dispose();
    _boughtPriceController.dispose();
    _soldTotalController.dispose();
    _boughtTotalController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _priceController.dispose();
    _totalController.dispose();
    _transactionInvestmentController.dispose();
    super.dispose();
  }

  Widget buildTextField(
    String label,
    String hint, {
    bool showCurrencySymbol = false,
    TextEditingController? controller,
  }) {
    return Container(
      height: 41.h,
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.greyBorder),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.end,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          labelText: label,
          suffixText: showCurrencySymbol ? 'USD' : null,
          suffixStyle: TextStyle(color: AppColors.greyColor, fontSize: 16.sp),
          labelStyle: TextStyle(color: AppColors.greyColor, fontSize: 16.sp),
          hintStyle: TextStyle(color: AppColors.greyColor, fontSize: 16.sp),
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }

  Widget buildDescriptionField() {
    return Container(
      height: 41.h,
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.greyBorder),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: TextField(
        controller: _descriptionController,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '',
          labelText: 'Description',
          labelStyle: TextStyle(color: AppColors.greyColor, fontSize: 16.sp),
          hintStyle: TextStyle(color: AppColors.greyColor, fontSize: 16.sp),
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        style: TextStyle(fontSize: 16.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 18.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: Image.asset(
                      AppIcons.backArrow,
                      width: 21.h,
                      height: 21.h,
                    ),
                  ),
                  CustomText(
                    selectedOption == 1 ? 'New Trade' : 'New Transaction',
                    size: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  SizedBox(width: 21.w),
                ],
              ),
            ),
            // Toggle Switch
            TradeTransactionToggleSwitch(
              option1Text: 'Trade',
              option2Text: 'Transaction',
              selectedOption: selectedOption,
              onOption1Tap: () {
                setState(() {
                  selectedOption = 1;
                });
              },
              onOption2Tap: () {
                setState(() {
                  selectedOption = 2;
                });
              },
              backgroundColor: AppColors.primary,
            ),
            27.verticalSpace,
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 7.w),
                    child: Column(
                      children: [
                        Center(
                          child: InkWell(
                            onTap: () {
                              DatePickerHelper.showStyledDatePicker(
                                context,
                                initialDate: selectedDate,
                              ).then((pickedDate) {
                                if (pickedDate != null) {
                                  setState(() {
                                    selectedDate = pickedDate;
                                  });
                                }
                              });
                            },
                            child: Container(
                              // width: 100.w,
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.greyBorder),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    'Date',
                                    color: AppColors.greyColor,
                                    size: 12.sp,
                                  ),
                                  CustomText(
                                    selectedDate == null
                                        ? 'select Date'
                                        : DateFormat(
                                            'dd.MM.yyyy',
                                          ).format(selectedDate!),
                                    size: 20.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        16.verticalSpace,
                        if (selectedOption == 1) ...[
                          // Trade Section
                          Column(
                            children: [
                              // Sold item
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xffFFEFEF),
                                  border: Border.all(
                                    color: AppColors.greyBorder,
                                  ),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(4.r),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      'sold',
                                      color: Color(0xffFF0000),
                                      size: 16.sp,
                                    ),
                                    6.verticalSpace,
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildTextField(
                                            'Amount',
                                            '0',
                                            controller: _soldAmountController,
                                          ),
                                        ),
                                        4.horizontalSpace,
                                        Expanded(
                                          child: InvestmentSelectorButton(
                                            controller:
                                                _soldInvestmentController,
                                            hintText: 'select',
                                            onSelected: (value) {
                                              _soldInvestmentController.text =
                                                  value.text;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    6.verticalSpace,
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildTextField(
                                            'Price',
                                            '0',
                                            showCurrencySymbol: true,
                                            controller: _soldPriceController,
                                          ),
                                        ),
                                        4.horizontalSpace,
                                        Expanded(
                                          child: buildTextField(
                                            'Total',
                                            '0',
                                            showCurrencySymbol: true,
                                            controller: _soldTotalController,
                                          ),
                                        ),
                                      ],
                                    ),
                                    9.verticalSpace,
                                  ],
                                ),
                              ),
                              // Bought item
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xffE5FFE7),
                                  border: Border.all(
                                    color: AppColors.greyBorder,
                                  ),
                                  borderRadius: BorderRadius.vertical(
                                    bottom: Radius.circular(4.r),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      'bought',
                                      color: Color(0xff009E0B),
                                      size: 16.sp,
                                    ),
                                    6.verticalSpace,
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildTextField(
                                            'Amount',
                                            '0',
                                            controller: _boughtAmountController,
                                          ),
                                        ),
                                        4.horizontalSpace,
                                        Expanded(
                                          child: InvestmentSelectorButton(
                                            controller:
                                                _boughtInvestmentController,
                                            hintText: 'select',
                                            onSelected: (value) {
                                              _boughtInvestmentController.text =
                                                  value.text;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    6.verticalSpace,
                                    Row(
                                      children: [
                                        Expanded(
                                          child: buildTextField(
                                            'Price',
                                            '0',
                                            showCurrencySymbol: true,
                                            controller: _boughtPriceController,
                                          ),
                                        ),
                                        4.horizontalSpace,
                                        Expanded(
                                          child: buildTextField(
                                            'Total',
                                            '0',
                                            showCurrencySymbol: true,
                                            controller: _boughtTotalController,
                                          ),
                                        ),
                                      ],
                                    ),
                                    9.verticalSpace,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Transaction Section
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 5.h,
                            ),
                            decoration: BoxDecoration(
                              color: isAddingInvestment
                                  ? Color(0xffE5FFE5)
                                  : Color(0xffFFE5E5),
                              border: Border.all(color: AppColors.greyBorder),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          isAddingInvestment =
                                              !isAddingInvestment;
                                        });
                                      },
                                      child: Container(
                                        width: 24.r,
                                        height: 24.r,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            4.r,
                                          ),
                                          border: Border.all(
                                            color: AppColors.greyBorder,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.25,
                                              ),
                                              blurRadius: 4,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Image.asset(
                                            isAddingInvestment
                                                ? AppIcons.plus
                                                : AppIcons.minus,
                                            color: isAddingInvestment
                                                ? Color(0xff00C00D)
                                                : Color(0xffFF0000),
                                            width: 16.r,
                                            height: 16.r,
                                          ),
                                        ),
                                      ),
                                    ),
                                    10.horizontalSpace,
                                    CustomText(
                                      isAddingInvestment
                                          ? 'Income'
                                          : 'Spending',
                                      size: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      color: isAddingInvestment
                                          ? Color(0xff00C00D)
                                          : Color(0xffFF0000),
                                    ),
                                  ],
                                ),
                                6.verticalSpace,
                                buildDescriptionField(),
                                6.verticalSpace,
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildTextField(
                                        'Amount',
                                        '0.00',
                                        showCurrencySymbol: true,
                                        controller: _priceController,
                                      ),
                                    ),
                                    4.horizontalSpace,
                                    Expanded(
                                      child: InvestmentSelectorButton(
                                        controller:
                                            _transactionInvestmentController,
                                        hintText: 'select',
                                        onSelected: (value) {
                                          _transactionInvestmentController
                                                  .text =
                                              value.text;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                4.verticalSpace,
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildTextField(
                                        'Price',
                                        '0.00',
                                        showCurrencySymbol: true,
                                        controller: _priceController,
                                      ),
                                    ),
                                    4.horizontalSpace,
                                    Expanded(
                                      child: buildTextField(
                                        'Total',
                                        '0.00',
                                        showCurrencySymbol: true,
                                        controller: _totalController,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        40.verticalSpace,
                        InkWell(
                          onTap: () {
                            // TODO: Save logic
                            Get.back();
                          },
                          child: Container(
                            width: 136.w,
                            height: 44.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Center(
                              child: CustomText(
                                'add',
                                size: 20.sp,
                                color: Color(0xff0071FF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        40.verticalSpace,
                      ],
                    ),
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
