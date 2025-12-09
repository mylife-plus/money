import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

/// Custom Toggle Switch Widget
/// A two-option toggle switch with icons and text
class CustomToggleSwitchSmall extends StatelessWidget {
  /// First option text
  final String option1Text;

  /// Second option text
  final String option2Text;

  /// Currently selected option (1 or 2)
  final int selectedOption;

  /// Callback when option 1 is tapped
  final VoidCallback onOption1Tap;

  /// Callback when option 2 is tapped
  final VoidCallback onOption2Tap;

  /// Background color of the toggle switch
  final Color backgroundColor;

  const CustomToggleSwitchSmall({
    super.key,

    required this.option1Text,
    required this.option2Text,
    required this.selectedOption,
    required this.onOption1Tap,
    required this.onOption2Tap,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.r, vertical: 1),
      width: 111.w,
      height: 24.h,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          // Option 1
          Expanded(
            child: GestureDetector(
              onTap: onOption1Tap,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: selectedOption == 1
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      option1Text,
                      size: 14.sp,
                      fontWeight: selectedOption == 1
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selectedOption == 1
                          ? Colors.black
                          : AppColors.greyColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Option 2
          Expanded(
            child: GestureDetector(
              onTap: onOption2Tap,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: selectedOption == 2
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      option2Text,
                      size: 14.sp,
                      fontWeight: selectedOption == 2
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selectedOption == 2
                          ? Colors.black
                          : AppColors.greyColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
