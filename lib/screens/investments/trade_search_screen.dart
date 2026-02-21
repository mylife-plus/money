import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/investment_activity_model.dart';
import 'package:moneyapp/services/currency_service.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/trades/trade_item_pair.dart';
import 'package:moneyapp/widgets/trades/transaction_item.dart';

class TradeSearchScreen extends StatefulWidget {
  const TradeSearchScreen({super.key});

  @override
  State<TradeSearchScreen> createState() => _TradeSearchScreenState();
}

class _TradeSearchScreenState extends State<TradeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<InvestmentActivity> _filteredActivities = [];
  final InvestmentController _controller = Get.find<InvestmentController>();

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

  /// Format double value as string for display
  String _formatAmount(double? value) {
    if (value == null) return '0';
    // Remove trailing zeros
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  /// Format price/total value as string
  String _formatPrice(double? value) {
    if (value == null) return '0';
    return value.toStringAsFixed(2);
  }

  /// Get investment ticker by ID
  String _getInvestmentTicker(int? investmentId) {
    if (investmentId == null) return '???';
    final investment = _controller.getInvestmentById(investmentId);
    return investment?.ticker ?? '???';
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredActivities = [];
      });
      return;
    }

    final allActivities = _controller.activities;

    // Filter activities (both transactions and trades) based on search query
    final lowerQuery = query.toLowerCase();
    _filteredActivities = allActivities.where((activity) {
      final description = (activity.description ?? '').toLowerCase();

      if (activity.isTrade) {
        // Search trade fields
        final soldTicker = _getInvestmentTicker(
          activity.tradeSoldInvestmentId,
        ).toLowerCase();
        final boughtTicker = _getInvestmentTicker(
          activity.tradeBoughtInvestmentId,
        ).toLowerCase();
        final soldAmount = _formatAmount(
          activity.tradeSoldAmount,
        ).toLowerCase();
        final boughtAmount = _formatAmount(
          activity.tradeBoughtAmount,
        ).toLowerCase();
        final soldTotal = _formatPrice(activity.tradeSoldTotal).toLowerCase();
        final boughtTotal = _formatPrice(
          activity.tradeBoughtTotal,
        ).toLowerCase();

        return soldTicker.contains(lowerQuery) ||
            boughtTicker.contains(lowerQuery) ||
            soldAmount.contains(lowerQuery) ||
            boughtAmount.contains(lowerQuery) ||
            soldTotal.contains(lowerQuery) ||
            boughtTotal.contains(lowerQuery) ||
            description.contains(lowerQuery);
      } else {
        // Search transaction fields
        final ticker = _getInvestmentTicker(
          activity.transactionInvestmentId,
        ).toLowerCase();
        final amount = _formatAmount(activity.transactionAmount).toLowerCase();
        final price = _formatPrice(activity.transactionPrice).toLowerCase();
        final total = _formatPrice(activity.transactionTotal).toLowerCase();
        final direction = activity.isDeposit ? 'deposit' : 'withdraw';

        return ticker.contains(lowerQuery) ||
            amount.contains(lowerQuery) ||
            price.contains(lowerQuery) ||
            total.contains(lowerQuery) ||
            direction.contains(lowerQuery) ||
            description.contains(lowerQuery);
      }
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
                    'Search Activities',
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
                  if (_filteredActivities.isNotEmpty) ...[
                    10.verticalSpace,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        '${_filteredActivities.length} result${_filteredActivities.length == 1 ? '' : 's'} found',
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
                  : _filteredActivities.isEmpty
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
            'Search for activities',
            size: 16.sp,
            color: AppColors.greyColor,
            fontWeight: FontWeight.w400,
          ),
          8.verticalSpace,
          CustomText(
            'Try searching by symbol, amount, total, or type',
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
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      itemCount: _filteredActivities.length,
      separatorBuilder: (context, index) => 10.verticalSpace,
      itemBuilder: (context, index) {
        final activity = _filteredActivities[index];

        if (activity.isTrade) {
          return TradeItemPair(
            tradeId: activity.id,
            soldAmount: _formatAmount(activity.tradeSoldAmount),
            soldSymbol: _getInvestmentTicker(activity.tradeSoldInvestmentId),
            soldPrice: _formatPrice(activity.tradeSoldPrice),
            soldPriceSymbol: CurrencyService.instance.portfolioCode,
            soldTotal: _formatPrice(activity.tradeSoldTotal),
            soldTotalSymbol: CurrencyService.instance.portfolioCode,
            boughtAmount: _formatAmount(activity.tradeBoughtAmount),
            boughtSymbol: _getInvestmentTicker(
              activity.tradeBoughtInvestmentId,
            ),
            boughtPrice: _formatPrice(activity.tradeBoughtPrice),
            boughtPriceSymbol: CurrencyService.instance.portfolioCode,
            boughtTotal: _formatPrice(activity.tradeBoughtTotal),
            boughtTotalSymbol: CurrencyService.instance.portfolioCode,
          );
        } else {
          return TransactionItem(
            activity: activity,
            symbol: _getInvestmentTicker(activity.transactionInvestmentId),
            isSelected: false,
            onSelect: (id) {},
            onDelete: (id) {
              _controller.deleteTrades([id]);
              _performSearch(_searchController.text);
            },
            isSelectionMode: false,
          );
        }
      },
    );
  }
}
