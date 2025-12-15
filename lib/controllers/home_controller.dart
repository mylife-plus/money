import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/data/sample_transactions.dart';
import 'package:moneyapp/models/transaction_model.dart';

/// Home Screen Controller
/// Manages state and business logic for Home Screen
class HomeController extends GetxController {
  // Observable variables
  final RxInt selectedToggleOption = 1.obs; // 1 = Spending, 2 = Income
  final RxInt selectedChartDurationOption = 1.obs; // 1 = Year, 2 = Month

  // Transactions
  final RxList<Transaction> transactions = <Transaction>[].obs;

  // Expandable state tracking
  final RxSet<int> expandedYears = <int>{}.obs;
  final RxSet<String> expandedMonths = <String>{}.obs; // Format: "year-month"

  @override
  void onInit() {
    super.onInit();
    // Load sample transactions
    transactions.value = SampleTransactions.getSampleTransactions();

    // Expand latest year and month by default
    _expandLatestYearAndMonth();
  }

  /// Expand all years and months by default
  void _expandLatestYearAndMonth() {
    for (var year in sortedYears) {
      expandedYears.add(year);

      final monthsInYear = getSortedMonths(year);
      for (var month in monthsInYear) {
        expandedMonths.add('$year-$month');
      }
    }
  }

  // Getters
  bool get isExpenseSelected => selectedToggleOption.value == 1;

  /// Get filtered transactions based on selected toggle (expense/income)
  List<Transaction> get filteredTransactions {
    if (isExpenseSelected) {
      return TransactionHelper.filterExpenses(transactions);
    } else {
      return TransactionHelper.filterIncome(transactions);
    }
  }

  /// Get sorted transactions (newest first)
  List<Transaction> get sortedTransactions {
    return TransactionHelper.sortByDateDesc(filteredTransactions);
  }

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
  void addTransaction(Transaction transaction) {
    transactions.add(transaction);
  }

  /// Remove a transaction
  void removeTransaction(int index) {
    if (index >= 0 && index < transactions.length) {
      transactions.removeAt(index);
    }
  }

  /// Update a transaction
  void updateTransaction(int index, Transaction transaction) {
    if (index >= 0 && index < transactions.length) {
      transactions[index] = transaction;
    }
  }

  /// Delete transaction by ID
  void deleteTransactionById(int id) {
    transactions.removeWhere((t) => t.id == id);
  }

  /// Delete multiple transactions by IDs
  void deleteTransactions(List<int> ids) {
    transactions.removeWhere((t) => t.id != null && ids.contains(t.id));
  }

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

  /// Group transactions by year
  Map<int, List<Transaction>> get transactionsByYear {
    final Map<int, List<Transaction>> grouped = {};
    for (var transaction in filteredTransactions) {
      final year = transaction.date.year;
      if (!grouped.containsKey(year)) {
        grouped[year] = [];
      }
      grouped[year]!.add(transaction);
    }
    return grouped;
  }

  /// Get years sorted (newest first)
  List<int> get sortedYears {
    return transactionsByYear.keys.toList()..sort((a, b) => b.compareTo(a));
  }

  /// Group transactions by month for a specific year
  Map<int, List<Transaction>> getTransactionsByMonth(int year) {
    final yearTransactions = transactionsByYear[year] ?? [];
    final Map<int, List<Transaction>> grouped = {};
    for (var transaction in yearTransactions) {
      final month = transaction.date.month;
      if (!grouped.containsKey(month)) {
        grouped[month] = [];
      }
      grouped[month]!.add(transaction);
    }
    return grouped;
  }

  /// Get months sorted (newest first) for a specific year
  List<int> getSortedMonths(int year) {
    final monthsMap = getTransactionsByMonth(year);
    return monthsMap.keys.toList()..sort((a, b) => b.compareTo(a));
  }

  /// Get transactions for a specific year and month
  List<Transaction> getTransactionsForMonth(int year, int month) {
    final monthsMap = getTransactionsByMonth(year);
    return TransactionHelper.sortByDateDesc(monthsMap[month] ?? []);
  }

  /// Calculate total for a year
  double calculateYearTotal(int year) {
    final yearTransactions = transactionsByYear[year] ?? [];
    return yearTransactions.fold(0.0, (sum, t) {
      return sum + (t.isExpense ? -t.amount : t.amount);
    });
  }

  /// Calculate total for a month
  double calculateMonthTotal(int year, int month) {
    final monthTransactions = getTransactionsForMonth(year, month);
    return monthTransactions.fold(0.0, (sum, t) {
      return sum + (t.isExpense ? -t.amount : t.amount);
    });
  }

  /// Get month name from number
  String getMonthName(int month) {
    final date = DateTime(2024, month);
    return DateFormat('MMMM').format(date);
  }
}
