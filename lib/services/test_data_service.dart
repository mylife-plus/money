import 'package:moneyapp/constants/mcc_data.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:moneyapp/controllers/hashtag_groups_controller.dart';
import 'package:moneyapp/controllers/home_controller.dart';
import 'package:moneyapp/models/transaction_model.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/services/database/database_helper.dart';
import 'package:moneyapp/services/database/repositories/hashtag_repository.dart';
import 'package:moneyapp/services/database/repositories/transaction_repository.dart';

class TestDataService {
  final TransactionRepository _transactionRepo = TransactionRepository();
  final HashtagRepository _hashtagRepo = HashtagRepository();

  /// Generate test data
  /// Clears existing data and creates 500+ random transactions
  Future<void> generateTestData({Function(String)? onProgress}) async {
    try {
      // 1. Clear old data
      if (onProgress != null) onProgress('Clearing old data...');
      await DatabaseHelper.instance.clearAllData();

      // 2. Create Categories (Hashtag Groups)
      if (onProgress != null) onProgress('Creating categories...');
      final createdSubgroups = await _createHashtagGroups();

      // 3. Generate Transactions
      if (onProgress != null) onProgress('Generating transactions...');
      await _generateTransactions(createdSubgroups, onProgress);

      // 4. Reload Controllers
      if (onProgress != null) onProgress('Refreshing app...');
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().loadTransactions();
      }
      if (Get.isRegistered<HashtagGroupsController>()) {
        await Get.find<HashtagGroupsController>().loadHashtagGroups();
      }

      if (onProgress != null) onProgress('Done!');
    } catch (e) {
      debugPrint('[TestDataService] Error generating test data: $e');
      rethrow;
    }
  }

  Future<List<HashtagGroup>> _createHashtagGroups() async {
    final categories = {
      'Housing': ['Rent', 'Mortgage', 'Utilities', 'Maintenance', 'Furniture'],
      'Transportation': [
        'Fuel',
        'Public Transport',
        'Car Insurance',
        'Repairs',
        'Parking',
      ],
      'Food': ['Groceries', 'Dining Out', 'Coffee', 'Snacks', 'Delivery'],
      'Entertainment': [
        'Movies',
        'Games',
        'Subscriptions',
        'Hobbies',
        'Concerts',
      ],
      'Health': ['Doctor', 'Pharmacy', 'Gym', 'Insurance', 'Therapy'],
      'Shopping': ['Clothes', 'Electronics', 'Home', 'Gifts', 'Beauty'],
      'Income': ['Salary', 'Freelance', 'Investments', 'Gifts', 'Rental'],
    };

    final List<HashtagGroup> allSubgroups = [];

    for (var entry in categories.entries) {
      // Create Main Group
      final mainGroupMap = {
        DatabaseHelper.columnHashtagGroupName: entry.key,
        DatabaseHelper.columnHashtagGroupIsCustom: 1,
        DatabaseHelper.columnHashtagGroupCreatedAt: DateTime.now()
            .toIso8601String(),
        DatabaseHelper.columnHashtagGroupUpdatedAt: DateTime.now()
            .toIso8601String(),
      };

      final mainId = await _hashtagRepo.insert(mainGroupMap);

      // Create Subgroups
      for (var subName in entry.value) {
        final subGroupMap = {
          DatabaseHelper.columnHashtagGroupName: subName,
          DatabaseHelper.columnHashtagGroupParentId: mainId,
          DatabaseHelper.columnHashtagGroupIsCustom: 1,
          DatabaseHelper.columnHashtagGroupCreatedAt: DateTime.now()
              .toIso8601String(),
          DatabaseHelper.columnHashtagGroupUpdatedAt: DateTime.now()
              .toIso8601String(),
        };

        final subId = await _hashtagRepo.insert(subGroupMap);

        // Create object for transaction generation
        allSubgroups.add(
          HashtagGroup(
            id: subId,
            name: subName,
            parentId: mainId,
            isCustom: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    }

    return allSubgroups;
  }

  Future<void> _generateTransactions(
    List<HashtagGroup> hashtags,
    Function(String)? onProgress,
  ) async {
    final random = Random();
    final startDate = DateTime(2015, 1, 1);
    final now = DateTime.now();
    final totalDays = now.difference(startDate).inDays;

    // Get valid MCC items
    final allMcCItems = MCCData.getMCCItems();

    const totalTransactions = 550;

    // Realistic Data Lists
    final expenseRecipients = [
      'Starbucks',
      'Uber',
      'Amazon',
      'Netflix',
      'McDonalds',
      'Shell Station',
      'Walmart',
      'Target',
      'Gym',
      'Pharmacy',
      'Apple Store',
      'Spotify',
      'Uber Eats',
      'Whole Foods',
      'CVS',
      '7-Eleven',
      'Delta Airlines',
      'Airbnb',
      'H&M',
      'Nike',
      'Steam',
      'PlayStation',
      'Cinema City',
    ];

    final incomeRecipients = [
      'Tech Corp',
      'Freelance Client A',
      'Freelance Client B',
      'Government',
      'Investment Fund',
      'Side Hustle',
      'Etsy Shop',
      'Refund',
      'Bank Interest',
    ];

    final expenseNotes = [
      'Morning coffee',
      'Ride to work',
      'Monthly subscription',
      'Groceries',
      'Dinner with friends',
      'Gas',
      'New headphones',
      'Gym membership',
      'Flight tickets',
      'Hotel booking',
      'New clothes',
      'Running shoes',
      'Video game',
      'Movie night',
      'Snacks',
      'Office supplies',
    ];

    final incomeNotes = [
      'Monthly Salary',
      'Web Design Project',
      'Q1 Bonus',
      'Tax Refund',
      'Dividend Payout',
      'Sold old bike',
      'Gift from parents',
      'Reimbursement',
    ];

    for (int i = 0; i < totalTransactions; i++) {
      // Random Date
      final randomDays = random.nextInt(totalDays);
      final date = startDate
          .add(Duration(days: randomDays))
          .add(
            Duration(hours: random.nextInt(24), minutes: random.nextInt(60)),
          );

      // Random Hashtag
      final hashtag = hashtags[random.nextInt(hashtags.length)];

      // Determine isExpense
      bool isExpense = random.nextDouble() < 0.8;
      if ([
        'Salary',
        'Freelance',
        'Investments',
        'Rental',
      ].contains(hashtag.name)) {
        isExpense = false; // Always income for these categories
      }

      // Random Amount
      double amount;
      if (isExpense) {
        amount = (random.nextDouble() * 195) + 5;
      } else {
        amount = (random.nextDouble() * 4000) + 1000;
      }

      // Valid MCC ID
      // If the hashtag matches a category name closely, we could try to match,
      // but for now random valid MCC is better than invalid ID.
      // We'll pick a random one from the list.
      final mccItem = allMcCItems[random.nextInt(allMcCItems.length)];
      final mccId = mccItem.id ?? 0;

      // Realistic Strings
      String recipient;
      String note;
      if (isExpense) {
        recipient = expenseRecipients[random.nextInt(expenseRecipients.length)];
        note = expenseNotes[random.nextInt(expenseNotes.length)];
      } else {
        recipient = incomeRecipients[random.nextInt(incomeRecipients.length)];
        note = incomeNotes[random.nextInt(incomeNotes.length)];
      }

      final transaction = Transaction(
        isExpense: isExpense,
        date: date,
        amount: double.parse(amount.toStringAsFixed(2)),
        mccId: mccId,
        recipient: recipient,
        note: note,
        hashtags: [hashtag],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _transactionRepo.addTransaction(transaction);

      if (onProgress != null && i % 50 == 0) {
        onProgress('Generated $i transactions...');
      }
    }
    // Generate some recent transactions (last 48 hours) to ensure 1D/2D views have data
    if (onProgress != null) onProgress('Adding recent transactions...');

    for (int i = 0; i < 15; i++) {
      // Random time in last 48 hours
      final hoursAgo = random.nextInt(48);
      final date = now.subtract(
        Duration(hours: hoursAgo, minutes: random.nextInt(60)),
      );

      final hashtag = hashtags[random.nextInt(hashtags.length)];

      // Determine isExpense
      bool isExpense = random.nextDouble() < 0.8;
      if ([
        'Salary',
        'Freelance',
        'Investments',
        'Rental',
      ].contains(hashtag.name)) {
        isExpense = false;
      }

      // Random Amount
      double amount;
      if (isExpense) {
        amount = (random.nextDouble() * 100) + 5;
      } else {
        amount = (random.nextDouble() * 500) + 200;
      }

      final mccItem = allMcCItems[random.nextInt(allMcCItems.length)];
      final mccId = mccItem.id ?? 0;

      String recipient;
      String note;
      if (isExpense) {
        recipient = expenseRecipients[random.nextInt(expenseRecipients.length)];
        note = 'Recent: ${expenseNotes[random.nextInt(expenseNotes.length)]}';
      } else {
        recipient = incomeRecipients[random.nextInt(incomeRecipients.length)];
        note = 'Recent: ${incomeNotes[random.nextInt(incomeNotes.length)]}';
      }

      final transaction = Transaction(
        isExpense: isExpense,
        date: date,
        amount: double.parse(amount.toStringAsFixed(2)),
        mccId: mccId,
        recipient: recipient,
        note: note,
        hashtags: [hashtag],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _transactionRepo.addTransaction(transaction);
    }
  }
}
