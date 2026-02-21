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

  const CustomAppBar({
    super.key,
    required this.title,
    required this.leadingIconPath,
    required this.actionIconPath,
    this.onActionIconTap,
    this.onSettingsReturn,
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
            width: 177.w,
            decoration: BoxDecoration(
              color: Color(0xffFFCC00),
              borderRadius: BorderRadius.vertical(top: Radius.circular(9.r)),
              border: Border.all(color: AppColors.greyBorder, width: 1.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(0, 1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                9.horizontalSpace,
                Image.asset(leadingIconPath, height: 32.r, width: 32.r),
                13.horizontalSpace,
                CustomText(
                  title,
                  color: Colors.white,
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
                // Action Icon (in container with shadow)
                GestureDetector(
                  onTap: onActionIconTap,
                  child: Container(
                    height: 43.w,
                    width: 46.w,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      border: Border.all(
                        color: AppColors.greyBorder,
                        width: 1.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          offset: const Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        actionIconPath,
                        height: 32.r,
                        width: 32.r,
                      ),
                    ),
                  ),
                ),
                // 13.horizontalSpace,
                Spacer(),

                // Settings Icon (always present)
                GestureDetector(
                  onTap: () async {
                    await Navigator.pushNamed(context, AppRoutes.settings.path);
                    onSettingsReturn?.call();
                  },
                  child: Image.asset(
                    AppIcons.setting,
                    height: 24.r,
                    width: 24.r,
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
