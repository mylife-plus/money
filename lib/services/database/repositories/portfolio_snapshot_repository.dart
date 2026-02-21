import 'package:flutter/foundation.dart';
import 'package:moneyapp/models/portfolio_snapshot_model.dart';
import '../database_helper.dart';

/// Repository for portfolio snapshots CRUD operations
/// Handles all database operations related to portfolio value tracking
class PortfolioSnapshotRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== CREATE ====================

  /// Insert a new portfolio snapshot
  Future<int> insert(PortfolioSnapshot snapshot) async {
    try {
      debugPrint(
        '[PortfolioSnapshotRepository][insert] Inserting ${snapshot.entryType.name} snapshot',
      );
      final db = await _dbHelper.database;
      final id = await db.insert(
        DatabaseHelper.tablePortfolioSnapshots,
        snapshot.toMap(),
      );
      debugPrint(
        '[PortfolioSnapshotRepository][insert] ✅ Inserted with ID: $id',
      );
      return id;
    } catch (e) {
      debugPrint('[PortfolioSnapshotRepository][insert] ❌ Error: $e');
      rethrow;
    }
  }

  // ==================== READ ====================

  /// Get all snapshots
  Future<List<PortfolioSnapshot>> getAll() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(DatabaseHelper.tablePortfolioSnapshots);
      return PortfolioSnapshotHelper.fromMapList(maps);
    } catch (e) {
      debugPrint('[PortfolioSnapshotRepository][getAll] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get all snapshots sorted by date (newest first)
  Future<List<PortfolioSnapshot>> getAllSortedByDate() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tablePortfolioSnapshots,
        orderBy: '${DatabaseHelper.columnSnapshotDate} DESC',
      );
      return PortfolioSnapshotHelper.fromMapList(maps);
    } catch (e) {
      debugPrint(
        '[PortfolioSnapshotRepository][getAllSortedByDate] ❌ Error: $e',
      );
      rethrow;
    }
  }

  /// Get snapshot by ID
  Future<PortfolioSnapshot?> getById(int id) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tablePortfolioSnapshots,
        where: '${DatabaseHelper.columnSnapshotId} = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return PortfolioSnapshot.fromMap(maps.first);
    } catch (e) {
      debugPrint('[PortfolioSnapshotRepository][getById] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get snapshot by activity ID
  Future<PortfolioSnapshot?> getByActivityId(int activityId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tablePortfolioSnapshots,
        where: '${DatabaseHelper.columnSnapshotActivityId} = ?',
        whereArgs: [activityId],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return PortfolioSnapshot.fromMap(maps.first);
    } catch (e) {
      debugPrint('[PortfolioSnapshotRepository][getByActivityId] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get snapshots by date range
  Future<List<PortfolioSnapshot>> getByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tablePortfolioSnapshots,
        where: '${DatabaseHelper.columnSnapshotDate} BETWEEN ? AND ?',
        whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
        orderBy: '${DatabaseHelper.columnSnapshotDate} DESC',
      );
      return PortfolioSnapshotHelper.fromMapList(maps);
    } catch (e) {
      debugPrint('[PortfolioSnapshotRepository][getByDateRange] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get latest snapshot
  Future<PortfolioSnapshot?> getLatest() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tablePortfolioSnapshots,
        orderBy: '${DatabaseHelper.columnSnapshotDate} DESC',
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return PortfolioSnapshot.fromMap(maps.first);
    } catch (e) {
      debugPrint('[PortfolioSnapshotRepository][getLatest] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get snapshots for a specific investment
  Future<List<PortfolioSnapshot>> getByInvestmentId(int investmentId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tablePortfolioSnapshots,
        where: '${DatabaseHelper.columnSnapshotInvestmentId} = ?',
        whereArgs: [investmentId],
        orderBy: '${DatabaseHelper.columnSnapshotDate} DESC',
      );
      return PortfolioSnapshotHelper.fromMapList(maps);
    } catch (e) {
      debugPrint(
        '[PortfolioSnapshotRepository][getByInvestmentId] ❌ Error: $e',
      );
      rethrow;
    }
  }

  /// Get latest snapshot for a specific investment
  Future<PortfolioSnapshot?> getLatestForInvestment(int investmentId) async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tablePortfolioSnapshots,
        where: '${DatabaseHelper.columnSnapshotInvestmentId} = ?',
        whereArgs: [investmentId],
        orderBy: '${DatabaseHelper.columnSnapshotDate} DESC',
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return PortfolioSnapshot.fromMap(maps.first);
    } catch (e) {
      debugPrint(
        '[PortfolioSnapshotRepository][getLatestForInvestment] ❌ Error: $e',
      );
      rethrow;
    }
  }

  /// Get manual price snapshots only
  Future<List<PortfolioSnapshot>> getManualPriceOnly() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query(
        DatabaseHelper.tablePortfolioSnapshots,
        where: '${DatabaseHelper.columnSnapshotIsManualPrice} = ?',
        whereArgs: [1],
        orderBy: '${DatabaseHelper.columnSnapshotDate} DESC',
      );
      return PortfolioSnapshotHelper.fromMapList(maps);
    } catch (e) {
      debugPrint(
        '[PortfolioSnapshotRepository][getManualPriceOnly] ❌ Error: $e',
      );
      rethrow;
    }
  }

  // ==================== UPDATE ====================

  /// Update a snapshot
  Future<int> update(PortfolioSnapshot snapshot) async {
    try {
      debugPrint(
        '[PortfolioSnapshotRepository][update] Updating ID: ${snapshot.id}',
      );
      final db = await _dbHelper.database;
      final result = await db.update(
        DatabaseHelper.tablePortfolioSnapshots,
        snapshot.copyWithUpdatedTimestamp().toMap(),
        where: '${DatabaseHelper.columnSnapshotId} = ?',
        whereArgs: [snapshot.id],
      );
      debugPrint(
        '[PortfolioSnapshotRepository][update] ✅ Result: $result rows affected',
      );
      return result;
    } catch (e) {
      debugPrint('[PortfolioSnapshotRepository][update] ❌ Error: $e');
      rethrow;
    }
  }

  // ==================== DELETE ====================

  /// Delete a snapshot by ID
  Future<int> delete(int id) async {
    try {
      debugPrint('[PortfolioSnapshotRepository][delete] Deleting ID: $id');
      final db = await _dbHelper.database;
      final result = await db.delete(
        DatabaseHelper.tablePortfolioSnapshots,
        where: '${DatabaseHelper.columnSnapshotId} = ?',
        whereArgs: [id],
      );
      debugPrint(
        '[PortfolioSnapshotRepository][delete] ✅ Result: $result rows deleted',
      );
      return result;
    } catch (e) {
      debugPrint('[PortfolioSnapshotRepository][delete] ❌ Error: $e');
      rethrow;
    }
  }

  /// Delete snapshot by activity ID
  Future<int> deleteByActivityId(int activityId) async {
    try {
      debugPrint(
        '[PortfolioSnapshotRepository][deleteByActivityId] Deleting for activity: $activityId',
      );
      final db = await _dbHelper.database;
      final result = await db.delete(
        DatabaseHelper.tablePortfolioSnapshots,
        where: '${DatabaseHelper.columnSnapshotActivityId} = ?',
        whereArgs: [activityId],
      );
      debugPrint(
        '[PortfolioSnapshotRepository][deleteByActivityId] ✅ Result: $result rows deleted',
      );
      return result;
    } catch (e) {
      debugPrint(
        '[PortfolioSnapshotRepository][deleteByActivityId] ❌ Error: $e',
      );
      rethrow;
    }
  }

  /// Delete all snapshots
  Future<int> deleteAll() async {
    try {
      debugPrint(
        '[PortfolioSnapshotRepository][deleteAll] Deleting all snapshots',
      );
      final db = await _dbHelper.database;
      final result = await db.delete(DatabaseHelper.tablePortfolioSnapshots);
      debugPrint(
        '[PortfolioSnapshotRepository][deleteAll] ✅ Deleted $result rows',
      );
      return result;
    } catch (e) {
      debugPrint('[PortfolioSnapshotRepository][deleteAll] ❌ Error: $e');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Check if snapshots exist in database
  Future<bool> hasData() async {
    try {
      final snapshots = await getAll();
      return snapshots.isNotEmpty;
    } catch (e) {
      debugPrint('[PortfolioSnapshotRepository][hasData] ❌ Error: $e');
      return false;
    }
  }

  /// Get total count of snapshots
  Future<int> count() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tablePortfolioSnapshots}',
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      debugPrint('[PortfolioSnapshotRepository][count] ❌ Error: $e');
      rethrow;
    }
  }

  /// Count snapshots for a specific investment
  Future<int> countSnapshotsForInvestment(int investmentId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tablePortfolioSnapshots} '
        'WHERE ${DatabaseHelper.columnSnapshotInvestmentId} = ?',
        [investmentId],
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      debugPrint(
        '[PortfolioSnapshotRepository][countSnapshotsForInvestment] ❌ Error: $e',
      );
      rethrow;
    }
  }

  /// Get latest snapshots for all investments (one per investment)
  Future<Map<int, PortfolioSnapshot>> getLatestForAllInvestments() async {
    try {
      final db = await _dbHelper.database;
      // Query to get latest snapshot per investment
      final maps = await db.rawQuery('''
        SELECT * FROM ${DatabaseHelper.tablePortfolioSnapshots} s1
        WHERE ${DatabaseHelper.columnSnapshotDate} = (
          SELECT MAX(${DatabaseHelper.columnSnapshotDate})
          FROM ${DatabaseHelper.tablePortfolioSnapshots} s2
          WHERE s1.${DatabaseHelper.columnSnapshotInvestmentId} = s2.${DatabaseHelper.columnSnapshotInvestmentId}
        )
      ''');

      final Map<int, PortfolioSnapshot> result = {};
      for (final map in maps) {
        final snapshot = PortfolioSnapshot.fromMap(map);
        result[snapshot.investmentId] = snapshot;
      }
      return result;
    } catch (e) {
      debugPrint(
        '[PortfolioSnapshotRepository][getLatestForAllInvestments] ❌ Error: $e',
      );
      rethrow;
    }
  }
}
