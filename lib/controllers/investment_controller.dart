import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/models/investment_model.dart';
import 'package:moneyapp/models/investment_activity_model.dart';
import 'package:moneyapp/models/portfolio_snapshot_model.dart';
import 'package:moneyapp/models/investment_list_item.dart';
import 'package:moneyapp/services/investment_service.dart';
import 'package:moneyapp/widgets/transactions/top_sort_sheet.dart';

/// Investment Controller
/// Manages state and business logic for Investment Screen
/// Now uses database-backed InvestmentService
class InvestmentController extends GetxController {
  final InvestmentService _service = InvestmentService();

  // Observable state
  final RxInt selectedToggleOption = 1.obs; // 1 = Portfolio, 2 = Trades
  final RxBool isLoading = false.obs;

  // Sorting state
  final Rx<SortOption?> selectedSortOption = Rx<SortOption?>(
    SortOption.mostRecent,
  );
  final Rx<SortDirection?> selectedSortDirection = Rx<SortDirection?>(
    SortDirection.top,
  );

  // Filter state
  final Rx<DateTime?> filterFromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> filterToDate = Rx<DateTime?>(null);
  final RxString filterActivityType = 'Trades & Transaction'.obs;
  final RxList<int> filterInvestmentIds = <int>[].obs;
  final Rx<double?> filterMinAmount = Rx<double?>(null);
  final Rx<double?> filterMaxAmount = Rx<double?>(null);
  final RxBool isFilterActive = false.obs;

  // Portfolio duration filtering state
  final RxString selectedPortfolioDurationTab = 'All'.obs;
  final Rx<DateTime> portfolioDateStart = DateTime.now().obs;
  final Rx<DateTime> portfolioDateEnd = DateTime.now().obs;
  final Rx<DateTime> portfolioSliderMinDate = DateTime.now().obs;
  final Rx<DateTime> portfolioSliderMaxDate = DateTime.now().obs;

  /// Get count of active filters
  int get activeFilterCount {
    int count = 0;
    // Count date range as 1 filter if either from or to date is set
    if (filterFromDate.value != null || filterToDate.value != null) count++;
    // Count activity type only if not 'All' or 'Trades & Transaction'
    if (filterActivityType.value != 'All' &&
        filterActivityType.value != 'Trades & Transaction')
      count++;
    if (filterInvestmentIds.isNotEmpty) count++;
    // Count amount range as 1 filter if either min or max is set
    if (filterMinAmount.value != null || filterMaxAmount.value != null) count++;
    return count;
  }

  // Expandable state tracking for activities
  final RxSet<int> expandedYears = <int>{}.obs;
  final RxSet<String> expandedMonths = <String>{}.obs; // Format: "year-month"

  // Database-backed data
  final RxList<Investment> investments = <Investment>[].obs;
  final RxList<InvestmentActivity> activities = <InvestmentActivity>[].obs;
  final RxList<PortfolioSnapshot> portfolioHistory = <PortfolioSnapshot>[].obs;

  // Current holdings (calculated)
  final RxMap<int, double> currentHoldings = <int, double>{}.obs;

  // Enriched investment data with holdings and prices
  final RxList<Map<String, dynamic>> enrichedInvestmentData =
      <Map<String, dynamic>>[].obs;

  // Pre-computed flat list for high-performance rendering
  final RxList<InvestmentListItem> visibleActivities =
      <InvestmentListItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();

    // Watch for changes that require visible activities rebuild
    ever(expandedYears, (_) => _updateVisibleActivities());
    ever(expandedMonths, (_) => _updateVisibleActivities());
    ever(selectedSortOption, (_) => _updateVisibleActivities());
    ever(selectedSortDirection, (_) => _updateVisibleActivities());
    ever(activities, (_) => _updateVisibleActivities());
    ever(filterFromDate, (_) => _updateVisibleActivities());
    ever(filterToDate, (_) => _updateVisibleActivities());
    ever(filterActivityType, (_) => _updateVisibleActivities());
    ever(filterInvestmentIds, (_) => _updateVisibleActivities());
    ever(filterMinAmount, (_) => _updateVisibleActivities());
    ever(filterMaxAmount, (_) => _updateVisibleActivities());
    // Watch investments for name/ticker/icon changes
    ever(investments, (_) => _updateVisibleActivities());
  }

  // ==================== DATA LOADING ====================

  /// Load all data from database
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      investments.value = await _service.getAllInvestments();
      activities.value = await _service.getAllActivities();
      portfolioHistory.value = await _service.getPortfolioHistory();
      currentHoldings.value = await _service.calculateCurrentHoldings();
      enrichedInvestmentData.value = await _service
          .getInvestmentHoldingsWithPrices();

      // Expand all years and months by default
      _initializeExpansionState();

      // Initialize portfolio date range
      _initializePortfolioDates();
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh data from database
  Future<void> refreshData() async {
    await loadData();
  }

  void _initializeExpansionState() {
    expandedYears.clear();
    expandedMonths.clear();

    for (var year in sortedYears) {
      expandedYears.add(year);

      final months = getSortedMonths(year);
      for (var month in months) {
        expandedMonths.add('$year-$month');
      }
    }

    // Initial build of visible activities
    _updateVisibleActivities();
  }

  /// Initialize portfolio date range from snapshot data
  void _initializePortfolioDates() {
    if (portfolioHistory.isEmpty) {
      // No data, set to today
      final now = DateTime.now();
      portfolioSliderMinDate.value = DateTime(now.year, now.month, now.day);
      portfolioSliderMaxDate.value = DateTime(
        now.year,
        now.month,
        now.day,
        23,
        59,
        59,
        999,
      );
      portfolioDateStart.value = portfolioSliderMinDate.value;
      portfolioDateEnd.value = portfolioSliderMaxDate.value;
      selectedPortfolioDurationTab.value = 'All';
      return;
    }

    // Find earliest and latest snapshot dates
    DateTime earliest = portfolioHistory.first.date;
    DateTime latest = portfolioHistory.first.date;

    for (var snapshot in portfolioHistory) {
      if (snapshot.date.isBefore(earliest)) earliest = snapshot.date;
      if (snapshot.date.isAfter(latest)) latest = snapshot.date;
    }

    // Set slider range
    portfolioSliderMinDate.value = DateTime(
      earliest.year,
      earliest.month,
      earliest.day,
    );
    portfolioSliderMaxDate.value = DateTime(
      latest.year,
      latest.month,
      latest.day,
      23,
      59,
      59,
      999,
    );

    // Default to 'All'
    portfolioDateStart.value = portfolioSliderMinDate.value;
    portfolioDateEnd.value = portfolioSliderMaxDate.value;
    selectedPortfolioDurationTab.value = 'All';
  }

  /// Available duration tabs based on portfolio data range (max 8 tabs)
  List<String> get availablePortfolioDurationTabs {
    if (portfolioHistory.isEmpty) {
      return ['1d', '7d', '1m', '6m', 'All'];
    }

    final now = DateTime.now();
    final dataMin = portfolioSliderMinDate.value;
    final duration = now.difference(dataMin);
    final days = duration.inDays;

    final tabs = <String>['1d', '7d', '1m', '6m'];

    if (days >= 365) {
      tabs.add('1y');
    }
    if (days >= 365 * 2) {
      tabs.add('2y');
    }
    if (days >= 365 * 5) {
      tabs.add('5y');
    }

    tabs.add('All');
    return tabs;
  }

  /// Update portfolio duration tab
  void updatePortfolioDurationTab(String tab) {
    selectedPortfolioDurationTab.value = tab;

    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    DateTime start = portfolioSliderMinDate.value;

    switch (tab) {
      case '1d':
        start = DateTime(now.year, now.month, now.day);
        break;
      case '7d':
        start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
        break;
      case '2w':
        start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 13));
        break;
      case '1m':
        start = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3m':
        start = DateTime(now.year, now.month - 3, now.day);
        break;
      case '6m':
        start = DateTime(now.year, now.month - 6, now.day);
        break;
      case '1y':
        start = DateTime(now.year - 1, now.month, now.day);
        break;
      case '2y':
        start = DateTime(now.year - 2, now.month, now.day);
        break;
      case '5y':
        start = DateTime(now.year - 5, now.month, now.day);
        break;
      case 'All':
        start = portfolioSliderMinDate.value;
        break;
    }

    portfolioDateStart.value = start;
    portfolioDateEnd.value = endOfDay;
  }

  /// Update portfolio date range from slider
  void updatePortfolioDateRange(DateTime start, DateTime end) {
    portfolioDateStart.value = start;
    portfolioDateEnd.value = end;

    // Check if matches a preset duration
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    if (start == portfolioSliderMinDate.value &&
        end.isAtSameMomentAs(endOfDay)) {
      selectedPortfolioDurationTab.value = 'All';
    } else {
      selectedPortfolioDurationTab.value = '';
    }
  }

  /// Filter portfolio history by current date range
  List<PortfolioSnapshot> get filteredPortfolioHistory {
    return portfolioHistory.where((snapshot) {
      return snapshot.date.isAfter(
            portfolioDateStart.value.subtract(Duration(days: 1)),
          ) &&
          snapshot.date.isBefore(portfolioDateEnd.value.add(Duration(days: 1)));
    }).toList();
  }

  /// Get enriched investment data filtered by portfolio date range
  /// Shows only investments with activity during the selected period
  /// with net change in holdings during that period
  Future<List<Map<String, dynamic>>> get filteredEnrichedInvestmentData async {
    final result = <Map<String, dynamic>>[];

    // Get all activities within the date range
    final filteredActivities = activities.where((activity) {
      return activity.date.isAfter(
            portfolioDateStart.value.subtract(Duration(days: 1)),
          ) &&
          activity.date.isBefore(portfolioDateEnd.value.add(Duration(days: 1)));
    }).toList();

    if (filteredActivities.isEmpty) {
      return result;
    }

    // Track net change and latest price per investment
    final investmentChanges = <int, Map<String, dynamic>>{};

    for (var activity in filteredActivities) {
      if (activity.isTransaction) {
        // Handle transaction (deposit/withdraw)
        final investmentId = activity.transactionInvestmentId;
        if (investmentId == null) continue;

        investmentChanges[investmentId] ??= {
          'netChange': 0.0,
          'latestPrice': null,
          'latestPriceDate': null,
        };

        final amount = activity.transactionAmount ?? 0;
        if (activity.isDeposit) {
          investmentChanges[investmentId]!['netChange'] += amount;
        } else if (activity.isWithdraw) {
          investmentChanges[investmentId]!['netChange'] -= amount;
        }

        // Update latest price
        if (activity.transactionPrice != null) {
          final existingDate =
              investmentChanges[investmentId]!['latestPriceDate'];
          if (existingDate == null || activity.date.isAfter(existingDate)) {
            investmentChanges[investmentId]!['latestPrice'] =
                activity.transactionPrice;
            investmentChanges[investmentId]!['latestPriceDate'] = activity.date;
          }
        }
      } else if (activity.isTrade) {
        // Handle trade (sold -> bought)
        // Sold investment
        if (activity.tradeSoldInvestmentId != null) {
          final soldId = activity.tradeSoldInvestmentId!;
          investmentChanges[soldId] ??= {
            'netChange': 0.0,
            'latestPrice': null,
            'latestPriceDate': null,
          };
          investmentChanges[soldId]!['netChange'] -=
              (activity.tradeSoldAmount ?? 0);

          if (activity.tradeSoldPrice != null) {
            final existingDate = investmentChanges[soldId]!['latestPriceDate'];
            if (existingDate == null || activity.date.isAfter(existingDate)) {
              investmentChanges[soldId]!['latestPrice'] =
                  activity.tradeSoldPrice;
              investmentChanges[soldId]!['latestPriceDate'] = activity.date;
            }
          }
        }

        // Bought investment
        if (activity.tradeBoughtInvestmentId != null) {
          final boughtId = activity.tradeBoughtInvestmentId!;
          investmentChanges[boughtId] ??= {
            'netChange': 0.0,
            'latestPrice': null,
            'latestPriceDate': null,
          };
          investmentChanges[boughtId]!['netChange'] +=
              (activity.tradeBoughtAmount ?? 0);

          if (activity.tradeBoughtPrice != null) {
            final existingDate =
                investmentChanges[boughtId]!['latestPriceDate'];
            if (existingDate == null || activity.date.isAfter(existingDate)) {
              investmentChanges[boughtId]!['latestPrice'] =
                  activity.tradeBoughtPrice;
              investmentChanges[boughtId]!['latestPriceDate'] = activity.date;
            }
          }
        }
      }
    }

    // Build result for investments with net changes
    for (var entry in investmentChanges.entries) {
      final investmentId = entry.key;
      final data = entry.value;
      final netChange = data['netChange'] as double;

      // Only show if there was net change
      if (netChange.abs() > 0.0001) {
        final investment = investments.firstWhereOrNull(
          (inv) => inv.id == investmentId,
        );

        if (investment == null) continue;

        final latestPrice = data['latestPrice'] as double?;
        final hasPrice = latestPrice != null;
        final totalValue = hasPrice ? netChange * latestPrice : 0.0;

        result.add({
          'investment': investment,
          'amount': netChange.abs(),
          'holdings': netChange,
          'latestPrice': latestPrice ?? 0.0,
          'hasPrice': hasPrice,
          'totalValue': totalValue,
        });
      }
    }

    return result;
  }

  /// Update the flat list of visible activities for high-performance rendering
  void _updateVisibleActivities() {
    final items = <InvestmentListItem>[];
    final years = sortedYears;

    for (var year in years) {
      // Add year header
      items.add(
        InvestmentYearHeaderItem(year: year, isExpanded: isYearExpanded(year)),
      );

      if (!isYearExpanded(year)) {
        items.add(InvestmentSpacerItem(18));
        continue;
      }

      final months = getSortedMonths(year);
      for (var month in months) {
        // Add month header
        final monthName = getMonthName(month);
        items.add(
          InvestmentMonthHeaderItem(
            year: year,
            month: month,
            monthName: monthName,
            isExpanded: isMonthExpanded(year, month),
          ),
        );

        if (!isMonthExpanded(year, month)) {
          items.add(InvestmentSpacerItem(18));
          continue;
        }

        // For Highest Amount sorting, we don't group by day
        if (selectedSortOption.value == SortOption.highestAmount) {
          final activities = getActivitiesForMonthSortedByAmount(year, month);
          int? lastDay;

          for (var activity in activities) {
            final currentDay = activity.date.day;

            // Add day header if day changed
            if (lastDay != currentDay) {
              final monthAbbr = getMonthName(month).substring(0, 3);
              items.add(
                InvestmentDayHeaderItem(
                  day: currentDay,
                  monthAbbr: monthAbbr,
                  showHeaders: true, // Always show headers in amount sorting
                ),
              );
              lastDay = currentDay;
            }

            // Add activity with pre-formatted data
            items.add(_createActivityItem(activity));
          }
        } else {
          // Normal day grouping for Most Recent sorting
          final days = getSortedDays(year, month);
          final monthAbbr = getMonthName(month).substring(0, 3);

          for (var day in days) {
            items.add(
              InvestmentDayHeaderItem(
                day: day,
                monthAbbr: monthAbbr,
                showHeaders: false, // Day headers act as section headers
              ),
            );

            final dayActivities = getActivitiesForDay(year, month, day);
            for (var activity in dayActivities) {
              items.add(_createActivityItem(activity));
            }
          }
        }

        items.add(InvestmentSpacerItem(18));
      }

      items.add(InvestmentSpacerItem(18));
    }

    visibleActivities.value = items;
  }

  /// Create an activity item with pre-formatted strings
  InvestmentActivityItem _createActivityItem(InvestmentActivity activity) {
    final currencyFormat = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    final amountFormat = NumberFormat('#,##0.########');

    if (activity.isTrade) {
      final soldInvestment = getInvestmentById(
        activity.tradeSoldInvestmentId ?? 0,
      );
      final boughtInvestment = getInvestmentById(
        activity.tradeBoughtInvestmentId ?? 0,
      );

      return InvestmentActivityItem(
        activity: activity,
        soldSymbol: soldInvestment?.ticker,
        boughtSymbol: boughtInvestment?.ticker,
        soldAmount: amountFormat.format(activity.tradeSoldAmount ?? 0),
        soldPrice: currencyFormat.format(activity.tradeSoldPrice ?? 0),
        soldTotal: currencyFormat.format(activity.tradeSoldTotal ?? 0),
        boughtAmount: amountFormat.format(activity.tradeBoughtAmount ?? 0),
        boughtPrice: currencyFormat.format(activity.tradeBoughtPrice ?? 0),
        boughtTotal: currencyFormat.format(activity.tradeBoughtTotal ?? 0),
      );
    } else {
      final investment = getInvestmentById(
        activity.transactionInvestmentId ?? 0,
      );

      return InvestmentActivityItem(
        activity: activity,
        transactionSymbol: investment?.ticker,
        transactionAmount: amountFormat.format(activity.transactionAmount ?? 0),
        transactionPrice: currencyFormat.format(activity.transactionPrice ?? 0),
        transactionTotal: currencyFormat.format(activity.transactionTotal ?? 0),
      );
    }
  }

  // ==================== TOGGLE STATE ====================

  bool get isPortfolioSelected => selectedToggleOption.value == 1;

  void selectPortfolio() {
    selectedToggleOption.value = 1;
  }

  void selectTrades() {
    selectedToggleOption.value = 2;
  }

  // ==================== SORTING STATE ====================

  /// Update sort option and direction
  void updateSortOption(SortOption? option, SortDirection? direction) {
    selectedSortOption.value = option;
    selectedSortDirection.value = direction;
    // Activities will be sorted when accessed through getters
  }

  // ==================== FILTER STATE ====================

  /// Apply filter settings
  void applyFilter({
    DateTime? fromDate,
    DateTime? toDate,
    String? activityType,
    List<int>? investmentIds,
    double? minAmount,
    double? maxAmount,
  }) {
    filterFromDate.value = fromDate;
    filterToDate.value = toDate;
    filterActivityType.value = activityType ?? 'All';
    filterInvestmentIds.value = investmentIds ?? [];
    filterMinAmount.value = minAmount;
    filterMaxAmount.value = maxAmount;

    // Check if any filter is active
    isFilterActive.value =
        fromDate != null ||
        toDate != null ||
        (activityType != 'All' && activityType != 'Trades & Transaction') ||
        (investmentIds != null && investmentIds.isNotEmpty) ||
        minAmount != null ||
        maxAmount != null;
  }

  /// Reset all filters
  void resetFilters() {
    filterFromDate.value = null;
    filterToDate.value = null;
    filterActivityType.value = 'Trades & Transaction';
    filterInvestmentIds.clear();
    filterMinAmount.value = null;
    filterMaxAmount.value = null;
    isFilterActive.value = false;

    // Force update of visible activities
    _updateVisibleActivities();
  }

  /// Force update of visible activities (useful after applying filters)
  void forceUpdateVisibleActivities() {
    _updateVisibleActivities();
  }

  /// Filter activities based on current filter settings
  List<InvestmentActivity> _applyFilters(List<InvestmentActivity> activities) {
    if (!isFilterActive.value) {
      return activities;
    }

    debugPrint('[InvestmentController] Filtering ${activities.length} activities');
    debugPrint('  Filters: fromDate=${filterFromDate.value}, toDate=${filterToDate.value}');
    debugPrint('  activityType=${filterActivityType.value}, investmentIds=$filterInvestmentIds');
    debugPrint('  minAmount=${filterMinAmount.value}, maxAmount=${filterMaxAmount.value}');

    final filtered = activities.where((activity) {
      // Date range filter
      if (filterFromDate.value != null) {
        if (activity.date.isBefore(filterFromDate.value!)) {
          return false;
        }
      }
      if (filterToDate.value != null) {
        final endOfDay = DateTime(
          filterToDate.value!.year,
          filterToDate.value!.month,
          filterToDate.value!.day,
          23,
          59,
          59,
        );
        if (activity.date.isAfter(endOfDay)) {
          return false;
        }
      }

      // Activity type filter
      if (filterActivityType.value != 'All' &&
          filterActivityType.value != 'Trades & Transaction') {
        if (filterActivityType.value == 'Trade' && !activity.isTrade) {
          return false;
        }
        if (filterActivityType.value == 'Transaction' &&
            !activity.isTransaction) {
          return false;
        }
        if (filterActivityType.value == 'Deposit' && !activity.isDeposit) {
          return false;
        }
        if (filterActivityType.value == 'Withdraw' && !activity.isWithdraw) {
          return false;
        }
      }

      // Investment IDs filter
      if (filterInvestmentIds.isNotEmpty) {
        if (activity.isTrade) {
          // For trades, check both sold and bought investments
          final soldId = activity.tradeSoldInvestmentId;
          final boughtId = activity.tradeBoughtInvestmentId;
          if (!filterInvestmentIds.contains(soldId) &&
              !filterInvestmentIds.contains(boughtId)) {
            return false;
          }
        } else {
          // For transactions, check transaction investment
          final investmentId = activity.transactionInvestmentId;
          if (!filterInvestmentIds.contains(investmentId)) {
            return false;
          }
        }
      }

      // Amount filter
      if (filterMinAmount.value != null || filterMaxAmount.value != null) {
        double activityAmount;
        if (activity.isTrade) {
          // For trades, use the sold total as the primary amount
          activityAmount = (activity.tradeSoldTotal ?? 0.0).abs();
        } else {
          // For transactions, use the absolute value of transaction total
          // (so both deposits and withdrawals are filtered by magnitude)
          activityAmount = (activity.transactionTotal ?? 0.0).abs();
        }

        if (filterMinAmount.value != null &&
            activityAmount < filterMinAmount.value!) {
          return false;
        }
        if (filterMaxAmount.value != null &&
            activityAmount > filterMaxAmount.value!) {
          return false;
        }
      }

      return true;
    }).toList();

    debugPrint('[InvestmentController] Filtered result: ${filtered.length} activities');
    return filtered;
  }

  // ==================== INVESTMENT CRUD ====================

  /// Add a new investment
  Future<Investment?> addInvestment({
    required String name,
    required String ticker,
    required Color color,
    required File imageFile,
  }) async {
    try {
      final investment = await _service.addInvestment(
        name: name,
        ticker: ticker,
        color: color,
        imageFile: imageFile,
      );
      if (investment != null) {
        investments.add(investment);
      }
      return investment;
    } catch (e) {
      debugPrint('[InvestmentController][addInvestment] Error: $e');
      rethrow;
    }
  }

  /// Update an investment
  Future<bool> updateInvestment(
    int id, {
    String? name,
    String? ticker,
    Color? color,
    File? newImageFile,
  }) async {
    try {
      final success = await _service.updateInvestment(
        id,
        name: name,
        ticker: ticker,
        color: color,
        newImageFile: newImageFile,
      );
      if (success) {
        // Reload investments to get updated data
        investments.value = await _service.getAllInvestments();
        // Also reload enriched data for portfolio section
        enrichedInvestmentData.value = await _service
            .getInvestmentHoldingsWithPrices();
      }
      return success;
    } catch (e) {
      debugPrint('[InvestmentController][updateInvestment] Error: $e');
      rethrow;
    }
  }

  /// Delete an investment
  Future<bool> deleteInvestment(int id) async {
    try {
      final success = await _service.deleteInvestment(id);
      if (success) {
        investments.removeWhere((i) => i.id == id);
      }
      return success;
    } catch (e) {
      debugPrint('[InvestmentController][deleteInvestment] Error: $e');
      rethrow;
    }
  }

  /// Get investment by ID
  Investment? getInvestmentById(int id) {
    try {
      return investments.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Search investments
  Future<List<Investment>> searchInvestments(String query) async {
    return _service.searchInvestments(query);
  }

  // ==================== ACTIVITY CRUD ====================

  /// Add a transaction (deposit/withdraw)
  Future<InvestmentActivity?> addTransaction({
    required int investmentId,
    required TransactionDirection direction,
    required double amount,
    required double price,
    required double total,
    required DateTime date,
    String? description,
  }) async {
    try {
      // Validate sufficient holdings for withdrawal
      if (direction == TransactionDirection.withdraw) {
        final currentAmount = currentHoldings[investmentId] ?? 0.0;
        if (amount > currentAmount) {
          throw Exception(
            'Insufficient holdings. You have $currentAmount units but trying to withdraw $amount units.',
          );
        }
      }

      final activity = await _service.addTransaction(
        investmentId: investmentId,
        direction: direction,
        amount: amount,
        price: price,
        total: total,
        date: date,
        description: description,
      );
      if (activity != null) {
        activities.insert(0, activity); // Add at beginning (newest first)
        currentHoldings.value = await _service.calculateCurrentHoldings();
        portfolioHistory.value = await _service.getPortfolioHistory();
        enrichedInvestmentData.value = await _service
            .getInvestmentHoldingsWithPrices();
        _initializeExpansionState();
      }
      return activity;
    } catch (e) {
      debugPrint('[InvestmentController][addTransaction] Error: $e');
      rethrow;
    }
  }

  /// Add a trade (sold/bought pair)
  Future<InvestmentActivity?> addTrade({
    required int soldInvestmentId,
    required double soldAmount,
    required double soldPrice,
    required double soldTotal,
    required int boughtInvestmentId,
    required double boughtAmount,
    required double boughtPrice,
    required double boughtTotal,
    required DateTime date,
    String? description,
  }) async {
    try {
      // Validate sufficient holdings for the sold investment
      final currentAmount = currentHoldings[soldInvestmentId] ?? 0.0;
      if (soldAmount > currentAmount) {
        final soldInvestment = getInvestmentById(soldInvestmentId);
        final soldSymbol = soldInvestment?.ticker ?? 'Unknown';
        throw Exception(
          'Insufficient holdings of $soldSymbol. You have $currentAmount units but trying to sell $soldAmount units.',
        );
      }

      final activity = await _service.addTrade(
        soldInvestmentId: soldInvestmentId,
        soldAmount: soldAmount,
        soldPrice: soldPrice,
        soldTotal: soldTotal,
        boughtInvestmentId: boughtInvestmentId,
        boughtAmount: boughtAmount,
        boughtPrice: boughtPrice,
        boughtTotal: boughtTotal,
        date: date,
        description: description,
      );
      if (activity != null) {
        activities.insert(0, activity); // Add at beginning (newest first)
        currentHoldings.value = await _service.calculateCurrentHoldings();
        portfolioHistory.value = await _service.getPortfolioHistory();
        enrichedInvestmentData.value = await _service
            .getInvestmentHoldingsWithPrices();
        _initializeExpansionState();
      }
      return activity;
    } catch (e) {
      debugPrint('[InvestmentController][addTrade] Error: $e');
      rethrow;
    }
  }

  /// Delete activities by IDs
  Future<bool> deleteActivities(List<int> ids) async {
    try {
      final success = await _service.deleteActivities(ids);
      if (success) {
        activities.removeWhere((a) => a.id != null && ids.contains(a.id));
        currentHoldings.value = await _service.calculateCurrentHoldings();
        portfolioHistory.value = await _service.getPortfolioHistory();
        enrichedInvestmentData.value = await _service
            .getInvestmentHoldingsWithPrices();
      }
      return success;
    } catch (e) {
      debugPrint('[InvestmentController][deleteActivities] Error: $e');
      return false;
    }
  }

  /// Get transactions only
  List<InvestmentActivity> get transactionsOnly {
    return InvestmentActivityHelper.filterTransactions(activities);
  }

  /// Get trades only
  List<InvestmentActivity> get tradesOnly {
    return InvestmentActivityHelper.filterTrades(activities);
  }

  // ==================== PORTFOLIO SNAPSHOTS ====================

  /// Add a manual price snapshot for a specific investment
  Future<PortfolioSnapshot?> addManualPriceSnapshot({
    required int investmentId,
    required double unitPrice,
    required DateTime date,
    String? note,
  }) async {
    try {
      final snapshot = await _service.addManualPriceSnapshot(
        investmentId: investmentId,
        unitPrice: unitPrice,
        date: date,
        note: note,
      );
      if (snapshot != null) {
        portfolioHistory.insert(0, snapshot);
      }
      return snapshot;
    } catch (e) {
      debugPrint('[InvestmentController][addManualPriceSnapshot] Error: $e');
      return null;
    }
  }

  /// Delete a portfolio snapshot
  Future<bool> deleteSnapshot(int id) async {
    try {
      final success = await _service.deleteSnapshot(id);
      if (success) {
        portfolioHistory.removeWhere((s) => s.id == id);
      }
      return success;
    } catch (e) {
      debugPrint('[InvestmentController][deleteSnapshot] Error: $e');
      return false;
    }
  }

  /// Get current portfolio value
  Future<double?> getCurrentPortfolioValue() async {
    return _service.getCurrentPortfolioValue();
  }

  /// Get all snapshots for a specific investment
  Future<List<PortfolioSnapshot>> getSnapshotsForInvestment(
    int investmentId,
  ) async {
    try {
      return await _service.getSnapshotsForInvestment(investmentId);
    } catch (e) {
      debugPrint('[InvestmentController][getSnapshotsForInvestment] Error: $e');
      return [];
    }
  }

  // ==================== ACTIVITY GROUPING ====================

  /// Get filtered activities (applies current filter settings)
  List<InvestmentActivity> get filteredActivities {
    return _applyFilters(activities);
  }

  /// Group activities by year
  Map<int, List<InvestmentActivity>> get activitiesByYear {
    return InvestmentActivityHelper.groupByYear(filteredActivities);
  }

  /// Get sorted years (newest first)
  List<int> get sortedYears {
    return activitiesByYear.keys.toList()..sort((a, b) => b.compareTo(a));
  }

  /// Get activities grouped by month for a specific year
  Map<int, List<InvestmentActivity>> getActivitiesByMonth(int year) {
    return InvestmentActivityHelper.groupByMonth(filteredActivities, year);
  }

  /// Get sorted months for a year (newest first)
  List<int> getSortedMonths(int year) {
    return getActivitiesByMonth(year).keys.toList()
      ..sort((a, b) => b.compareTo(a));
  }

  /// Get activities for a specific month
  List<InvestmentActivity> getActivitiesForMonth(int year, int month) {
    final monthActivities = getActivitiesByMonth(year)[month] ?? [];
    return InvestmentActivityHelper.sortByDateDesc(monthActivities);
  }

  /// Get activities for a month sorted by amount (for Highest Amount sorting)
  List<InvestmentActivity> getActivitiesForMonthSortedByAmount(
    int year,
    int month,
  ) {
    final monthActivities = getActivitiesByMonth(year)[month] ?? [];
    return _sortActivities(monthActivities);
  }

  /// Get activities grouped by day for a specific month
  Map<int, List<InvestmentActivity>> getActivitiesByDay(int year, int month) {
    final monthActivities = getActivitiesForMonth(year, month);
    final Map<int, List<InvestmentActivity>> grouped = {};
    for (var activity in monthActivities) {
      final day = activity.date.day;
      grouped.putIfAbsent(day, () => []);
      grouped[day]!.add(activity);
    }
    // Apply sorting to each day's activities
    grouped.forEach((day, activities) {
      grouped[day] = _sortActivities(activities);
    });
    return grouped;
  }

  /// Get sorted days for a month
  List<int> getSortedDays(int year, int month) {
    // For Highest Amount sorting, we don't use day grouping
    // Return empty list to indicate we should use getActivitiesForMonthSortedByAmount
    if (selectedSortOption.value == SortOption.highestAmount) {
      return [];
    }

    final days = getActivitiesByDay(year, month).keys.toList();
    // Sort days based on sort direction
    if (selectedSortDirection.value == SortDirection.top) {
      days.sort((a, b) => b.compareTo(a)); // Newest first
    } else {
      days.sort((a, b) => a.compareTo(b)); // Oldest first
    }
    return days;
  }

  /// Get activities for a specific day
  List<InvestmentActivity> getActivitiesForDay(int year, int month, int day) {
    return getActivitiesByDay(year, month)[day] ?? [];
  }

  /// Sort activities based on selected sort option and direction
  List<InvestmentActivity> _sortActivities(
    List<InvestmentActivity> activities,
  ) {
    final sorted = List<InvestmentActivity>.from(activities);

    // Apply sorting based on selected option
    if (selectedSortOption.value == SortOption.mostRecent) {
      sorted.sort((a, b) => b.date.compareTo(a.date));
    } else if (selectedSortOption.value == SortOption.highestAmount) {
      // Sort by total amount (for transactions) or sold total (for trades)
      sorted.sort((a, b) {
        final aAmount = a.isTrade
            ? (a.tradeSoldTotal ?? 0.0)
            : (a.transactionTotal ?? 0.0);
        final bAmount = b.isTrade
            ? (b.tradeSoldTotal ?? 0.0)
            : (b.transactionTotal ?? 0.0);
        return bAmount.compareTo(aAmount);
      });
    }

    // Reverse if direction is bottom
    if (selectedSortDirection.value == SortDirection.bottom) {
      return sorted.reversed.toList();
    }

    return sorted;
  }

  // ==================== EXPANSION STATE ====================

  /// Toggle year expansion
  void toggleYearExpansion(int year) {
    if (expandedYears.contains(year)) {
      expandedYears.remove(year);
      // Also collapse all months in this year
      expandedMonths.removeWhere((key) => key.startsWith('$year-'));
    } else {
      expandedYears.add(year);
    }
  }

  /// Toggle month expansion
  void toggleMonthExpansion(int year, int month) {
    final key = '$year-$month';
    if (expandedMonths.contains(key)) {
      expandedMonths.remove(key);
    } else {
      expandedMonths.add(key);
    }
  }

  /// Check if year is expanded
  bool isYearExpanded(int year) {
    return expandedYears.contains(year);
  }

  /// Check if month is expanded
  bool isMonthExpanded(int year, int month) {
    return expandedMonths.contains('$year-$month');
  }

  /// Get month name from number
  String getMonthName(int month) {
    final date = DateTime(2024, month);
    return DateFormat('MMMM').format(date);
  }

  // ==================== LEGACY COMPATIBILITY ====================
  // These methods provide backward compatibility with existing UI code
  // that expects the old Trade class structure

  /// Get trades (legacy compatibility - returns activities that are trades)
  List<InvestmentActivity> get trades => tradesOnly;

  /// Group trades by year (legacy compatibility)
  Map<int, List<InvestmentActivity>> get tradesByYear {
    return InvestmentActivityHelper.groupByYear(tradesOnly);
  }

  /// Get trades by month (legacy compatibility)
  Map<int, List<InvestmentActivity>> getTradesByMonth(int year) {
    return InvestmentActivityHelper.groupByMonth(tradesOnly, year);
  }

  /// Get trades for month (legacy compatibility)
  List<InvestmentActivity> getTradesForMonth(int year, int month) {
    final monthTrades = getTradesByMonth(year)[month] ?? [];
    return InvestmentActivityHelper.sortByDateDesc(monthTrades);
  }

  /// Get trades by day (legacy compatibility)
  Map<int, List<InvestmentActivity>> getTradesByDay(int year, int month) {
    final monthTrades = getTradesForMonth(year, month);
    final Map<int, List<InvestmentActivity>> grouped = {};
    for (var trade in monthTrades) {
      final day = trade.date.day;
      grouped.putIfAbsent(day, () => []);
      grouped[day]!.add(trade);
    }
    return grouped;
  }

  /// Get trades for day (legacy compatibility)
  List<InvestmentActivity> getTradesForDay(int year, int month, int day) {
    return getTradesByDay(year, month)[day] ?? [];
  }

  /// Delete trades by IDs (legacy compatibility)
  Future<void> deleteTrades(List<int> tradeIds) async {
    await deleteActivities(tradeIds);
  }

  // ==================== INVESTMENT RECOMMENDATIONS (LEGACY) ====================
  // These provide compatibility with old InvestmentRecommendation-based code
  // The new code should use Investment model directly

  /// Get investments as legacy format (for UI compatibility)
  List<Investment> get recommendations => investments;

  /// Add investment (legacy naming)
  Future<Investment?> addRecommendation({
    required String name,
    required String ticker,
    required Color color,
    required File imageFile,
  }) async {
    return addInvestment(
      name: name,
      ticker: ticker,
      color: color,
      imageFile: imageFile,
    );
  }

  /// Remove investment by index (legacy compatibility)
  Future<bool> removeRecommendation(int index) async {
    if (index >= 0 && index < investments.length) {
      final investment = investments[index];
      if (investment.id != null) {
        return deleteInvestment(investment.id!);
      }
    }
    return false;
  }

  /// Update investment by index (legacy compatibility)
  Future<bool> updateRecommendation(
    int index, {
    String? name,
    String? ticker,
    Color? color,
    File? newImageFile,
  }) async {
    if (index >= 0 && index < investments.length) {
      final investment = investments[index];
      if (investment.id != null) {
        return updateInvestment(
          investment.id!,
          name: name,
          ticker: ticker,
          color: color,
          newImageFile: newImageFile,
        );
      }
    }
    return false;
  }
}
