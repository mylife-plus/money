import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final String categoryGroup;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? prefixColor;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.categoryGroup,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xffDFDFDF),
    this.textColor = Colors.black,
    this.prefixColor = const Color(0xffA0A0A0),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 41.h,
        padding: EdgeInsets.fromLTRB(8.r, 0.r, 11.r, 0.r),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(7.r),
          border: Border.all(color: borderColor!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(categoryGroup, size: 12.sp, color: Color(0xffB4B4B4)),
            Center(
              child: CustomText.richText(
                children: [
                  CustomText.span('# ', size: 16.sp, color: prefixColor),
                  CustomText.span(category, size: 16.sp, color: textColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
