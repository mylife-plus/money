import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../models/investment_model.dart';
import '../models/investment_activity_model.dart';
import '../models/portfolio_snapshot_model.dart';
import 'database/repositories/investment_repository.dart';
import 'database/repositories/investment_activity_repository.dart';
import 'database/repositories/portfolio_snapshot_repository.dart';

/// Service layer for investment operations
/// Handles business logic, auto-snapshot creation, and image management
class InvestmentService {
  static final InvestmentService _instance = InvestmentService._internal();
  factory InvestmentService() => _instance;
  InvestmentService._internal();

  final InvestmentRepository _investmentRepo = InvestmentRepository();
  final InvestmentActivityRepository _activityRepo =
      InvestmentActivityRepository();
  final PortfolioSnapshotRepository _snapshotRepo =
      PortfolioSnapshotRepository();

  // ==================== INVESTMENT CRUD ====================

  /// Add a new investment
  /// Copies the image to app folder and stores the local path
  Future<Investment?> addInvestment({
    required String name,
    required String ticker,
    required Color color,
    required File imageFile,
  }) async {
    try {
      debugPrint('[InvestmentService][addInvestment] Adding: $name ($ticker)');

      // Check if ticker already exists
      final tickerExists = await _investmentRepo.tickerExists(ticker);
      if (tickerExists) {
        debugPrint('[InvestmentService][addInvestment] Ticker already exists');
        throw Exception('TICKER_ALREADY_EXISTS');
      }

      // Create investment with temporary image path (will update after we get ID)
      final tempInvestment = Investment.withColor(
        name: name.trim(),
        ticker: ticker.trim().toUpperCase(),
        color: color,
        imagePath: '', // Temporary
      );

      // Insert to get ID
      final id = await _investmentRepo.insert(tempInvestment);
      if (id <= 0) {
        debugPrint('[InvestmentService][addInvestment] Failed to insert');
        return null;
      }

      // Copy image to app folder
      final localImagePath = await _copyImageToAppFolder(imageFile, id);

      // Update investment with correct image path
      final investment = tempInvestment.copyWith(
        id: id,
        imagePath: localImagePath,
      );
      await _investmentRepo.update(investment);

      debugPrint(
        '[InvestmentService][addInvestment] ✅ Added investment ID: $id',
      );
      return investment;
    } catch (e) {
      debugPrint('[InvestmentService][addInvestment] ❌ Error: $e');
      if (e.toString().contains('TICKER_ALREADY_EXISTS')) {
        rethrow;
      }
      return null;
    }
  }

  /// Update an existing investment
  Future<bool> updateInvestment(
    int id, {
    String? name,
    String? ticker,
    Color? color,
    File? newImageFile,
  }) async {
    try {
      debugPrint('[InvestmentService][updateInvestment] Updating ID: $id');

      final existing = await _investmentRepo.getById(id);
      if (existing == null) {
        debugPrint(
          '[InvestmentService][updateInvestment] Investment not found',
        );
        return false;
      }

      // Check if new ticker already exists (if changing ticker)
      if (ticker != null &&
          ticker.toUpperCase() != existing.ticker.toUpperCase()) {
        final tickerExists = await _investmentRepo.tickerExists(
          ticker,
          excludeId: id,
        );
        if (tickerExists) {
          debugPrint(
            '[InvestmentService][updateInvestment] New ticker already exists',
          );
          throw Exception('TICKER_ALREADY_EXISTS');
        }
      }

      // Handle image update if provided
      String imagePath = existing.imagePath;
      if (newImageFile != null) {
        // Delete old image
        await _deleteImageFromAppFolder(existing.imagePath);
        // Copy new image
        imagePath = await _copyImageToAppFolder(newImageFile, id);
      }

      final updated = Investment(
        id: id,
        name: name?.trim() ?? existing.name,
        ticker: ticker?.trim().toUpperCase() ?? existing.ticker,
        colorValue: color?.toARGB32() ?? existing.colorValue,
        imagePath: imagePath,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );

      final result = await _investmentRepo.update(updated);
      debugPrint(
        '[InvestmentService][updateInvestment] ✅ Updated: $result rows',
      );
      return result > 0;
    } catch (e) {
      debugPrint('[InvestmentService][updateInvestment] ❌ Error: $e');
      if (e.toString().contains('TICKER_ALREADY_EXISTS')) {
        rethrow;
      }
      return false;
    }
  }

  /// Delete an investment (only if no activities or snapshots reference it)
  Future<bool> deleteInvestment(int id) async {
    try {
      debugPrint('[InvestmentService][deleteInvestment] Deleting ID: $id');

      final existing = await _investmentRepo.getById(id);
      if (existing == null) {
        debugPrint(
          '[InvestmentService][deleteInvestment] Investment not found',
        );
        return false;
      }

      // Check if any activities reference this investment
      final activitiesCount = await _investmentRepo
          .countActivitiesForInvestment(id);
      if (activitiesCount > 0) {
        debugPrint(
          '[InvestmentService][deleteInvestment] Cannot delete - has $activitiesCount activities',
        );
        throw Exception('CANNOT_DELETE_INVESTMENT_IN_USE');
      }

      // Check if any snapshots reference this investment
      final snapshotsCount = await _snapshotRepo.countSnapshotsForInvestment(
        id,
      );
      if (snapshotsCount > 0) {
        debugPrint(
          '[InvestmentService][deleteInvestment] Cannot delete - has $snapshotsCount price snapshots',
        );
        throw Exception('CANNOT_DELETE_INVESTMENT_HAS_SNAPSHOTS');
      }

      // Delete image file
      await _deleteImageFromAppFolder(existing.imagePath);

      // Delete from database
      final result = await _investmentRepo.delete(id);
      debugPrint(
        '[InvestmentService][deleteInvestment] ✅ Deleted: $result rows',
      );
      return result > 0;
    } catch (e) {
      debugPrint('[InvestmentService][deleteInvestment] ❌ Error: $e');
      if (e.toString().contains('CANNOT_DELETE_INVESTMENT')) {
        rethrow;
      }
      return false;
    }
  }

  /// Get all investments
  Future<List<Investment>> getAllInvestments() async {
    try {
      return await _investmentRepo.getAll();
    } catch (e) {
      debugPrint('[InvestmentService][getAllInvestments] ❌ Error: $e');
      return [];
    }
  }

  /// Get investment by ID
  Future<Investment?> getInvestmentById(int id) async {
    try {
      return await _investmentRepo.getById(id);
    } catch (e) {
      debugPrint('[InvestmentService][getInvestmentById] ❌ Error: $e');
      return null;
    }
  }

  /// Search investments
  Future<List<Investment>> searchInvestments(String query) async {
    try {
      return await _investmentRepo.search(query);
    } catch (e) {
      debugPrint('[InvestmentService][searchInvestments] ❌ Error: $e');
      return [];
    }
  }

  // ==================== ACTIVITY CRUD ====================

  /// Add a transaction (deposit/withdraw) with auto-snapshot
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
      debugPrint(
        '[InvestmentService][addTransaction] Adding ${direction.name} for investment $investmentId',
      );

      final activity = InvestmentActivity.transaction(
        date: date,
        description: description,
        direction: direction,
        investmentId: investmentId,
        amount: amount,
        price: price,
        total: total,
      );

      final id = await _activityRepo.insert(activity);
      if (id <= 0) {
        debugPrint('[InvestmentService][addTransaction] Failed to insert');
        return null;
      }

      final savedActivity = activity.copyWith(id: id);

      // Auto-create portfolio snapshot
      await _createAutoSnapshot(
        activity: savedActivity,
        entryType: SnapshotEntryType.transaction,
      );

      debugPrint(
        '[InvestmentService][addTransaction] ✅ Added transaction ID: $id',
      );
      return savedActivity;
    } catch (e) {
      debugPrint('[InvestmentService][addTransaction] ❌ Error: $e');
      return null;
    }
  }

  /// Add a trade (sold/bought pair) with auto-snapshot
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
      debugPrint(
        '[InvestmentService][addTrade] Adding trade: sold $soldInvestmentId -> bought $boughtInvestmentId',
      );

      final activity = InvestmentActivity.trade(
        date: date,
        description: description,
        soldInvestmentId: soldInvestmentId,
        soldAmount: soldAmount,
        soldPrice: soldPrice,
        soldTotal: soldTotal,
        boughtInvestmentId: boughtInvestmentId,
        boughtAmount: boughtAmount,
        boughtPrice: boughtPrice,
        boughtTotal: boughtTotal,
      );

      final id = await _activityRepo.insert(activity);
      if (id <= 0) {
        debugPrint('[InvestmentService][addTrade] Failed to insert');
        return null;
      }

      final savedActivity = activity.copyWith(id: id);

      // Auto-create portfolio snapshot
      await _createAutoSnapshot(
        activity: savedActivity,
        entryType: SnapshotEntryType.trade,
      );

      debugPrint('[InvestmentService][addTrade] ✅ Added trade ID: $id');
      return savedActivity;
    } catch (e) {
      debugPrint('[InvestmentService][addTrade] ❌ Error: $e');
      return null;
    }
  }

  /// Update an activity
  Future<bool> updateActivity(InvestmentActivity activity) async {
    try {
      debugPrint(
        '[InvestmentService][updateActivity] Updating ID: ${activity.id}',
      );
      final result = await _activityRepo.update(activity);
      return result > 0;
    } catch (e) {
      debugPrint('[InvestmentService][updateActivity] ❌ Error: $e');
      return false;
    }
  }

  /// Delete an activity (snapshot FK will be set to NULL)
  Future<bool> deleteActivity(int id) async {
    try {
      debugPrint('[InvestmentService][deleteActivity] Deleting ID: $id');
      final result = await _activityRepo.delete(id);
      debugPrint('[InvestmentService][deleteActivity] ✅ Deleted: $result rows');
      return result > 0;
    } catch (e) {
      debugPrint('[InvestmentService][deleteActivity] ❌ Error: $e');
      return false;
    }
  }

  /// Delete multiple activities
  Future<bool> deleteActivities(List<int> ids) async {
    try {
      debugPrint(
        '[InvestmentService][deleteActivities] Deleting ${ids.length} activities',
      );
      final result = await _activityRepo.deleteByIds(ids);
      debugPrint(
        '[InvestmentService][deleteActivities] ✅ Deleted: $result rows',
      );
      return result > 0;
    } catch (e) {
      debugPrint('[InvestmentService][deleteActivities] ❌ Error: $e');
      return false;
    }
  }

  /// Get all activities sorted by date
  Future<List<InvestmentActivity>> getAllActivities() async {
    try {
      return await _activityRepo.getAllSortedByDate();
    } catch (e) {
      debugPrint('[InvestmentService][getAllActivities] ❌ Error: $e');
      return [];
    }
  }

  /// Get activities for a specific investment
  Future<List<InvestmentActivity>> getActivitiesForInvestment(
    int investmentId,
  ) async {
    try {
      return await _activityRepo.getByInvestmentId(investmentId);
    } catch (e) {
      debugPrint('[InvestmentService][getActivitiesForInvestment] ❌ Error: $e');
      return [];
    }
  }

  /// Get transactions only
  Future<List<InvestmentActivity>> getTransactionsOnly() async {
    try {
      return await _activityRepo.getTransactionsOnly();
    } catch (e) {
      debugPrint('[InvestmentService][getTransactionsOnly] ❌ Error: $e');
      return [];
    }
  }

  /// Get trades only
  Future<List<InvestmentActivity>> getTradesOnly() async {
    try {
      return await _activityRepo.getTradesOnly();
    } catch (e) {
      debugPrint('[InvestmentService][getTradesOnly] ❌ Error: $e');
      return [];
    }
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
      debugPrint(
        '[InvestmentService][addManualPriceSnapshot] Adding manual price for investment $investmentId: $unitPrice',
      );

      // Verify investment exists
      final investment = await _investmentRepo.getById(investmentId);
      if (investment == null) {
        debugPrint(
          '[InvestmentService][addManualPriceSnapshot] Investment not found',
        );
        throw Exception('INVESTMENT_NOT_FOUND');
      }

      final snapshot = PortfolioSnapshot.manualPrice(
        investmentId: investmentId,
        date: date,
        unitPrice: unitPrice,
        note: note,
      );

      final id = await _snapshotRepo.insert(snapshot);
      if (id <= 0) {
        debugPrint(
          '[InvestmentService][addManualPriceSnapshot] Failed to insert',
        );
        return null;
      }

      debugPrint(
        '[InvestmentService][addManualPriceSnapshot] ✅ Added snapshot ID: $id',
      );
      return snapshot.copyWith(id: id);
    } catch (e) {
      debugPrint('[InvestmentService][addManualPriceSnapshot] ❌ Error: $e');
      return null;
    }
  }

  /// Update a portfolio snapshot
  Future<bool> updateSnapshot(PortfolioSnapshot snapshot) async {
    try {
      debugPrint(
        '[InvestmentService][updateSnapshot] Updating ID: ${snapshot.id}',
      );
      final result = await _snapshotRepo.update(snapshot);
      return result > 0;
    } catch (e) {
      debugPrint('[InvestmentService][updateSnapshot] ❌ Error: $e');
      return false;
    }
  }

  /// Delete a portfolio snapshot
  Future<bool> deleteSnapshot(int id) async {
    try {
      debugPrint('[InvestmentService][deleteSnapshot] Deleting ID: $id');
      final result = await _snapshotRepo.delete(id);
      return result > 0;
    } catch (e) {
      debugPrint('[InvestmentService][deleteSnapshot] ❌ Error: $e');
      return false;
    }
  }

  /// Get portfolio history
  Future<List<PortfolioSnapshot>> getPortfolioHistory() async {
    try {
      return await _snapshotRepo.getAllSortedByDate();
    } catch (e) {
      debugPrint('[InvestmentService][getPortfolioHistory] ❌ Error: $e');
      return [];
    }
  }

  /// Get latest portfolio snapshot
  Future<PortfolioSnapshot?> getLatestSnapshot() async {
    try {
      return await _snapshotRepo.getLatest();
    } catch (e) {
      debugPrint('[InvestmentService][getLatestSnapshot] ❌ Error: $e');
      return null;
    }
  }

  /// Get all snapshots for a specific investment (sorted by date desc)
  Future<List<PortfolioSnapshot>> getSnapshotsForInvestment(
    int investmentId,
  ) async {
    try {
      return await _snapshotRepo.getByInvestmentId(investmentId);
    } catch (e) {
      debugPrint('[InvestmentService][getSnapshotsForInvestment] ❌ Error: $e');
      return [];
    }
  }

  // ==================== CALCULATIONS ====================

  /// Calculate current holdings for all investments
  /// Returns Map<investmentId, amount>
  Future<Map<int, double>> calculateCurrentHoldings() async {
    try {
      final activities = await _activityRepo.getAllSortedByDate();
      final Map<int, double> holdings = {};

      // Process activities in chronological order (oldest first)
      final sortedActivities = InvestmentActivityHelper.sortByDateAsc(
        activities,
      );

      for (final activity in sortedActivities) {
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
          // Decrease sold investment
          final soldId = activity.tradeSoldInvestmentId!;
          holdings.putIfAbsent(soldId, () => 0);
          holdings[soldId] =
              holdings[soldId]! - (activity.tradeSoldAmount ?? 0);

          // Increase bought investment
          final boughtId = activity.tradeBoughtInvestmentId!;
          holdings.putIfAbsent(boughtId, () => 0);
          holdings[boughtId] =
              holdings[boughtId]! + (activity.tradeBoughtAmount ?? 0);
        }
      }

      return holdings;
    } catch (e) {
      debugPrint('[InvestmentService][calculateCurrentHoldings] ❌ Error: $e');
      return {};
    }
  }

  /// Get enriched investment data with holdings and latest prices
  /// Returns list of maps with investment, amount, latestPrice, and totalValue
  /// Only includes investments with non-zero holdings
  Future<List<Map<String, dynamic>>> getInvestmentHoldingsWithPrices() async {
    try {
      debugPrint(
        '[InvestmentService][getInvestmentHoldingsWithPrices] Calculating...',
      );

      // Get current holdings from activities
      final holdings = await calculateCurrentHoldings();

      // Get latest snapshots for all investments
      final latestSnapshots = await _snapshotRepo.getLatestForAllInvestments();

      // Get all investments
      final investments = await _investmentRepo.getAll();

      final List<Map<String, dynamic>> enrichedData = [];

      for (final investment in investments) {
        final amount = holdings[investment.id] ?? 0.0;

        // Skip investments with 0 holding
        if (amount <= 0) continue;

        // Get latest price snapshot for this investment
        final latestSnapshot = latestSnapshots[investment.id];
        final latestPrice = latestSnapshot?.unitPrice ?? 0.0;

        // Calculate total value
        final totalValue = amount * latestPrice;

        enrichedData.add({
          'investment': investment,
          'amount': amount,
          'latestPrice': latestPrice,
          'totalValue': totalValue,
          'hasPrice': latestSnapshot != null,
        });
      }

      debugPrint(
        '[InvestmentService][getInvestmentHoldingsWithPrices] ✅ Found ${enrichedData.length} investments with holdings',
      );
      return enrichedData;
    } catch (e) {
      debugPrint(
        '[InvestmentService][getInvestmentHoldingsWithPrices] ❌ Error: $e',
      );
      return [];
    }
  }

  /// Get current total portfolio value
  /// Sum of all investment holdings × latest prices
  Future<double> getCurrentPortfolioValue() async {
    try {
      final enrichedData = await getInvestmentHoldingsWithPrices();
      double total = 0.0;

      for (final data in enrichedData) {
        total += data['totalValue'] as double;
      }

      debugPrint('[InvestmentService][getCurrentPortfolioValue] Total: $total');
      return total;
    } catch (e) {
      debugPrint('[InvestmentService][getCurrentPortfolioValue] ❌ Error: $e');
      return 0.0;
    }
  }

  // ==================== PRIVATE HELPERS ====================

  /// Copy image to app's documents folder
  Future<String> _copyImageToAppFolder(File imageFile, int investmentId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final investmentsDir = Directory(p.join(appDir.path, 'investments'));

      // Create directory if it doesn't exist
      if (!await investmentsDir.exists()) {
        await investmentsDir.create(recursive: true);
      }

      // Determine file extension
      final ext = p.extension(imageFile.path);
      final fileName = '$investmentId$ext';
      final localPath = p.join(investmentsDir.path, fileName);

      // Copy the file
      await imageFile.copy(localPath);

      debugPrint('[InvestmentService] Image copied to: $localPath');
      return localPath;
    } catch (e) {
      debugPrint('[InvestmentService] Error copying image: $e');
      rethrow;
    }
  }

  /// Delete image from app's documents folder
  Future<void> _deleteImageFromAppFolder(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('[InvestmentService] Image deleted: $imagePath');
      }
    } catch (e) {
      debugPrint('[InvestmentService] Error deleting image: $e');
      // Don't rethrow - image deletion failure shouldn't block other operations
    }
  }

  /// Create auto-snapshot when activity is added
  /// For transactions: creates one snapshot for the involved investment
  /// For trades: creates two snapshots (one for sold, one for bought investment)
  Future<void> _createAutoSnapshot({
    required InvestmentActivity activity,
    required SnapshotEntryType entryType,
  }) async {
    try {
      if (activity.isTransaction) {
        // Create snapshot for transaction investment
        final snapshot = PortfolioSnapshot.fromTransaction(
          investmentId: activity.transactionInvestmentId!,
          date: activity.date,
          unitPrice: activity.transactionPrice!,
          activityId: activity.id!,
        );
        await _snapshotRepo.insert(snapshot);
        debugPrint(
          '[InvestmentService] Auto-snapshot created for transaction ${activity.id}',
        );
      } else if (activity.isTrade) {
        // Create snapshot for sold investment
        final soldSnapshot = PortfolioSnapshot.fromTrade(
          investmentId: activity.tradeSoldInvestmentId!,
          date: activity.date,
          unitPrice: activity.tradeSoldPrice!,
          activityId: activity.id!,
        );
        await _snapshotRepo.insert(soldSnapshot);

        // Create snapshot for bought investment
        final boughtSnapshot = PortfolioSnapshot.fromTrade(
          investmentId: activity.tradeBoughtInvestmentId!,
          date: activity.date,
          unitPrice: activity.tradeBoughtPrice!,
          activityId: activity.id!,
        );
        await _snapshotRepo.insert(boughtSnapshot);
        debugPrint(
          '[InvestmentService] Auto-snapshots created for trade ${activity.id}',
        );
      }
    } catch (e) {
      debugPrint('[InvestmentService] Error creating auto-snapshot: $e');
      // Don't rethrow - snapshot creation failure shouldn't block activity creation
    }
  }
}
