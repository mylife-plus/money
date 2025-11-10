import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/widgets/custom_text.dart';
import 'package:moneyapp/widgets/transaction_content.dart';

class TransactionPopupMenu extends StatelessWidget {
  final double transactionWidth;
  final String label;
  final String title;
  final String category;
  final String amount;
  final Color? labelColor;
  final Color? titleColor;
  final Color? categoryColor;
  final Color? amountColor;
  final Color? backgroundColor;
  final VoidCallback onSplit;
  final VoidCallback onEdit;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  const TransactionPopupMenu({
    super.key,
    required this.transactionWidth,
    required this.label,
    required this.title,
    required this.category,
    required this.amount,
    required this.onSplit,
    required this.onEdit,
    required this.onSelect,
    required this.onDelete,
    this.labelColor,
    this.titleColor,
    this.categoryColor,
    this.amountColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: transactionWidth,
          child: TransactionContent(
            label: label,
            title: title,
            category: category,
            amount: amount,
            labelColor: labelColor,
            titleColor: titleColor,
            categoryColor: categoryColor,
            amountColor: amountColor,
            backgroundColor: backgroundColor,
            borderColor: const Color(0xff0088FF),
            borderWidth: 2,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: IntrinsicWidth(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: const Border(
                  left: BorderSide(color: Color(0xff0088FF), width: 1),
                  right: BorderSide(color: Color(0xff0088FF), width: 1),
                  bottom: BorderSide(color: Color(0xff0088FF), width: 1),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4.r),
                  bottomRight: Radius.circular(4.r),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMenuItem(label: 'split', onTap: onSplit),
                  _buildDivider(),
                  _buildMenuItem(label: 'edit', onTap: onEdit),
                  _buildDivider(),
                  _buildMenuItem(label: 'select', onTap: onSelect),
                  _buildDivider(),
                  _buildMenuItem(
                    label: 'delete',
                    color: Colors.red,
                    onTap: onDelete,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 22.w),
        child: CustomText(label, size: 16.sp, color: color ?? Colors.black87),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1.h, color: const Color(0xff0088FF));
  }
}
