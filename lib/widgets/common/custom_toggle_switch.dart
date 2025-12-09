import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

/// Custom Toggle Switch Widget
/// A two-option toggle switch with icons and text
class CustomToggleSwitch extends StatelessWidget {
  /// First option icon path
  final String option1IconPath;

  /// First option text
  final String option1Text;

  /// Second option icon path
  final String option2IconPath;

  /// Second option text
  final String option2Text;

  /// Currently selected option (1 or 2)
  final int selectedOption;

  /// Callback when option 1 is tapped
  final VoidCallback onOption1Tap;

  /// Callback when option 2 is tapped
  final VoidCallback onOption2Tap;

  const CustomToggleSwitch({
    super.key,
    required this.option1IconPath,
    required this.option1Text,
    required this.option2IconPath,
    required this.option2Text,
    required this.selectedOption,
    required this.onOption1Tap,
    required this.onOption2Tap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.r),
      width: 289.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12.r),
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
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(option1IconPath, width: 33.r, height: 33.r),
                    3.horizontalSpace,
                    CustomText(
                      option1Text,
                      size: 20.sp,
                      fontWeight: selectedOption == 1
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selectedOption == 1
                          ? Colors.black
                          : const Color(0xff6E6E6E),
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
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(option2IconPath, width: 33.r, height: 33.r),
                    3.horizontalSpace,
                    CustomText(
                      option2Text,
                      size: 20.sp,
                      fontWeight: selectedOption == 2
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: selectedOption == 2
                          ? Colors.black
                          : const Color(0xff6E6E6E),
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
