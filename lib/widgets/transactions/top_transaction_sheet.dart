import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class TopTransactionSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onClose;

  const TopTransactionSheet({
    super.key,
    required this.title,
    required this.child,
    this.onClose,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    VoidCallback? onClose,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return TopTransactionSheet(
          title: title,
          onClose: onClose,
          child: child,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8.r),
              bottomRight: Radius.circular(8.r),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 22.r),
                      CustomText(
                        title,
                        size: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (onClose != null) {
                            onClose!();
                          }
                          Navigator.of(context).pop();
                        },
                        child: Image.asset(
                          AppIcons.tickLight,
                          height: 22.r,
                          width: 22.r,
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(child: SingleChildScrollView(child: child)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
