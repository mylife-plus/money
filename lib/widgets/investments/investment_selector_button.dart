import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/models/investment_recommendation.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/investments/investment_selection_dialog.dart';

class InvestmentSelectorButton extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(InvestmentRecommendation)? onSelected;

  const InvestmentSelectorButton({
    super.key,
    required this.controller,
    this.hintText = 'select',
    this.onSelected,
  });

  @override
  State<InvestmentSelectorButton> createState() =>
      _InvestmentSelectorButtonState();
}

class _InvestmentSelectorButtonState extends State<InvestmentSelectorButton> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {
      // Rebuild when controller text changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await showDialog<InvestmentRecommendation>(
          context: context,
          builder: (context) => InvestmentSelectionDialog(
            onSelected: (investment) {
              widget.controller.text = investment.text;
              widget.onSelected?.call(investment);
            },
          ),
        );
      },
      child: Container(
        height: 41.h,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffDFDFDF)),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 7.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomText(
                'Investment',
                size: 12.sp,
                color: Color(0xffCACACA),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: CustomText(
                    widget.controller.text.isEmpty
                        ? widget.hintText
                        : widget.controller.text,
                    size: 16.sp,
                    color: widget.controller.text.isEmpty
                        ? const Color(0xffB4B4B4)
                        : Colors.black,
                  ),
                ),
              ),
              8.horizontalSpace,
              Icon(
                Icons.arrow_drop_down,
                size: 20.sp,
                color: const Color(0xffB4B4B4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
