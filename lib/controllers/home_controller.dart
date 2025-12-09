import 'package:get/get.dart';
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

  @override
  void onInit() {
    super.onInit();
    // Load sample transactions
    transactions.value = SampleTransactions.getSampleTransactions();
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
}
