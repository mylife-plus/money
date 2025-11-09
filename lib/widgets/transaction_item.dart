import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/widgets/custom_text.dart';
import 'package:moneyapp/widgets/top_sheet.dart';
import 'package:moneyapp/widgets/split_spending_content.dart';

class TransactionItem extends StatelessWidget {
  final String label;
  final String title;
  final String category;
  final String amount;
  final Color? labelColor;
  final Color? titleColor;
  final Color? categoryColor;
  final Color? amountColor;
  final Color? backgroundColor;
  final Color? borderColor;

  const TransactionItem({
    super.key,
    required this.label,
    required this.title,
    required this.category,
    required this.amount,
    this.labelColor = const Color(0xff707070),
    this.titleColor = Colors.black,
    this.categoryColor = const Color(0xff0088FF),
    this.amountColor = const Color(0xffFF0000),
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xffDFDFDF),
  });

  void _handleSplit(BuildContext context) {
    TopSheet.show(
      context: context,
      title: 'Split Spending',
      child: SplitSpendingContent(
        label: label,
        title: title,
        category: category,
        amount: amount,
      ),
    );
  }

  void _handleEdit(BuildContext context) {
    // TODO: Implement edit functionality
    print('Edit tapped for $title');
  }

  void _handleSelect(BuildContext context) {
    // TODO: Implement select functionality
    print('Select tapped for $title');
  }

  void _handleDelete(BuildContext context) {
    // TODO: Implement delete functionality
    print('Delete tapped for $title');
  }

  void _showTransactionMenu(BuildContext context, TapDownDetails details) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = details.globalPosition;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width - position.dx,
        overlay.size.height - position.dy,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: const BorderSide(color: Color(0xff0088FF), width: 2),
      ),
      color: Colors.white,
      elevation: 4,
      items: [
        PopupMenuItem(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          onTap: () => _handleSplit(context),
          child: CustomText('split', size: 18.sp, color: Colors.black),
        ),
        PopupMenuItem(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          onTap: () => _handleEdit(context),
          child: CustomText('edit', size: 18.sp, color: Colors.black),
        ),
        PopupMenuItem(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          onTap: () => _handleSelect(context),
          child: CustomText('select', size: 18.sp, color: Colors.black),
        ),
        PopupMenuItem(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          onTap: () => _handleDelete(context),
          child: CustomText(
            'delete',
            size: 18.sp,
            color: const Color(0xffFF0000),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => _showTransactionMenu(context, details),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 7.r, horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: backgroundColor,
          border: Border.all(color: borderColor!),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 220,
              child: Row(
                children: [
                  CustomText(label, size: 16.sp, color: labelColor),
                  7.horizontalSpace,
                  CustomText(title, size: 16.sp, color: titleColor),
                ],
              ),
            ),
            CustomText.richText(
              children: [
                CustomText.span(category, size: 16.sp, color: categoryColor),
                CustomText.span(
                  ' #',
                  size: 16.sp,
                  color: const Color(0xff707070),
                ),
              ],
            ),
            Expanded(
              flex: 116,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomText('€ $amount', size: 16.sp, color: amountColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
