import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

/// Custom App Bar Widget
/// Reusable app bar with title, leading icon, and one action icon
/// Settings icon is always included and navigates to settings screen
class CustomAppBar extends StatelessWidget {
  /// Title text to display
  final String title;

  /// Leading icon path (left side)
  final String leadingIconPath;

  /// Action icon path (in container)
  final String actionIconPath;

  /// Callback when action icon is tapped
  final VoidCallback? onActionIconTap;

  /// Callback when returning from settings screen
  final VoidCallback? onSettingsReturn;

  /// Whether to show the yellow background on the title card
  final bool showYellowBackground;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.leadingIconPath,
    required this.actionIconPath,
    this.onActionIconTap,
    this.onSettingsReturn,
    this.showYellowBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(21.w, 11.h, 11.w, 0),
      child: Row(
        children: [
          70.horizontalSpace,
          // Title Section with Leading Icon
          Container(
            height: 43.h,
            width: 180.w,
            decoration: BoxDecoration(
              color: showYellowBackground ? const Color(0xffFFCC00) : Colors.transparent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(9.r)),
              border: Border.all(color: showYellowBackground ? AppColors.greyBorder : Colors.transparent, width: 1.w),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                9.horizontalSpace,
                Image.asset(leadingIconPath, height: 32.r, width: 32.r),
                13.horizontalSpace,
                CustomText(
                  title,
                  color: showYellowBackground ? Colors.white : Colors.black,
                  size: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),

          17.horizontalSpace,

          // Action Icons Section
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onActionIconTap,
                  child: SizedBox(
                    height: 43.h,
                    width: 46.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/button_rect_bg.png',
                          height: 43.h,
                          width: 46.w,
                          fit: BoxFit.fill,
                        ),
                        Image.asset(
                          actionIconPath,
                          height: 32.r,
                          width: 32.r,
                        ),
                      ],
                    ),
                  ),
                ),
                // if (showYellowBackground) Spacer() else Spacer(),

                // Settings Icon (always present)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await Navigator.pushNamed(context, AppRoutes.settings.path);
                    onSettingsReturn?.call();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10.r),

                   
                    child: Image.asset(
                      AppIcons.setting,
                      height: 24.r,
                      width: 24.r,
                    ),
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
