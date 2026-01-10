import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/trades/trade_item_pair.dart';

class TradeSearchScreen extends StatefulWidget {
  const TradeSearchScreen({super.key});

  @override
  State<TradeSearchScreen> createState() => _TradeSearchScreenState();
}

class _TradeSearchScreenState extends State<TradeSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Trade> _filteredTrades = [];

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
        _filteredTrades = [];
      });
      return;
    }

    final controller = Get.find<InvestmentController>();
    final allTrades = controller.trades;

    // Filter trades based on search query
    final lowerQuery = query.toLowerCase();
    _filteredTrades = allTrades.where((trade) {
      final soldSymbol = trade.soldSymbol.toLowerCase();
      final boughtSymbol = trade.boughtSymbol.toLowerCase();
      final soldAmount = trade.soldAmount.toLowerCase();
      final boughtAmount = trade.boughtAmount.toLowerCase();
      final soldTotal = trade.soldTotal.toLowerCase();
      final boughtTotal = trade.boughtTotal.toLowerCase();

      return soldSymbol.contains(lowerQuery) ||
          boughtSymbol.contains(lowerQuery) ||
          soldAmount.contains(lowerQuery) ||
          boughtAmount.contains(lowerQuery) ||
          soldTotal.contains(lowerQuery) ||
          boughtTotal.contains(lowerQuery);
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
                  CustomText('Search Trades', size: 16.sp, color: Colors.black),
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
                  if (_filteredTrades.isNotEmpty) ...[
                    10.verticalSpace,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        '${_filteredTrades.length} result${_filteredTrades.length == 1 ? '' : 's'} found',
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
                  : _filteredTrades.isEmpty
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
            'Search for trades',
            size: 16.sp,
            color: AppColors.greyColor,
            fontWeight: FontWeight.w400,
          ),
          8.verticalSpace,
          CustomText(
            'Try searching by symbol, amount, or total',
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
        itemCount: _filteredTrades.length,
        separatorBuilder: (context, index) => 10.verticalSpace,
        itemBuilder: (context, index) {
          final trade = _filteredTrades[index];
          return TradeItemPair(
            soldAmount: trade.soldAmount,
            soldSymbol: trade.soldSymbol,
            soldPrice: trade.soldPrice,
            soldPriceSymbol: trade.soldPriceSymbol,
            soldTotal: trade.soldTotal,
            soldTotalSymbol: trade.soldTotalSymbol,
            boughtAmount: trade.boughtAmount,
            boughtSymbol: trade.boughtSymbol,
            boughtPrice: trade.boughtPrice,
            boughtPriceSymbol: trade.boughtPriceSymbol,
            boughtTotal: trade.boughtTotal,
            boughtTotalSymbol: trade.boughtTotalSymbol,
          );
        },
      ),
    );
  }
}
