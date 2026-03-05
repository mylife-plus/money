import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/models/investment_model.dart';
import 'package:moneyapp/models/investment_activity_model.dart';
import 'package:moneyapp/models/portfolio_snapshot_model.dart';
import 'package:moneyapp/models/investment_list_item.dart';
import 'package:moneyapp/services/currency_service.dart';
import 'package:moneyapp/services/investment_service.dart';
import 'package:moneyapp/utils/number_format_helper.dart';
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
      investments.value = await _service.getAllInvestments()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
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

  void _refreshDerivedDataInBackground() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      final results = await Future.wait([
        _service.getAllActivities(),
        _service.getPortfolioHistory(),
        _service.getAllInvestments(),
        _service.getLatestSnapshotsForAll(),
      ]);

      final allActivities = results[0] as List<InvestmentActivity>;
      final history = results[1] as List<PortfolioSnapshot>;
      final allInvestments = results[2] as List<Investment>;
      final latestSnapshots = results[3] as Map<int, PortfolioSnapshot>;

      final computed = await compute(_computeDerivedData, {
        'activities': allActivities,
        'investments': allInvestments,
        'latestSnapshots': latestSnapshots,
      });

      activities.value = allActivities;
      currentHoldings.value = computed['holdings'] as Map<int, double>;
      portfolioHistory.value = history;
      enrichedInvestmentData.value =
          computed['enriched'] as List<Map<String, dynamic>>;
      _initializeExpansionState();
      _extendPortfolioSliderRange();
    });
  }

  static Map<String, dynamic> _computeDerivedData(
    Map<String, dynamic> params,
  ) {
    final activities = params['activities'] as List<InvestmentActivity>;
    final investments = params['investments'] as List<Investment>;
    final latestSnapshots =
        params['latestSnapshots'] as Map<int, PortfolioSnapshot>;

    final sorted = InvestmentActivityHelper.sortByDateAsc(activities);
    final Map<int, double> holdings = {};

    for (final activity in sorted) {
      if (activity.isTransaction) {
        final investmentId = activity.transactionInvestmentId!;
        holdings.putIfAbsent(investmentId, () => 0);
        if (activity.isDeposit) {
          holdings[investmentId] =
              holdings[investmentId]! + (activity.transactionAmount ?? 0);
        } else {
          holdings[investmentId] =
              holdings[investmentId]! - (activity.transactionAmount ?? 0);
        }
      } else if (activity.isTrade) {
        final soldId = activity.tradeSoldInvestmentId!;
        holdings.putIfAbsent(soldId, () => 0);
        holdings[soldId] = holdings[soldId]! - (activity.tradeSoldAmount ?? 0);

        final boughtId = activity.tradeBoughtInvestmentId!;
        holdings.putIfAbsent(boughtId, () => 0);
        holdings[boughtId] =
            holdings[boughtId]! + (activity.tradeBoughtAmount ?? 0);
      }
    }

    final List<Map<String, dynamic>> enrichedData = [];
    for (final investment in investments) {
      final amount = holdings[investment.id] ?? 0.0;
      if (amount <= 0) continue;

      final latestSnapshot = latestSnapshots[investment.id];
      final latestPrice = latestSnapshot?.unitPrice ?? 0.0;
      final totalValue = amount * latestPrice;

      enrichedData.add({
        'investment': investment,
        'amount': amount,
        'latestPrice': latestPrice,
        'totalValue': totalValue,
        'hasPrice': latestSnapshot != null,
      });
    }

    return {
      'holdings': holdings,
      'enriched': enrichedData,
    };
  }

  /// Get a single activity by ID from database
  Future<InvestmentActivity?> getActivityById(int id) async {
    return await _service.getActivityById(id);
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

  /// Returns end-of-day or now, depending on whether [date] is today.
  DateTime _endDateTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    if (d.isAtSameMomentAs(today)) return now;
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Initialize portfolio date range from snapshot data
  void _initializePortfolioDates() {
    if (portfolioHistory.isEmpty) {
      final now = DateTime.now();
      portfolioSliderMinDate.value = DateTime(now.year, now.month, now.day);
      portfolioSliderMaxDate.value = now;
      portfolioDateStart.value = portfolioSliderMinDate.value;
      portfolioDateEnd.value = portfolioSliderMaxDate.value;
      selectedPortfolioDurationTab.value = 'All';
      return;
    }

    DateTime earliest = portfolioHistory.first.date;
    DateTime latest = portfolioHistory.first.date;
    for (var snapshot in portfolioHistory) {
      if (snapshot.date.isBefore(earliest)) earliest = snapshot.date;
      if (snapshot.date.isAfter(latest)) latest = snapshot.date;
    }

    portfolioSliderMinDate.value = DateTime(
      earliest.year,
      earliest.month,
      earliest.day,
    );
    portfolioSliderMaxDate.value = _endDateTime(latest);

    portfolioDateStart.value = portfolioSliderMinDate.value;
    portfolioDateEnd.value = portfolioSliderMaxDate.value;
    selectedPortfolioDurationTab.value = 'All';
  }

  /// Extend portfolio slider range to cover any new snapshot dates
  /// without resetting the user's selected duration tab.
  void _extendPortfolioSliderRange() {
    if (portfolioHistory.isEmpty) return;

    DateTime earliest = portfolioHistory.first.date;
    DateTime latest = portfolioHistory.first.date;
    for (var snapshot in portfolioHistory) {
      if (snapshot.date.isBefore(earliest)) earliest = snapshot.date;
      if (snapshot.date.isAfter(latest)) latest = snapshot.date;
    }

    final newMin = DateTime(earliest.year, earliest.month, earliest.day);
    final newMax = _endDateTime(latest);

    final minChanged = newMin.isBefore(portfolioSliderMinDate.value);
    final maxChanged = newMax.isAfter(portfolioSliderMaxDate.value);

    if (minChanged) portfolioSliderMinDate.value = newMin;
    if (maxChanged) portfolioSliderMaxDate.value = newMax;

    if (selectedPortfolioDurationTab.value == 'All') {
      if (minChanged) portfolioDateStart.value = newMin;
      if (maxChanged) portfolioDateEnd.value = newMax;
    }
  }

  /// Available duration tabs — only show tabs whose duration <= data span
  List<String> get availablePortfolioDurationTabs {
    if (portfolioHistory.isEmpty) return ['All'];

    final days = DateTime.now().difference(portfolioSliderMinDate.value).inDays;
    final tabs = <String>[];

    if (days >= 7) tabs.add('7d');
    if (days >= 14) tabs.add('2w');
    if (days >= 30) tabs.add('1m');
    if (days >= 90) tabs.add('3m');
    if (days >= 180) tabs.add('6m');
    if (days >= 365) tabs.add('1y');
    if (days >= 730) tabs.add('2y');
    if (days >= 1825) tabs.add('5y');
    tabs.add('All');

    return tabs;
  }

  /// Update portfolio duration tab
  void updatePortfolioDurationTab(String tab) {
    selectedPortfolioDurationTab.value = tab;

    final now = DateTime.now();
    DateTime start = portfolioSliderMinDate.value;

    switch (tab) {
    
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
    portfolioDateEnd.value = _endDateTime(now);
  }

  /// Update portfolio date range from slider
  void updatePortfolioDateRange(DateTime start, DateTime end) {
    portfolioDateStart.value = DateTime(start.year, start.month, start.day);
    portfolioDateEnd.value = _endDateTime(end);

    if (start == portfolioSliderMinDate.value &&
        portfolioDateEnd.value == portfolioSliderMaxDate.value) {
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

  int get uniqueDataDaysCount {
    final days = <String>{};
    for (var a in activities) {
      days.add('${a.date.year}-${a.date.month}-${a.date.day}');
    }
    for (var s in portfolioHistory) {
      days.add('${s.date.year}-${s.date.month}-${s.date.day}');
    }
    return days.length;
  }

  /// Get all price points (from manual snapshots and activities) for graph building
  /// Returns a map of DateTime to Map of investmentId to unitPrice
  /// Uses the latest price from any source (manual snapshot, transaction, or trade)
  Map<DateTime, Map<int, double>> getAllPricePointsForGraph() {
    Map<DateTime, Map<int, double>> dateInvestmentPrices = {};

    // Add prices from manual snapshots
    for (var snapshot in filteredPortfolioHistory) {
      DateTime key = snapshot.date;
      dateInvestmentPrices[key] ??= {};
      dateInvestmentPrices[key]![snapshot.investmentId] = snapshot.unitPrice;
    }

    // Add prices from activities (transactions and trades)
    final filteredActivities = activities.where((activity) {
      return activity.date.isAfter(
            portfolioDateStart.value.subtract(Duration(days: 1)),
          ) &&
          activity.date.isBefore(portfolioDateEnd.value.add(Duration(days: 1)));
    }).toList();

    for (var activity in filteredActivities) {
      if (activity.isTransaction) {
        final investmentId = activity.transactionInvestmentId;
        if (investmentId != null && activity.transactionPrice != null) {
          DateTime key = activity.date;
          dateInvestmentPrices[key] ??= {};
          dateInvestmentPrices[key]![investmentId] = activity.transactionPrice!;
        }
      } else if (activity.isTrade) {
        // Add sold investment price
        if (activity.tradeSoldInvestmentId != null &&
            activity.tradeSoldPrice != null) {
          DateTime key = activity.date;
          dateInvestmentPrices[key] ??= {};
          dateInvestmentPrices[key]![activity.tradeSoldInvestmentId!] =
              activity.tradeSoldPrice!;
        }

        // Add bought investment price
        if (activity.tradeBoughtInvestmentId != null &&
            activity.tradeBoughtPrice != null) {
          DateTime key = activity.date;
          dateInvestmentPrices[key] ??= {};
          dateInvestmentPrices[key]![activity.tradeBoughtInvestmentId!] =
              activity.tradeBoughtPrice!;
        }
      }
    }

    return dateInvestmentPrices;
  }

  /// Returns the latest known unit price for each investment strictly before [beforeDate].
  /// Considers both manual snapshots and activity prices.
  Map<int, double> getLatestPricesBeforeDate(DateTime beforeDate) {
    final Map<int, MapEntry<DateTime, double>> latestEntries = {};

    void update(int investmentId, DateTime date, double price) {
      if (date.isBefore(beforeDate)) {
        final existing = latestEntries[investmentId];
        if (existing == null || date.isAfter(existing.key)) {
          latestEntries[investmentId] = MapEntry(date, price);
        }
      }
    }

    for (var snapshot in portfolioHistory) {
      update(snapshot.investmentId, snapshot.date, snapshot.unitPrice);
    }

    for (var activity in activities) {
      if (activity.isTransaction &&
          activity.transactionInvestmentId != null &&
          activity.transactionPrice != null) {
        update(
          activity.transactionInvestmentId!,
          activity.date,
          activity.transactionPrice!,
        );
      } else if (activity.isTrade) {
        if (activity.tradeSoldInvestmentId != null &&
            activity.tradeSoldPrice != null) {
          update(
            activity.tradeSoldInvestmentId!,
            activity.date,
            activity.tradeSoldPrice!,
          );
        }
        if (activity.tradeBoughtInvestmentId != null &&
            activity.tradeBoughtPrice != null) {
          update(
            activity.tradeBoughtInvestmentId!,
            activity.date,
            activity.tradeBoughtPrice!,
          );
        }
      }
    }

    return latestEntries.map((id, entry) => MapEntry(id, entry.value));
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

    final endDate = portfolioDateEnd.value;
    final holdingsAtEnd = buildHoldingsTimeline([endDate])[endDate] ?? {};
    final pricesAtEnd = getLatestPricesBeforeDate(
      endDate.add(Duration(days: 1)),
    );

    for (final investmentId in holdingsAtEnd.keys) {
      final holdings = holdingsAtEnd[investmentId] ?? 0.0;
      if (holdings <= 0) continue;

      final investment = investments.firstWhereOrNull(
        (inv) => inv.id == investmentId,
      );
      if (investment == null) continue;

      final latestPrice = pricesAtEnd[investmentId];
      final hasPrice = latestPrice != null;
      final totalValue = hasPrice ? holdings * latestPrice : 0.0;

      result.add({
        'investment': investment,
        'amount': holdings,
        'holdings': holdings,
        'latestPrice': latestPrice ?? 0.0,
        'hasPrice': hasPrice,
        'totalValue': totalValue,
      });
    }

    // Sort alphabetically by investment name (A → Z)
    result.sort((a, b) {
      final nameA = (a['investment'] as Investment).name.toLowerCase();
      final nameB = (b['investment'] as Investment).name.toLowerCase();
      return nameA.compareTo(nameB);
    });

    return result;
  }

  /// Computes cumulative holdings for each investment at each given date.
  /// Uses all activities (not filtered by date range) so the graph reflects
  /// the true portfolio value at each point in time.
  Map<DateTime, Map<int, double>> buildHoldingsTimeline(List<DateTime> dates) {
    final sortedDates = [...dates]..sort();
    final sortedActivities = [...activities]
      ..sort((a, b) => a.date.compareTo(b.date));

    final Map<int, double> running = {};
    final Map<DateTime, Map<int, double>> result = {};
    int idx = 0;

    for (final date in sortedDates) {
      final dateDay = DateTime(date.year, date.month, date.day);
      while (idx < sortedActivities.length) {
        final activity = sortedActivities[idx];
        final activityDay = DateTime(
          activity.date.year,
          activity.date.month,
          activity.date.day,
        );
        if (activityDay.isAfter(dateDay)) break;

        if (activity.isTransaction) {
          final id = activity.transactionInvestmentId!;
          running.putIfAbsent(id, () => 0);
          if (activity.isDeposit) {
            running[id] = running[id]! + (activity.transactionAmount ?? 0);
          } else {
            running[id] = running[id]! - (activity.transactionAmount ?? 0);
          }
        } else if (activity.isTrade) {
          final soldId = activity.tradeSoldInvestmentId!;
          running.putIfAbsent(soldId, () => 0);
          running[soldId] = running[soldId]! - (activity.tradeSoldAmount ?? 0);

          final boughtId = activity.tradeBoughtInvestmentId!;
          running.putIfAbsent(boughtId, () => 0);
          running[boughtId] =
              running[boughtId]! + (activity.tradeBoughtAmount ?? 0);
        }
        idx++;
      }
      result[date] = Map.from(running);
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
                showHeaders: true,
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
    final locale = CurrencyService.instance.portfolioLocale;
    String fmtCurrency(double? v) =>
        NumberFormatHelper.formatCurrency(v ?? 0, locale: locale);
    String fmtAmount(double? v) =>
        NumberFormatHelper.formatAmount(v ?? 0, locale: locale);

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
        soldAmount: fmtAmount(activity.tradeSoldAmount),
        soldPrice: fmtCurrency(activity.tradeSoldPrice),
        soldTotal: fmtCurrency(activity.tradeSoldTotal),
        boughtAmount: fmtAmount(activity.tradeBoughtAmount),
        boughtPrice: fmtCurrency(activity.tradeBoughtPrice),
        boughtTotal: fmtCurrency(activity.tradeBoughtTotal),
      );
    } else {
      final investment = getInvestmentById(
        activity.transactionInvestmentId ?? 0,
      );

      return InvestmentActivityItem(
        activity: activity,
        transactionSymbol: investment?.ticker,
        transactionAmount: fmtAmount(activity.transactionAmount),
        transactionPrice: fmtCurrency(activity.transactionPrice),
        transactionTotal: fmtCurrency(activity.transactionTotal),
      );
    }
  }

  // ==================== TOGGLE STATE ====================

  bool get isPortfolioSelected => selectedToggleOption.value == 1;

  void selectPortfolio() {
    selectedToggleOption.value = 1;
  }

  void selectHistory() {
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

    debugPrint(
      '[InvestmentController] Filtering ${activities.length} activities',
    );
    debugPrint(
      '  Filters: fromDate=${filterFromDate.value}, toDate=${filterToDate.value}',
    );
    debugPrint(
      '  activityType=${filterActivityType.value}, investmentIds=$filterInvestmentIds',
    );
    debugPrint(
      '  minAmount=${filterMinAmount.value}, maxAmount=${filterMaxAmount.value}',
    );

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

    debugPrint(
      '[InvestmentController] Filtered result: ${filtered.length} activities',
    );
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
        investments.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
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
        // Reload investments to get updated data (sorted A → Z)
        investments.value = await _service.getAllInvestments()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
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
          final inv = getInvestmentById(investmentId);
          final symbol = inv?.ticker ?? '';
          throw Exception(
            'Not enough $symbol to withdraw. You have ${NumberFormatHelper.formatCurrency(currentAmount, locale: CurrencyService.instance.portfolioLocale)} but tried to withdraw ${NumberFormatHelper.formatCurrency(amount, locale: CurrencyService.instance.portfolioLocale)}.',
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
        _refreshDerivedDataInBackground();
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
        final soldSymbol = soldInvestment?.ticker ?? '';
        throw Exception(
          'Not enough $soldSymbol to sell. You have ${NumberFormatHelper.formatCurrency(currentAmount, locale: CurrencyService.instance.portfolioLocale)} but tried to sell ${NumberFormatHelper.formatCurrency(soldAmount, locale: CurrencyService.instance.portfolioLocale)}.',
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
        _refreshDerivedDataInBackground();
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
        _refreshDerivedDataInBackground();
      }
      return success;
    } catch (e) {
      debugPrint('[InvestmentController][deleteActivities] Error: $e');
      return false;
    }
  }

  /// Update an existing activity and refresh its snapshot + all derived state.
  Future<bool> updateActivity(InvestmentActivity activity) async {
    try {
      final success = await _service.updateActivityWithSnapshot(activity);
      if (success) {
        _refreshDerivedDataInBackground();
      }
      return success;
    } catch (e) {
      debugPrint('[InvestmentController][updateActivity] Error: $e');
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
        _extendPortfolioSliderRange();
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
        enrichedInvestmentData.value = await _service
            .getInvestmentHoldingsWithPrices();
        _extendPortfolioSliderRange();
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
