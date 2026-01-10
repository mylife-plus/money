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
  void updateSortOption(SortOption option) {
    selectedSortOption.value = option;
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
  final Rx<SortOption> selectedSortOption = SortOption.mostRecent.obs;

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
      case '2d':
        // Today + Yesterday (from 00:00:00 yesterday)
        start = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 1));
        break;
      case '3m':
        // Last 3 months (from start of day)
        start = DateTime(now.year, now.month - 3, now.day);
        break;
      case '1y':
        // Last 1 year (from start of day)
        start = DateTime(now.year - 1, now.month, now.day);
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

    // 6. Generate Chart Data
    // Grouping depends on the duration

    DateFormat dateFormat;

    if (durationInDays <= 2) {
      // 1-2 Days: Plot *sequential* transactions instead of hourly buckets
      dateFormat = DateFormat('HH:mm');
    } else if (durationInDays <= 90) {
      // <= 3 Months: Group by Day
      dateFormat = DateFormat('MMM d');
    } else if (durationInDays <= 365 * 2) {
      // <= 2 Years: Group by Month
      dateFormat = DateFormat('MMM yy');
    } else {
      // > 2 Years: Group by Year
      dateFormat = DateFormat('yyyy');
    }

    // Sort transactions by date for charting
    relevantTransactions.sort((a, b) => a.date.compareTo(b.date));

    List<ChartDataPoint> points = [];

    if (durationInDays <= 2) {
      // SEQUENTIAL PLOTTING (No gaps, no buckets)
      // Plot every transaction as a point.
      // If multiple transactions at exact same time, we could aggregate,
      // but usually they are distinct enough or it doesn't hurt.
      // Better UX: Show every transaction time.
      for (var t in relevantTransactions) {
        points.add(
          ChartDataPoint(
            label: dateFormat.format(t.date),
            value: t.amount, // Show amount of this specific transaction
          ),
        );
      }
    } else {
      // TIME BUCKET GROUPING (Days/Months/Years)
      Map<DateTime, double> timeGrouped = {};

      for (var t in relevantTransactions) {
        DateTime key;
        if (durationInDays <= 90) {
          key = DateTime(t.date.year, t.date.month, t.date.day);
        } else if (durationInDays <= 365 * 2) {
          key = DateTime(t.date.year, t.date.month);
        } else {
          key = DateTime(t.date.year);
        }

        timeGrouped.update(
          key,
          (value) => value + t.amount,
          ifAbsent: () => t.amount,
        );
      }

      var sortedKeys = timeGrouped.keys.toList()..sort();

      for (var key in sortedKeys) {
        points.add(
          ChartDataPoint(
            label: dateFormat.format(key),
            value: timeGrouped[key]!,
          ),
        );
      }
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

        if (selectedSortOption.value == SortOption.highestAmount) {
          // Highest Amount First
          monthTransactions.sort((a, b) => b.amount.compareTo(a.amount));
        } else {
          // Most Recent First (Date Descending)
          monthTransactions.sort((a, b) => b.date.compareTo(a.date));
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
      // Collapse associated months
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
    // Determine month name safely
    // Using a fixed year 2024 to avoid leap year issues or similar quirks with day 29-31
    final date = DateTime(2024, month);
    return DateFormat('MMMM').format(date);
  }
}
