import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/investment_model.dart';
import 'package:moneyapp/models/investment_activity_model.dart';
import 'package:moneyapp/constants/app_currencies.dart';
import 'package:moneyapp/services/currency_service.dart';
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
  bool _isSaving = false;
  bool _hasPortfolioCurrency = false;
  AppCurrency? _selectedPortfolioCurrency;

  // Selected investment references
  Investment? _soldInvestment;
  Investment? _boughtInvestment;
  Investment? _transactionInvestment;

  final InvestmentController _controller = Get.find<InvestmentController>();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _loadPortfolioCurrency();

    // Listen for investment changes and update references
    ever(_controller.investments, (_) {
      _updateInvestmentReferences();
    });
  }

  Future<void> _loadPortfolioCurrency() async {
    final has = await CurrencyService.instance.hasPortfolioCurrency();
    if (mounted) {
      setState(() {
        _hasPortfolioCurrency = has;
      });
    }
  }

  Future<void> _confirmPortfolioCurrency() async {
    if (_selectedPortfolioCurrency == null) return;
    await CurrencyService.instance.setPortfolioCurrency(
      _selectedPortfolioCurrency!,
    );
    setState(() {
      _hasPortfolioCurrency = true;
    });
  }

  /// Update investment references when investments list changes
  void _updateInvestmentReferences() {
    if (_soldInvestment != null) {
      final updated = _controller.getInvestmentById(_soldInvestment!.id!);
      if (updated != null) {
        setState(() {
          _soldInvestment = updated;
          _soldInvestmentController.text = updated.ticker;
        });
      }
    }

    if (_boughtInvestment != null) {
      final updated = _controller.getInvestmentById(_boughtInvestment!.id!);
      if (updated != null) {
        setState(() {
          _boughtInvestment = updated;
          _boughtInvestmentController.text = updated.ticker;
        });
      }
    }

    if (_transactionInvestment != null) {
      final updated = _controller.getInvestmentById(
        _transactionInvestment!.id!,
      );
      if (updated != null) {
        setState(() {
          _transactionInvestment = updated;
          _transactionInvestmentController.text = updated.ticker;
        });
      }
    }
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

  // Calculation helper methods
  bool _isUpdating = false; // Prevent infinite loops during calculations

  void _calculateTotalFromAmountPrice(
    TextEditingController amountController,
    TextEditingController priceController,
    TextEditingController totalController,
  ) {
    if (_isUpdating) return;
    _isUpdating = true;

    final amount = double.tryParse(amountController.text);
    final price = double.tryParse(priceController.text);

    if (amount != null && price != null) {
      final total = amount * price;
      totalController.text = total.toStringAsFixed(2);
    }

    _isUpdating = false;
  }

  void _calculatePriceFromTotalAmount(
    TextEditingController totalController,
    TextEditingController amountController,
    TextEditingController priceController,
  ) {
    if (_isUpdating) return;
    _isUpdating = true;

    final total = double.tryParse(totalController.text);
    final amount = double.tryParse(amountController.text);

    if (total != null && amount != null && amount != 0) {
      final price = total / amount;
      priceController.text = price.toStringAsFixed(2);
    }

    _isUpdating = false;
  }

  void _calculateAmountFromTotalPrice(
    TextEditingController totalController,
    TextEditingController priceController,
    TextEditingController amountController,
  ) {
    if (_isUpdating) return;
    _isUpdating = true;

    final total = double.tryParse(totalController.text);
    final price = double.tryParse(priceController.text);

    if (total != null && price != null && price != 0) {
      final amount = total / price;
      amountController.text = amount
          .toStringAsFixed(8)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }

    _isUpdating = false;
  }

  void _showSnackbar(String title, String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(message, style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveTrade() async {
    if (_soldInvestment == null || _boughtInvestment == null) {
      _showSnackbar('Error', 'Please select both sold and bought investments');
      return;
    }

    final soldAmount = double.tryParse(_soldAmountController.text);
    final soldPrice = double.tryParse(_soldPriceController.text);
    final soldTotal = double.tryParse(_soldTotalController.text);
    final boughtAmount = double.tryParse(_boughtAmountController.text);
    final boughtPrice = double.tryParse(_boughtPriceController.text);
    final boughtTotal = double.tryParse(_boughtTotalController.text);

    if (soldAmount == null ||
        soldPrice == null ||
        soldTotal == null ||
        boughtAmount == null ||
        boughtPrice == null ||
        boughtTotal == null) {
      _showSnackbar('Error', 'Please enter valid numbers for all fields');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final activity = await _controller.addTrade(
        soldInvestmentId: _soldInvestment!.id!,
        soldAmount: soldAmount,
        soldPrice: soldPrice,
        soldTotal: soldTotal,
        boughtInvestmentId: _boughtInvestment!.id!,
        boughtAmount: boughtAmount,
        boughtPrice: boughtPrice,
        boughtTotal: boughtTotal,
        date: selectedDate ?? DateTime.now(),
        description:
            'Traded ${_soldInvestment!.ticker} for ${_boughtInvestment!.ticker}',
      );

      if (activity != null) {
        _showSnackbar('Success', 'Trade added successfully', isError: false);
        if (mounted) Navigator.of(context).pop();
      } else {
        _showSnackbar('Error', 'Failed to add trade');
      }
    } catch (e) {
      _showSnackbar('Error', 'An error occurred: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveTransaction() async {
    if (_transactionInvestment == null) {
      _showSnackbar('Error', 'Please select an investment');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    final price = double.tryParse(_priceController.text);
    final total = double.tryParse(_totalController.text);

    if (amount == null || price == null || total == null) {
      _showSnackbar('Error', 'Please enter valid numbers for all fields');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final direction = isAddingInvestment
          ? TransactionDirection.deposit
          : TransactionDirection.withdraw;

      final activity = await _controller.addTransaction(
        investmentId: _transactionInvestment!.id!,
        direction: direction,
        amount: amount,
        price: price,
        total: total,
        date: selectedDate ?? DateTime.now(),
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : '${isAddingInvestment ? "Bought" : "Sold"} ${_transactionInvestment!.ticker}',
      );

      if (activity != null) {
        _showSnackbar(
          'Success',
          'Transaction added successfully',
          isError: false,
        );
        if (mounted) Navigator.of(context).pop();
      } else {
        _showSnackbar('Error', 'Failed to add transaction');
      }
    } catch (e) {
      _showSnackbar('Error', 'An error occurred: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget buildTextField(
    String label,
    String hint, {
    bool showCurrencySymbol = false,
    TextEditingController? controller,
    Function(String)? onChanged,
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
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          labelText: label,
          suffixText: showCurrencySymbol
              ? CurrencyService.instance.portfolioCode
              : null,
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
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset(
                      AppIcons.backArrow,
                      width: 21.h,
                      height: 21.h,
                    ),
                  ),
                  CustomText(
                    selectedOption == 1 ? 'New Trade' : 'Transaction',
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
                        if ((selectedOption != 1 ||
                                _controller.transactionsOnly.isNotEmpty) &&
                            (selectedOption != 2 || _hasPortfolioCurrency))
                          Center(
                            child: Container(
                              height: 41.h,
                              width: 109.w,
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
                                controller: TextEditingController(
                                  text: selectedDate != null
                                      ? DateFormat(
                                          'dd.MM.yyyy',
                                        ).format(selectedDate!)
                                      : '',
                                ),
                                readOnly: true,
                                onTap: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate ?? DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: AppColors.primary,
                                            onPrimary: Colors.black,
                                            surface: AppColors.background,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.black,
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      selectedDate = picked;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Select Date',
                                  labelText: 'Date',
                                  labelStyle: TextStyle(
                                    color: AppColors.greyColor,
                                    fontSize: 16.sp,
                                  ),
                                  hintStyle: TextStyle(
                                    color: AppColors.greyColor,
                                    fontSize: 16.sp,
                                  ),
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: TextStyle(fontSize: 16.sp),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                        16.verticalSpace,
                        if (selectedOption == 1) ...[
                          // Trade Section
                          if (_controller.transactionsOnly.isEmpty) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 40.h,
                              ),
                              child: CustomText(
                                'you need to make a deposit first before being able to trade',
                                size: 20.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ] else
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        'sold',
                                        color: Color(0xffFF0000),
                                        size: 16.sp,
                                      ),
                                      7.verticalSpace,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: InvestmentSelectorButton(
                                              controller:
                                                  _soldInvestmentController,
                                              hintText: 'select',
                                              onSelected: (investment) {
                                                _soldInvestment = investment;
                                                _soldInvestmentController.text =
                                                    investment.ticker;
                                              },
                                            ),
                                          ),
                                          4.horizontalSpace,

                                          Expanded(
                                            child: buildTextField(
                                              'Amount',
                                              '0',
                                              controller: _soldAmountController,
                                              onChanged: (value) {
                                                _calculateTotalFromAmountPrice(
                                                  _soldAmountController,
                                                  _soldPriceController,
                                                  _soldTotalController,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      7.verticalSpace,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: buildTextField(
                                              'Price',
                                              '0',
                                              showCurrencySymbol: true,
                                              controller: _soldPriceController,
                                              onChanged: (value) {
                                                _calculateTotalFromAmountPrice(
                                                  _soldAmountController,
                                                  _soldPriceController,
                                                  _soldTotalController,
                                                );
                                              },
                                            ),
                                          ),
                                          4.horizontalSpace,
                                          Expanded(
                                            child: buildTextField(
                                              'Total',
                                              '0',
                                              showCurrencySymbol: true,
                                              controller: _soldTotalController,
                                              onChanged: (value) {
                                                final amount = double.tryParse(
                                                  _soldAmountController.text,
                                                );
                                                final price = double.tryParse(
                                                  _soldPriceController.text,
                                                );

                                                if (amount != null &&
                                                    amount != 0) {
                                                  _calculatePriceFromTotalAmount(
                                                    _soldTotalController,
                                                    _soldAmountController,
                                                    _soldPriceController,
                                                  );
                                                } else if (price != null &&
                                                    price != 0) {
                                                  _calculateAmountFromTotalPrice(
                                                    _soldTotalController,
                                                    _soldPriceController,
                                                    _soldAmountController,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      7.verticalSpace,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        'bought',
                                        color: Color(0xff00C00D),
                                        size: 16.sp,
                                      ),
                                      7.verticalSpace,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: InvestmentSelectorButton(
                                              controller:
                                                  _boughtInvestmentController,
                                              hintText: 'select',
                                              onSelected: (investment) {
                                                _boughtInvestment = investment;
                                                _boughtInvestmentController
                                                        .text =
                                                    investment.ticker;
                                              },
                                            ),
                                          ),
                                          4.horizontalSpace,

                                          Expanded(
                                            child: buildTextField(
                                              'Amount',
                                              '0',
                                              controller:
                                                  _boughtAmountController,
                                              onChanged: (value) {
                                                _calculateTotalFromAmountPrice(
                                                  _boughtAmountController,
                                                  _boughtPriceController,
                                                  _boughtTotalController,
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      7.verticalSpace,
                                      Row(
                                        children: [
                                          Expanded(
                                            child: buildTextField(
                                              'Price',
                                              '0',
                                              showCurrencySymbol: true,
                                              controller:
                                                  _boughtPriceController,
                                              onChanged: (value) {
                                                _calculateTotalFromAmountPrice(
                                                  _boughtAmountController,
                                                  _boughtPriceController,
                                                  _boughtTotalController,
                                                );
                                              },
                                            ),
                                          ),
                                          4.horizontalSpace,
                                          Expanded(
                                            child: buildTextField(
                                              'Total',
                                              '0',
                                              showCurrencySymbol: true,
                                              controller:
                                                  _boughtTotalController,
                                              onChanged: (value) {
                                                final amount = double.tryParse(
                                                  _boughtAmountController.text,
                                                );
                                                final price = double.tryParse(
                                                  _boughtPriceController.text,
                                                );

                                                if (amount != null &&
                                                    amount != 0) {
                                                  _calculatePriceFromTotalAmount(
                                                    _boughtTotalController,
                                                    _boughtAmountController,
                                                    _boughtPriceController,
                                                  );
                                                } else if (price != null &&
                                                    price != 0) {
                                                  _calculateAmountFromTotalPrice(
                                                    _boughtTotalController,
                                                    _boughtPriceController,
                                                    _boughtAmountController,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      7.verticalSpace,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ] else if (selectedOption == 2) ...[
                          // Portfolio currency selection (one-time)
                          if (!_hasPortfolioCurrency) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 20.h,
                              ),
                              child: CustomText(
                                'select the Currency for all future Trades & Transactions',
                                size: 20.sp,
                                color: AppColors.greyColor,
                                fontWeight: FontWeight.w400,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            20.verticalSpace,
                            Center(
                              child: IntrinsicWidth(
                                child: Container(
                                  height: 45.h,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 7.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: AppColors.greyBorder,
                                    ),
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        'Currency',
                                        size: 12.sp,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.greyColor,
                                      ),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton<AppCurrency>(
                                          value: _selectedPortfolioCurrency,
                                          hint: Text('Select Currency'),
                                          isExpanded: false,
                                          isDense: true,
                                          menuMaxHeight: 400.h,
                                          icon: Padding(
                                            padding: EdgeInsets.only(left: 8.w),
                                            child: Image.asset(
                                              AppIcons.arrowDown,
                                              width: 16.r,
                                              height: 16.r,
                                              color: AppColors.greyColor,
                                            ),
                                          ),
                                          items: AppCurrencies.all.map((
                                            currency,
                                          ) {
                                            return DropdownMenuItem<
                                              AppCurrency
                                            >(
                                              value: currency,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CustomText(
                                                    currency.name,
                                                    size: 16.sp,
                                                    color: Colors.black,
                                                  ),
                                                  6.horizontalSpace,
                                                  CustomText(
                                                    currency.symbol,
                                                    size: 16.sp,
                                                    color: AppColors.greyColor,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedPortfolioCurrency =
                                                  value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            20.verticalSpace,
                            AnimatedOpacity(
                              opacity: _selectedPortfolioCurrency != null
                                  ? 1.0
                                  : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: IgnorePointer(
                                ignoring: _selectedPortfolioCurrency == null,
                                child: InkWell(
                                  onTap: _confirmPortfolioCurrency,
                                  child: Container(
                                    width: 120.w,
                                    height: 41.h,
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
                                      child: Text(
                                        'Confirm',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: Color(0xff0071FF),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ] else
                            // Transaction Section
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 15.w,
                                vertical: 6.h,
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
                                            ? 'Deposit'
                                            : 'Withdraw',
                                        size: 16.sp,
                                        color: isAddingInvestment
                                            ? Color(0xff00C00D)
                                            : Color(0xffFF0000),
                                      ),
                                    ],
                                  ),
                                  7.verticalSpace,
                                  buildDescriptionField(),
                                  7.verticalSpace,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InvestmentSelectorButton(
                                          controller:
                                              _transactionInvestmentController,
                                          hintText: 'select',
                                          onSelected: (investment) {
                                            _transactionInvestment = investment;
                                            _transactionInvestmentController
                                                    .text =
                                                investment.ticker;
                                          },
                                        ),
                                      ),
                                      4.horizontalSpace,
                                      Expanded(
                                        child: buildTextField(
                                          'Amount',
                                          '0.00',
                                          showCurrencySymbol: false,
                                          controller: _amountController,
                                          onChanged: (value) {
                                            _calculateTotalFromAmountPrice(
                                              _amountController,
                                              _priceController,
                                              _totalController,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  7.verticalSpace,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: buildTextField(
                                          'Price',
                                          '0.00',
                                          showCurrencySymbol: true,
                                          controller: _priceController,
                                          onChanged: (value) {
                                            _calculateTotalFromAmountPrice(
                                              _amountController,
                                              _priceController,
                                              _totalController,
                                            );
                                          },
                                        ),
                                      ),
                                      4.horizontalSpace,
                                      Expanded(
                                        child: buildTextField(
                                          'Total',
                                          '0.00',
                                          showCurrencySymbol: true,
                                          controller: _totalController,
                                          onChanged: (value) {
                                            // When total changes, try to calculate amount or price
                                            final amount = double.tryParse(
                                              _amountController.text,
                                            );
                                            final price = double.tryParse(
                                              _priceController.text,
                                            );

                                            if (amount != null && amount != 0) {
                                              // Calculate price from total and amount
                                              _calculatePriceFromTotalAmount(
                                                _totalController,
                                                _amountController,
                                                _priceController,
                                              );
                                            } else if (price != null &&
                                                price != 0) {
                                              // Calculate amount from total and price
                                              _calculateAmountFromTotalPrice(
                                                _totalController,
                                                _priceController,
                                                _amountController,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  7.verticalSpace,
                                ],
                              ),
                            ),
                        ],
                        if (!(selectedOption == 1 &&
                                _controller.transactionsOnly.isEmpty) &&
                            !(selectedOption == 2 &&
                                !_hasPortfolioCurrency)) ...[
                          40.verticalSpace,
                          InkWell(
                            onTap: _isSaving
                                ? null
                                : () {
                                    if (selectedOption == 1) {
                                      _saveTrade();
                                    } else {
                                      _saveTransaction();
                                    }
                                  },
                            child: Container(
                              width: 120.w,
                              height: 41.h,
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
                                child: _isSaving
                                    ? SizedBox(
                                        width: 20.r,
                                        height: 20.r,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xff0071FF),
                                        ),
                                      )
                                    : CustomText(
                                        'add',
                                        size: 16.sp,
                                        color: Color(0xff0071FF),
                                        fontWeight: FontWeight.w400,
                                      ),
                              ),
                            ),
                          ),
                        ],
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
