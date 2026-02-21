import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class TradeItemPair extends StatefulWidget {
  final int? tradeId;
  final String soldAmount;
  final String soldSymbol;
  final String soldPrice;
  final String soldPriceSymbol;
  final String soldTotal;
  final String soldTotalSymbol;
  final String boughtAmount;
  final String boughtSymbol;
  final String boughtPrice;
  final String boughtPriceSymbol;
  final String boughtTotal;
  final String boughtTotalSymbol;
  final bool isSelected;
  final Function(int)? onSelect;
  final Function(int)? onDelete;
  final bool isSelectionMode;

  const TradeItemPair({
    super.key,
    this.tradeId,
    required this.soldAmount,
    required this.soldSymbol,
    required this.soldPrice,
    required this.soldPriceSymbol,
    required this.soldTotal,
    required this.soldTotalSymbol,
    required this.boughtAmount,
    required this.boughtSymbol,
    required this.boughtPrice,
    required this.boughtPriceSymbol,
    required this.boughtTotal,
    required this.boughtTotalSymbol,
    this.isSelected = false,
    this.onSelect,
    this.onDelete,
    this.isSelectionMode = false,
  });

  @override
  State<TradeItemPair> createState() => _TradeItemPairState();
}

class _TradeItemPairState extends State<TradeItemPair> {
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
    if (widget.onSelect != null && widget.tradeId != null) {
      widget.onSelect!(widget.tradeId!);
    }
  }

  void _handleDelete() {
    if (widget.onDelete != null && widget.tradeId != null) {
      widget.onDelete!(widget.tradeId!);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          // Sold item
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Color(0xffFFEFEF),
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
            child: Row(
              children: [
                Expanded(
                  flex: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        'sold',
                        color: Color(0xffFF0000),
                        size: 16.sp,
                        fontWeight: FontWeight.w400,
                      ),
                      CustomText.richText(
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        children: [
                          CustomText.span(
                            '${widget.soldAmount} ',
                            color: Color(0xffFF0000),
                            size: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          CustomText.span(
                            widget.soldSymbol,
                            color: AppColors.greyColor,
                            size: 14.sp,
                            fontWeight: FontWeight.w400,
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
                      CustomText(
                        widget.soldPriceSymbol,
                        color: AppColors.greyColor,
                        size: 12.sp,
                      ),
                      CustomText(
                        widget.soldPrice,
                        color: Colors.black,
                        size: 18.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 150,

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomText(
                        widget.soldTotalSymbol,
                        color: AppColors.greyColor,
                        size: 12.sp,
                      ),
                      CustomText(
                        widget.soldTotal,
                        color: Color(0xffFF0000),
                        size: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bought item
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Color(0xffD1FFD4),
              border: widget.isSelected
                  ? Border(
                      top: BorderSide.none,
                      bottom: BorderSide(color: Color(0xff0066FF), width: 2),
                      left: BorderSide(color: Color(0xff0066FF), width: 2),
                      right: BorderSide(color: Color(0xff0066FF), width: 2),
                    )
                  : Border.all(color: Color(0xffDFDFDF), width: 1),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.r)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        'bought',
                        color: Color(0xff00C00D),
                        size: 16.sp,
                      ),
                      CustomText.richText(
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        children: [
                          CustomText.span(
                            '${widget.boughtAmount} ',
                            color: Color(0xff008309),
                            size: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          CustomText.span(
                            widget.boughtSymbol,
                            color: AppColors.greyColor,
                            size: 14.sp,
                            fontWeight: FontWeight.w400,
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
                      CustomText(
                        widget.boughtPriceSymbol,
                        color: AppColors.greyColor,
                        size: 12.sp,
                      ),
                      CustomText(
                        widget.boughtPrice,
                        color: Colors.black,
                        size: 18.sp,
                        fontWeight: FontWeight.w400,
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

                      CustomText(
                        widget.boughtTotalSymbol,
                        color: AppColors.greyColor,
                        size: 12.sp,
                      ),
                      CustomText(
                        widget.boughtTotal,
                        color: Color(0xff008309),
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
