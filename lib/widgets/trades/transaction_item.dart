import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/models/investment_activity_model.dart';
import 'package:moneyapp/services/currency_service.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class TransactionItem extends StatefulWidget {
  final InvestmentActivity activity;
  final String symbol;
  final bool isSelected;
  final Function(int id)? onSelect;
  final Function(int id)? onDelete;
  final bool isSelectionMode;

  const TransactionItem({
    super.key,
    required this.activity,
    required this.symbol,
    this.isSelected = false,
    this.onSelect,
    this.onDelete,
    this.isSelectionMode = false,
  });

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  /// Format double value as string for display
  String _formatAmount(double? value) {
    if (value == null) return '0';
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Format price/total value as string
  String _formatPrice(double? value) {
    if (value == null) return '0';
    return value.toStringAsFixed(2);
  }

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

  void _handleSelect() {
    if (widget.onSelect != null && widget.activity.id != null) {
      widget.onSelect!(widget.activity.id!);
    }
  }

  void _handleDelete() {
    if (widget.onDelete != null && widget.activity.id != null) {
      widget.onDelete!(widget.activity.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeposit =
        widget.activity.transactionDirection == TransactionDirection.deposit;

    return GestureDetector(
      onTap: () {
        if (widget.isSelectionMode) {
          _handleSelect();
        }
      },
      onLongPress: () {
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
      child: Column(
        children: [
          if (widget.activity.description != null &&
              widget.activity.description!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isDeposit ? Color(0xffD1FFD4) : Color(0xffFFEFEF),
                border: widget.isSelected
                    ? Border(
                        bottom: BorderSide.none,
                        top: BorderSide(color: Color(0xff0066FF), width: 2),
                        left: BorderSide(color: Color(0xff0066FF), width: 2),
                        right: BorderSide(color: Color(0xff0066FF), width: 2),
                      )
                    : Border.all(color: Color(0xffDFDFDF), width: 1),
                borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
              ),
              child: CustomText(
                widget.activity.description!,
                textAlign: TextAlign.start,
                color: Colors.black,
                size: 16.sp,
              ),
            ),
          ],
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isDeposit ? Color(0xffD1FFD4) : Color(0xffFFEFEF),
              border: widget.isSelected
                  ? (widget.activity.description != null &&
                            widget.activity.description!.isNotEmpty
                        ? Border(
                            top: BorderSide.none,
                            bottom: BorderSide(
                              color: Color(0xff0066FF),
                              width: 2,
                            ),
                            left: BorderSide(
                              color: Color(0xff0066FF),
                              width: 2,
                            ),
                            right: BorderSide(
                              color: Color(0xff0066FF),
                              width: 2,
                            ),
                          )
                        : Border.all(color: Color(0xff0066FF), width: 2))
                  : Border.all(color: Color(0xffDFDFDF), width: 1),
              borderRadius:
                  widget.activity.description != null &&
                      widget.activity.description!.isNotEmpty
                  ? BorderRadius.vertical(bottom: Radius.circular(4.r))
                  : BorderRadius.circular(4.r),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        isDeposit ? 'deposit' : 'withdraw',
                        color: isDeposit
                            ? Color(0xff00C00D)
                            : Color(0xffFF0000),
                        size: 16.sp,
                      ),
                      CustomText.richText(
                        textAlign: TextAlign.right,
                        children: [
                          CustomText.span(
                            '${_formatAmount(widget.activity.transactionAmount)} ',
                            color: isDeposit
                                ? Color(0xff008309)
                                : Color(0xffFF0000),
                            fontWeight: FontWeight.bold,
                            size: 18.sp,
                          ),
                          CustomText.span(
                            widget.symbol,
                            color: AppColors.greyColor,
                            size: 14.sp,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      4.verticalSpace,
                      CustomText(CurrencyService.instance.portfolioCode, color: Color(0xffCCCCCC), size: 12.sp),
                      CustomText(
                        '${_formatPrice(widget.activity.transactionPrice)} ',
                        color: Colors.black,
                        size: 18.sp,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      4.verticalSpace,
                      CustomText(CurrencyService.instance.portfolioCode, color: Color(0xff999999), size: 12.sp),
                      CustomText(
                        '${_formatPrice(widget.activity.transactionTotal)} ',
                        color: isDeposit
                            ? Color(0xff008309)
                            : Color(0xffFF0000),
                        size: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
