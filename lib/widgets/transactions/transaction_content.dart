import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/models/transaction_model.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/common/category_chip.dart';

class TransactionContent extends StatelessWidget {
  final Transaction transaction;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onCardTap;
  final VoidCallback? onCardLongPress;

  const TransactionContent({
    super.key,
    required this.transaction,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xffDFDFDF),
    this.borderWidth = 1,
    this.onCardTap,
    this.onCardLongPress,
  });

  void _showNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    'Transaction Details',
                    size: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 24.sp),
                  ),
                ],
              ),
              16.verticalSpace,

              // Date
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xffDFDFDF)),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  children: [
                    CustomText(
                      'Date:',
                      size: 14.sp,
                      color: const Color(0xff707070),
                    ),
                    12.horizontalSpace,
                    CustomText(
                      DateFormat('dd.MM.yyyy').format(transaction.date),
                      size: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
              8.verticalSpace,

              // MCC Category
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xffDFDFDF)),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  children: [
                    CustomText(
                      'MCC:',
                      size: 14.sp,
                      color: const Color(0xff707070),
                    ),
                    12.horizontalSpace,
                    if (transaction.mcc.assetPath != null)
                      Image.asset(
                        transaction.mcc.assetPath!,
                        width: 20.r,
                        height: 20.r,
                      ),
                    8.horizontalSpace,
                    CustomText(
                      transaction.mcc.text,
                      size: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              ),
              8.verticalSpace,

              // Amount
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xffDFDFDF)),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  children: [
                    CustomText(
                      'Amount:',
                      size: 14.sp,
                      color: const Color(0xff707070),
                    ),
                    12.horizontalSpace,
                    CustomText(
                      transaction.getFormattedAmount(),
                      size: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: transaction.isExpense
                          ? const Color(0xffFF0000)
                          : const Color(0xff00C00D),
                    ),
                    8.horizontalSpace,
                    CustomText(
                      transaction.isExpense ? '(Expense)' : '(Income)',
                      size: 12.sp,
                      color: const Color(0xff707070),
                    ),
                  ],
                ),
              ),
              8.verticalSpace,

              // Recipient
              if (transaction.recipient.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        'Recipient:',
                        size: 14.sp,
                        color: const Color(0xff707070),
                      ),
                      4.verticalSpace,
                      CustomText(
                        transaction.recipient,
                        size: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                8.verticalSpace,
              ],

              // Note
              if (transaction.note.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        'Note:',
                        size: 14.sp,
                        color: const Color(0xff707070),
                      ),
                      4.verticalSpace,
                      CustomText(
                        transaction.note,
                        size: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                8.verticalSpace,
              ],

              // Hashtags
              if (transaction.hashtags.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        'Hashtags:',
                        size: 14.sp,
                        color: const Color(0xff707070),
                      ),
                      8.verticalSpace,
                      Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: transaction.hashtags.map((hashtag) {
                          return CategoryChip(
                            category: hashtag.name,
                            categoryGroup: hashtag.isMainGroup
                                ? 'Main Group'
                                : hashtag.name,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  Image.asset(
                    transaction.mcc.assetPath ?? '',
                    width: 16.r,
                    height: 16.r,
                  ),
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
              onTap: () => _showNoteDialog(context),
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
