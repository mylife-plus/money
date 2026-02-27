import 'package:moneyapp/constants/mcc_data.dart';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:moneyapp/controllers/hashtag_groups_controller.dart';
import 'package:moneyapp/controllers/home_controller.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/transaction_model.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/models/investment_model.dart';
import 'package:moneyapp/models/investment_activity_model.dart';
import 'package:moneyapp/models/portfolio_snapshot_model.dart';
import 'package:moneyapp/services/database/database_helper.dart';
import 'package:moneyapp/services/database/repositories/hashtag_repository.dart';
import 'package:moneyapp/services/database/repositories/transaction_repository.dart';
import 'package:moneyapp/services/database/repositories/investment_repository.dart';
import 'package:moneyapp/services/database/repositories/investment_activity_repository.dart';
import 'package:moneyapp/services/database/repositories/portfolio_snapshot_repository.dart';

class TestDataService {
  final TransactionRepository _transactionRepo = TransactionRepository();
  final HashtagRepository _hashtagRepo = HashtagRepository();
  final InvestmentRepository _investmentRepo = InvestmentRepository();
  final InvestmentActivityRepository _activityRepo =
      InvestmentActivityRepository();
  final PortfolioSnapshotRepository _snapshotRepo =
      PortfolioSnapshotRepository();

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

  // ==================== INVESTMENT TEST DATA ====================

  /// Generate investment test data
  /// Clears existing investment data and creates sample investments, activities, and snapshots
  Future<void> generateInvestmentTestData({
    Function(String)? onProgress,
  }) async {
    try {
      // 1. Clear old investment data
      if (onProgress != null) onProgress('Clearing old investment data...');
      await _snapshotRepo.deleteAll();
      await _activityRepo.deleteAll();
      await _investmentRepo.deleteAll();

      // 2. Create Investments
      if (onProgress != null) onProgress('Creating investments...');
      final investments = await _createInvestments();

      // 3. Generate Activities (transactions and trades)
      if (onProgress != null) onProgress('Generating activities...');
      await _generateInvestmentActivities(investments, onProgress);

      // Activities now auto-create snapshots, so no need for separate snapshot generation

      // 4. Reload Controller
      if (onProgress != null) onProgress('Refreshing app...');
      if (Get.isRegistered<InvestmentController>()) {
        await Get.find<InvestmentController>().loadData();
      }

      if (onProgress != null) onProgress('Done!');
    } catch (e) {
      debugPrint('[TestDataService] Error generating investment test data: $e');
      rethrow;
    }
  }

  Future<List<Investment>> _createInvestments() async {
    // Map tickers to asset icons (using available app icons)
    final investmentData = [
      {
        'name': 'Bitcoin',
        'ticker': 'BTC',
        'color': const Color(0xffF7931A),
        'asset': 'assets/icons/bitcoin-convert.png',
      },
      {
        'name': 'Ethereum',
        'ticker': 'ETH',
        'color': const Color(0xff627EEA),
        'asset': 'assets/icons/digital_currency_icon.png',
      },
      {
        'name': 'Apple Inc',
        'ticker': 'AAPL',
        'color': const Color(0xffA2AAAD),
        'asset': 'assets/icons/chart_square.png',
      },
      {
        'name': 'Tesla',
        'ticker': 'TSLA',
        'color': const Color(0xffCC0000),
        'asset': 'assets/icons/car_icon.png',
      },
      {
        'name': 'S&P 500 ETF',
        'ticker': 'SPY',
        'color': const Color(0xff1E88E5),
        'asset': 'assets/icons/investment_icon.png',
      },
      {
        'name': 'Euro',
        'ticker': 'EUR',
        'color': const Color(0xff003399),
        'asset': 'assets/icons/transaction_icon.png',
      },
      {
        'name': 'Gold',
        'ticker': 'GOLD',
        'color': const Color(0xffFFD700),
        'asset': 'assets/icons/atm_icon.png',
      },
      {
        'name': 'Real Estate',
        'ticker': 'HOUSE',
        'color': const Color(0xff4CAF50),
        'asset': 'assets/icons/home_icon.png',
      },
    ];

    // Get app documents directory for storing investment images
    final appDir = await getApplicationDocumentsDirectory();
    final investmentsDir = Directory(p.join(appDir.path, 'investments'));
    if (!await investmentsDir.exists()) {
      await investmentsDir.create(recursive: true);
    }

    final List<Investment> createdInvestments = [];

    for (final data in investmentData) {
      // First insert to get ID
      final tempInvestment = Investment(
        name: data['name'] as String,
        ticker: data['ticker'] as String,
        colorValue: (data['color'] as Color).toARGB32(),
        imagePath: '', // Temporary, will update after copying asset
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await _investmentRepo.insert(tempInvestment);

      // Copy asset to app folder
      final assetPath = data['asset'] as String;
      final ext = p.extension(assetPath);
      final localPath = p.join(investmentsDir.path, '$id$ext');

      try {
        // Load asset and write to file
        final byteData = await rootBundle.load(assetPath);
        final file = File(localPath);
        await file.writeAsBytes(byteData.buffer.asUint8List());
        debugPrint('[TestDataService] Copied asset to: $localPath');
      } catch (e) {
        debugPrint('[TestDataService] Failed to copy asset $assetPath: $e');
        // Fallback: use asset path directly (won't work in production but OK for test)
      }

      // Update investment with actual image path
      final investment = tempInvestment.copyWith(id: id, imagePath: localPath);
      await _investmentRepo.update(investment);
      createdInvestments.add(investment);
    }

    return createdInvestments;
  }

  Future<void> _generateInvestmentActivities(
    List<Investment> investments,
    Function(String)? onProgress,
  ) async {
    final random = Random();
    final startDate = DateTime(2020, 1, 1);
    final now = DateTime.now();
    final totalDays = now.difference(startDate).inDays;

    // Get controller to use its methods (which auto-create snapshots)
    final controller = Get.isRegistered<InvestmentController>()
        ? Get.find<InvestmentController>()
        : null;

    if (controller == null) {
      debugPrint(
        '[TestDataService] InvestmentController not registered, skipping activity generation',
      );
      return;
    }

    // Generate 40 historical transactions (deposits/withdrawals) - older data
    for (int i = 0; i < 40; i++) {
      // First 40 are historical (older than 30 days ago)
      final randomDays = random.nextInt(totalDays - 30); // Exclude last 30 days
      final baseDate = startDate.add(Duration(days: randomDays));
      final date = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        random.nextInt(24),
        random.nextInt(60),
      );

      final investment = investments[random.nextInt(investments.length)];
      final isDeposit = random.nextDouble() < 0.7; // 70% deposits
      final amount = (random.nextDouble() * 10) + 0.1;
      final price = _getRealisticPrice(investment.ticker, random);
      final total = amount * price;

      // Use controller method to ensure snapshots are created
      try {
        await controller.addTransaction(
          investmentId: investment.id!,
          direction: isDeposit
              ? TransactionDirection.deposit
              : TransactionDirection.withdraw,
          amount: double.parse(amount.toStringAsFixed(4)),
          price: double.parse(price.toStringAsFixed(2)),
          total: double.parse(total.toStringAsFixed(2)),
          date: date,
          description: isDeposit
              ? 'Bought ${investment.ticker}'
              : 'Sold ${investment.ticker}',
        );
      } catch (e) {
        // Skip if insufficient holdings (validation working correctly)
        debugPrint('[TestDataService] Skipping invalid transaction: $e');
      }

      if (onProgress != null && i % 10 == 0) {
        onProgress('Generated $i historical transactions...');
      }
    }

    // Generate 40 RECENT transactions (last 30 days) with MULTIPLE per day
    if (onProgress != null) onProgress('Generating recent transactions...');
    for (int i = 0; i < 40; i++) {
      // Recent data - last 30 days
      final daysAgo = random.nextInt(30);
      final date = now.subtract(Duration(days: daysAgo));

      // Add some hours/minutes variation for same-day entries
      final hoursOffset = random.nextInt(24);
      final minutesOffset = random.nextInt(60);
      final dateWithTime = DateTime(
        date.year,
        date.month,
        date.day,
        hoursOffset,
        minutesOffset,
      );

      final investment = investments[random.nextInt(investments.length)];
      final isDeposit = random.nextDouble() < 0.7; // 70% deposits
      final amount = (random.nextDouble() * 10) + 0.1;
      final price = _getRealisticPrice(investment.ticker, random);
      final total = amount * price;

      try {
        await controller.addTransaction(
          investmentId: investment.id!,
          direction: isDeposit
              ? TransactionDirection.deposit
              : TransactionDirection.withdraw,
          amount: double.parse(amount.toStringAsFixed(4)),
          price: double.parse(price.toStringAsFixed(2)),
          total: double.parse(total.toStringAsFixed(2)),
          date: dateWithTime,
          description: isDeposit
              ? 'Recent buy ${investment.ticker}'
              : 'Recent sell ${investment.ticker}',
        );
      } catch (e) {
        debugPrint('[TestDataService] Skipping invalid recent transaction: $e');
      }

      if (onProgress != null && i % 10 == 0) {
        onProgress('Generated $i recent transactions...');
      }
    }

    // Generate 20 historical trades (swaps between investments) - older data
    for (int i = 0; i < 20; i++) {
      final randomDays = random.nextInt(totalDays - 30); // Exclude last 30 days
      final baseDate = startDate.add(Duration(days: randomDays));
      final date = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        random.nextInt(24),
        random.nextInt(60),
      );

      // Pick two different investments
      final soldInvestment = investments[random.nextInt(investments.length)];
      Investment boughtInvestment;
      do {
        boughtInvestment = investments[random.nextInt(investments.length)];
      } while (boughtInvestment.id == soldInvestment.id);

      final soldAmount = (random.nextDouble() * 5) + 0.5;
      final soldPrice = _getRealisticPrice(soldInvestment.ticker, random);
      final soldTotal = soldAmount * soldPrice;

      final boughtPrice = _getRealisticPrice(boughtInvestment.ticker, random);
      final boughtAmount = soldTotal / boughtPrice;
      final boughtTotal = soldTotal;

      // Use controller method to ensure snapshots are created
      try {
        await controller.addTrade(
          soldInvestmentId: soldInvestment.id!,
          soldAmount: double.parse(soldAmount.toStringAsFixed(4)),
          soldPrice: double.parse(soldPrice.toStringAsFixed(2)),
          soldTotal: double.parse(soldTotal.toStringAsFixed(2)),
          boughtInvestmentId: boughtInvestment.id!,
          boughtAmount: double.parse(boughtAmount.toStringAsFixed(4)),
          boughtPrice: double.parse(boughtPrice.toStringAsFixed(2)),
          boughtTotal: double.parse(boughtTotal.toStringAsFixed(2)),
          date: date,
          description:
              'Traded ${soldInvestment.ticker} for ${boughtInvestment.ticker}',
        );
      } catch (e) {
        // Skip if insufficient holdings (validation working correctly)
        debugPrint('[TestDataService] Skipping invalid trade: $e');
      }

      if (onProgress != null && i % 10 == 0) {
        onProgress('Generated $i historical trades...');
      }
    }

    // Generate 30 RECENT trades (last 30 days) with MULTIPLE per day
    if (onProgress != null) onProgress('Generating recent trades...');
    for (int i = 0; i < 30; i++) {
      // Recent data - last 30 days
      final daysAgo = random.nextInt(30);
      final date = now.subtract(Duration(days: daysAgo));

      // Add some hours/minutes variation for same-day entries
      final hoursOffset = random.nextInt(24);
      final minutesOffset = random.nextInt(60);
      final dateWithTime = DateTime(
        date.year,
        date.month,
        date.day,
        hoursOffset,
        minutesOffset,
      );

      // Pick two different investments
      final soldInvestment = investments[random.nextInt(investments.length)];
      Investment boughtInvestment;
      do {
        boughtInvestment = investments[random.nextInt(investments.length)];
      } while (boughtInvestment.id == soldInvestment.id);

      final soldAmount = (random.nextDouble() * 5) + 0.5;
      final soldPrice = _getRealisticPrice(soldInvestment.ticker, random);
      final soldTotal = soldAmount * soldPrice;

      final boughtPrice = _getRealisticPrice(boughtInvestment.ticker, random);
      final boughtAmount = soldTotal / boughtPrice;
      final boughtTotal = soldTotal;

      try {
        await controller.addTrade(
          soldInvestmentId: soldInvestment.id!,
          soldAmount: double.parse(soldAmount.toStringAsFixed(4)),
          soldPrice: double.parse(soldPrice.toStringAsFixed(2)),
          soldTotal: double.parse(soldTotal.toStringAsFixed(2)),
          boughtInvestmentId: boughtInvestment.id!,
          boughtAmount: double.parse(boughtAmount.toStringAsFixed(4)),
          boughtPrice: double.parse(boughtPrice.toStringAsFixed(2)),
          boughtTotal: double.parse(boughtTotal.toStringAsFixed(2)),
          date: dateWithTime,
          description:
              'Recent trade ${soldInvestment.ticker} → ${boughtInvestment.ticker}',
        );
      } catch (e) {
        debugPrint('[TestDataService] Skipping invalid recent trade: $e');
      }

      if (onProgress != null && i % 10 == 0) {
        onProgress('Generated $i recent trades...');
      }
    }
  }

  double _getRealisticPrice(String ticker, Random random) {
    // Return realistic price ranges for each ticker
    switch (ticker) {
      case 'BTC':
        return 30000 + random.nextDouble() * 70000; // 30k-100k
      case 'ETH':
        return 1500 + random.nextDouble() * 3500; // 1.5k-5k
      case 'AAPL':
        return 120 + random.nextDouble() * 100; // 120-220
      case 'TSLA':
        return 150 + random.nextDouble() * 250; // 150-400
      case 'SPY':
        return 350 + random.nextDouble() * 200; // 350-550
      case 'EUR':
        return 1.0 + random.nextDouble() * 0.2; // 1.0-1.2
      case 'GOLD':
        return 1700 + random.nextDouble() * 500; // 1700-2200
      case 'HOUSE':
        return 250000 + random.nextDouble() * 250000; // 250k-500k
      default:
        return 100 + random.nextDouble() * 100;
    }
  }

  Future<void> generateCorrectInvestmentDummyData({Function(String)? onProgress}) async {
    try {
      if (onProgress != null) onProgress('Clearing old investment data...');
      await _snapshotRepo.deleteAll();
      await _activityRepo.deleteAll();
      await _investmentRepo.deleteAll();

      if (onProgress != null) onProgress('Creating investments...');
      final investments = await _createCorrectInvestments();

      final controller = Get.isRegistered<InvestmentController>() ? Get.find<InvestmentController>() : null;
      if (controller == null) return;

      final random = Random(42);
      final now = DateTime.now();
      final startDate = DateTime(now.year - 5, 1, 1);

      final Map<String, double> basePrices = {'MSFT': 180.0, 'AMZN': 95.0, 'NVDA': 30.0, 'SLVR': 18.0, 'SOL': 1.5, 'JPM': 115.0};
      final Map<String, double> volatility = {'MSFT': 0.07, 'AMZN': 0.10, 'NVDA': 0.18, 'SLVR': 0.06, 'SOL': 0.25, 'JPM': 0.06};

      final Map<int, List<_PricePoint>> priceTimelines = {};
      for (final inv in investments) {
        final points = <_PricePoint>[];
        double price = basePrices[inv.ticker] ?? 100.0;
        final vol = volatility[inv.ticker] ?? 0.08;
        var cur = DateTime(startDate.year, startDate.month, 1);
        while (!cur.isAfter(now)) {
          price = (price * (1 + (random.nextDouble() - 0.45) * vol)).clamp(0.01, double.infinity);
          points.add(_PricePoint(date: cur, price: price));
          cur = _nextMonth(cur);
        }
        priceTimelines[inv.id!] = points;
      }

      final Map<int, double> holdings = {for (final inv in investments) inv.id!: 0.0};

      if (onProgress != null) onProgress('Generating deposits...');
      var eventDate = startDate;
      int batch = 0;
      while (eventDate.isBefore(now)) {
        for (final inv in investments) {
          if (random.nextDouble() < 0.6) {
            final price = _priceAtDate(priceTimelines[inv.id!]!, eventDate);
            final units = double.parse((random.nextDouble() * 15 + 1).toStringAsFixed(4));
            final total = double.parse((units * price).toStringAsFixed(2));
            final time = DateTime(eventDate.year, eventDate.month, eventDate.day, random.nextInt(23) + 1, random.nextInt(60));
            try {
              await controller.addTransaction(
                investmentId: inv.id!, direction: TransactionDirection.deposit,
                amount: units, price: double.parse(price.toStringAsFixed(2)), total: total, date: time,
                description: 'Buy ${inv.ticker}',
              );
              holdings[inv.id!] = (holdings[inv.id!] ?? 0) + units;
            } catch (e) {
              debugPrint('[TestDataService] Skip deposit: $e');
            }
          }
        }
        eventDate = eventDate.add(Duration(days: 14 + random.nextInt(14)));
        batch++;
        if (onProgress != null && batch % 20 == 0) onProgress('Processed $batch deposit batches...');
      }

      if (onProgress != null) onProgress('Generating withdrawals...');
      var qDate = DateTime(startDate.year, startDate.month + 2, 15);
      while (qDate.isBefore(now)) {
        for (final inv in investments) {
          final h = holdings[inv.id!] ?? 0;
          if (h > 1.0 && random.nextDouble() < 0.4) {
            final units = double.parse(((h * 0.05) + random.nextDouble() * h * 0.10).toStringAsFixed(4));
            if (units <= 0 || units > h) continue;
            final price = _priceAtDate(priceTimelines[inv.id!]!, qDate);
            final total = double.parse((units * price).toStringAsFixed(2));
            final time = DateTime(qDate.year, qDate.month, qDate.day, random.nextInt(23) + 1, random.nextInt(60));
            try {
              await controller.addTransaction(
                investmentId: inv.id!, direction: TransactionDirection.withdraw,
                amount: units, price: double.parse(price.toStringAsFixed(2)), total: total, date: time,
                description: 'Sell ${inv.ticker}',
              );
              holdings[inv.id!] = (holdings[inv.id!] ?? 0) - units;
            } catch (e) {
              debugPrint('[TestDataService] Skip withdrawal: $e');
            }
          }
        }
        qDate = DateTime(qDate.year, qDate.month + 3, 15);
      }

      if (onProgress != null) onProgress('Generating price snapshots...');
      for (final inv in investments) {
        for (final point in priceTimelines[inv.id!]!) {
          if (point.date.isAfter(now)) continue;
          final time = DateTime(point.date.year, point.date.month, random.nextInt(28) + 1, random.nextInt(23) + 1, random.nextInt(60));
          try {
            await controller.addManualPriceSnapshot(investmentId: inv.id!, unitPrice: double.parse(point.price.toStringAsFixed(2)), date: time);
          } catch (e) {
            debugPrint('[TestDataService] Skip snapshot: $e');
          }
        }
      }

      if (onProgress != null) onProgress('Done!');
    } catch (e) {
      debugPrint('[TestDataService] Error generating correct investment data: $e');
      rethrow;
    }
  }

  Future<List<Investment>> _createCorrectInvestments() async {
    final configs = [
      {'name': 'Microsoft', 'ticker': 'MSFT', 'color': const Color(0xff0078D4), 'asset': 'assets/icons/chart_square.png'},
      {'name': 'Amazon', 'ticker': 'AMZN', 'color': const Color(0xffFF9900), 'asset': 'assets/icons/investment_icon.png'},
      {'name': 'Nvidia', 'ticker': 'NVDA', 'color': const Color(0xff76B900), 'asset': 'assets/icons/digital_currency_icon.png'},
      {'name': 'Silver', 'ticker': 'SLVR', 'color': const Color(0xffA2AAAD), 'asset': 'assets/icons/atm_icon.png'},
      {'name': 'Solana', 'ticker': 'SOL', 'color': const Color(0xff9945FF), 'asset': 'assets/icons/bitcoin-convert.png'},
      {'name': 'JP Morgan', 'ticker': 'JPM', 'color': const Color(0xff003366), 'asset': 'assets/icons/transaction_icon.png'},
    ];
    final appDir = await getApplicationDocumentsDirectory();
    final investmentsDir = Directory(p.join(appDir.path, 'investments'));
    if (!await investmentsDir.exists()) await investmentsDir.create(recursive: true);
    final List<Investment> created = [];
    for (final cfg in configs) {
      final temp = Investment(name: cfg['name'] as String, ticker: cfg['ticker'] as String, colorValue: (cfg['color'] as Color).toARGB32(), imagePath: '');
      final id = await _investmentRepo.insert(temp);
      final assetPath = cfg['asset'] as String;
      final ext = p.extension(assetPath);
      final localPath = p.join(investmentsDir.path, '$id$ext');
      try {
        final byteData = await rootBundle.load(assetPath);
        await File(localPath).writeAsBytes(byteData.buffer.asUint8List());
      } catch (e) {
        debugPrint('[TestDataService] Asset copy failed: $e');
      }
      final investment = temp.copyWith(id: id, imagePath: localPath);
      await _investmentRepo.update(investment);
      created.add(investment);
    }
    return created;
  }

  double _priceAtDate(List<_PricePoint> points, DateTime date) {
    _PricePoint? best;
    for (final pt in points) {
      if (!pt.date.isAfter(date)) best = pt;
      else break;
    }
    return best?.price ?? points.first.price;
  }

  DateTime _nextMonth(DateTime date) {
    if (date.month == 12) return DateTime(date.year + 1, 1, 1);
    return DateTime(date.year, date.month + 1, 1);
  }

  Future<void> _generatePortfolioSnapshots(Function(String)? onProgress) async {
    final random = Random();
    final startDate = DateTime(2020, 1, 1);
    final now = DateTime.now();

    // Generate monthly snapshots
    var currentDate = startDate;
    var portfolioValue = 10000.0; // Starting value

    int count = 0;
    while (currentDate.isBefore(now)) {
      // Random monthly growth/decline (-10% to +15%)
      final change = (random.nextDouble() * 0.25) - 0.10;
      portfolioValue = portfolioValue * (1 + change);
      portfolioValue = portfolioValue.clamp(5000, 500000); // Keep it reasonable

      // Note: This test data generation needs to be updated for per-investment snapshots
      // For now, we'll skip generating portfolio snapshots as they require investmentId
      // TODO: Update this to generate per-investment price snapshots instead

      // Move to next month
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
      count++;

      if (onProgress != null && count % 12 == 0) {
        onProgress(
          'Skipped ${count ~/ 12} years of snapshots (needs investment-specific data)...',
        );
      }
    }
  }
}

class _PricePoint {
  final DateTime date;
  final double price;
  const _PricePoint({required this.date, required this.price});
}
