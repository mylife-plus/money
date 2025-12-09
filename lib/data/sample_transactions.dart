import 'package:flutter/material.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/models/transaction_model.dart';

/// Sample transaction data for testing and development
class SampleTransactions {
  SampleTransactions._();

  /// Sample hashtag groups
  static final List<HashtagGroup> _sampleHashtags = [
    HashtagGroup(
      id: 1,
      name: 'Shopping',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    HashtagGroup(
      id: 2,
      name: 'Travel',
      parentId: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    HashtagGroup(
      id: 3,
      name: 'Repair',
      parentId: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    HashtagGroup(
      id: 4,
      name: 'Food',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    HashtagGroup(
      id: 5,
      name: 'Transport',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    HashtagGroup(
      id: 6,
      name: 'Entertainment',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  /// Sample MCCs (Merchant Category Codes)
  static final List<MCC> _sampleMCCs = [
    MCC.fromAsset(
      assetPath: AppIcons.cart,
      text: 'Shopping',
      shortText: '🛒',
      color: const Color(0xffFFD4A3),
    ),
    MCC.fromAsset(
      assetPath: AppIcons.car,
      text: 'Transport',
      shortText: '🚗',
      color: const Color(0xffA3FFD4),
    ),
    MCC.fromAsset(
      assetPath: AppIcons.investment,
      text: 'Investment',
      shortText: '💰',
      color: const Color(0xffB7DDFF),
    ),
    MCC.fromAsset(
      assetPath: AppIcons.atm,
      text: 'Cash Withdrawal',
      shortText: '💵',
      color: const Color(0xffFFD4A3),
    ),
    MCC.fromAsset(
      assetPath: AppIcons.digitalCurrency,
      text: 'Crypto',
      shortText: '₿',
      color: const Color(0xffFFF1B8),
    ),
    MCC.fromAsset(
      assetPath: AppIcons.transaction,
      text: 'General',
      shortText: '📝',
      color: const Color(0xffDFDFDF),
    ),
  ];

  /// Sample transactions
  static final List<Transaction> transactions = [
    // Expense: Shopping at supermarket
    Transaction(
      id: 1,
      isExpense: true,
      date: DateTime.now().subtract(const Duration(days: 1)),
      amount: 125.50,
      mcc: _sampleMCCs[0], // Shopping
      recipient: 'Lidl Supermarket',
      note: 'Weekly grocery shopping',
      hashtags: [_sampleHashtags[0], _sampleHashtags[4]], // Shopping, Food
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),

    // Expense: Car fuel
    Transaction(
      id: 2,
      isExpense: true,
      date: DateTime.now().subtract(const Duration(days: 2)),
      amount: 65.00,
      mcc: _sampleMCCs[1], // Transport
      recipient: 'Shell Gas Station',
      note: 'Fuel at Shell station',
      hashtags: [_sampleHashtags[4]], // Transport
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),

    // Income: Salary
    Transaction(
      id: 3,
      isExpense: false,
      date: DateTime.now().subtract(const Duration(days: 3)),
      amount: 3500.00,
      mcc: _sampleMCCs[5], // General
      recipient: 'Company Payroll',
      note: 'Monthly salary payment',
      hashtags: [],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),

    // Expense: Investment in crypto
    Transaction(
      id: 4,
      isExpense: true,
      date: DateTime.now().subtract(const Duration(days: 4)),
      amount: 500.00,
      mcc: _sampleMCCs[4], // Crypto
      recipient: 'Coinbase Exchange',
      note: 'Bought Bitcoin',
      hashtags: [],
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),

    // Expense: ATM withdrawal
    Transaction(
      id: 5,
      isExpense: true,
      date: DateTime.now().subtract(const Duration(days: 5)),
      amount: 200.00,
      mcc: _sampleMCCs[3], // Cash Withdrawal
      recipient: 'ATM Deutsche Bank',
      note: 'Cash for weekly expenses',
      hashtags: [],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),

    // Expense: Restaurant
    Transaction(
      id: 6,
      isExpense: true,
      date: DateTime.now().subtract(const Duration(days: 6)),
      amount: 85.30,
      mcc: _sampleMCCs[0], // Shopping
      recipient: 'Bella Italia Restaurant',
      note: 'Dinner with family',
      hashtags: [_sampleHashtags[3], _sampleHashtags[5]], // Food, Entertainment
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
      updatedAt: DateTime.now().subtract(const Duration(days: 6)),
    ),

    // Expense: Travel booking
    Transaction(
      id: 7,
      isExpense: true,
      date: DateTime.now().subtract(const Duration(days: 7)),
      amount: 450.00,
      mcc: _sampleMCCs[1], // Transport
      recipient: 'Ryanair Airlines',
      note: 'Flight tickets to Barcelona',
      hashtags: [_sampleHashtags[1]], // Travel
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),

    // Income: Freelance work
    Transaction(
      id: 8,
      isExpense: false,
      date: DateTime.now().subtract(const Duration(days: 8)),
      amount: 750.00,
      mcc: _sampleMCCs[5], // General
      recipient: 'Tech Startup GmbH',
      note: 'Freelance web development project',
      hashtags: [],
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(days: 8)),
    ),

    // Expense: Car repair
    Transaction(
      id: 9,
      isExpense: true,
      date: DateTime.now().subtract(const Duration(days: 9)),
      amount: 320.00,
      mcc: _sampleMCCs[1], // Transport
      recipient: 'AutoWerkstatt Müller',
      note: 'Oil change and brake inspection',
      hashtags: [_sampleHashtags[2], _sampleHashtags[4]], // Repair, Transport
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
      updatedAt: DateTime.now().subtract(const Duration(days: 9)),
    ),

    // Expense: Online shopping
    Transaction(
      id: 10,
      isExpense: true,
      date: DateTime.now().subtract(const Duration(days: 10)),
      amount: 89.99,
      mcc: _sampleMCCs[0], // Shopping
      recipient: 'Amazon.de',
      note: 'Books and USB cables',
      hashtags: [_sampleHashtags[0]], // Shopping
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),

    // Income: Investment return
    Transaction(
      id: 11,
      isExpense: false,
      date: DateTime.now().subtract(const Duration(days: 12)),
      amount: 150.00,
      mcc: _sampleMCCs[2], // Investment
      recipient: 'Trade Republic',
      note: 'Quarterly dividend payment',
      hashtags: [],
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      updatedAt: DateTime.now().subtract(const Duration(days: 12)),
    ),

    // Expense: Gym membership
    Transaction(
      id: 12,
      isExpense: true,
      date: DateTime.now().subtract(const Duration(days: 15)),
      amount: 45.00,
      mcc: _sampleMCCs[5], // General
      recipient: 'FitX Fitness Studio',
      note: 'Monthly gym membership fee',
      hashtags: [_sampleHashtags[5]], // Entertainment
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  /// Get sample transactions
  static List<Transaction> getSampleTransactions() {
    return transactions;
  }

  /// Get sample hashtags
  static List<HashtagGroup> getSampleHashtags() {
    return _sampleHashtags;
  }

  /// Get sample MCCs
  static List<MCC> getSampleMCCs() {
    return _sampleMCCs;
  }

  /// Get expenses only
  static List<Transaction> getSampleExpenses() {
    return TransactionHelper.filterExpenses(transactions);
  }

  /// Get income only
  static List<Transaction> getSampleIncome() {
    return TransactionHelper.filterIncome(transactions);
  }

  /// Get transactions from last 7 days
  static List<Transaction> getLastWeekTransactions() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return TransactionHelper.filterByDateRange(transactions, weekAgo, now);
  }

  /// Get transactions from last 30 days
  static List<Transaction> getLastMonthTransactions() {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    return TransactionHelper.filterByDateRange(transactions, monthAgo, now);
  }

  /// Get total balance from sample data
  static double getSampleBalance() {
    return TransactionHelper.getBalance(transactions);
  }

  /// Get total expenses from sample data
  static double getSampleTotalExpenses() {
    return TransactionHelper.calculateTotalExpenses(transactions);
  }

  /// Get total income from sample data
  static double getSampleTotalIncome() {
    return TransactionHelper.calculateTotalIncome(transactions);
  }
}
