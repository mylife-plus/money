import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/investment_recommendation.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/investments/investment_selection_dialog.dart';

class InvestmentListScreen extends StatelessWidget {
  const InvestmentListScreen({super.key});

  Future<void> _showAddDialog(BuildContext context) async {
    await showDialog<InvestmentRecommendation>(
      context: context,
      builder: (context) => AddEditInvestmentDialog(),
    );
  }

  Future<void> _showEditDialog(
    BuildContext context,
    InvestmentRecommendation investment,
  ) async {
    await showDialog<InvestmentRecommendation>(
      context: context,
      builder: (context) =>
          AddEditInvestmentDialog(existingInvestment: investment),
    );
  }

  Future<void> _deleteInvestment(
    BuildContext context,
    InvestmentRecommendation investment,
  ) async {
    final InvestmentController controller = Get.find();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        title: CustomText(
          'Delete Investment',
          size: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        content: CustomText(
          'Are you sure you want to delete "${investment.text}"? This action cannot be undone.',
          size: 14.sp,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: CustomText(
              'Cancel',
              size: 14.sp,
              color: const Color(0xff707070),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: CustomText(
              'Delete',
              size: 14.sp,
              color: const Color(0xffFF0000),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final index = controller.recommendations.indexOf(investment);
      if (index != -1) {
        controller.removeRecommendation(index);
        Get.snackbar(
          'Success',
          'Investment deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final InvestmentController controller = Get.find();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            8.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 21.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      AppIcons.backArrow,
                      width: 21.h,
                      height: 21.h,
                    ),
                  ),
                  CustomText('Investments', size: 16.sp, color: Colors.black),
                  21.horizontalSpace,
                ],
              ),
            ),
            30.verticalSpace,

            Expanded(
              child: Obx(
                () => ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  itemCount: controller.recommendations.length,
                  separatorBuilder: (context, index) => 4.verticalSpace,
                  itemBuilder: (context, index) {
                    final investment = controller.recommendations[index];
                    return _InvestmentListItem(
                      investment: investment,
                      onEdit: () => _showEditDialog(context, investment),
                      onDelete: () => _deleteInvestment(context, investment),
                    );
                  },
                ),
              ),
            ),

            // Add button at the bottom
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 20.h),
              child: InkWell(
                onTap: () => _showAddDialog(context),
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: const Color(0xff0088FF),
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 20.sp),
                        8.horizontalSpace,
                        CustomText(
                          'Add New Investment',
                          size: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvestmentListItem extends StatelessWidget {
  final InvestmentRecommendation investment;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InvestmentListItem({
    required this.investment,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Image/Icon Container
        Container(
          height: 35.h,
          width: 40.w,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xffDFDFDF)),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: investment.isAssetImage
                ? Image.asset(investment.assetPath!, width: 16.w, height: 16.h)
                : investment.isFileImage
                ? Image.file(investment.imageFile!, width: 16.w, height: 16.h)
                : Icon(
                    Icons.image,
                    size: 16.sp,
                    color: const Color(0xffB4B4B4),
                  ),
          ),
        ),
        6.horizontalSpace,
        // Investment Name Field
        Expanded(
          child: Container(
            height: 35.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xffDFDFDF)),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: CustomText(
                investment.text,
                size: 14.sp,
                color: Colors.black,
              ),
            ),
          ),
        ),
        4.horizontalSpace,
        // Short Text Field
        Container(
          height: 35.h,
          width: 56.w,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xffDFDFDF)),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: CustomText(
              investment.shortText,
              size: 14.sp,
              color: Colors.black,
            ),
          ),
        ),
        4.horizontalSpace,
        // Color Indicator
        Container(
          height: 35.h,
          width: 40.w,
          decoration: BoxDecoration(
            color: investment.color ?? Colors.white,
            border: Border.all(color: const Color(0xffDFDFDF)),
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        12.horizontalSpace,
        // Edit Icon
        InkWell(
          onTap: onEdit,
          child: Image.asset(AppIcons.edit, width: 22.r, height: 22.r),
        ),
        8.horizontalSpace,
        // Delete Icon
        InkWell(
          onTap: onDelete,
          child: Icon(Icons.delete, size: 22.r, color: const Color(0xffFF0000)),
        ),
      ],
    );
  }
}
