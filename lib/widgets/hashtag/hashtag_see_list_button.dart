import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

/// "See List" button widget for navigating to full hashtag group screen
class HashtagSeeListButton extends StatelessWidget {
  final UiController uiController;
  final VoidCallback onTap;
  final bool isInFilterMode;

  const HashtagSeeListButton({
    super.key,
    required this.uiController,
    required this.onTap,
    this.isInFilterMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(height: 1.h, color: Colors.grey.withValues(alpha: 0.3)),
        InkWell(
          onTap: onTap,
          child: Container(
            height: isInFilterMode ? 40.h : null,
            padding: isInFilterMode
                ? EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                    top: 12.h,
                    bottom: 0,
                  )
                : EdgeInsets.only(
                    left: 12.w,
                    right: 12.w,
                    top: 8.h,
                    bottom: 8.h,
                  ),
            child: Center(
              child: CustomText(
                'See List',
                size: 18.sp,
                fontWeight: FontWeight.w500,
                color: uiController.currentMainColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
