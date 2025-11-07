import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/widgets/custom_text.dart';

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

  const CustomAppBar({
    super.key,
    required this.title,
    required this.leadingIconPath,
    required this.actionIconPath,
    this.onActionIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(21.w, 11.h, 11.w, 0),
      child: Row(
        children: [
          // Title Section with Leading Icon
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Image.asset(leadingIconPath, height: 32.r, width: 32.r),
                5.horizontalSpace,
                CustomText(
                  title,
                  color: AppColors.appBarText,
                  size: 20.r,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),

          // Action Icons Section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Action Icon (in container with shadow)
              GestureDetector(
                onTap: onActionIconTap,
                child: Container(
                  height: 43.w,
                  width: 46.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(12.r)),
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
              13.horizontalSpace,

              // Settings Icon (always present)
              GestureDetector(
                onTap: () {
                  // Navigate to settings screen
                  Get.toNamed(AppRoutes.settings.path);
                },
                child: Image.asset(AppIcons.setting, height: 24.r, width: 24.r),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
