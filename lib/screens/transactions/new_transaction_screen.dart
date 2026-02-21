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

import 'package:moneyapp/services/currency_service.dart';
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
  final HashtagGroupsController hashtagController = Get.put(
    HashtagGroupsController(),
  );

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
      amountController.text = existingTransaction!.amount
          .toStringAsFixed(2)
          .replaceAll('.', ',');
      recipientController.text = existingTransaction!.recipient;
      noteController.text = existingTransaction!.note;
      selectedHashtags = existingTransaction!.hashtags.map((h) {
        return hashtagController.findGroupById(h.id ?? -1) ?? h;
      }).toList();

      // Get existing transaction mccId which is now nullable
      if (existingTransaction!.mccId != null) {
        selectedMCC = mccController.getMCCById(existingTransaction!.mccId!);
      } else {
        selectedMCC = null;
      }
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

    // Refresh selected hashtags to ensure latest data (names, etc.)
    setState(() {
      selectedHashtags = selectedHashtags.map((h) {
        return hashtagController.findGroupById(h.id ?? -1) ?? h;
      }).toList();
    });
  }

  void _showSnackbar(String title, String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    message,
                    style: TextStyle(fontSize: 12.sp, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(10.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Validate inputs
    if (selectedDate == null) {
      _showSnackbar('Error', 'Please select a date');
      return;
    }

    if (amountController.text.isEmpty) {
      _showSnackbar('Error', 'Please enter an amount');
      return;
    }

    final double? amount = double.tryParse(
      amountController.text.replaceAll(',', '.'),
    );
    if (amount == null || amount <= 0) {
      _showSnackbar('Error', 'Please enter a valid amount');
      return;
    }

    // New Requirement: Recipient is Mandatory
    if (recipientController.text.trim().isEmpty) {
      _showSnackbar('Error', 'Please enter a recipient');
      return;
    }

    // New Requirement: MCC is Optional (Removed check)

    // Get HomeController
    final homeController = Get.find<HomeController>();

    if (isEditMode && existingTransaction != null) {
      // Update existing transaction
      final updatedTransaction = existingTransaction!.copyWith(
        isExpense: !isAddingIncome,
        date: selectedDate!,
        amount: amount,
        mccId: selectedMCC?.id, // Can be null now
        recipient: recipientController.text.trim(),
        note: noteController.text.trim(),
        hashtags: selectedHashtags,
        updatedAt: DateTime.now(),
      );

      await homeController.updateTransaction(updatedTransaction);

      if (!mounted) return;
      Navigator.pop(context);
      _showSnackbar(
        'Success',
        'Transaction updated successfully',
        isError: false,
      );
    } else {
      // Create new transaction
      final newTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch, // Simple ID generation
        isExpense: !isAddingIncome,
        date: selectedDate!,
        amount: amount,
        mccId: selectedMCC?.id, // Can be null now
        recipient: recipientController.text.trim(),
        note: noteController.text.trim(),
        hashtags: selectedHashtags,
      );

      await homeController.addTransaction(newTransaction);
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackbar(
        'Success',
        'Transaction added successfully',
        isError: false,
      );
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
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      AppIcons.backArrow,
                      width: 21.h,
                      height: 21.h,
                    ),
                  ),
                  CustomText(
                    isEditMode ? 'Edit Cashflow' : 'New Cashflow',
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
                                        colorScheme: ColorScheme.light(
                                          primary: AppColors.primary,
                                          onPrimary: Colors.black,
                                          surface: AppColors.background,
                                        ),
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
                                  suffixText:
                                      CurrencyService.instance.cashflowCode,
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
                                  // 3.verticalSpace,
                                  Center(
                                    child: selectedMCC != null
                                        ? selectedMCC!.getIcon(size: 15.r)
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
                                  hintText: '',
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
                        constraints: BoxConstraints(minHeight: 41.h),
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
                          minLines: 1,
                          maxLines: 4,
                          maxLength: 150,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '',
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
                            counterText: "", // Hide the counter
                          ),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                      7.verticalSpace,

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Obx(() {
                          // Register dependency to avoid "improper use of GetX" when list is empty
                          // This ensures the widget rebuilds when groups are loaded/updated
                          // Accessing .length is required to register the listener on the RxList
                          hashtagController.allGroups.length;

                          return Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: [
                              InkWell(
                                onTap: _showHashtagSelectionDialog,
                                child: Container(
                                  height: 42.h,
                                  width: 37.w,
                                  padding: EdgeInsets.fromLTRB(
                                    5.r,
                                    0.r,
                                    5.r,
                                    0.r,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4.r),
                                    border: Border.all(
                                      color: AppColors.greyBorder,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 4.r,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CustomText(
                                        'Add',
                                        size: 12.sp,
                                        color: AppColors.greyColor,
                                      ),
                                      CustomText(
                                        '#',
                                        size: 16.sp,
                                        color: Color(0xff0088FF),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ...selectedHashtags.map((hashtag) {
                                // Find latest hashtag data from controller to ensure updates are reflected
                                // and parent references are correct
                                final currentHashtag =
                                    hashtagController.findGroupById(
                                      hashtag.id ?? -1,
                                    ) ??
                                    hashtag;

                                // Find parent group name
                                String categoryGroup = 'Main Group';
                                if (currentHashtag.isSubgroup) {
                                  final mainGroup = hashtagController.allGroups
                                      .firstWhereOrNull(
                                        (g) => g.id == currentHashtag.parentId,
                                      );
                                  categoryGroup = mainGroup?.name ?? 'Unknown';
                                }

                                return CategoryChip(
                                  category: currentHashtag.name,
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
                            ],
                          );
                        }),
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
