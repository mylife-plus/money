import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/hashtag_groups_controller.dart';
import 'package:moneyapp/controllers/home_controller.dart';
import 'package:moneyapp/controllers/mcc_controller.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/models/mcc_model.dart';
import 'package:moneyapp/models/transaction_model.dart';
import 'package:moneyapp/utils/date_picker_helper.dart';
import 'package:moneyapp/widgets/common/category_chip.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/hashtag/hashtag_selection_dialog.dart';
import 'package:moneyapp/widgets/mcc/mcc_selection_dialog.dart';

class NewTransactionScreen extends StatefulWidget {
  const NewTransactionScreen({super.key});

  @override
  State<NewTransactionScreen> createState() => _NewTransactionScreenState();
}

class _NewTransactionScreenState extends State<NewTransactionScreen> {
  final MCCController mccController = Get.find<MCCController>();
  final HashtagGroupsController hashtagController =
      Get.find<HashtagGroupsController>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController recipientController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  DateTime? selectedDate = DateTime.now();
  bool isAddingIncome = false;
  MCCItem? selectedMCC;
  List<HashtagGroup> selectedHashtags = [];

  Transaction? existingTransaction;
  bool get isEditMode => existingTransaction != null;

  @override
  void initState() {
    super.initState();

    // Check if editing existing transaction
    existingTransaction = Get.arguments?['transaction'] as Transaction?;

    if (isEditMode && existingTransaction != null) {
      // Populate fields with existing data
      isAddingIncome = !existingTransaction!.isExpense;
      selectedDate = existingTransaction!.date;
      amountController.text = existingTransaction!.amount.toStringAsFixed(2);
      recipientController.text = existingTransaction!.recipient;
      noteController.text = existingTransaction!.note;
      selectedHashtags = List.from(existingTransaction!.hashtags);

      // Find matching MCC from controller
      selectedMCC = mccController.mccItems.firstWhereOrNull(
        (item) => item.name == existingTransaction!.mcc.text,
      );
    } else {
      final bool isExpenseSelected =
          Get.arguments?['isExpenseSelected'] ?? true;
      isAddingIncome = !isExpenseSelected;
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    recipientController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _showMCCSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => MCCSelectionDialog(
        onSelected: (mcc) {
          setState(() {
            selectedMCC = mcc;
          });
        },
      ),
    );
  }

  Future<void> _showHashtagSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => HashtagSelectionDialog(
        onSelected: (hashtag) {
          setState(() {
            // Add hashtag if not already selected
            if (!selectedHashtags.any((h) => h.id == hashtag.id)) {
              selectedHashtags.add(hashtag);
            }
          });
        },
      ),
    );
  }

  void _saveTransaction() {
    // Validate inputs
    if (selectedDate == null) {
      Get.snackbar('Error', 'Please select a date');
      return;
    }

    if (amountController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter an amount');
      return;
    }

    final double? amount = double.tryParse(
      amountController.text.replaceAll(',', '.'),
    );
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount');
      return;
    }

    if (selectedMCC == null) {
      Get.snackbar('Error', 'Please select an MCC category');
      return;
    }

    // Create MCC object from selectedMCC
    final mcc = MCC.fromAsset(
      assetPath: selectedMCC!.iconPath ?? AppIcons.transaction,
      text: selectedMCC!.name,
      shortText: selectedMCC!.categoryName,
    );

    // Get HomeController
    final homeController = Get.find<HomeController>();

    if (isEditMode && existingTransaction != null) {
      // Update existing transaction
      final updatedTransaction = existingTransaction!.copyWith(
        isExpense: !isAddingIncome,
        date: selectedDate!,
        amount: amount,
        mcc: mcc,
        recipient: recipientController.text.trim(),
        note: noteController.text.trim(),
        hashtags: selectedHashtags,
        updatedAt: DateTime.now(),
      );

      // Find and update the transaction in the list
      final index = homeController.transactions.indexWhere(
        (t) => t.id == existingTransaction!.id,
      );
      if (index != -1) {
        homeController.updateTransaction(index, updatedTransaction);
      }

      Get.back();
      Get.snackbar('Success', 'Transaction updated successfully');
    } else {
      // Create new transaction
      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch, // Simple ID generation
        isExpense: !isAddingIncome,
        date: selectedDate!,
        amount: amount,
        mcc: mcc,
        recipient: recipientController.text.trim(),
        note: noteController.text.trim(),
        hashtags: selectedHashtags,
      );

      homeController.addTransaction(newTransaction);
      Get.back();
      Get.snackbar('Success', 'Transaction added successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: Image.asset(
                      AppIcons.backArrow,
                      width: 21.h,
                      height: 21.h,
                    ),
                  ),
                  CustomText(
                    isEditMode ? 'Edit Transaction' : 'New Transaction',
                    size: 16.sp,
                    color: Colors.black,
                  ),
                  SizedBox(width: 21.w),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 33.w),
                  child: Column(
                    children: [
                      12.verticalSpace,
                      Row(
                        children: [
                          Container(
                            height: 41.h,
                            width: 109.w,
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.greyBorder),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: TextField(
                              controller: TextEditingController(
                                text: selectedDate != null
                                    ? DateFormat(
                                        'dd.MM.yyyy',
                                      ).format(selectedDate!)
                                    : '',
                              ),
                              readOnly: true,
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.black,
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (picked != null) {
                                  setState(() {
                                    selectedDate = picked;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Select Date',
                                labelText: 'Date',
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
                                suffixStyle: TextStyle(
                                  color: AppColors.greyColor,
                                  fontSize: 16.sp,
                                ),
                              ),
                              style: TextStyle(fontSize: 16.sp),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          8.horizontalSpace,
                          InkWell(
                            onTap: () {
                              setState(() {
                                isAddingIncome = !isAddingIncome;
                              });
                            },
                            child: Container(
                              height: 37.h,
                              width: 39.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(
                                  color: AppColors.greyBorder,
                                  width: 1,
                                ),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  isAddingIncome
                                      ? AppIcons.plus
                                      : AppIcons.minus,
                                  color: isAddingIncome
                                      ? const Color(0xff00C00D)
                                      : const Color(0xffFF0000),
                                  width: 20.w,
                                  height: 20.h,
                                ),
                              ),
                            ),
                          ),
                          4.horizontalSpace,
                          Expanded(
                            child: Container(
                              height: 41.h,
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.greyBorder),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: TextField(
                                controller: amountController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '0,00',
                                  labelText: isAddingIncome
                                      ? 'Income'
                                      : 'Spending',
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
                                  suffixStyle: TextStyle(
                                    color: AppColors.greyColor,
                                    fontSize: 16.sp,
                                  ),
                                  suffixText: 'EUR',
                                ),
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: isAddingIncome
                                      ? Color(0xff00C00D)
                                      : Color(0xffFF0000),
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ),
                        ],
                      ),
                      7.verticalSpace,

                      Row(
                        children: [
                          InkWell(
                            onTap: _showMCCSelectionDialog,
                            child: Container(
                              height: 41.h,
                              width: 35.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.greyBorder),
                                borderRadius: BorderRadius.circular(4.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  CustomText(
                                    'MCC',
                                    size: 12.sp,
                                    color: AppColors.greyColor,
                                  ),
                                  3.verticalSpace,
                                  Center(
                                    child: selectedMCC != null
                                        ? selectedMCC!.getIcon(size: 17.r)
                                        : Image.asset(
                                            AppIcons.shopIcon,
                                            height: 17.r,
                                            width: 19.r,
                                            color: AppColors.greyColor,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          8.horizontalSpace,

                          Expanded(
                            child: Container(
                              height: 41.h,

                              padding: EdgeInsets.symmetric(
                                horizontal: 7.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.greyBorder),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: TextField(
                                controller: recipientController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Recipient',
                                  labelText: 'Recipient',
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
                        ],
                      ),
                      7.verticalSpace,
                      Container(
                        height: 41.h,

                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppColors.greyBorder),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: TextField(
                          controller: noteController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Note',
                            labelText: 'Note',
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
                      7.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            'Hashtags',
                            size: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          InkWell(
                            onTap: _showHashtagSelectionDialog,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                AppIcons.plus,
                                width: 16.w,
                                height: 16.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                      7.verticalSpace,
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: selectedHashtags.map((hashtag) {
                            // Find parent group name
                            String categoryGroup = 'Main Group';
                            if (hashtag.isSubgroup) {
                              final mainGroup = hashtagController.allGroups
                                  .firstWhereOrNull(
                                    (g) => g.id == hashtag.parentId,
                                  );
                              categoryGroup = mainGroup?.name ?? 'Unknown';
                            }

                            return CategoryChip(
                              category: hashtag.name,
                              categoryGroup: categoryGroup,
                              onRemove: () {
                                setState(() {
                                  selectedHashtags.removeWhere(
                                    (h) => h.id == hashtag.id,
                                  );
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      23.verticalSpace,
                      InkWell(
                        onTap: _saveTransaction,
                        child: Container(
                          width: 120.w,
                          height: 41.h,
                          decoration: BoxDecoration(
                            color: const Color(0xffFFFFFF),
                            borderRadius: BorderRadius.circular(13.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Center(
                            child: CustomText(
                              isEditMode ? 'Save' : 'Add',
                              size: 16.sp,
                              color: Color(0xff0071FF),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
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
