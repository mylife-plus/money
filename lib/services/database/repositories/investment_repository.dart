import 'package:flutter/foundation.dart';
import 'package:moneyapp/models/investment_model.dart';
import '../database_helper.dart';

/// Repository for investments CRUD operations
/// Handles all database operations related to investments
class InvestmentRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== CREATE ====================

  /// Insert a new investment
  Future<int> insert(Investment investment) async {
    try {
      debugPrint('[InvestmentRepository][insert] Inserting: ${investment.name}');
      final db = await _dbHelper.database;
      final id = await db.insert(
        DatabaseHelper.tableInvestments,
        investment.toMap(),
      );
      debugPrint('[InvestmentRepository][insert] ✅ Inserted with ID: $id');
      return id;
    } catch (e) {
      debugPrint('[InvestmentRepository][insert] ❌ Error: $e');
      rethrow;
    }
  }

  // ==================== READ ====================

  /// Get all investments
  Future<List<Investment>> getAll() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableInvestments,
        orderBy: '${DatabaseHelper.columnInvestmentName} ASC',
      );
      return InvestmentHelper.fromMapList(maps);
    } catch (e) {
      debugPrint('[InvestmentRepository][getAll] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get investment by ID
  Future<Investment?> getById(int id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableInvestments,
        where: '${DatabaseHelper.columnInvestmentId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Investment.fromMap(maps.first);
    } catch (e) {
      debugPrint('[InvestmentRepository][getById] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get investment by ticker
  Future<Investment?> getByTicker(String ticker) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableInvestments,
        where: 'LOWER(${DatabaseHelper.columnInvestmentTicker}) = ?',
        whereArgs: [ticker.toLowerCase()],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return Investment.fromMap(maps.first);
    } catch (e) {
      debugPrint('[InvestmentRepository][getByTicker] ❌ Error: $e');
      rethrow;
    }
  }

  /// Check if ticker exists
  Future<bool> tickerExists(String ticker, {int? excludeId}) async {
    try {
      final db = await _dbHelper.database;
      final whereClause = excludeId != null
          ? 'LOWER(${DatabaseHelper.columnInvestmentTicker}) = ? AND ${DatabaseHelper.columnInvestmentId} != ?'
          : 'LOWER(${DatabaseHelper.columnInvestmentTicker}) = ?';
      final whereArgs =
          excludeId != null ? [ticker.toLowerCase(), excludeId] : [ticker.toLowerCase()];

      final results = await db.query(
        DatabaseHelper.tableInvestments,
        where: whereClause,
        whereArgs: whereArgs,
        limit: 1,
      );
      return results.isNotEmpty;
    } catch (e) {
      debugPrint('[InvestmentRepository][tickerExists] ❌ Error: $e');
      rethrow;
    }
  }

  /// Search investments by name or ticker
  Future<List<Investment>> search(String query) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tableInvestments,
        where:
            'LOWER(${DatabaseHelper.columnInvestmentName}) LIKE ? OR LOWER(${DatabaseHelper.columnInvestmentTicker}) LIKE ?',
        whereArgs: ['%${query.toLowerCase()}%', '%${query.toLowerCase()}%'],
        orderBy: '${DatabaseHelper.columnInvestmentName} ASC',
      );
      return InvestmentHelper.fromMapList(maps);
    } catch (e) {
      debugPrint('[InvestmentRepository][search] ❌ Error: $e');
      rethrow;
    }
  }

  // ==================== UPDATE ====================

  /// Update an investment
  Future<int> update(Investment investment) async {
    try {
      debugPrint(
        '[InvestmentRepository][update] Updating ID: ${investment.id}',
      );
      final db = await _dbHelper.database;
      final result = await db.update(
        DatabaseHelper.tableInvestments,
        investment.copyWithUpdatedTimestamp().toMap(),
        where: '${DatabaseHelper.columnInvestmentId} = ?',
        whereArgs: [investment.id],
      );
      debugPrint(
        '[InvestmentRepository][update] ✅ Result: $result rows affected',
      );
      return result;
    } catch (e) {
      debugPrint('[InvestmentRepository][update] ❌ Error: $e');
      rethrow;
    }
  }

  // ==================== DELETE ====================

  /// Delete an investment
  /// Returns 0 if investment has activities referencing it (cannot delete)
  Future<int> delete(int id) async {
    try {
      debugPrint('[InvestmentRepository][delete] Deleting ID: $id');

      // Check if any activities reference this investment
      final activitiesCount = await countActivitiesForInvestment(id);
      if (activitiesCount > 0) {
        debugPrint(
          '[InvestmentRepository][delete] Cannot delete - has $activitiesCount activities',
        );
        return 0;
      }

      final db = await _dbHelper.database;
      final result = await db.delete(
        DatabaseHelper.tableInvestments,
        where: '${DatabaseHelper.columnInvestmentId} = ?',
        whereArgs: [id],
      );
      debugPrint(
        '[InvestmentRepository][delete] ✅ Result: $result rows deleted',
      );
      return result;
    } catch (e) {
      debugPrint('[InvestmentRepository][delete] ❌ Error: $e');
      rethrow;
    }
  }

  /// Delete all investments (only if no activities exist)
  Future<int> deleteAll() async {
    try {
      debugPrint('[InvestmentRepository][deleteAll] Deleting all investments');

      // Check if any activities exist
      final db = await _dbHelper.database;
      final activitiesResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableInvestmentActivities}',
      );
      final activitiesCount = (activitiesResult.first['count'] as int?) ?? 0;
      if (activitiesCount > 0) {
        debugPrint(
          '[InvestmentRepository][deleteAll] Cannot delete - $activitiesCount activities exist',
        );
        return 0;
      }

      final result = await db.delete(DatabaseHelper.tableInvestments);
      debugPrint('[InvestmentRepository][deleteAll] ✅ Deleted $result rows');
      return result;
    } catch (e) {
      debugPrint('[InvestmentRepository][deleteAll] ❌ Error: $e');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Check if investments exist in database
  Future<bool> hasData() async {
    try {
      final investments = await getAll();
      return investments.isNotEmpty;
    } catch (e) {
      debugPrint('[InvestmentRepository][hasData] ❌ Error: $e');
      return false;
    }
  }

  /// Count activities that reference an investment
  Future<int> countActivitiesForInvestment(int investmentId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) as count FROM ${DatabaseHelper.tableInvestmentActivities}
        WHERE ${DatabaseHelper.columnTxInvestmentId} = ?
           OR ${DatabaseHelper.columnTradeSoldInvestmentId} = ?
           OR ${DatabaseHelper.columnTradeBoughtInvestmentId} = ?
        ''',
        [investmentId, investmentId, investmentId],
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      debugPrint(
        '[InvestmentRepository][countActivitiesForInvestment] ❌ Error: $e',
      );
      rethrow;
    }
  }

  /// Get total count of investments
  Future<int> count() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableInvestments}',
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      debugPrint('[InvestmentRepository][count] ❌ Error: $e');
      rethrow;
    }
  }
}
