import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/controllers/mcc_controller.dart';
import 'package:moneyapp/controllers/hashtag_groups_controller.dart';
import 'package:moneyapp/controllers/home_controller.dart';
import 'package:moneyapp/models/transaction_model.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/widgets/common/category_chip.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/services/currency_service.dart';
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
  bool _isMenuOpen = false;

  void _showPopupMenu(BuildContext context, TapDownDetails details) {
    setState(() => _isMenuOpen = true);
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
      setState(() => _isMenuOpen = false);
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
    final mccController = Get.find<MCCController>();
    final mcc = widget.transaction.mccId != null
        ? mccController.getMCCById(widget.transaction.mccId!)
        : null;

    final dateFormat = 'dd.';
    final label = '${widget.transaction.date.day}.$dateFormat';
    final title = mcc?.name ?? 'Unknown';
    final hashtags = widget.transaction.hashtags.isNotEmpty
        ? widget.transaction.hashtags.first.name
        : '';
    final amount = widget.transaction.amount.toString();

    Navigator.pushNamed(
      context,
      AppRoutes.splitSpending.path,
      arguments: {
        'label': label,
        'title': title,
        'category': hashtags,
        'amount': amount,
        'isExpense': widget.transaction.isExpense,
        'transaction': widget.transaction,
      },
    );
  }

  void _handleEdit() {
    Navigator.pushNamed(
      context,
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
    if (widget.transaction.id != null) {
      Get.find<HomeController>().deleteTransactionById(widget.transaction.id!);
    }
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    Color? valueColor,
    Widget? prefix,
    Widget? suffix,
  }) {
    return Container(
      height: 41.h,
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffDFDFDF)),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          if (prefix != null) ...[prefix, 6.horizontalSpace],
          Expanded(
            child: TextField(
              controller: TextEditingController(text: value),
              readOnly: true,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: label,
                labelStyle: TextStyle(
                  color: const Color(0xff707070),
                  fontSize: 16.sp,
                ),
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 16.sp,
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
          if (suffix != null) ...[6.horizontalSpace, suffix],
        ],
      ),
    );
  }

  void _showDetailDialog(BuildContext context) {
    final mccController = Get.put(MCCController());
    final mcc = widget.transaction.mccId != null
        ? mccController.getMCCById(widget.transaction.mccId!)
        : null;
    final hashtagController = Get.put(HashtagGroupsController());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    'Transaction Details',
                    size: 16.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
              16.verticalSpace,

              // Date + Amount row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildReadOnlyField(
                      label: 'Date',
                      value: DateFormat(
                        'dd.MM.yyyy',
                      ).format(widget.transaction.date),
                    ),
                  ),
                  10.horizontalSpace,
                  Expanded(
                    flex: 3,
                    child: _buildReadOnlyField(
                      label: widget.transaction.isExpense
                          ? 'Spending'
                          : 'Income',
                      value: widget.transaction.getFormattedAmount(
                        currency: '',
                      ),
                      valueColor: widget.transaction.isExpense
                          ? const Color(0xffFF0000)
                          : const Color(0xff00C00D),
                      suffix: CustomText(
                        CurrencyService.instance.cashflowCode,
                        size: 12.sp,
                        color: const Color(0xff707070),
                      ),
                    ),
                  ),
                ],
              ),
              7.verticalSpace,

              // MCC Category
              if (mcc != null)
                _buildReadOnlyField(
                  label: 'MCC',
                  value: mcc.name,
                  prefix: mcc.emoji != null
                      ? Text(mcc.emoji!, style: TextStyle(fontSize: 20.sp))
                      : null,
                  suffix: CustomText(
                    mcc.categoryName,
                    size: 12.sp,
                    color: const Color(0xff707070),
                  ),
                ),
              if (mcc != null) 7.verticalSpace,

              // Recipient
              if (widget.transaction.recipient.isNotEmpty) ...[
                _buildReadOnlyField(
                  label: 'Recipient',
                  value: widget.transaction.recipient,
                ),
                7.verticalSpace,
              ],

              // Note
              if (widget.transaction.note.isNotEmpty) ...[
                _buildReadOnlyField(
                  label: 'Note',
                  value: widget.transaction.note,
                ),
                7.verticalSpace,
              ],

              // Hashtags
              if (widget.transaction.hashtags.isNotEmpty) ...[
                Obx(() {
                  // Register dependency to ensure rebuilds
                  hashtagController.allGroups.length;

                  return Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: widget.transaction.hashtags.map((hashtag) {
                      final freshHashtag =
                          hashtagController.findGroupById(hashtag.id ?? -1) ??
                          hashtag;

                      String groupName = 'Main Group';
                      if (freshHashtag.isSubgroup) {
                        final parent = hashtagController.findGroupById(
                          freshHashtag.parentId ?? -1,
                        );
                        groupName = parent?.name ?? 'Unknown';
                      }

                      return CategoryChip(
                        category: freshHashtag.name,
                        categoryGroup: groupName,
                      );
                    }).toList(),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showHighlight = widget.isSelected || _isMenuOpen;
    return TransactionContent(
      transaction: widget.transaction,
      backgroundColor: widget.backgroundColor,
      borderWidth: showHighlight ? 2 : 1,
      borderColor: showHighlight ? Color(0xff0088FF) : widget.borderColor,
      onCardTap: widget.isSelectionMode
          ? _handleSelect
          : () => _showDetailDialog(context),
      onNoteTap: () => _showDetailDialog(context),
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
