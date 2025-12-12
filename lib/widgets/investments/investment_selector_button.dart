import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/models/investment_recommendation.dart';
import 'package:moneyapp/screens/home/investment_list_screen.dart';

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
    return Container(
      height: 41.h,
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.greyBorder),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: TextField(
        controller: widget.controller,
        readOnly: true,
        onTap: () async {
          final result = await Navigator.push<InvestmentRecommendation>(
            context,
            MaterialPageRoute(
              builder: (context) => const InvestmentListScreen(),
            ),
          );

          if (result != null) {
            widget.controller.text = result.text;
            widget.onSelected?.call(result);
          }
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hintText,
          labelText: 'Investment',
          labelStyle: TextStyle(color: AppColors.greyColor, fontSize: 16.sp),
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        style: TextStyle(fontSize: 16.sp),
        textAlign: TextAlign.end,
      ),
    );
  }
}
