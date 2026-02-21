import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/constants/app_theme.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/investment_model.dart';
import 'package:moneyapp/models/portfolio_snapshot_model.dart';
import 'package:moneyapp/services/currency_service.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/investments/price_entry_dialog.dart';

class InvestmentValueHistoryScreen extends StatefulWidget {
  const InvestmentValueHistoryScreen({super.key});

  @override
  State<InvestmentValueHistoryScreen> createState() =>
      _InvestmentValueHistoryScreenState();
}

class _InvestmentValueHistoryScreenState
    extends State<InvestmentValueHistoryScreen> {
  final InvestmentController controller = Get.find();
  late Investment investment;
  List<PortfolioSnapshot> snapshots = [];
  bool _isLoading = true;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Get investment from arguments
    investment = Get.arguments as Investment;
    _loadSnapshots();
  }

  Future<void> _loadSnapshots() async {
    setState(() => _isLoading = true);
    snapshots = await controller.getSnapshotsForInvestment(investment.id!);
    setState(() => _isLoading = false);
  }

  void _showSnackbar(String title, String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(message, style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showAddPriceDialog() {
    showDialog(
      context: context,
      builder: (context) => PriceEntryDialog(
        onSave: (date, unitPrice, note) async {
          await controller.addManualPriceSnapshot(
            investmentId: investment.id!,
            unitPrice: unitPrice,
            date: date,
            note: note,
          );
          await _loadSnapshots();
          _showSnackbar('Success', 'Price added successfully', isError: false);
        },
      ),
    );
  }

  void _showEditPriceDialog(int index) {
    final snapshot = snapshots[index];
    showDialog(
      context: context,
      builder: (context) => PriceEntryDialog(
        initialDate: snapshot.date,
        initialUnitPrice: snapshot.unitPrice,
        initialNote: snapshot.note,
        onDelete: () {
          Navigator.pop(context);
          _deleteEntry(index);
        },
        onSave: (date, unitPrice, note) async {
          // Update snapshot (would need updateSnapshot method in controller)
          // For now, delete and recreate
          await controller.deleteSnapshot(snapshot.id!);
          await controller.addManualPriceSnapshot(
            investmentId: investment.id!,
            unitPrice: unitPrice,
            date: date,
            note: note,
          );
          await _loadSnapshots();
          _showSnackbar(
            'Success',
            'Price updated successfully',
            isError: false,
          );
        },
      ),
    );
  }

  Future<void> _deleteEntry(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        title: CustomText(
          'Delete Price',
          size: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        content: CustomText(
          'Are you sure you want to delete this price entry?',
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
      await controller.deleteSnapshot(snapshots[index].id!);
      await _loadSnapshots();
      _showSnackbar('Success', 'Price deleted successfully', isError: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: Image.asset(
                      AppIcons.backArrow,
                      width: 21.h,
                      height: 21.h,
                    ),
                  ),
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: Image.file(
                          File(investment.imagePath),
                          height: 16.r,
                          width: 16.r,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.image,
                            size: 16.sp,
                            color: AppColors.greyColor,
                          ),
                        ),
                      ),
                      8.horizontalSpace,
                      CustomText(
                        '${investment.name} Prices',
                        size: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _showAddPriceDialog,
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

            // Content
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : snapshots.isEmpty
                  ? Center(
                      child: CustomText(
                        'No price history yet',
                        size: 16.sp,
                        color: AppColors.greyColor,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: 33.h,
                          left: 35.w,
                          right: 24.w,
                        ),
                        child: Column(
                          spacing: 6.h,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 0; i < snapshots.length; i++)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  vertical: 6.h,
                                  horizontal: 11.w,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4.r),
                                  border: Border.all(
                                    color: AppColors.greyBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Date Container
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomText(
                                            DateFormat(
                                              'dd.MM.yyyy',
                                            ).format(snapshots[i].date),
                                            size: 20.sp,
                                            color: Colors.black,
                                          ),
                                          if (snapshots[i].note != null &&
                                              snapshots[i].note!.isNotEmpty)
                                            CustomText(
                                              snapshots[i].note!,
                                              size: 12.sp,
                                              color: AppColors.greyColor,
                                            ),
                                        ],
                                      ),
                                    ),

                                    // Price Container
                                    CustomText(
                                      '${CurrencyService.instance.portfolioSymbol} ${NumberFormat('#,##0.00').format(snapshots[i].unitPrice)}',
                                      size: 20.sp,
                                      color: Colors.black,
                                    ),
                                    CustomText(
                                      ' ${CurrencyService.instance.portfolioCode}',
                                      size: 12.sp,
                                      color: AppColors.greyColor,
                                    ),
                                    20.horizontalSpace,
                                    // Edit Icon (only for manual entries)
                                    if (snapshots[i].isManualPrice)
                                      InkWell(
                                        onTap: () => _showEditPriceDialog(i),
                                        child: Image.asset(
                                          AppIcons.edit,
                                          width: 22.r,
                                          height: 22.r,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
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
