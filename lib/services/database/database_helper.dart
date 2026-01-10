import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// Core database helper that manages database connection and schema
/// Each entity (transactions, MCCs, hashtags, assets, etc.) should have its own repository
class DatabaseHelper {
  static const _databaseName = 'money_app.db';
  static const _databaseVersion = 1;

  // Table names
  static const tableHashtagGroups = 'hashtag_groups';
  static const tableTransactions = 'transactions';
  static const tableMCCCategories = 'mcc_categories';
  static const tableMCCItems = 'mcc_items';
  static const tableAssets = 'assets';

  // Hashtag Groups table columns
  static const columnHashtagGroupId = 'hashtag_group_id';
  static const columnHashtagGroupName = 'hashtag_group_name';
  static const columnHashtagGroupParentId = 'hashtag_group_parent_id';
  static const columnHashtagGroupOrder = 'hashtag_group_order';
  static const columnHashtagGroupIsCustom = 'hashtag_group_is_custom';
  static const columnHashtagGroupCreatedAt = 'hashtag_group_created_at';
  static const columnHashtagGroupUpdatedAt = 'hashtag_group_updated_at';

  // Transaction table columns
  static const columnTransactionId = 'transaction_id';
  static const columnTransactionIsExpense = 'transaction_is_expense';
  static const columnTransactionDate = 'transaction_date';
  static const columnTransactionAmount = 'transaction_amount';
  static const columnTransactionMccId = 'transaction_mcc_id';
  static const columnTransactionRecipient = 'transaction_recipient';
  static const columnTransactionNote = 'transaction_note';
  static const columnTransactionHashtags = 'transaction_hashtags';
  static const columnTransactionCreatedAt = 'transaction_created_at';
  static const columnTransactionUpdatedAt = 'transaction_updated_at';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  static bool _isInitializing = false;

  /// Get database instance (creates if not exists)
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    // Prevent concurrent initialization
    if (_isInitializing) {
      // Wait for initialization to complete
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (_database != null && _database!.isOpen) {
        return _database!;
      }
    }

    _isInitializing = true;
    try {
      _database = await _initDatabase();
      return _database!;
    } finally {
      _isInitializing = false;
    }
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _databaseName);

      debugPrint('[DatabaseHelper] Initializing database at: $path');

      final db = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      // Verify database is accessible
      await _verifyDatabase(db);

      debugPrint('[DatabaseHelper] ✅ Database initialized successfully');
      return db;
    } catch (e) {
      debugPrint('[DatabaseHelper] ❌ Error initializing database: $e');

      // Try to recover by deleting corrupted database
      return await _recoverDatabase();
    }
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    debugPrint('[DatabaseHelper] Creating database schema version $version');

    // Create Hashtag Groups table
    await db.execute('''
      CREATE TABLE $tableHashtagGroups (
        $columnHashtagGroupId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnHashtagGroupName TEXT NOT NULL,
        $columnHashtagGroupParentId INTEGER,
        $columnHashtagGroupOrder INTEGER DEFAULT 0,
        $columnHashtagGroupIsCustom INTEGER DEFAULT 0,
        $columnHashtagGroupCreatedAt TEXT NOT NULL,
        $columnHashtagGroupUpdatedAt TEXT NOT NULL,
        FOREIGN KEY ($columnHashtagGroupParentId)
          REFERENCES $tableHashtagGroups ($columnHashtagGroupId)
          ON DELETE CASCADE
      )
    ''');
    debugPrint('[DatabaseHelper] ✅ Hashtag groups table created');

    // TODO: Add more tables as needed
    // Example:
    // Create Transactions table
    await _createTransactionsTable(db);
    // await _createMCCTables(db);
    // await _createAssetsTable(db);
  }

  Future<void> _createTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableTransactions (
        $columnTransactionId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnTransactionIsExpense INTEGER DEFAULT 1,
        $columnTransactionDate TEXT NOT NULL,
        $columnTransactionAmount REAL NOT NULL,
        $columnTransactionMccId INTEGER, -- Foreign Key to MCCItem
        $columnTransactionRecipient TEXT,
        $columnTransactionNote TEXT,
        $columnTransactionHashtags TEXT, -- Stored as JSON list of HashtagGroup objects
        $columnTransactionCreatedAt TEXT NOT NULL,
        $columnTransactionUpdatedAt TEXT NOT NULL
      )
    ''');
    debugPrint('[DatabaseHelper] ✅ Transactions table created');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint(
      '[DatabaseHelper] Upgrading database from version $oldVersion to $newVersion',
    );

    // Add migration logic here when you update the schema
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE ...');
    // }
  }

  /// Verify database is accessible
  Future<void> _verifyDatabase(Database db) async {
    try {
      await db.rawQuery('SELECT 1');
      debugPrint('[DatabaseHelper] Database accessibility verified');
    } catch (e) {
      debugPrint('[DatabaseHelper] Warning: Database verification failed: $e');
      rethrow;
    }
  }

  /// Recover database by deleting corrupted file and recreating
  Future<Database> _recoverDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _databaseName);
      final file = File(path);

      if (await file.exists()) {
        debugPrint('[DatabaseHelper] Attempting to delete corrupted database');
        await file.delete();
      }

      // Try to initialize again
      final db = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );

      await _verifyDatabase(db);
      debugPrint('[DatabaseHelper] ✅ Database recovered successfully');

      return db;
    } catch (recoveryError) {
      debugPrint(
        '[DatabaseHelper] ❌ Failed to recover database: $recoveryError',
      );
      rethrow;
    }
  }

  /// Reset database connection (useful for recovery or testing)
  Future<void> resetConnection() async {
    try {
      if (_database != null && _database!.isOpen) {
        debugPrint('[DatabaseHelper] Closing database connection');
        await _database!.close();
      }
    } catch (e) {
      debugPrint('[DatabaseHelper] Error closing database: $e');
    } finally {
      _database = null;
      _isInitializing = false;
    }

    // Reinitialize
    debugPrint('[DatabaseHelper] Reinitializing database connection');
    await database;
  }

  /// Check if database is healthy
  Future<bool> isHealthy() async {
    try {
      final db = await database;
      if (!db.isOpen) return false;

      await db.rawQuery('SELECT 1');
      return true;
    } catch (e) {
      debugPrint('[DatabaseHelper] Database health check failed: $e');
      return false;
    }
  }

  /// Clear all data from all tables (for testing purposes)
  Future<void> clearAllData() async {
    try {
      debugPrint('[DatabaseHelper] Clearing all data...');
      final db = await database;

      await db.delete(tableHashtagGroups);
      await db.delete(tableTransactions);
      // TODO: Add more tables when they are created
      // await db.delete(tableMCCCategories);
      // await db.delete(tableMCCItems);
      // await db.delete(tableAssets);

      debugPrint('[DatabaseHelper] ✅ All data cleared');
    } catch (e) {
      debugPrint('[DatabaseHelper] ❌ Error clearing data: $e');
      rethrow;
    }
  }

  /// Delete database file (for testing purposes)
  Future<void> deleteDatabase() async {
    try {
      debugPrint('[DatabaseHelper] Deleting database file...');

      // Close connection first
      await resetConnection();

      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, _databaseName);
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
        debugPrint('[DatabaseHelper] ✅ Database file deleted');
      } else {
        debugPrint('[DatabaseHelper] Database file does not exist');
      }
    } catch (e) {
      debugPrint('[DatabaseHelper] ❌ Error deleting database: $e');
      rethrow;
    }
  }
}
