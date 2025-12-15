import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final String categoryGroup;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? prefixColor;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const CategoryChip({
    super.key,
    required this.category,
    required this.categoryGroup,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xffDFDFDF),
    this.textColor = Colors.black,
    this.prefixColor = const Color(0xffA0A0A0),
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
              height: 42.h,
              padding: EdgeInsets.fromLTRB(8.r, 0.r, 11.r, 0.r),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(color: AppColors.greyBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4.r,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    categoryGroup,
                    size: 12.sp,
                    color: Color(0xffB4B4B4),
                  ),
                  CustomText("# $category", size: 16.sp, color: Colors.black),
                ],
              ),
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: -6.h,
              right: -6.w,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 20.r,
                  height: 20.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.greyColor),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 14.sp,
                    color: AppColors.greyColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
