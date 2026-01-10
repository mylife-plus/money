import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/investment_recommendation.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/investments/investment_selection_dialog.dart';

class InvestmentListScreen extends StatefulWidget {
  const InvestmentListScreen({super.key});

  @override
  State<InvestmentListScreen> createState() => _InvestmentListScreenState();
}

class _InvestmentListScreenState extends State<InvestmentListScreen> {
  final TextEditingController searchController = TextEditingController();
  List<InvestmentRecommendation> filteredInvestments = [];
  late final InvestmentController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<InvestmentController>();
    filteredInvestments = controller.recommendations;
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      if (searchController.text.isEmpty) {
        filteredInvestments = controller.recommendations;
      } else {
        filteredInvestments = controller.recommendations
            .where(
              (investment) => investment.text.toLowerCase().contains(
                searchController.text.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Success',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Investment deleted successfully',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Expanded(
                    child: CustomText(
                      'Investments',
                      textAlign: TextAlign.center,
                      size: 16.sp,
                      color: Colors.black,
                    ),
                  ),
                  InkWell(
                    onTap: () => _showAddDialog(context),
                    child: Image.asset(
                      AppIcons.plus,
                      color: AppColors.greyColor,
                      width: 21.h,
                      height: 21.h,
                    ),
                  ),
                ],
              ),
            ),
            38.verticalSpace,

            // Search field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: Container(
                height: 41.h,
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.greyBorder),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '',
                    suffixIcon: Icon(
                      Icons.search,
                      size: 20.sp,
                      color: AppColors.greyColor,
                    ),
                    suffixIconConstraints: BoxConstraints(
                      minWidth: 24.w,
                      minHeight: 24.h,
                    ),
                    label: Text('Search Investment'),

                    labelStyle: TextStyle(
                      color: AppColors.greyColor,
                      fontSize: 16.sp,
                    ),
                    hintStyle: TextStyle(
                      color: AppColors.greyColor,
                      fontSize: 16.sp,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: TextStyle(fontSize: 16.sp),
                ),
              ),
            ),
            16.verticalSpace,

            Expanded(
              child: Obx(() {
                // Update filtered list when recommendations change
                if (searchController.text.isEmpty) {
                  filteredInvestments = controller.recommendations;
                } else {
                  filteredInvestments = controller.recommendations
                      .where(
                        (investment) => investment.text.toLowerCase().contains(
                          searchController.text.toLowerCase(),
                        ),
                      )
                      .toList();
                }

                return ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  itemCount: filteredInvestments.length,
                  separatorBuilder: (context, index) => 4.verticalSpace,
                  itemBuilder: (context, index) {
                    final investment = filteredInvestments[index];
                    return _InvestmentListItem(
                      investment: investment,
                      onTap: () => Navigator.pop(context, investment),
                      onEdit: () => _showEditDialog(context, investment),
                      onDelete: () => _deleteInvestment(context, investment),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvestmentListItem extends StatelessWidget {
  final InvestmentRecommendation investment;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InvestmentListItem({
    required this.investment,
    this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: investment.color,
          border: Border.all(color: AppColors.greyBorder),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image/Icon Container
            investment.isAssetImage
                ? Image.asset(investment.assetPath!, width: 16.w, height: 16.h)
                : investment.isFileImage
                ? Image.file(investment.imageFile!, width: 16.w, height: 16.h)
                : Icon(
                    Icons.image,
                    size: 16.sp,
                    color: const Color(0xffB4B4B4),
                  ),
            23.horizontalSpace,

            Expanded(
              child: CustomText(
                investment.text,
                size: 20.sp,
                color: Colors.black,
              ),
            ),
            4.horizontalSpace,
            // Short Text Field
            CustomText(investment.shortText, size: 20.sp, color: Colors.black),
            20.horizontalSpace,

            // Edit Icon (only show in non-selection mode)
            InkWell(
              onTap: onEdit,
              child: Image.asset(AppIcons.edit, width: 22.r, height: 22.r),
            ),
          ],
        ),
      ),
    );
  }
}
