import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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

  bool isHashtagSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _filteredRecommendations = [];
  final GlobalKey _searchFieldKey = GlobalKey();

  // Predefined icons for selection
  final List<String> predefinedIcons = [
    AppIcons.digitalCurrency,
    AppIcons.bitcoinConvert,
    AppIcons.investment,
    AppIcons.car,
    AppIcons.atm,
    AppIcons.cart,
  ];

  // Sample recommendations - replace with your actual data
  final List<String> _allRecommendations = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Healthcare',
    'Bills & Utilities',
    'Travel',
    'Education',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);

    // Get original transaction data from arguments
    final args = Get.arguments;
    if (args != null) {
      final String title = args['title'] ?? '';
      final String amount = args['amount'] ?? '';
      final bool isExpense = args['isExpense'] ?? true;

      // Create original transaction for display
      originalTransaction = Transaction(
        id: 0,
        isExpense: isExpense,
        date: DateTime.now(),
        amount: double.tryParse(amount.replaceAll(',', '.')) ?? 0.0,
        recipient: title,
        mcc: MCC.fromAsset(
          assetPath: AppIcons.transaction,
          text: title,
          shortText: title.isNotEmpty ? title.substring(0, 1) : 'T',
        ),
        note: '',
      );

      // Initialize with 2 split items by default
      splitItems = [
        SplitItem(date: DateTime.now(), isExpense: isExpense),
        SplitItem(date: DateTime.now(), isExpense: isExpense),
      ];
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchFocusNode.dispose();
    for (var item in splitItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredRecommendations = [];
      } else {
        _filteredRecommendations = _allRecommendations
            .where(
              (item) => item.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  void _onFocusChanged() {
    // Show all recommendations when focused and field is empty
    if (_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
      setState(() {
        _filteredRecommendations = _allRecommendations;
      });
    } else if (!_searchFocusNode.hasFocus) {
      // Delay to allow tap on recommendations
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _filteredRecommendations = [];
          });
        }
      });
    }
  }

  void _selectRecommendation(String value) {
    _searchController.text = value;
    _filteredRecommendations = [];
    _searchFocusNode.unfocus();
  }

  void _addNewItem() {
    // TODO: Implement add new item logic
    print('Add new item: ${_searchController.text}');
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  void _seeAll() {
    // TODO: Implement see all logic
    print('See all recommendations');
  }

  void _addSplitItem() {
    setState(() {
      splitItems.add(
        SplitItem(
          date: DateTime.now(),
          isExpense: originalTransaction?.isExpense ?? true,
        ),
      );
    });
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

  void _saveTransaction() {
    // Validate all split items
    for (int i = 0; i < splitItems.length; i++) {
      final item = splitItems[i];

      if (item.date == null) {
        Get.snackbar('Error', 'Please select a date for item ${i + 1}');
        return;
      }

      if (item.amountController.text.isEmpty) {
        Get.snackbar('Error', 'Please enter an amount for item ${i + 1}');
        return;
      }

      final double? amount = double.tryParse(
        item.amountController.text.replaceAll(',', '.'),
      );
      if (amount == null || amount <= 0) {
        Get.snackbar('Error', 'Please enter a valid amount for item ${i + 1}');
        return;
      }

      if (item.mcc == null) {
        Get.snackbar(
          'Error',
          'Please select an MCC category for item ${i + 1}',
        );
        return;
      }
    }

    // Get HomeController
    final homeController = Get.find<HomeController>();

    // Create transactions for each split item
    for (var item in splitItems) {
      final amount = double.parse(
        item.amountController.text.replaceAll(',', '.'),
      );

      final mcc = MCC.fromAsset(
        assetPath: item.mcc!.iconPath ?? AppIcons.transaction,
        text: item.mcc!.name,
        shortText: item.mcc!.categoryName,
      );

      final newTransaction = Transaction(
        id:
            DateTime.now().millisecondsSinceEpoch +
            splitItems.indexOf(item), // Unique ID
        isExpense: item.isExpense,
        date: item.date!,
        amount: amount,
        mcc: mcc,
        recipient: item.recipientController.text.trim(),
        note: item.noteController.text.trim(),
        hashtags: item.hashtags,
      );

      homeController.addTransaction(newTransaction);
    }

    Get.back();
    Get.snackbar(
      'Success',
      '${splitItems.length} transactions added successfully',
    );
  }

  Widget _buildSplitItemWidget(int index) {
    final item = splitItems[index];
    final isIncome = !item.isExpense;

    return Container(
      decoration: BoxDecoration(
        color: isIncome ? const Color(0xffEEFFEE) : const Color(0xffFFEEEE),
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
                      InkWell(
                        onTap: () {
                          DatePickerHelper.showStyledDatePicker(
                            context,
                            initialDate: item.date,
                          ).then((pickedDate) {
                            if (pickedDate != null) {
                              setState(() {
                                item.date = pickedDate;
                              });
                            }
                          });
                        },
                        child: Container(
                          height: 41.h,
                          width: 109.w,
                          padding: EdgeInsets.only(left: 7.w, right: 12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xffDFDFDF)),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (item.date != null)
                                  CustomText(
                                    'Date',
                                    size: 12.sp,
                                    color: const Color(0xffC1C1C1),
                                  ),
                                CustomText(
                                  item.date == null
                                      ? 'select Date'
                                      : DateFormat(
                                          'dd.MM.yyyy',
                                        ).format(item.date!),
                                  size: 16.sp,
                                  color: item.date == null
                                      ? const Color(0xffB4B4B4)
                                      : Colors.black,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      10.horizontalSpace,
                      Expanded(
                        child: Container(
                          height: 41.h,
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xffDFDFDF)),
                            borderRadius: BorderRadius.circular(6.r),
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
                                color: const Color(0xffB4B4B4),
                                fontSize: 16.sp,
                              ),
                              hintStyle: TextStyle(
                                color: const Color(0xffB4B4B4),
                                fontSize: 16.sp,
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              suffixStyle: TextStyle(
                                color: const Color(0xffB4B4B4),
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
                            border: Border.all(color: const Color(0xffDFDFDF)),
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
                                color: const Color(0xffC1C1C1),
                              ),
                              3.verticalSpace,
                              Center(
                                child: item.mcc != null
                                    ? item.mcc!.getIcon(size: 17.r)
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
                            border: Border.all(color: const Color(0xffDFDFDF)),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: TextField(
                            controller: item.recipientController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Recipient',
                              labelText: 'Recipient',
                              labelStyle: TextStyle(
                                color: const Color(0xffB4B4B4),
                                fontSize: 16.sp,
                              ),
                              hintStyle: TextStyle(
                                color: const Color(0xffB4B4B4),
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
                      border: Border.all(color: const Color(0xffDFDFDF)),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: TextField(
                      controller: item.noteController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Note',
                        labelText: 'Note',
                        labelStyle: TextStyle(
                          color: const Color(0xffB4B4B4),
                          fontSize: 16.sp,
                        ),
                        hintStyle: TextStyle(
                          color: const Color(0xffB4B4B4),
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
                        onTap: () => _showHashtagSelectionDialog(index),
                        child: Image.asset(
                          AppIcons.plus,
                          width: 16.w,
                          height: 16.h,
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
                      children: item.hashtags.map((hashtag) {
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
                              item.hashtags.removeWhere(
                                (h) => h.id == hashtag.id,
                              );
                            });
                          },
                        );
                      }).toList(),
                    ),
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
                    onTap: () => Get.back(),
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
                          InkWell(
                            onTap: _addSplitItem,
                            child: Image.asset(
                              AppIcons.plus,
                              width: 21.w,
                              height: 21.h,
                            ),
                          ),
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
                            width: 136.w,
                            height: 44.h,
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
                                size: 20.sp,
                                color: const Color(0xff0071FF),
                                fontWeight: FontWeight.w500,
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
