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
                // Action Icon (in container with shadow)
                GestureDetector(
                  onTap: onActionIconTap,
                  child: Container(
                    height: 43.h,
                    width: 46.w,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.all(Radius.circular(12.r)),
                      border: Border.all(
                        color: AppColors.greyBorder,
                        width: 1.w,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(11.r)),
                      child: Stack(
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.12),
                                  Colors.black.withValues(alpha: 0.04),
                                  Colors.transparent,
                                  Colors.white.withValues(alpha: 0.3),
                                ],
                                stops: const [0.0, 0.15, 0.5, 1.0],
                              ),
                            ),
                            child: const SizedBox.expand(),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.black.withValues(alpha: 0.06),
                                  Colors.transparent,
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.03),
                                ],
                                stops: const [0.0, 0.2, 0.8, 1.0],
                              ),
                            ),
                            child: const SizedBox.expand(),
                          ),
                          Center(
                            child: Image.asset(
                              actionIconPath,
                              height: 32.r,
                              width: 32.r,
                            ),
                          ),
                        ],
                      ),
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
