import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/home_controller.dart';
import 'package:moneyapp/controllers/mcc_controller.dart';
import 'package:moneyapp/models/transaction_model.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/transactions/transaction_item.dart';

class TransactionSearchScreen extends StatefulWidget {
  const TransactionSearchScreen({super.key});

  @override
  State<TransactionSearchScreen> createState() =>
      _TransactionSearchScreenState();
}

class _TransactionSearchScreenState extends State<TransactionSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Transaction> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredTransactions = [];
      });
      return;
    }

    final controller = Get.find<HomeController>();
    final mccController = Get.find<MCCController>();
    final allTransactions = <Transaction>[];

    // Collect all transactions directly from the source
    // Note: We might want to filter by the current expense/income toggle if desired,
    // but typically search searches everything.
    // If we want to search everything:
    allTransactions.addAll(controller.transactions);

    // If we wanted to search only filtered (e.g. only expenses if on expense tab):
    // allTransactions.addAll(controller.filteredTransactions);

    // Filter transactions based on search query
    final lowerQuery = query.toLowerCase();
    _filteredTransactions = allTransactions.where((transaction) {
      final recipient = transaction.recipient.toLowerCase();
      final mcc = mccController.getMCCById(transaction.mccId);
      final mccText = mcc?.name.toLowerCase() ?? '';
      final mccCode = mcc?.mccCode?.toLowerCase() ?? '';
      final hashtags = transaction.hashtags
          .map((h) => h.name.toLowerCase())
          .join(' ');
      final note = transaction.note.toLowerCase();
      final amount = transaction.amount.toStringAsFixed(2).replaceAll('.', ',');

      return recipient.contains(lowerQuery) ||
          mccText.contains(lowerQuery) ||
          mccCode.contains(lowerQuery) ||
          hashtags.contains(lowerQuery) ||
          note.contains(lowerQuery) ||
          amount.contains(lowerQuery);
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header matching new_transaction_screen
            Padding(
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
                  CustomText(
                    'Search Transactions',
                    size: 16.sp,
                    color: Colors.black,
                  ),
                  SizedBox(width: 21.w),
                ],
              ),
            ),

            // Search field matching new_transaction_screen text field style
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 33.w),
              child: Column(
                children: [
                  12.verticalSpace,
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
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: AppColors.greyColor,
                          size: 20.r,
                        ),
                        8.horizontalSpace,
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onChanged: _performSearch,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '',
                              labelText: 'Search',
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
                        if (_searchController.text.isNotEmpty)
                          InkWell(
                            onTap: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                            child: Icon(
                              Icons.clear,
                              color: AppColors.greyColor,
                              size: 20.r,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_filteredTransactions.isNotEmpty) ...[
                    10.verticalSpace,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        '${_filteredTransactions.length} result${_filteredTransactions.length == 1 ? '' : 's'} found',
                        size: 14.sp,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ],
                  15.verticalSpace,
                ],
              ),
            ),

            // Search Results
            Expanded(
              child: _searchController.text.isEmpty
                  ? _buildEmptyState()
                  : _filteredTransactions.isEmpty
                  ? _buildNoResultsState()
                  : _buildSearchResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppIcons.search,
            height: 60.r,
            width: 60.r,
            color: AppColors.greyColor.withValues(alpha: 0.3),
          ),
          20.verticalSpace,
          CustomText(
            'Search for transactions',
            size: 16.sp,
            color: AppColors.greyColor,
            fontWeight: FontWeight.w400,
          ),
          8.verticalSpace,
          CustomText(
            'Try searching by description, category, or amount',
            size: 14.sp,
            color: AppColors.greyColor.withValues(alpha: 0.7),
            fontWeight: FontWeight.w300,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 60.r,
            color: AppColors.greyColor.withValues(alpha: 0.3),
          ),
          20.verticalSpace,
          CustomText(
            'No results found',
            size: 16.sp,
            color: AppColors.greyColor,
            fontWeight: FontWeight.w400,
          ),
          8.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: CustomText(
              'Try adjusting your search terms',
              size: 14.sp,
              color: AppColors.greyColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w300,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        itemCount: _filteredTransactions.length,
        separatorBuilder: (context, index) => 8.verticalSpace,
        itemBuilder: (context, index) {
          final transaction = _filteredTransactions[index];
          return TransactionItem(
            transaction: transaction,
            isSelected: false,
            onSelect: (id) {},
            isSelectionMode: false,
          );
        },
      ),
    );
  }
}
