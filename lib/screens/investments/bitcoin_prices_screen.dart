import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

  void _showAddPriceDialog() {
    showDialog(
      context: context,
      builder: (context) => PriceEntryDialog(
        onSave: (date, price) {
          setState(() {
            priceEntries.insert(0, PriceEntry(date: date, price: price));
          });
          Get.snackbar(
            'Success',
            'Price added successfully',
            snackPosition: SnackPosition.BOTTOM,
          );
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
        onSave: (date, price) {
          setState(() {
            priceEntries[index] = PriceEntry(date: date, price: price);
          });
          Get.snackbar(
            'Success',
            'Price updated successfully',
            snackPosition: SnackPosition.BOTTOM,
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
      Get.snackbar(
        'Success',
        'Price deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
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
                    onTap: () => Get.back(),
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
                      width: 21.h,
                      height: 21.h,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 33.h),
                  child: Column(
                    spacing: 5.h,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Column headers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomText(
                            'Date',
                            size: 12.sp,
                            color: Color(0xffC0C0C0),
                          ),
                          76.horizontalSpace,
                          CustomText(
                            'Price',
                            size: 12.sp,
                            color: Color(0xffC0C0C0),
                          ),
                          37.horizontalSpace,
                        ],
                      ),

                      // Existing price entries
                      for (int i = 0; i < priceEntries.length; i++)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Date Container
                            Container(
                              height: 30.h,
                              width: 90.w,
                              padding: EdgeInsets.symmetric(
                                horizontal: 5.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xffDFDFDF),
                                ),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Center(
                                child: CustomText(
                                  DateFormat(
                                    'dd.MM.yyyy',
                                  ).format(priceEntries[i].date),
                                  size: 16.sp,
                                  textAlign: TextAlign.center,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            7.horizontalSpace,
                            // Price Container
                            Container(
                              height: 30.h,
                              width: 98.w,
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xffDFDFDF),
                                ),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Center(
                                child: CustomText(
                                  '\$ ${priceEntries[i].price}',
                                  size: 16.sp,
                                  textAlign: TextAlign.center,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            15.horizontalSpace,
                            // Edit Icon
                            InkWell(
                              onTap: () => _showEditPriceDialog(i),
                              child: Image.asset(
                                AppIcons.edit,
                                width: 22.r,
                                height: 22.r,
                              ),
                            ),
                            6.horizontalSpace,
                            // Delete Icon
                            InkWell(
                              onTap: () => _deleteEntry(i),
                              child: Image.asset(
                                AppIcons.delete,
                                width: 22.r,
                                height: 22.r,
                              ),
                            ),
                          ],
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
