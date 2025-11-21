import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class SettingsTile extends StatelessWidget {
  final Widget? icon;
  final String title;
  final Widget? trailing;
  final String? titleSuffix;
  final VoidCallback? onTap;
  final Color? titleColor;

  const SettingsTile({
    super.key,
    this.icon,
    required this.title,
    this.titleSuffix,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: trailing != null ? 0.h : 12.h,
          horizontal: 12.w,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              SizedBox(width: 24, height: 24, child: Center(child: icon)),
              10.horizontalSpace,
            ],
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: CustomText(
                      title,
                      size: 16.sp,
                      color: titleColor ?? Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (titleSuffix != null) ...[
                    CustomText(
                      titleSuffix!,
                      size: 16.sp,
                      color: Color(0xff9F9F9F),
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ],
              ),
            ),
            10.horizontalSpace,

            if (trailing != null)
              trailing!
            else
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
