import 'package:flutter/foundation.dart';
import '../database_helper.dart';

/// Repository for hashtag groups CRUD operations
/// Handles all database operations related to hashtag groups
class HashtagRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== CREATE ====================

  /// Insert a new hashtag group
  Future<int> insert(Map<String, dynamic> group) async {
    try {
      debugPrint('[HashtagRepository][insert] Inserting group: $group');
      final db = await _dbHelper.database;
      final id = await db.insert(
        DatabaseHelper.tableHashtagGroups,
        group,
      );
      debugPrint('[HashtagRepository][insert] ✅ Inserted with ID: $id');
      return id;
    } catch (e) {
      debugPrint('[HashtagRepository][insert] ❌ Error: $e');
      rethrow;
    }
  }

  // ==================== READ ====================

  /// Get all hashtag groups
  Future<List<Map<String, dynamic>>> getAll() async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        DatabaseHelper.tableHashtagGroups,
        orderBy: '${DatabaseHelper.columnHashtagGroupOrder} ASC',
      );
    } catch (e) {
      debugPrint('[HashtagRepository][getAll] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get main hashtag groups only (no parent)
  Future<List<Map<String, dynamic>>> getMainGroups() async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        DatabaseHelper.tableHashtagGroups,
        where: '${DatabaseHelper.columnHashtagGroupParentId} IS NULL',
        orderBy: '${DatabaseHelper.columnHashtagGroupOrder} ASC',
      );
    } catch (e) {
      debugPrint('[HashtagRepository][getMainGroups] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get subgroups for a specific main group
  Future<List<Map<String, dynamic>>> getSubgroups(int mainGroupId) async {
    try {
      final db = await _dbHelper.database;
      return await db.query(
        DatabaseHelper.tableHashtagGroups,
        where: '${DatabaseHelper.columnHashtagGroupParentId} = ?',
        whereArgs: [mainGroupId],
        orderBy: '${DatabaseHelper.columnHashtagGroupOrder} ASC',
      );
    } catch (e) {
      debugPrint('[HashtagRepository][getSubgroups] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get a specific hashtag group by ID
  Future<Map<String, dynamic>?> getById(int groupId) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        DatabaseHelper.tableHashtagGroups,
        where: '${DatabaseHelper.columnHashtagGroupId} = ?',
        whereArgs: [groupId],
        limit: 1,
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      debugPrint('[HashtagRepository][getById] ❌ Error: $e');
      rethrow;
    }
  }

  /// Get hashtag group by name
  Future<Map<String, dynamic>?> getByName(String name) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        DatabaseHelper.tableHashtagGroups,
        where: '${DatabaseHelper.columnHashtagGroupName} = ?',
        whereArgs: [name],
        limit: 1,
      );
      return results.isNotEmpty ? results.first : null;
    } catch (e) {
      debugPrint('[HashtagRepository][getByName] ❌ Error: $e');
      rethrow;
    }
  }

  /// Count subgroups for a main group
  Future<int> countSubgroups(int mainGroupId) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseHelper.tableHashtagGroups} '
        'WHERE ${DatabaseHelper.columnHashtagGroupParentId} = ?',
        [mainGroupId],
      );
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      debugPrint('[HashtagRepository][countSubgroups] ❌ Error: $e');
      rethrow;
    }
  }

  // ==================== UPDATE ====================

  /// Update a hashtag group
  Future<int> update(int groupId, Map<String, dynamic> updates) async {
    try {
      debugPrint('[HashtagRepository][update] Updating group ID: $groupId');
      debugPrint('[HashtagRepository][update] Updates: $updates');

      final db = await _dbHelper.database;
      final result = await db.update(
        DatabaseHelper.tableHashtagGroups,
        updates,
        where: '${DatabaseHelper.columnHashtagGroupId} = ?',
        whereArgs: [groupId],
      );

      debugPrint('[HashtagRepository][update] Result: $result rows affected');
      return result;
    } catch (e) {
      debugPrint('[HashtagRepository][update] ❌ Error: $e');
      rethrow;
    }
  }

  // ==================== DELETE ====================

  /// Delete a hashtag group
  /// Returns 0 if group has subgroups (cannot delete)
  Future<int> delete(int groupId) async {
    try {
      debugPrint('[HashtagRepository][delete] Deleting group ID: $groupId');

      // Check if this is a main group with subgroups
      final subgroupsCount = await countSubgroups(groupId);
      if (subgroupsCount > 0) {
        debugPrint(
          '[HashtagRepository][delete] Cannot delete - has $subgroupsCount subgroups',
        );
        return 0;
      }

      final db = await _dbHelper.database;
      final result = await db.delete(
        DatabaseHelper.tableHashtagGroups,
        where: '${DatabaseHelper.columnHashtagGroupId} = ?',
        whereArgs: [groupId],
      );

      debugPrint('[HashtagRepository][delete] Result: $result rows deleted');
      return result;
    } catch (e) {
      debugPrint('[HashtagRepository][delete] ❌ Error: $e');
      rethrow;
    }
  }

  /// Delete all hashtag groups
  Future<int> deleteAll() async {
    try {
      debugPrint('[HashtagRepository][deleteAll] Deleting all groups');
      final db = await _dbHelper.database;
      final result = await db.delete(DatabaseHelper.tableHashtagGroups);
      debugPrint('[HashtagRepository][deleteAll] ✅ Deleted $result rows');
      return result;
    } catch (e) {
      debugPrint('[HashtagRepository][deleteAll] ❌ Error: $e');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================

  /// Check if hashtag groups exist in database
  Future<bool> hasData() async {
    try {
      final groups = await getAll();
      return groups.isNotEmpty;
    } catch (e) {
      debugPrint('[HashtagRepository][hasData] ❌ Error: $e');
      return false;
    }
  }

  /// Check if a hashtag name already exists (case-insensitive)
  Future<bool> nameExists(String name, {int? excludeId}) async {
    try {
      final db = await _dbHelper.database;
      final whereClause = excludeId != null
          ? 'LOWER(${DatabaseHelper.columnHashtagGroupName}) = ? AND ${DatabaseHelper.columnHashtagGroupId} != ?'
          : 'LOWER(${DatabaseHelper.columnHashtagGroupName}) = ?';
      final whereArgs = excludeId != null ? [name.toLowerCase(), excludeId] : [name.toLowerCase()];

      final results = await db.query(
        DatabaseHelper.tableHashtagGroups,
        where: whereClause,
        whereArgs: whereArgs,
        limit: 1,
      );
      return results.isNotEmpty;
    } catch (e) {
      debugPrint('[HashtagRepository][nameExists] ❌ Error: $e');
      rethrow;
    }
  }
}
