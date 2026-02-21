import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_currencies.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/services/currency_service.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class CurrencySelectionScreen extends StatefulWidget {
  const CurrencySelectionScreen({super.key});

  @override
  State<CurrencySelectionScreen> createState() =>
      _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  AppCurrency? selectedCurrency;

  Future<void> _onConfirm() async {
    if (selectedCurrency == null) return;
    await CurrencyService.instance.setCashflowCurrency(selectedCurrency!);
    Get.offAllNamed(AppRoutes.home.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Title
              CustomText(
                'new Cashflow',
                size: 32.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary,
              ),

              30.verticalSpace,

              // Subtitle
              CustomText(
                'select the Currency for all',
                size: 20.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.greyColor,
              ),
              4.verticalSpace,
              CustomText(
                'future Cashflows',
                size: 20.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.greyColor,
              ),

              const Spacer(flex: 2),

              // Currency selector dropdown
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
                          hint: Text('Select Currency'),
                          value: selectedCurrency,
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
                          onChanged: (value) {
                            setState(() {
                              selectedCurrency = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              20.verticalSpace,

              // Confirm button
              AnimatedOpacity(
                opacity: selectedCurrency != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: selectedCurrency == null,
                  child: InkWell(
                    onTap: _onConfirm,
                    child: Container(
                      height: 41.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
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

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
