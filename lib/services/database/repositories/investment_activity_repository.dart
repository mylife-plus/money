import 'package:flutter/foundation.dart';
import 'package:moneyapp/models/investment_activity_model.dart';
import '../database_helper.dart';

/// Repository for investment activities CRUD operations
/// Handles all database operations related to investment transactions and trades
class InvestmentActivityRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== CREATE ====================

  /// Insert a new investment activity
  Future<int> insert(InvestmentActivity activity) async {
    try {
      debugPrint(
        '[InvestmentActivityRepository][insert] Inserting ${activity.type.name}',
      );
      final db = await _dbHelper.database;
      final id = await db.insert(
        DatabaseHelper.tableInvestmentActivities,
        activity.toMap(),
      );
      debugPrint('[InvestmentActivityRepository][insert] ✅ Inserted with ID: $id');
      return id;
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][insert] ❌ Error: $e');
      rethrow;
    }
  }

  // ==================== READ ====================

  /// Get all activities
  Future<List<InvestmentActivity>> getAll() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(DatabaseHelper.tableInvestmentActivities);
      return InvestmentActivityHelper.fromMapList(maps);
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][getAll] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get all activities sorted by date (newest first)
  Future<List<InvestmentActivity>> getAllSortedByDate() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableInvestmentActivities,
        orderBy: '${DatabaseHelper.columnActivityDate} DESC',
      );
      return InvestmentActivityHelper.fromMapList(maps);
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][getAllSortedByDate] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get activity by ID
  Future<InvestmentActivity?> getById(int id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableInvestmentActivities,
        where: '${DatabaseHelper.columnActivityId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return InvestmentActivity.fromMap(maps.first);
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][getById] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get activities by date range
  Future<List<InvestmentActivity>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableInvestmentActivities,
        where: '${DatabaseHelper.columnActivityDate} BETWEEN ? AND ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: '${DatabaseHelper.columnActivityDate} DESC',
      );
      return InvestmentActivityHelper.fromMapList(maps);
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][getByDateRange] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get activities by investment ID (checks all investment fields)
  Future<List<InvestmentActivity>> getByInvestmentId(int investmentId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableInvestmentActivities,
        where: '''
          ${DatabaseHelper.columnTxInvestmentId} = ? OR
          ${DatabaseHelper.columnTradeSoldInvestmentId} = ? OR
          ${DatabaseHelper.columnTradeBoughtInvestmentId} = ?
        ''',
        whereArgs: [investmentId, investmentId, investmentId],
        orderBy: '${DatabaseHelper.columnActivityDate} DESC',
      );
      return InvestmentActivityHelper.fromMapList(maps);
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][getByInvestmentId] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get transactions only
  Future<List<InvestmentActivity>> getTransactionsOnly() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableInvestmentActivities,
        where: '${DatabaseHelper.columnActivityType} = ?',
        whereArgs: [InvestmentActivityType.transaction.name],
        orderBy: '${DatabaseHelper.columnActivityDate} DESC',
      );
      return InvestmentActivityHelper.fromMapList(maps);
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][getTransactionsOnly] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get trades only
  Future<List<InvestmentActivity>> getTradesOnly() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableInvestmentActivities,
        where: '${DatabaseHelper.columnActivityType} = ?',
        whereArgs: [InvestmentActivityType.trade.name],
        orderBy: '${DatabaseHelper.columnActivityDate} DESC',
      );
      return InvestmentActivityHelper.fromMapList(maps);
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][getTradesOnly] ❌ Error: $e');
      rethrow;
    }
  }

  // ==================== UPDATE ====================

  /// Update an activity
  Future<int> update(InvestmentActivity activity) async {
    try {
      debugPrint(
        '[InvestmentActivityRepository][update] Updating ID: ${activity.id}',
      );
      final db = await _dbHelper.database;
      final result = await db.update(
        DatabaseHelper.tableInvestmentActivities,
        activity.copyWithUpdatedTimestamp().toMap(),
        where: '${DatabaseHelper.columnActivityId} = ?',
        whereArgs: [activity.id],
      );
      debugPrint(
        '[InvestmentActivityRepository][update] ✅ Result: $result rows affected',
      );
      return result;
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][update] ❌ Error: $e');
      rethrow;
    }
  }

  // ==================== DELETE ====================

  /// Delete an activity by ID
  Future<int> delete(int id) async {
    try {
      debugPrint('[InvestmentActivityRepository][delete] Deleting ID: $id');
      final db = await _dbHelper.database;
      final result = await db.delete(
        DatabaseHelper.tableInvestmentActivities,
        where: '${DatabaseHelper.columnActivityId} = ?',
        whereArgs: [id],
      );
      debugPrint(
        '[InvestmentActivityRepository][delete] ✅ Result: $result rows deleted',
      );
      return result;
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][delete] ❌ Error: $e');
      rethrow;
    }
  }

  /// Delete multiple activities by IDs
  Future<int> deleteByIds(List<int> ids) async {
    try {
      debugPrint(
        '[InvestmentActivityRepository][deleteByIds] Deleting ${ids.length} activities',
      );
      if (ids.isEmpty) return 0;

      final db = await _dbHelper.database;
      final placeholders = List.filled(ids.length, '?').join(',');
      final result = await db.delete(
        DatabaseHelper.tableInvestmentActivities,
        where: '${DatabaseHelper.columnActivityId} IN ($placeholders)',
        whereArgs: ids,
      );
      debugPrint(
        '[InvestmentActivityRepository][deleteByIds] ✅ Result: $result rows deleted',
      );
      return result;
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][deleteByIds] ❌ Error: $e');
      rethrow;
    }
  }

  /// Delete all activities
  Future<int> deleteAll() async {
    try {
      debugPrint('[InvestmentActivityRepository][deleteAll] Deleting all activities');
      final db = await _dbHelper.database;
      final result = await db.delete(DatabaseHelper.tableInvestmentActivities);
      debugPrint('[InvestmentActivityRepository][deleteAll] ✅ Deleted $result rows');
      return result;
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][deleteAll] ❌ Error: $e');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Check if activities exist in database
  Future<bool> hasData() async {
    try {
      final activities = await getAll();
      return activities.isNotEmpty;
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][hasData] ❌ Error: $e');
      return false;
    }
  }

  /// Get total count of activities
  Future<int> count() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableInvestmentActivities}',
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][count] ❌ Error: $e');
      rethrow;
    }
  }

  /// Count transactions
  Future<int> countTransactions() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableInvestmentActivities} WHERE ${DatabaseHelper.columnActivityType} = ?',
        [InvestmentActivityType.transaction.name],
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][countTransactions] ❌ Error: $e');
      rethrow;
    }
  }

  /// Count trades
  Future<int> countTrades() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableInvestmentActivities} WHERE ${DatabaseHelper.columnActivityType} = ?',
        [InvestmentActivityType.trade.name],
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      debugPrint('[InvestmentActivityRepository][countTrades] ❌ Error: $e');
      rethrow;
    }
  }
}
