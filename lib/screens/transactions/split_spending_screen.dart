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

import 'package:moneyapp/widgets/common/category_chip.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/hashtag/hashtag_selection_dialog.dart';
import 'package:moneyapp/widgets/mcc/mcc_selection_dialog.dart';
import 'package:moneyapp/widgets/transactions/transaction_item.dart';

class SplitSpendingScreen extends StatefulWidget {
  const SplitSpendingScreen({super.key});

  @override
  State<SplitSpendingScreen> createState() => _SplitSpendingScreenState();
}

// Data model for each split item
class SplitItem {
  DateTime? date;
  bool isExpense;
  TextEditingController amountController;
  MCCItem? mcc;
  TextEditingController recipientController;
  TextEditingController noteController;
  List<HashtagGroup> hashtags;

  SplitItem({
    this.date,
    this.isExpense = true,
    MCCItem? mcc,
    List<HashtagGroup>? hashtags,
  }) : amountController = TextEditingController(),
       recipientController = TextEditingController(),
       noteController = TextEditingController(),
       mcc = mcc,
       hashtags = hashtags ?? [];

  void dispose() {
    amountController.dispose();
    recipientController.dispose();
    noteController.dispose();
  }
}

class _SplitSpendingScreenState extends State<SplitSpendingScreen> {
  final MCCController mccController = Get.find<MCCController>();
  final HashtagGroupsController hashtagController =
      Get.find<HashtagGroupsController>();

  Transaction? originalTransaction;
  List<SplitItem> splitItems = [];

  // Predefined icons for selection
  final List<String> predefinedIcons = [
    AppIcons.digitalCurrency,
    AppIcons.bitcoinConvert,
    AppIcons.investment,
    AppIcons.car,
    AppIcons.atm,
    AppIcons.cart,
  ];

  @override
  void initState() {
    super.initState();

    // Get original transaction data from arguments
    final args = Get.arguments;
    if (args != null) {
      if (args['transaction'] != null && args['transaction'] is Transaction) {
        // Use the passed transaction object directly
        originalTransaction = args['transaction'] as Transaction;

        // Initialize with 2 split items
        splitItems = [
          SplitItem(
            date: originalTransaction!.date,
            isExpense: originalTransaction!.isExpense,
            mcc: originalTransaction!.mccId != null
                ? mccController.getMCCById(originalTransaction!.mccId!)
                : null,
            hashtags: originalTransaction!.hashtags.map((h) {
              return hashtagController.findGroupById(h.id ?? -1) ?? h;
            }).toList(),
          ),
          SplitItem(
            date: originalTransaction!.date,
            isExpense: originalTransaction!.isExpense,
          ),
        ];

        // Item 1: Pre-fill specific details
        splitItems[0].amountController.text = originalTransaction!.amount
            .toStringAsFixed(2)
            .replaceAll('.', ',');
        splitItems[0].recipientController.text = originalTransaction!.recipient;
        splitItems[0].noteController.text = originalTransaction!.note;

        // Item 2: Empty/Default (Amount 0, no MCC, nohashtags)
        splitItems[1].amountController.text = '0,00';
      } else {
        // Fallback to manual args if transaction object missing (legacy/safety)
        final String title = args['title'] ?? '';
        final String amount = args['amount'] ?? '';
        final bool isExpense = args['isExpense'] ?? true;

        originalTransaction = Transaction(
          id: 0,
          isExpense: isExpense,
          date: DateTime.now(),
          amount: double.tryParse(amount.replaceAll(',', '.')) ?? 0.0,
          recipient: title,
          mccId: null,
          note: '',
        );

        splitItems = [
          SplitItem(date: DateTime.now(), isExpense: isExpense),
          SplitItem(date: DateTime.now(), isExpense: isExpense),
        ];

        splitItems[0].amountController.text = amount.replaceAll('.', ',');
        splitItems[1].amountController.text = '0,00';
      }

      // Add listeners for auto-calculation
      splitItems[0].amountController.addListener(() => _onAmountChanged(0));
      splitItems[1].amountController.addListener(() => _onAmountChanged(1));
    }
  }

  bool _isUpdating = false;

  void _onAmountChanged(int index) {
    if (_isUpdating || originalTransaction == null) return;

    final otherIndex = index == 0 ? 1 : 0;
    final otherController = splitItems[otherIndex].amountController;
    final currentController = splitItems[index].amountController;

    final currentText = currentController.text.replaceAll(',', '.');
    final double currentAmount = double.tryParse(currentText) ?? 0.0;
    final double totalAmount = originalTransaction!.amount;

    // effective remaining
    double otherAmount = totalAmount - currentAmount;
    if (otherAmount < 0) otherAmount = 0;

    final formattedOther = otherAmount.toStringAsFixed(2).replaceAll('.', ',');

    // Only update if value is different to avoid cursor jumping/loops
    // (though _isUpdating handles loops, this is good practice)
    if (otherController.text != formattedOther) {
      _isUpdating = true;
      otherController.text = formattedOther;
      _isUpdating = false;
    }
  }

  @override
  void dispose() {
    for (var item in splitItems) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _showHashtagSelectionDialog(int index) async {
    await showDialog(
      context: context,
      builder: (context) => HashtagSelectionDialog(
        onSelected: (hashtag) {
          setState(() {
            // Add hashtag if not already selected
            if (!splitItems[index].hashtags.any((h) => h.id == hashtag.id)) {
              splitItems[index].hashtags.add(hashtag);
            }
          });
        },
      ),
    );

    // Refresh selected hashtags to ensure latest data (names, etc.)
    setState(() {
      splitItems[index].hashtags = splitItems[index].hashtags
          .map((h) => hashtagController.findGroupById(h.id ?? -1) ?? h)
          .toList();
    });
  }

  Future<void> _showMCCSelectionDialog(int index) async {
    await showDialog(
      context: context,
      builder: (context) => MCCSelectionDialog(
        onSelected: (mcc) {
          setState(() {
            splitItems[index].mcc = mcc;
          });
        },
      ),
    );
  }

  void _showSnackbar(String title, String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(message),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    // Validate all split items
    for (int i = 0; i < splitItems.length; i++) {
      final item = splitItems[i];

      if (item.date == null) {
        _showSnackbar('Error', 'Please select a date for item ${i + 1}');
        return;
      }

      if (item.amountController.text.isEmpty) {
        _showSnackbar('Error', 'Please enter an amount for item ${i + 1}');
        return;
      }

      final double? amount = double.tryParse(
        item.amountController.text.replaceAll(',', '.'),
      );
      if (amount == null || amount <= 0) {
        _showSnackbar('Error', 'Please enter a valid amount for item ${i + 1}');
        return;
      }

      // New: Recipient is mandatory
      if (item.recipientController.text.trim().isEmpty) {
        _showSnackbar('Error', 'Please enter a recipient for item ${i + 1}');
        return;
      }

      // New: MCC is optional (removed check)
    }

    // Validate total sum matches original transaction
    double totalSplitAmount = 0;
    for (var item in splitItems) {
      totalSplitAmount +=
          double.tryParse(item.amountController.text.replaceAll(',', '.')) ??
          0.0;
    }

    // Allow a small epsilon for floating point errors
    if ((totalSplitAmount - originalTransaction!.amount).abs() > 0.01) {
      _showSnackbar('Error', 'Amount not match');
      return;
    }

    // Get HomeController
    final homeController = Get.find<HomeController>();

    try {
      // Create/Update transactions
      for (int i = 0; i < splitItems.length; i++) {
        final item = splitItems[i];
        final amount = double.parse(
          item.amountController.text.replaceAll(',', '.'),
        );

        // If this is the first item and we have a valid original transaction ID, update it
        if (i == 0 &&
            originalTransaction!.id != null &&
            originalTransaction!.id != 0) {
          final updatedTx = originalTransaction!.copyWith(
            amount: amount,
            date: item.date,
            isExpense: item.isExpense,
            mccId: item.mcc?.id, // Can be null
            recipient: item.recipientController.text.trim(),
            note: item.noteController.text.trim(),
            hashtags: item.hashtags,
            updatedAt: DateTime.now(),
          );
          await homeController.updateTransaction(updatedTx);
        } else {
          // Otherwise create a new transaction
          final newTx = Transaction(
            id: DateTime.now().millisecondsSinceEpoch + i, // Unique ID
            isExpense: item.isExpense,
            date: item.date!,
            amount: amount,
            mccId: item.mcc?.id, // Can be null
            recipient: item.recipientController.text.trim(),
            note: item.noteController.text.trim(),
            hashtags: item.hashtags,
          );
          await homeController.addTransaction(newTx);
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      _showSnackbar('Success', 'Item split successfully', isError: false);
    } catch (e) {
      _showSnackbar('Error', 'Failed to save splits: $e');
    }
  }

  Widget _buildSplitItemWidget(int index) {
    final item = splitItems[index];
    final isIncome = !item.isExpense;

    return Container(
      decoration: BoxDecoration(
        color: isIncome ? const Color(0xffE5FFE7) : const Color(0xffFFEEEE),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Padding(
        padding: EdgeInsets.only(right: 33.w, top: 10.h, bottom: 10.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            10.horizontalSpace,
            CustomText('${index + 1}.', size: 20.sp, color: Colors.black),
            10.horizontalSpace,
            Expanded(
              child: Column(
                children: [
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
                            text: item.date != null
                                ? DateFormat('dd.MM.yyyy').format(item.date!)
                                : '',
                          ),
                          readOnly: true,
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: item.date ?? DateTime.now(),
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
                                item.date = picked;
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
                            controller: item.amountController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0,00',
                              labelText: isIncome ? 'Income' : 'Spending',
                              prefix: Image.asset(
                                isIncome ? AppIcons.plus : AppIcons.minus,
                                width: 16.w,
                                height: 16.h,
                                color: isIncome
                                    ? const Color(0xff00C00D)
                                    : const Color(0xffFF0000),
                              ),
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
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: isIncome
                                  ? const Color(0xff00C00D)
                                  : const Color(0xffFF0000),
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
                        onTap: () => _showMCCSelectionDialog(index),
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
                                child: item.mcc != null
                                    ? item.mcc!.getIcon(size: 15.r)
                                    : Image.asset(
                                        AppIcons.shopIcon,
                                        height: 17.r,
                                        width: 19.r,
                                        color: const Color(0xffC9C9C9),
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
                            controller: item.recipientController,
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
                      controller: item.noteController,
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
                      hashtagController.allGroups.length;

                      return Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          InkWell(
                            onTap: () => _showHashtagSelectionDialog(index),
                            child: Container(
                              height: 42.h,
                              width: 37.w,
                              padding: EdgeInsets.fromLTRB(5.r, 0.r, 5.r, 0.r),
                              decoration: BoxDecoration(
                                color: Colors.white,
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
                          ...item.hashtags.map((hashtag) {
                            // Find latest hashtag data
                            final currentHashtag =
                                hashtagController.findGroupById(
                                  hashtag.id ?? -1,
                                ) ??
                                hashtag;

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
                                  item.hashtags.removeWhere(
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (originalTransaction == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 21.w, vertical: 8.h),
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
                  CustomText(
                    originalTransaction!.isExpense
                        ? 'Split Spending'
                        : 'Split Income',
                    size: 16.sp,
                    color: Colors.black,
                  ),
                  SizedBox(width: 21.w),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 7.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      6.verticalSpace,
                      TransactionItem(
                        transaction: originalTransaction!,
                        isSelected: false,
                      ),
                      21.verticalSpace,
                      Row(
                        children: [
                          8.horizontalSpace,
                          Expanded(
                            child: CustomText(
                              'into',
                              size: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          // Plus button removed as per requirement (limit to 2 options)
                          13.horizontalSpace,
                        ],
                      ),
                      8.verticalSpace,
                      // Build all split items dynamically
                      ...List.generate(
                        splitItems.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(bottom: 8.h),
                          child: _buildSplitItemWidget(index),
                        ),
                      ),
                      39.verticalSpace,
                      Align(
                        alignment: Alignment.center,
                        child: InkWell(
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
                                'confirm',
                                size: 16.sp,
                                color: const Color(0xff0071FF),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                      24.verticalSpace,
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
