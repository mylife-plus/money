import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/models/home_list_item.dart';
import 'package:moneyapp/models/transaction_model.dart';
import 'package:moneyapp/services/database/repositories/transaction_repository.dart';

import 'package:moneyapp/widgets/transactions/top_sort_sheet.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/models/mcc_model.dart';
import 'package:moneyapp/models/chart_data_point.dart';

/// Home Screen Controller
/// Manages state and business logic for Home Screen with optimized lazy loading support
class HomeController extends GetxController {
  // ... existing code ...

  /// Update sort option
  void updateSortOption(SortOption? option, SortDirection? direction) {
    selectedSortOption.value = option;
    selectedSortDirection.value = direction;
  }

  final TransactionRepository _transactionRepository = TransactionRepository();

  // Observable variables
  final RxInt selectedToggleOption = 1.obs; // 1 = Spending, 2 = Income
  final RxInt selectedChartDurationOption = 1.obs; // 1 = Year, 2 = Month

  // Transactions
  final RxList<Transaction> transactions = <Transaction>[].obs;
  final RxBool isLoading = false.obs;

  // Expandable state tracking
  final RxSet<int> expandedYears = <int>{}.obs;
  final RxSet<String> expandedMonths = <String>{}.obs; // Format: "year-month"

  // Optimized Flattened List for UI
  final RxList<HomeListItem> visibleItems = <HomeListItem>[].obs;

  // Financial Insights
  final RxList<ChartDataPoint> chartData = <ChartDataPoint>[].obs;
  final RxDouble averageDaily = 0.0.obs;
  final RxDouble averageMonthly = 0.0.obs;
  final RxDouble averageYearly = 0.0.obs;

  // Internal Cache
  // Year -> { Month -> List<Transaction> }
  Map<int, Map<int, List<Transaction>>> _cachedGroupedData = {};
  List<int> _cachedSortedYears = [];

  // Sort Option
  final Rxn<SortOption> selectedSortOption = Rxn<SortOption>(SortOption.mostRecent);
  final Rxn<SortDirection> selectedSortDirection = Rxn<SortDirection>(SortDirection.top);

  @override
  void onInit() {
    super.onInit();

    // Debounce data/filter/sort changes
    debounce(transactions, (_) {
      // If "All" is selected, automatically expand range to include new transactions
      if (selectedDurationTab.value == 'All') {
        _applyAllFilterLogic();
      }
      _rebuildCacheAndItems();
    }, time: const Duration(milliseconds: 50));
    debounce(
      selectedToggleOption,
      (_) => _rebuildCacheAndItems(),
      time: const Duration(milliseconds: 50),
    );
    debounce(
      selectedSortOption,
      (_) => _rebuildCacheAndItems(),
      time: const Duration(milliseconds: 50),
    );
    debounce(
      selectedSortDirection,
      (_) => _rebuildCacheAndItems(),
      time: const Duration(milliseconds: 50),
    );

    // Expansion changes handle purely visual flattening, no re-grouping needed
    ever(expandedYears, (_) => _updateVisibleItems());
    ever(expandedMonths, (_) => _updateVisibleItems());

    loadTransactions();
  }

  // Filter State
  final Rx<DateTime?> _transactionDateStart = Rx<DateTime?>(null);
  final Rx<DateTime?> _transactionDateEnd = Rx<DateTime?>(null);
  final RxDouble minAmount = 0.0.obs;
  final RxDouble maxAmount = double.infinity.obs;

  // "All" is selected by default for duration tabs
  final RxString selectedDurationTab = 'All'.obs;

  // Computed properties
  DateTime get transactionDateStart => _transactionDateStart.value ?? minDate;
  DateTime get transactionDateEnd => _transactionDateEnd.value ?? maxDate;

  // Helper to determine the full available date range from data
  DateTime get minDate {
    if (transactions.isEmpty) {
      // Default to 30 days ago if no data, to ensure slider has range
      return DateUtils.dateOnly(
        DateTime.now(),
      ).subtract(const Duration(days: 30));
    }
    return transactions
        .map((t) => t.date)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  DateTime get maxDate {
    if (transactions.isEmpty) return DateUtils.dateOnly(DateTime.now());
    return transactions
        .map((t) => t.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  // Slider Bounds (Safe for RangeSlider)
  DateTime get sliderMinDate {
    final tStart = _transactionDateStart.value ?? minDate;
    // Return the minimum of data-min and selected-start
    return tStart.isBefore(minDate) ? tStart : minDate;
  }

  DateTime get sliderMaxDate {
    final tEnd = _transactionDateEnd.value ?? maxDate;
    // Return the maximum of data-max and selected-end
    // Also ensure we at least cover "now" if that's relevant to the filter?
    // Filters often go up to "now".
    final effectiveMax = tEnd.isAfter(maxDate) ? tEnd : maxDate;

    // Ensure min < max for the slider. If they are equal, add a small buffer.
    if (effectiveMax.isAtSameMomentAs(sliderMinDate) ||
        effectiveMax.isBefore(sliderMinDate)) {
      return sliderMinDate.add(const Duration(days: 1));
    }
    return effectiveMax;
  }

  final RxList<MCCItem> selectedMCCFilters = <MCCItem>[].obs;
  final RxList<HashtagGroup> selectedHashtagFilters = <HashtagGroup>[].obs;

  void updateMCCFilters(List<MCCItem> mccs) {
    selectedMCCFilters.assignAll(mccs);
    _rebuildCacheAndItems();
    _calculateStatsAndChart();
  }

  void updateHashtagFilters(List<HashtagGroup> hashtags) {
    selectedHashtagFilters.assignAll(hashtags);

    _rebuildCacheAndItems();
    _calculateStatsAndChart();
  }

  int get activeFilterCount {
    int count = 0;
    // If "All" tab is selected, we consider date filter inactive
    if (selectedDurationTab.value != 'All' &&
        !isFullRange(transactionDateStart, transactionDateEnd)) {
      count++;
    }
    if (minAmount.value > 0 || maxAmount.value < double.infinity) count++;
    if (selectedMCCFilters.isNotEmpty) count++;
    if (selectedHashtagFilters.isNotEmpty) count++;
    return count;
  }

  // Setters
  void updateDateRange(DateTime? start, DateTime? end) {
    // Logic to see if this matches a predefined tab or should be custom/unselected
    // If null (reset) or full range, select 'All'
    if ((start == null && end == null) ||
        (start != null && end != null && isFullRange(start, end))) {
      selectedDurationTab.value = 'All';

      // Apply "All" logic manually to ensure we extend to today
      _applyAllFilterLogic();
    } else {
      selectedDurationTab.value = ''; // Custom
      _transactionDateStart.value = start;
      _transactionDateEnd.value = end;
    }

    _rebuildCacheAndItems();
    _calculateStatsAndChart();
  }

  bool isFullRange(DateTime start, DateTime end) {
    // Check start matches minDate
    final startMatches = start.isAtSameMomentAs(minDate);

    // Check end matches EITHER maxDate OR proper "All" end logic (end of today)
    // Because _applyAllFilterLogic sets end to endOfToday if maxDate < endOfToday
    // we need to be flexible here.
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final effectiveMax = maxDate.isAfter(endOfDay) ? maxDate : endOfDay;

    final endMatches =
        end.isAtSameMomentAs(maxDate) ||
        end.isAtSameMomentAs(effectiveMax) ||
        end.isAtSameMomentAs(endOfDay);

    return startMatches && endMatches;
  }

  // Available Duration filtering
  List<String> get availableDurationTabs {
    // Determine the extent of the data
    // If no transactions, fallback to basic options
    if (transactions.isEmpty) {
      return ['1d', '7d', '2w', '1m', '3m', '6m', 'All'];
    }

    // Min date vs Now
    // We base "availability" on whether there is any data extending back that far?
    // OR just use minDate vs Now duration?
    // "if you have dates from up to 6 years you show all"
    // So we calculate the difference between Now and MinDate.

    final now = DateTime.now();
    final dataMin = minDate; // This is computed from transactions
    final duration = now.difference(dataMin);
    final days = duration.inDays;

    final tabs = <String>['1d', '7d', '2w', '1m', '3m', '6m'];

    // Add 1y if we have >= 365 days of data (approx)
    // Or actually, the request says: "if only transaction from 1 year are there [show up to 6m, all]"
    // This implies 1y button only appears if there's > 1 year of data? Or maybe >= 6 months?
    // "if only transaction from 1 year are there you should only show(1d, 7d, 2w, 1m, 3m, 6m, all)"
    // This phrasing is slightly ambiguous. "From 1 year" could mean data IS 1 year old.
    // Let's assume:
    // If data duration >= 1 year -> Show 1y
    // If data duration >= 2 years -> Show 2y
    // If data duration >= 5 years -> Show 5y

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

  void updateDurationTab(String tab) {
    selectedDurationTab.value = tab;

    // Logic
    final now = DateTime.now();
    // End of today (23:59:59.999) to ensure all transactions of the current day are included
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    DateTime start = minDate;

    switch (tab) {
      case '1d':
        // Today (from 00:00:00)
        start = DateTime(now.year, now.month, now.day);
        break;
      case '7d':
        // Last 7 days
        start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));
        break;
      case '2w':
        // Last 2 weeks (14 days)
        start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 13));
        break;
      case '1m':
        // Last 1 month
        start = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3m':
        // Last 3 months (from start of day)
        start = DateTime(now.year, now.month - 3, now.day);
        break;
      case '6m':
        // Last 6 months
        start = DateTime(now.year, now.month - 6, now.day);
        break;
      case '1y':
        // Last 1 year (from start of day)
        start = DateTime(now.year - 1, now.month, now.day);
        break;
      case '2y':
        // Last 2 years
        start = DateTime(now.year - 2, now.month, now.day);
        break;
      case '5y':
        // Last 5 years (from start of day)
        start = DateTime(now.year - 5, now.month, now.day);
        break;
      case 'All':
      default:
        start = minDate; // This will trigger full range
        break;
    }

    // If "All", we just cover min to max transaction date
    if (tab == 'All') {
      _applyAllFilterLogic();
    } else {
      _transactionDateStart.value = start;
      _transactionDateEnd.value = endOfDay;
    }

    _rebuildCacheAndItems();
    _calculateStatsAndChart();
  }

  void _applyAllFilterLogic() {
    _transactionDateStart.value = minDate;
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    final effectiveMax = maxDate.isAfter(endOfDay) ? maxDate : endOfDay;
    _transactionDateEnd.value = effectiveMax;
  }

  void updateAmountRange(double min, double max) {
    minAmount.value = min;
    maxAmount.value = max;
    _rebuildCacheAndItems();
  }

  Future<void> loadTransactions() async {
    try {
      isLoading.value = true;
      final loadedTransactions = await _transactionRepository
          .getAllTransactions();
      transactions.value = loadedTransactions;
    } catch (e) {
      debugPrint('[HomeController] Error loading transactions: $e');
    } finally {
      isLoading.value = false;
      _calculateStatsAndChart();
    }
  }

  void _rebuildCacheAndItems() {
    _buildGroupingCache();
    if (expandedYears.isEmpty && _cachedSortedYears.isNotEmpty) {
      _expandAll();
    } else if (_cachedSortedYears.isEmpty) {
      // Reset expansion state when no data so that next add triggers _expandAll
      expandedYears.clear();
      expandedMonths.clear();
    }
    _updateVisibleItems();
    _calculateStatsAndChart();
  }

  /// Calculate averages and chart data
  void _calculateStatsAndChart() {
    // 1. Get relevant transactions (Expense vs Income)
    var relevantTransactions = isExpenseSelected
        ? TransactionHelper.filterExpenses(transactions)
        : TransactionHelper.filterIncome(transactions);

    // 2. Filter by currently selected date range & filters
    relevantTransactions = relevantTransactions.where((t) {
      final date = t.date;
      final matchesDate =
          (date.isAfter(transactionDateStart) ||
              date.isAtSameMomentAs(transactionDateStart)) &&
          (date.isBefore(transactionDateEnd) ||
              date.isAtSameMomentAs(transactionDateEnd));

      final matchesAmount =
          t.amount >= minAmount.value && t.amount <= maxAmount.value;

      bool matchesMCC = true;
      if (selectedMCCFilters.isNotEmpty) {
        final mccIds = selectedMCCFilters.map((e) => e.id).toSet();
        matchesMCC = mccIds.contains(t.mccId);
      }

      bool matchesHashtag = true;
      if (selectedHashtagFilters.isNotEmpty) {
        final hashtagIds = selectedHashtagFilters.map((e) => e.id).toSet();
        matchesHashtag = t.hashtags.any((h) => hashtagIds.contains(h.id));
      }

      return matchesDate && matchesAmount && matchesMCC && matchesHashtag;
    }).toList();

    // 3. Calculate Totals
    double totalAmount = 0;
    for (var t in relevantTransactions) {
      totalAmount += t.amount;
    }

    // 4. Calculate Duration in Days
    // If start == end (e.g. single day), duration is 1 day.
    int durationInDays = transactionDateEnd
        .difference(transactionDateStart)
        .inDays;
    if (durationInDays < 1) durationInDays = 1;

    // 5. Calculate Averages
    // Daily is simple total / days
    averageDaily.value = totalAmount / durationInDays;
    // Monthly is Total / (Days / 30) => Total * 30 / Days
    averageMonthly.value = (totalAmount / durationInDays) * 30;
    // Yearly is Total / (Days / 365) => Total * 365 / Days
    averageYearly.value = (totalAmount / durationInDays) * 365;

    // 6. Generate Chart Data with Dynamic Points
    List<ChartDataPoint> points = [];

    // Determine target points based on duration
    int targetPoints;
    if (durationInDays <= 2) {
      // 1d: Show 24 hourly points
      targetPoints = 24;
    } else if (durationInDays < 90) {
      // < 90 days: Show actual number of days as points
      targetPoints = durationInDays.ceil();
    } else {
      // >= 90 days: Use fixed 90 points with aggregation
      targetPoints = 90;
    }

    // Calculate aggregation window in milliseconds
    final totalDurationMs = transactionDateEnd.millisecondsSinceEpoch -
                           transactionDateStart.millisecondsSinceEpoch;
    final windowSizeMs = totalDurationMs / targetPoints;

    // Create a map of all transactions by timestamp for quick lookup
    Map<int, List<Transaction>> transactionsByWindow = {};
    for (var t in relevantTransactions) {
      final windowIndex = ((t.date.millisecondsSinceEpoch -
                           transactionDateStart.millisecondsSinceEpoch) /
                           windowSizeMs).floor();
      transactionsByWindow.putIfAbsent(windowIndex, () => []).add(t);
    }

    // Generate points with step-line effect (duplicate points at transitions)
    double lastValue = 0.0; // Track last value for step effect

    for (int i = 0; i < targetPoints; i++) {
      final windowStartMs = transactionDateStart.millisecondsSinceEpoch +
                           (i * windowSizeMs).toInt();
      final windowEndMs = windowStartMs + windowSizeMs.toInt();

      // Create DateTime objects for start and end of window
      final windowStart = DateTime.fromMillisecondsSinceEpoch(windowStartMs);
      final windowEnd = DateTime.fromMillisecondsSinceEpoch(windowEndMs);
      final windowMidpoint = DateTime.fromMillisecondsSinceEpoch(
        ((windowStartMs + windowEndMs) / 2).toInt(),
      );

      // Calculate average/sum for this window
      double windowValue = 0.0;
      if (transactionsByWindow.containsKey(i)) {
        final windowTransactions = transactionsByWindow[i]!;
        windowValue = windowTransactions.fold(0.0, (sum, t) => sum + t.amount);
      } else {
        // No data in this window - use last value
        windowValue = lastValue;
      }

      // Format label based on duration (for X-axis)
      String label;
      String tooltipLabel;

      if (durationInDays <= 2) {
        // Hourly labels
        label = DateFormat('HH:mm').format(windowMidpoint);
        tooltipLabel = '${windowValue.toStringAsFixed(2)}\n'
                      '${DateFormat('HH:mm dd.MM.yyyy').format(windowMidpoint)}';
      } else if (durationInDays <= 90) {
        // Daily labels (<= 3 months)
        label = DateFormat('dd.MM.yyyy').format(windowMidpoint);
        tooltipLabel = '${windowValue.toStringAsFixed(2)}\n'
                      '${DateFormat('dd.MM.yyyy').format(windowMidpoint)}';
      } else if (durationInDays <= 365 * 2 + 10) {
        // Monthly labels (> 3 months)
        label = DateFormat('MMM yyyy').format(windowMidpoint);
        tooltipLabel = '${windowValue.toStringAsFixed(2)}\n'
                      '${DateFormat('dd.MM.yyyy').format(windowStart)} - '
                      '${DateFormat('dd.MM.yyyy').format(windowEnd)}';
      } else {
        // Yearly labels (> 3 months)
        label = DateFormat('yyyy').format(windowMidpoint);
        tooltipLabel = '${windowValue.toStringAsFixed(2)}\n'
                      '${DateFormat('dd.MM.yyyy').format(windowStart)} - '
                      '${DateFormat('dd.MM.yyyy').format(windowEnd)}';
      }

      // Step-line effect: Add duplicate point at transition if value changed
      if (i > 0 && windowValue != lastValue) {
        // Add point at current X position with PREVIOUS value (horizontal continuation)
        points.add(
          ChartDataPoint(
            label: label,
            value: lastValue, // Keep previous value
            tooltipLabel: '${lastValue.toStringAsFixed(2)}\n$label',
            xValue: i.toDouble(), // Same X position as new value
          ),
        );
      }

      // Add the actual point with new value
      points.add(
        ChartDataPoint(
          label: label,
          value: windowValue,
          tooltipLabel: tooltipLabel,
          xValue: i.toDouble(), // X position based on window index
        ),
      );

      // Update last value for next iteration
      lastValue = windowValue;
    }

    chartData.value = points;
  }

  /// Builds the nested map structure (Year -> Month -> Transactions)
  void _buildGroupingCache() {
    // 1. Filter
    var filtered = isExpenseSelected
        ? TransactionHelper.filterExpenses(transactions)
        : TransactionHelper.filterIncome(transactions);

    // Apply Date Range Filter
    filtered = filtered.where((t) {
      final date = t.date;
      return (date.isAfter(transactionDateStart) ||
              date.isAtSameMomentAs(transactionDateStart)) &&
          (date.isBefore(transactionDateEnd) ||
              date.isAtSameMomentAs(transactionDateEnd));
    }).toList();

    // Apply Amount Range Filter
    filtered = filtered.where((t) {
      return t.amount >= minAmount.value && t.amount <= maxAmount.value;
    }).toList();

    // Apply MCC Filter
    if (selectedMCCFilters.isNotEmpty) {
      final mccIds = selectedMCCFilters.map((e) => e.id).toSet();
      filtered = filtered.where((t) => mccIds.contains(t.mccId)).toList();
    }

    // Apply Hashtag Filter
    if (selectedHashtagFilters.isNotEmpty) {
      final hashtagIds = selectedHashtagFilters.map((e) => e.id).toSet();
      filtered = filtered.where((t) {
        return t.hashtags.any((h) => hashtagIds.contains(h.id));
      }).toList();
    }

    // 2. Group by Year and Month
    _cachedGroupedData = {};
    for (var t in filtered) {
      final year = t.date.year;
      final month = t.date.month;

      _cachedGroupedData.putIfAbsent(year, () => {});
      _cachedGroupedData[year]!.putIfAbsent(month, () => []);
      _cachedGroupedData[year]![month]!.add(t);
    }

    // 3. Sort Years (Always Descending)
    _cachedSortedYears = _cachedGroupedData.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    // 4. Sort Transactions within each Month
    for (var year in _cachedGroupedData.keys) {
      for (var month in _cachedGroupedData[year]!.keys) {
        var monthTransactions = _cachedGroupedData[year]![month]!;

        if (selectedSortOption.value != null) {
          final isTopDirection = selectedSortDirection.value == SortDirection.top;

          if (selectedSortOption.value == SortOption.highestAmount) {
            // Sort by Amount
            if (isTopDirection) {
              // Highest Amount First (top)
              monthTransactions.sort((a, b) => b.amount.compareTo(a.amount));
            } else {
              // Lowest Amount First (bottom)
              monthTransactions.sort((a, b) => a.amount.compareTo(b.amount));
            }
          } else if (selectedSortOption.value == SortOption.mostRecent) {
            // Sort by Date
            if (isTopDirection) {
              // Most Recent First (top)
              monthTransactions.sort((a, b) => b.date.compareTo(a.date));
            } else {
              // Oldest First (bottom)
              monthTransactions.sort((a, b) => a.date.compareTo(b.date));
            }
          }
        }
      }
    }
  }

  /// Flattens the grouped data into a single list based on expansion state
  void _updateVisibleItems() {
    final newItems = <HomeListItem>[];

    for (var year in _cachedSortedYears) {
      final monthsMap = _cachedGroupedData[year]!;

      // Calculate Year Total
      double yearTotal = 0;
      for (var monthList in monthsMap.values) {
        for (var t in monthList) {
          yearTotal += (t.isExpense ? -t.amount : t.amount);
        }
      }

      final isYearExpanded = expandedYears.contains(year);
      newItems.add(
        YearHeaderItem(
          year: year,
          totalAmount: yearTotal,
          isExpanded: isYearExpanded,
        ),
      );

      if (isYearExpanded) {
        final sortedMonths = monthsMap.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        for (var month in sortedMonths) {
          final monthTrans = monthsMap[month]!;

          // Calculate Month Total
          double monthTotal = 0;
          for (var t in monthTrans) {
            monthTotal += (t.isExpense ? -t.amount : t.amount);
          }

          final isMonthExpanded = expandedMonths.contains('$year-$month');
          newItems.add(
            MonthHeaderItem(
              year: year,
              month: month,
              monthName: getMonthName(month),
              totalAmount: monthTotal,
              isExpanded: isMonthExpanded,
            ),
          );

          if (isMonthExpanded) {
            newItems.add(SpacerItem(height: 13.h)); // Top padding
            for (var t in monthTrans) {
              if (t.id != null) {
                newItems.add(TransactionListItem(transaction: t));
              }
            }
            // No explicit bottom padding item needed as next header adds space,
            // or we can add small spacer if design requirements dictate.
          }

          // Add spacing between months if expanded
          if (isMonthExpanded && month != sortedMonths.last) {
            newItems.add(SpacerItem(height: 18.h));
          }
        }
      }

      // Add spacing between years
      if (year != _cachedSortedYears.last) {
        newItems.add(SpacerItem(height: 18.h));
      }
    }

    // Bottom padding for scrolling
    newItems.add(SpacerItem(height: 150.h));

    visibleItems.value = newItems;
  }

  /// Expand all years and months by default
  void _expandAll() {
    for (var year in _cachedSortedYears) {
      expandedYears.add(year);
      final monthsMap = _cachedGroupedData[year];
      if (monthsMap != null) {
        for (var month in monthsMap.keys) {
          expandedMonths.add('$year-$month');
        }
      }
    }
  }

  // Getters
  bool get isExpenseSelected => selectedToggleOption.value == 1;

  // Methods
  void selectSpending() {
    selectedToggleOption.value = 1;
  }

  void selectIncome() {
    selectedToggleOption.value = 2;
  }

  void selectYear() {
    selectedChartDurationOption.value = 1;
  }

  void selectMonth() {
    selectedChartDurationOption.value = 2;
  }

  /// Add a new transaction
  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _transactionRepository.addTransaction(transaction);
      // loadTransactions triggers the worker flow
      await loadTransactions();
    } catch (e) {
      debugPrint('[HomeController] Error adding transaction: $e');
    }
  }

  /// Update a transaction
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await _transactionRepository.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      debugPrint('[HomeController] Error updating transaction: $e');
    }
  }

  /// Delete transaction by ID
  Future<void> deleteTransactionById(int id) async {
    try {
      await _transactionRepository.deleteTransaction(id);
      await loadTransactions();
    } catch (e) {
      debugPrint('[HomeController] Error deleting transaction: $e');
    }
  }

  /// Delete multiple transactions by IDs
  Future<void> deleteTransactions(List<int> ids) async {
    try {
      for (final id in ids) {
        await _transactionRepository.deleteTransaction(id);
      }
      await loadTransactions();
    } catch (e) {
      debugPrint('[HomeController] Error deleting transactions: $e');
    }
  }

  /// Update MCC for multiple transactions
  Future<void> updateTransactionsMCC(List<int> ids, int mccId) async {
    try {
      for (final id in ids) {
        // Find existing transaction to preserve other fields
        final existingTransactionIndex = transactions.indexWhere(
          (t) => t.id == id,
        );
        if (existingTransactionIndex != -1) {
          final existingTransaction = transactions[existingTransactionIndex];
          final updatedTransaction = existingTransaction.copyWith(mccId: mccId);
          await _transactionRepository.updateTransaction(updatedTransaction);
        }
      }
      await loadTransactions();
    } catch (e) {
      debugPrint('[HomeController] Error updating transactions MCC: $e');
    }
  }

  /// Update Hashtag for multiple transactions
  Future<void> updateTransactionsHashtag(
    List<int> ids,
    HashtagGroup hashtag,
  ) async {
    try {
      for (final id in ids) {
        final existingTransactionIndex = transactions.indexWhere(
          (t) => t.id == id,
        );
        if (existingTransactionIndex != -1) {
          final existingTransaction = transactions[existingTransactionIndex];

          // Check if hashtag already exists
          final alreadyExists = existingTransaction.hashtags.any(
            (h) => h.id == hashtag.id,
          );

          if (!alreadyExists) {
            final updatedHashtags = List<HashtagGroup>.from(
              existingTransaction.hashtags,
            )..add(hashtag);
            final updatedTransaction = existingTransaction.copyWith(
              hashtags: updatedHashtags,
            );
            await _transactionRepository.updateTransaction(updatedTransaction);
          }
        }
      }
      await loadTransactions();
    } catch (e) {
      debugPrint('[HomeController] Error updating transactions Hashtag: $e');
    }
  }

  /// Toggle year expansion
  void toggleYearExpansion(int year) {
    if (expandedYears.contains(year)) {
      expandedYears.remove(year);
      // Don't collapse associated months to preserve state
      // expandedMonths.removeWhere((key) => key.startsWith('$year-'));
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
    // Determine month name safely
    // Using a fixed year 2024 to avoid leap year issues or similar quirks with day 29-31
    final date = DateTime(2024, month);
    return DateFormat('MMMM').format(date);
  }
}
