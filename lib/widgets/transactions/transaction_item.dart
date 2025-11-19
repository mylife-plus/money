import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/widgets/common/custom_popup.dart';
import 'package:moneyapp/widgets/transactions/edit_transaction_content.dart';
import 'package:moneyapp/widgets/transactions/top_transaction_sheet.dart';
import 'package:moneyapp/widgets/transactions/split_spending_content.dart';
import 'package:moneyapp/widgets/transactions/transaction_content.dart';
import 'package:moneyapp/widgets/transactions/transaction_popup_menu.dart';

class TransactionItem extends StatefulWidget {
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

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  final GlobalKey<CustomPopupState> _popupKey = GlobalKey<CustomPopupState>();

  void _handleSplit(BuildContext context) {
    _popupKey.currentState?.dismiss();
    TopTransactionSheet.show(
      context: context,
      title: 'split Spending',
      child: SplitSpendingContent(
        label: widget.label,
        title: widget.title,
        category: widget.category,
        amount: widget.amount,
      ),
    );
  }

  void _handleEdit(BuildContext context) {
    _popupKey.currentState?.dismiss();
    TopTransactionSheet.show(
      context: context,
      title: 'edit Transaction',
      child: EditTransactionContent(
        label: widget.label,
        title: widget.title,
        category: widget.category,
        amount: widget.amount,
      ),
    );
  }

  void _handleSelect() {
    _popupKey.currentState?.dismiss();
    // TODO: Implement select logic
  }

  void _handleDelete() {
    _popupKey.currentState?.dismiss();
    // TODO: Implement delete logic
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPopup(
          key: _popupKey,
          position: PopupPosition.bottom,
          backgroundColor: Colors.transparent,
          showArrow: false,
          contentPadding: EdgeInsets.zero,
          contentBorderRadius: BorderRadius.circular(4.r),
          barrierColor: Colors.black.withOpacity(0.1),
          alignment: Alignment.topLeft,
          offset: const Offset(0, 0),
          contentDecoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(4.r),
          ),
          animationDuration: Duration.zero,
          content: TransactionPopupMenu(
            transactionWidth: constraints.maxWidth,
            label: widget.label,
            title: widget.title,
            category: widget.category,
            amount: widget.amount,
            labelColor: widget.labelColor,
            titleColor: widget.titleColor,
            categoryColor: widget.categoryColor,
            amountColor: widget.amountColor,
            backgroundColor: widget.backgroundColor,
            onSplit: () {
              _handleSplit(context);
            },
            onEdit: () {
              _handleEdit(context);
            },
            onSelect: _handleSelect,
            onDelete: _handleDelete,
          ),
          child: TransactionContent(
            label: widget.label,
            title: widget.title,
            category: widget.category,
            amount: widget.amount,
            labelColor: widget.labelColor,
            titleColor: widget.titleColor,
            categoryColor: widget.categoryColor,
            amountColor: widget.amountColor,
            backgroundColor: widget.backgroundColor,
            borderColor: widget.borderColor,
          ),
        );
      },
    );
  }
}
