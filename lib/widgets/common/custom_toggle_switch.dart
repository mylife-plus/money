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

  final Color? option1Color;
  final Color? option2Color;

  ///
  final bool iconColorShouldEffect;

  const CustomToggleSwitch({
    super.key,
    required this.option1IconPath,
    required this.option1Text,
    required this.option2IconPath,
    required this.option2Text,
    required this.selectedOption,
    required this.onOption1Tap,
    required this.onOption2Tap,
    this.iconColorShouldEffect = false,
    this.option1Color,
    this.option2Color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        91.horizontalSpace,
        // Option 1
        InkWell(
          onTap: onOption1Tap,
          child: Container(
            width: selectedOption == 1 ? 118.w : 59.w,
            height: 35.h,
            decoration: BoxDecoration(
              color: selectedOption == 1
                  ? Color(0xffFFE374)
                  : AppColors.background,
              border: Border.all(color: AppColors.greyBorder, width: 1.r),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(9.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  option1IconPath,
                  width: 33.r,
                  height: 33.r,
                  color: iconColorShouldEffect
                      ? (selectedOption == 1 ? null : AppColors.greyColor)
                      : null,
                ),
                if (selectedOption == 1) ...[
                  3.horizontalSpace,
                  CustomText(
                    option1Text,
                    size: 16.sp,
                    fontWeight: selectedOption == 1
                        ? FontWeight.w500
                        : FontWeight.w500,
                    color: selectedOption == 1
                        ? option1Color ?? Colors.black
                        : const Color(0xff6E6E6E),
                  ),
                ],
              ],
            ),
          ),
        ),
        InkWell(
          onTap: onOption2Tap,
          child: Container(
            width: selectedOption == 2 ? 118.w : 59.w,
            height: 35.h,
            decoration: BoxDecoration(
              color: selectedOption == 2
                  ? Color(0xffFFE374)
                  : AppColors.background,
              border: Border.all(color: AppColors.greyBorder, width: 2.r),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(9.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  option2IconPath,
                  width: 33.r,
                  height: 33.r,
                  color: iconColorShouldEffect
                      ? (selectedOption == 2 ? null : AppColors.greyColor)
                      : null,
                ),
                if (selectedOption == 2) ...[
                  3.horizontalSpace,
                  CustomText(
                    option2Text,
                    size: 16.sp,
                    fontWeight: selectedOption == 2
                        ? FontWeight.w500
                        : FontWeight.w500,
                    color: selectedOption == 2
                        ? option2Color ?? Colors.black
                        : const Color(0xff6E6E6E),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
