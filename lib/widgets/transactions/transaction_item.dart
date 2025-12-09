import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/models/transaction_model.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/widgets/transactions/transaction_content.dart';

class TransactionItem extends StatefulWidget {
  final Transaction transaction;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool isSelected;
  final Function(int id)? onSelect;
  final bool isSelectionMode;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xffDFDFDF),
    required this.isSelected,
    this.isSelectionMode = false,
    this.onSelect,
  });

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  void _showPopupMenu(BuildContext context, TapDownDetails details) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        details.globalPosition & const Size(40, 40),
        Offset.zero & overlay.size,
      ),
      items: [
        PopupMenuItem(
          value: 'split',
          child: Row(
            children: [
              Icon(Icons.call_split, size: 20.sp),
              SizedBox(width: 12.w),
              Text(
                widget.transaction.isExpense
                    ? 'Split Spending'
                    : 'Split Income',
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20.sp),
              SizedBox(width: 12.w),
              Text('Edit Transaction'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'select',
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 20.sp),
              SizedBox(width: 12.w),
              Text('Select'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20.sp, color: Colors.red),
              SizedBox(width: 12.w),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (!mounted) return;
      if (value != null) {
        switch (value) {
          case 'split':
            _handleSplit();
            break;
          case 'edit':
            _handleEdit();
            break;
          case 'select':
            _handleSelect();
            break;
          case 'delete':
            _handleDelete();
            break;
        }
      }
    });
  }

  void _handleSplit() {
    final dateFormat = 'dd.';
    final label = '${widget.transaction.date.day}.$dateFormat';
    final title = widget.transaction.mcc.text;
    final hashtags = widget.transaction.hashtags.isNotEmpty
        ? widget.transaction.hashtags.first.name
        : '';
    final amount = widget.transaction.amount.toString();

    Get.toNamed(
      AppRoutes.splitSpending.path,
      arguments: {
        'label': label,
        'title': title,
        'category': hashtags,
        'amount': amount,
        'isExpense': widget.transaction.isExpense,
      },
    );
  }

  void _handleEdit() {
    Get.toNamed(
      AppRoutes.editTransaction.path,
      arguments: {'transaction': widget.transaction},
    );
  }

  void _handleSelect() {
    if (widget.onSelect != null && widget.transaction.id != null) {
      widget.onSelect!(widget.transaction.id!);
    }
  }

  void _handleDelete() {
    // TODO: Implement delete logic
  }

  @override
  Widget build(BuildContext context) {
    return TransactionContent(
      transaction: widget.transaction,
      backgroundColor: widget.backgroundColor,
      borderWidth: widget.isSelected ? 2 : 1,
      borderColor: widget.isSelected ? Color(0xff0088FF) : widget.borderColor,
      onCardTap: widget.isSelectionMode
          ? _handleSelect
          : () {
              final RenderBox box = context.findRenderObject() as RenderBox;
              final Offset position = box.localToGlobal(Offset.zero);
              final Size size = box.size;
              _showPopupMenu(
                context,
                TapDownDetails(
                  globalPosition:
                      position + Offset(size.width / 2, size.height / 2),
                ),
              );
            },
    );
  }
}
