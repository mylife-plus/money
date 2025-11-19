import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/investments/price_entry_row.dart';

class TopPriceChangeScreen extends StatefulWidget {
  const TopPriceChangeScreen({super.key});

  static Future<T?> show<T>({required BuildContext context}) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return TopPriceChangeScreen();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  @override
  State<TopPriceChangeScreen> createState() => _TopInvestmentSheetState();
}

class _TopInvestmentSheetState extends State<TopPriceChangeScreen> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8.r),
              bottomRight: Radius.circular(8.r),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.fromLTRB(15.w, 18.h, 22.w, 13.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 33.h),
                      child: Column(
                        spacing: 5.h,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                          PriceEntryRow(
                            initialIsEditable: true,
                            onSave: (date, price) {
                              // Handle save logic here
                              print('Save: Date: $date, Price: $price');
                            },
                          ),
                          PriceEntryRow(
                            initialDate: DateTime(2025, 12, 12),
                            initialPrice: '130.000',
                            initialIsEditable: false,
                            onSave: (date, price) {
                              // Handle edit/update logic here
                              print('Update: Date: $date, Price: $price');
                            },
                          ),
                          PriceEntryRow(
                            initialDate: DateTime(2025, 10, 12),
                            initialPrice: '100.000',
                            initialIsEditable: false,
                            onSave: (date, price) {
                              // Handle edit/update logic here
                              print('Update: Date: $date, Price: $price');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
