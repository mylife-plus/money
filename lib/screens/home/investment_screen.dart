import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/investment_list_item.dart';
import 'package:moneyapp/models/investment_model.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/screens/filter/portfolio_filter_screen.dart';
import 'package:moneyapp/screens/investments/new_trade_transaction_screen.dart';
import 'package:moneyapp/screens/investments/trade_search_screen.dart';
import 'package:moneyapp/services/currency_service.dart';
import 'package:moneyapp/widgets/common/custom_app_bar.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/common/custom_toggle_switch.dart';
import 'package:moneyapp/widgets/common/selection_app_bar.dart';
import 'package:moneyapp/widgets/common/slide_from_top_route.dart';
import 'package:moneyapp/utils/number_format_helper.dart';
import 'package:moneyapp/widgets/investments/investment_item.dart';
import 'package:moneyapp/widgets/investments/portfolio_section.dart';
import 'package:moneyapp/widgets/trades/trade_item_pair.dart';
import 'package:moneyapp/widgets/trades/transaction_item.dart';
import 'package:moneyapp/widgets/transactions/top_sort_sheet.dart';

/// Investment Screen
/// Main investment screen of the app
class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _lastScrollOffset = 0;
  bool _isAppBarVisible = true;
  bool _showScrollToTop = false;
  bool _isFabVisible = true;
  bool _isAtTop = true;
  static const double _scrollThreshold = 5.0;

  // Selection state
  final List<int> _selectedActivityIds = [];
  Worker? _toggleWorker;

  bool get _isSelectionMode => _selectedActivityIds.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _scrollController.addListener(_onScroll);

    // Clear selection state whenever the tab changes (portfolio ↔ trades).
    final controller = Get.find<InvestmentController>();
    _toggleWorker = ever(controller.selectedToggleOption, (_) {
      if (_selectedActivityIds.isNotEmpty) {
        setState(() {
          _selectedActivityIds.clear();
        });
      }
    });
  }

  void _onScroll() {
    // Don't hide app bar while in selection mode
    if (_isSelectionMode) return;

    final currentScrollOffset = _scrollController.offset;
    final scrollDelta = currentScrollOffset - _lastScrollOffset;
    bool needsRebuild = false;

    if (currentScrollOffset > 200 && !_showScrollToTop) {
      _showScrollToTop = true;
      needsRebuild = true;
    } else if (currentScrollOffset <= 200 && _showScrollToTop) {
      _showScrollToTop = false;
      needsRebuild = true;
    }

    if (_isAtTop && currentScrollOffset > 1) {
      setState(() => _isAtTop = false);
    } else if (!_isAtTop && currentScrollOffset <= 3) {
      setState(() => _isAtTop = true);
    }

    if (scrollDelta.abs() < _scrollThreshold) {
      _lastScrollOffset = currentScrollOffset;
      return;
    }

    if (scrollDelta > 0 && currentScrollOffset > 50) {
      if (_isAppBarVisible) {
        _isAppBarVisible = false;
        _animationController.reverse();
      }
      if (_isFabVisible) {
        _isFabVisible = false;
        needsRebuild = true;
      }
    } else if (scrollDelta < 0) {
      if (!_isAppBarVisible) {
        _isAppBarVisible = true;
        _animationController.forward();
      }
      if (!_isFabVisible) {
        _isFabVisible = true;
        needsRebuild = true;
      }
    }

    if (needsRebuild) setState(() {});
    _lastScrollOffset = currentScrollOffset;
  }

  void _cancelSelection() {
    setState(() {
      _selectedActivityIds.clear();
    });
  }

  void _deleteSelectedActivities() {
    final controller = Get.find<InvestmentController>();
    final ids = List<int>.from(_selectedActivityIds);
    controller.deleteTrades(ids).then((_) {
      if (mounted) {
        setState(() {
          _selectedActivityIds.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _toggleWorker?.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InvestmentController>();

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isSelectionMode
          ? null
          : AnimatedOpacity(
              opacity: _isFabVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_isFabVisible,
                child: InkWell(
                  onTap: () {
                    final controller = Get.find<InvestmentController>();
                    Navigator.push(
                      context,
                      SlideFromTopRoute(
                        page: NewTradeTransactionScreen(
                          fromPortfolio: controller.isPortfolioSelected,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 51.r,
                    width: 51.r,
                    decoration: BoxDecoration(
                      color: const Color(0xffFFCC00),
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                    child: Center(
                      child: Image.asset(
                        AppIcons.roundedPlus,
                        height: 27.r,
                        width: 27.r,
                      ),
                    ),
                  ),
                ),
              ),
            ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: [
                // Top bar: SelectionAppBar (screen level) OR animated CustomAppBar
                if (_isSelectionMode)
                  SelectionAppBar(
                    selectedCount: _selectedActivityIds.length,
                    onCancel: _cancelSelection,
                    onDelete: _deleteSelectedActivities,
                  )
                else
                  SizeTransition(
                    sizeFactor: _animation,
                    child: FadeTransition(
                      opacity: _animation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomAppBar(
                            title: 'Investments',
                            leadingIconPath: AppIcons.investmentGraphIcon,
                            actionIconPath: AppIcons.transaction,
                            showYellowBackground: _isAtTop,
                            onActionIconTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.home.path,
                              );
                            },
                            onSettingsReturn: () {
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                // Main content — CustomScrollView for proper virtualization
                Expanded(
                  child: Obx(() {
                    final isPortfolio = controller.isPortfolioSelected;

                    if (isPortfolio) {
                      return FutureBuilder<List<Map<String, dynamic>>>(
                        future: controller.filteredEnrichedInvestmentData,
                        builder: (context, snapshot) {
                          final enrichedData = snapshot.data ?? [];
                          return CustomScrollView(
                            controller: _scrollController,
                            slivers: [
                              // Toggle switch
                              SliverToBoxAdapter(
                                child: _buildToggleSwitch(controller),
                              ),
                              // Chart section
                              SliverToBoxAdapter(
                                child: PortfolioSection(
                                  isPortfolioSelected: true,
                                ),
                              ),
                              if (enrichedData.isEmpty)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 23.0.w,
                                    ),
                                    child: Column(
                                      children: [
                                        33.verticalSpace,
                                        CustomText(
                                          'you have no 📈Investments',
                                          size: 20.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        33.verticalSpace,
                                        CustomText(
                                          "make your initial deposit by clicking ➕ or add multiple Trades/Transactions via ⚙️Settings → ⬆️ Upload 📈Investments ",
                                          size: 20.sp,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                          textAlign: TextAlign.center,
                                        ),
                                        150.verticalSpace,
                                      ],
                                    ),
                                  ),
                                )
                              else ...[
                                // Column headers
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 9.w,
                                      right: 9.w,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 140,
                                          child: CustomText(
                                            'Investment',
                                            textAlign: TextAlign.center,
                                            color: Color(0xffCCCCCC),
                                            size: 14.sp,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 100,
                                          child: CustomText(
                                            textAlign: TextAlign.center,
                                            'Price',
                                            color: Color(0xffCCCCCC),
                                            size: 14.sp,
                                          ),
                                        ),
                                        10.horizontalSpace,
                                        Expanded(
                                          flex: 140,
                                          child: CustomText(
                                            'Total',
                                            textAlign: TextAlign.center,
                                            color: Color(0xffCCCCCC),
                                            size: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: SizedBox(height: 11.h),
                                ),
                                // Portfolio items — virtualized SliverList
                                SliverList.builder(
                                  itemCount: enrichedData.length,
                                  itemBuilder: (context, index) {
                                    final data = enrichedData[index];
                                    return _buildPortfolioItem(data);
                                  },
                                ),
                                // Bottom spacing
                                SliverToBoxAdapter(
                                  child: SizedBox(height: 150),
                                ),
                              ],
                            ],
                          );
                        },
                      );
                    }

                    final items = controller.visibleActivities.toList();
                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        // Toggle switch
                        SliverToBoxAdapter(
                          child: _buildToggleSwitch(controller),
                        ),
                        // Trades toolbar
                        SliverToBoxAdapter(
                          child: _buildTradesToolbar(controller),
                        ),
                        // Trades list — virtualized SliverList
                        _buildTradesSliverList(items, controller),
                        // Bottom spacing
                        SliverToBoxAdapter(child: SizedBox(height: 150)),
                      ],
                    );
                  }),
                ),
              ],
            ),
            if (_showScrollToTop && !_isSelectionMode)
              Positioned(
                bottom: 40.h,
                right: 30.w,
                child: AnimatedOpacity(
                  opacity: _isFabVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !_isFabVisible,
                    child: InkWell(
                      onTap: () {
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        height: 30.r,
                        width: 30.r,
                        decoration: BoxDecoration(
                          color: const Color(0xffFFCC00),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(2.r),
                            child: Image.asset(
                              AppIcons.arrowUp,
                              color: Colors.white,
                            ),
                          ),
                        ),
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

  /// Toggle switch shared between portfolio and trades views
  Widget _buildToggleSwitch(InvestmentController controller) {
    return Offstage(
      offstage: _isSelectionMode,
      child: CustomToggleSwitch(
        option1Color: const Color(0xff0071FF),
        option2Color: const Color(0xff0071FF),
        iconColorShouldEffect: true,
        option1IconPath: AppIcons.chartBlue,
        option1Text: 'Portfolio',
        option2IconPath: AppIcons.historyIcon,
        option2Text: 'History',
        selectedOption: controller.selectedToggleOption.value,
        onOption1Tap: controller.selectPortfolio,
        onOption2Tap: controller.selectHistory,
      ),
    );
  }

  /// Build a single portfolio investment item
  Widget _buildPortfolioItem(Map<String, dynamic> data) {
    final investment = data['investment'] as Investment;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 1.5.h),
      child: InkWell(
        key: ValueKey('portfolio_${investment.id}'),
        onTap: () {
          Get.toNamed(
            AppRoutes.investmentValueHistory.path,
            arguments: investment,
          );
        },
        child: InvestmentItem(
          backgroundColor: investment.color,
          imageWidget: _buildInvestmentImage(investment.imagePath),
          name: investment.name,
          amount: NumberFormatHelper.formatAmount(
            data['amount'] as double,
            locale: CurrencyService.instance.portfolioLocale,
          ),
          symbol: investment.ticker,
          unitPrice: (data['hasPrice'] as bool)
              ? '${CurrencyService.instance.portfolioSymbol}${NumberFormatHelper.formatCurrency(data['latestPrice'] as double, locale: CurrencyService.instance.portfolioLocale)}'
              : 'No price data',
          totalValue: (data['hasPrice'] as bool)
              ? '${CurrencyService.instance.portfolioSymbol}${NumberFormatHelper.formatCurrency(data['totalValue'] as double, locale: CurrencyService.instance.portfolioLocale)}'
              : '---',
        ),
      ),
    );
  }

  /// Build investment image from path
  Widget _buildInvestmentImage(String? imagePath) {
    if (imagePath != null && imagePath.isNotEmpty) {
      if (imagePath.startsWith('assets/')) {
        return Image.asset(imagePath, height: 16.r, width: 16.r);
      } else {
        final file = File(imagePath);
        if (file.existsSync()) {
          return Image.file(file, height: 16.r, width: 16.r, fit: BoxFit.cover);
        }
      }
    }
    return Icon(Icons.image, size: 16.r, color: AppColors.greyColor);
  }

  /// Trades toolbar (sort, filter, search)
  Widget _buildTradesToolbar(InvestmentController controller) {
    return Column(
      children: [
        40.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.0.w),
          child: Row(
            children: [
              InkWell(
                onTap: () async {
                  await TopSortSheet.show(
                    context: context,
                    title: 'Sorting',
                    selectedOption: controller.selectedSortOption.value,
                    selectedDirection: controller.selectedSortDirection.value,
                    onOptionSelected: (option, direction) {
                      controller.updateSortOption(option, direction);
                    },
                  );
                },
                child: Image.asset(AppIcons.sort, height: 24.r, width: 24.r),
              ),
              40.horizontalSpace,
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    SlideFromTopRoute(page: const PortfolioFilterScreen()),
                  );
                },
                child: Obx(
                  () => Badge(
                    isLabelVisible: controller.activeFilterCount > 0,
                    label: Text(controller.activeFilterCount.toString()),
                    child: Image.asset(
                      AppIcons.filter,
                      height: 24.r,
                      width: 24.r,
                    ),
                  ),
                ),
              ),
              40.horizontalSpace,
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    SlideFromTopRoute(page: const TradeSearchScreen()),
                  );
                },
                child: Image.asset(AppIcons.search, height: 24.r, width: 24.r),
              ),
              Spacer(),
            ],
          ),
        ),
        16.verticalSpace,
      ],
    );
  }

  /// Virtualized trades list as a Sliver
  SliverList _buildTradesSliverList(
    List<InvestmentListItem> items,
    InvestmentController controller,
  ) {
    return SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final nextItem = index < items.length - 1 ? items[index + 1] : null;

        // Calculate bottom spacing based on item type transitions
        double bottomSpacing = 0;
        if (item is InvestmentActivityItem) {
          if (nextItem is InvestmentActivityItem) {
            bottomSpacing = 10.h;
          } else if (nextItem is InvestmentDayHeaderItem) {
            bottomSpacing = 22.h;
          } else {
            bottomSpacing = 9.h;
          }
        } else if (item is InvestmentDayHeaderItem) {
          bottomSpacing = 9.h;
        } else if (item is InvestmentMonthHeaderItem) {
          bottomSpacing = 13.h;
        } else if (item is InvestmentYearHeaderItem &&
            nextItem is InvestmentMonthHeaderItem) {
          bottomSpacing = 18.h;
        }

        return Padding(
          padding: EdgeInsets.only(bottom: bottomSpacing),
          child: _buildTradeItem(item, controller),
        );
      },
    );
  }

  /// Build individual trade/transaction item widget
  Widget _buildTradeItem(
    InvestmentListItem item,
    InvestmentController controller,
  ) {
    return switch (item) {
      InvestmentYearHeaderItem(:final year) => Padding(
        key: ValueKey('inv_year_$year'),
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: InkWell(
          onTap: () => controller.toggleYearExpansion(year),
          child: Row(
            children: [
              CustomText(
                year.toString(),
                color: AppColors.greyColor,
                size: 16.sp,
              ),
              5.horizontalSpace,
              Icon(
                controller.isYearExpanded(year)
                    ? Icons.arrow_drop_down_rounded
                    : Icons.arrow_drop_up_rounded,
                size: 32.r,
                color: AppColors.greyColor,
              ),
            ],
          ),
        ),
      ),

      InvestmentMonthHeaderItem(:final year, :final month, :final monthName) =>
        Padding(
          key: ValueKey('inv_month_${year}_$month'),
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: InkWell(
            onTap: () => controller.toggleMonthExpansion(year, month),
            child: Row(
              children: [
                CustomText(monthName, color: AppColors.greyColor, size: 16.sp),
                5.horizontalSpace,
                Icon(
                  controller.isMonthExpanded(year, month)
                      ? Icons.arrow_drop_down_rounded
                      : Icons.arrow_drop_up_rounded,
                  size: 32.r,
                  color: AppColors.greyColor,
                ),
              ],
            ),
          ),
        ),

      InvestmentDayHeaderItem(
        :final day,
        :final monthAbbr,
        :final showHeaders,
      ) =>
        Padding(
          key: ValueKey('inv_day_${day}_$monthAbbr'),
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Row(
            children: [
              8.horizontalSpace,
              Expanded(
                flex: 100,
                child: CustomText(
                  '$day. $monthAbbr.',
                  textAlign: TextAlign.start,
                  color: Color(0xffCCCCCC),
                  size: 14.sp,
                ),
              ),
              if (showHeaders) ...[
                Expanded(
                  flex: 100,
                  child: CustomText(
                    textAlign: TextAlign.center,
                    'Amount/Price',
                    color: Color(0xffCCCCCC),
                    size: 14.sp,
                  ),
                ),
                Expanded(
                  flex: 150,
                  child: CustomText(
                    'Total',
                    textAlign: TextAlign.center,
                    color: Color(0xffCCCCCC),
                    size: 14.sp,
                  ),
                ),
              ] else ...[
                Expanded(flex: 100, child: SizedBox()),
                Expanded(flex: 150, child: SizedBox()),
              ],
            ],
          ),
        ),

      InvestmentActivityItem(:final activity) => Padding(
        key: ValueKey('inv_activity_${activity.id}'),
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: activity.isTrade
            ? TradeItemPair(
                tradeId: activity.id,
                soldAmount: item.soldAmount ?? '',
                soldSymbol: item.soldSymbol ?? '???',
                soldPrice: item.soldPrice ?? '',
                soldPriceSymbol: CurrencyService.instance.portfolioCode,
                soldTotal: item.soldTotal ?? '',
                soldTotalSymbol: CurrencyService.instance.portfolioCode,
                boughtAmount: item.boughtAmount ?? '',
                boughtSymbol: item.boughtSymbol ?? '???',
                boughtPrice: item.boughtPrice ?? '',
                boughtPriceSymbol: CurrencyService.instance.portfolioCode,
                boughtTotal: item.boughtTotal ?? '',
                boughtTotalSymbol: CurrencyService.instance.portfolioCode,
                isSelected: _selectedActivityIds.contains(activity.id),
                onSelect: (id) {
                  setState(() {
                    if (_selectedActivityIds.contains(id)) {
                      _selectedActivityIds.remove(id);
                    } else {
                      _selectedActivityIds.add(id);
                    }
                  });
                },
                onDelete: (id) {
                  controller.deleteTrades([id]);
                },
                onEdit: (id) {
                  Navigator.push(
                    context,
                    SlideFromTopRoute(
                      page: NewTradeTransactionScreen(
                        editingActivity: activity,
                      ),
                    ),
                  );
                },
                isSelectionMode: _selectedActivityIds.isNotEmpty,
              )
            : TransactionItem(
                activity: activity,
                symbol: item.transactionSymbol ?? '???',
                isSelected: _selectedActivityIds.contains(activity.id),
                onSelect: (id) {
                  setState(() {
                    if (_selectedActivityIds.contains(id)) {
                      _selectedActivityIds.remove(id);
                    } else {
                      _selectedActivityIds.add(id);
                    }
                  });
                },
                onDelete: (id) {
                  controller.deleteTrades([id]);
                },
                onEdit: (id) {
                  Navigator.push(
                    context,
                    SlideFromTopRoute(
                      page: NewTradeTransactionScreen(
                        editingActivity: activity,
                      ),
                    ),
                  );
                },
                isSelectionMode: _selectedActivityIds.isNotEmpty,
              ),
      ),

      InvestmentSpacerItem() => const SizedBox.shrink(),
    };
  }
}
