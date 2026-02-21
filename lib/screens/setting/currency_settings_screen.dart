import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_currencies.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/services/currency_service.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

enum CurrencyType { cashflow, portfolio }

class CurrencySettingsScreen extends StatefulWidget {
  final CurrencyType currencyType;

  const CurrencySettingsScreen({super.key, required this.currencyType});

  @override
  State<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends State<CurrencySettingsScreen> {
  AppCurrency? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _loadCurrentCurrency();
  }

  Future<void> _loadCurrentCurrency() async {
    AppCurrency? current;
    if (widget.currencyType == CurrencyType.cashflow) {
      current = await CurrencyService.instance.getCashflowCurrency();
    } else {
      current = await CurrencyService.instance.getPortfolioCurrency();
    }
    if (mounted) {
      setState(() {
        _selectedCurrency = current;
      });
    }
  }

  Future<void> _onCurrencyChanged(AppCurrency currency) async {
    setState(() {
      _selectedCurrency = currency;
    });

    if (widget.currencyType == CurrencyType.cashflow) {
      await CurrencyService.instance.setCashflowCurrency(currency);
    } else {
      await CurrencyService.instance.setPortfolioCurrency(currency);
    }
  }

  String get _title {
    return widget.currencyType == CurrencyType.cashflow
        ? 'Cashflow Currency'
        : 'Investment Currency';
  }

  String get _emoji {
    return widget.currencyType == CurrencyType.cashflow ? '💸' : '📈';
  }

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UiController>();

    return Scaffold(
      backgroundColor: Color(0xffDEEDFF),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomText(_emoji, size: 18.sp),
            8.horizontalSpace,
            CustomText(
              _title,
              size: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            35.horizontalSpace,
          ],
        ),
        centerTitle: true,
        backgroundColor: uiController.currentMainColor,
        foregroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
        child: Column(
          children: [
            CustomText(
              'this only changes the Symbol and does not convert amounts',
              size: 16.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              textAlign: TextAlign.center,
            ),
            30.verticalSpace,
            IntrinsicWidth(
              child: Container(
                height: 45.h,
                padding: EdgeInsets.symmetric(horizontal: 7.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.greyBorder),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      'Currency',
                      size: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.greyColor,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<AppCurrency>(
                        value: _selectedCurrency,
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
                        items: AppCurrencies.all.map((currency) {
                          return DropdownMenuItem<AppCurrency>(
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
                        onChanged: (currency) {
                          if (currency != null) {
                            _onCurrencyChanged(currency);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
