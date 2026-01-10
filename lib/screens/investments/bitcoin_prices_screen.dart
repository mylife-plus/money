import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/investments/price_entry_dialog.dart';

class BitcoinPricesScreen extends StatefulWidget {
  const BitcoinPricesScreen({super.key});

  @override
  State<BitcoinPricesScreen> createState() => _BitcoinPricesScreenState();
}

class _BitcoinPricesScreenState extends State<BitcoinPricesScreen> {
  // Sample data - replace with actual data management
  List<PriceEntry> priceEntries = [
    PriceEntry(date: DateTime(2025, 12, 12), price: '130.000'),
    PriceEntry(date: DateTime(2025, 10, 12), price: '100.000'),
  ];

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

  void _showAddPriceDialog() {
    showDialog(
      context: context,
      builder: (context) => PriceEntryDialog(
        onSave: (date, price) {
          setState(() {
            priceEntries.insert(0, PriceEntry(date: date, price: price));
          });
          _showSnackbar('Success', 'Price added successfully', isError: false);
        },
      ),
    );
  }

  void _showEditPriceDialog(int index) {
    final entry = priceEntries[index];
    showDialog(
      context: context,
      builder: (context) => PriceEntryDialog(
        initialDate: entry.date,
        initialPrice: entry.price,
        onDelete: () {
          Navigator.pop(context);
          _deleteEntry(index);
        },
        onSave: (date, price) {
          setState(() {
            priceEntries[index] = PriceEntry(date: date, price: price);
          });
          _showSnackbar(
            'Success',
            'Price updated successfully',
            isError: false,
          );
        },
      ),
    );
  }

  Future<void> _deleteEntry(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        title: CustomText(
          'Delete Price',
          size: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        content: CustomText(
          'Are you sure you want to delete this price entry?',
          size: 14.sp,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: CustomText(
              'Cancel',
              size: 14.sp,
              color: const Color(0xff707070),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: CustomText(
              'Delete',
              size: 14.sp,
              color: const Color(0xffFF0000),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        priceEntries.removeAt(index);
      });
      _showSnackbar('Success', 'Price deleted successfully', isError: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
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
                  Row(
                    children: [
                      Image.asset(
                        AppIcons.digitalCurrency,
                        height: 16.r,
                        width: 16.r,
                      ),
                      8.horizontalSpace,
                      CustomText(
                        'Bitcoin Prices',
                        size: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _showAddPriceDialog,
                    child: Image.asset(
                      AppIcons.plus,
                      color: AppColors.greyColor,
                      width: 21.h,
                      height: 21.h,
                    ),
                  ),
                ],
              ),
            ),
            38.verticalSpace,

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: 33.h,
                    left: 35.w,
                    right: 24.w,
                  ),
                  child: Column(
                    spacing: 6.h,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < priceEntries.length; i++)
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 6.h,
                            horizontal: 11.w,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: AppColors.greyBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Date Container
                              Expanded(
                                child: CustomText(
                                  DateFormat(
                                    'dd.MM.yyyy',
                                  ).format(priceEntries[i].date),
                                  size: 20.sp,
                                  color: Colors.black,
                                ),
                              ),

                              // Price Container
                              CustomText(
                                '\$ ${priceEntries[i].price}',
                                size: 20.sp,
                                color: Colors.black,
                              ),
                              CustomText(
                                ' USD',
                                size: 12.sp,
                                color: AppColors.greyColor,
                              ),
                              20.horizontalSpace,
                              // Edit Icon
                              InkWell(
                                onTap: () => _showEditPriceDialog(i),
                                child: Image.asset(
                                  AppIcons.edit,
                                  width: 22.r,
                                  height: 22.r,
                                ),
                              ),
                            ],
                          ),
                        ),
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

class PriceEntry {
  final DateTime date;
  final String price;

  PriceEntry({required this.date, required this.price});
}
