import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/trades/trade_transaction_toggle_switch_.dart';

class TopInvestmentSheet extends StatefulWidget {
  final String title;
  final Widget tradeChild;
  final Widget transactionChild;

  const TopInvestmentSheet({
    super.key,
    required this.title,
    required this.tradeChild,
    required this.transactionChild,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget tradeChild,
    required Widget transactionChild,
    VoidCallback? onClose,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return TopInvestmentSheet(
          title: title,
          tradeChild: tradeChild,
          transactionChild: transactionChild,
        );
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
  State<TopInvestmentSheet> createState() => _TopInvestmentSheetState();
}

class _TopInvestmentSheetState extends State<TopInvestmentSheet> {
  int selectedOption = 1;
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
                  padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 32.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(
                        widget.title,
                        size: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
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
                  backgroundColor: Colors.yellow,
                ),
                27.h.verticalSpace,
                // Content
                selectedOption == 1
                    ? Flexible(
                        child: SingleChildScrollView(child: widget.tradeChild),
                      )
                    : Flexible(
                        child: SingleChildScrollView(
                          child: widget.transactionChild,
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
