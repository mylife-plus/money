import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/mcc_controller.dart';
import 'package:moneyapp/models/transaction_model.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class TransactionContent extends StatelessWidget {
  final Transaction transaction;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onCardTap;
  final VoidCallback? onCardLongPress;
  final VoidCallback? onNoteTap;

  const TransactionContent({
    super.key,
    required this.transaction,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xffDFDFDF),
    this.borderWidth = 1,
    this.onCardTap,
    this.onCardLongPress,
    this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    final mccController = Get.put(MCCController());
    final mcc = mccController.getMCCById(transaction.mccId);

    final dateFormat = DateFormat('dd.');
    final labelColor = const Color(0xff707070);
    final titleColor = Colors.black;
    final amountColor = transaction.isExpense
        ? const Color(0xffFF0000)
        : const Color(0xff00C00D);

    return GestureDetector(
      onTap: onCardTap,
      onLongPress: onCardLongPress,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: backgroundColor,
          border: Border.all(color: borderColor!, width: borderWidth),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 220,
              child: Row(
                children: [
                  CustomText(
                    dateFormat.format(transaction.date),
                    size: 16.sp,
                    color: labelColor,
                  ),
                  7.horizontalSpace,
                  if (mcc?.emoji != null)
                    Text(mcc!.emoji!, style: TextStyle(fontSize: 16.sp)),
                  7.horizontalSpace,
                  Flexible(
                    child: CustomText(
                      transaction.recipient,
                      size: 16.sp,
                      color: titleColor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            8.horizontalSpace,
            InkWell(
              onTap: onNoteTap,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Image.asset(
                  AppIcons.notesIcon,
                  width: 21.r,
                  height: 21.r,
                ),
              ),
            ),
            8.horizontalSpace,

            Expanded(
              flex: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: CustomText(
                      transaction.getFormattedAmount(),
                      textAlign: TextAlign.end,
                      size: 16.sp,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
