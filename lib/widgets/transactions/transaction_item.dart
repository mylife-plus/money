import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/models/transaction_model.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/widgets/common/category_chip.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
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

  void _showDetailDialog(BuildContext context) {
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
                      DateFormat('dd.MM.yyyy').format(widget.transaction.date),
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
                    if (widget.transaction.mcc.assetPath != null)
                      Image.asset(
                        widget.transaction.mcc.assetPath!,
                        width: 20.r,
                        height: 20.r,
                      ),
                    8.horizontalSpace,
                    CustomText(
                      widget.transaction.mcc.text,
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
                      widget.transaction.getFormattedAmount(),
                      size: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: widget.transaction.isExpense
                          ? const Color(0xffFF0000)
                          : const Color(0xff00C00D),
                    ),
                    8.horizontalSpace,
                    CustomText(
                      widget.transaction.isExpense ? '(Expense)' : '(Income)',
                      size: 12.sp,
                      color: const Color(0xff707070),
                    ),
                  ],
                ),
              ),
              8.verticalSpace,

              // Recipient
              if (widget.transaction.recipient.isNotEmpty) ...[
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
                        widget.transaction.recipient,
                        size: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                8.verticalSpace,
              ],

              // Note
              if (widget.transaction.note.isNotEmpty) ...[
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
                        widget.transaction.note,
                        size: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                8.verticalSpace,
              ],

              // Hashtags
              if (widget.transaction.hashtags.isNotEmpty) ...[
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
                        children: widget.transaction.hashtags.map((hashtag) {
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
    return TransactionContent(
      transaction: widget.transaction,
      backgroundColor: widget.backgroundColor,
      borderWidth: widget.isSelected ? 2 : 1,
      borderColor: widget.isSelected ? Color(0xff0088FF) : widget.borderColor,
      onCardTap: widget.isSelectionMode
          ? _handleSelect
          : () => _showDetailDialog(context),
      onCardLongPress: () {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final Offset position = box.localToGlobal(Offset.zero);
        final Size size = box.size;
        _showPopupMenu(
          context,
          TapDownDetails(
            globalPosition: position + Offset(size.width / 2, size.height / 2),
          ),
        );
      },
    );
  }
}
