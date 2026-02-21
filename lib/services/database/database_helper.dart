import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// Core database helper that manages database connection and schema
/// Each entity (transactions, MCCs, hashtags, assets, etc.) should have its own repository
class DatabaseHelper {
  static const _databaseName = 'money_app.db';
  static const _databaseVersion = 5;

  // Table names
  static const tableHashtagGroups = 'hashtag_groups';
  static const tableTransactions = 'transactions';
  static const tableMCCCategories = 'mcc_categories';
  static const tableMCCItems = 'mcc_items';
  static const tableAssets = 'assets';
  static const tableInvestments = 'investments';
  static const tableInvestmentActivities = 'investment_activities';
  static const tablePortfolioSnapshots = 'portfolio_snapshots';
  static const tableAppSettings = 'app_settings';

  // App Settings table columns
  static const columnSettingKey = 'setting_key';
  static const columnSettingValue = 'setting_value';

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

  // Investments table columns
  static const columnInvestmentId = 'investment_id';
  static const columnInvestmentName = 'investment_name';
  static const columnInvestmentTicker = 'investment_ticker';
  static const columnInvestmentColor = 'investment_color';
  static const columnInvestmentImagePath = 'investment_image_path';
  static const columnInvestmentCreatedAt = 'investment_created_at';
  static const columnInvestmentUpdatedAt = 'investment_updated_at';

  // Investment Activities table columns
  static const columnActivityId = 'activity_id';
  static const columnActivityType = 'activity_type';
  static const columnActivityDate = 'activity_date';
  static const columnActivityDescription = 'activity_description';
  static const columnActivityCreatedAt = 'activity_created_at';
  static const columnActivityUpdatedAt = 'activity_updated_at';
  // Transaction-specific columns (NULL for trades)
  static const columnTxIsWithdraw = 'tx_is_withdraw';
  static const columnTxInvestmentId = 'tx_investment_id';
  static const columnTxAmount = 'tx_amount';
  static const columnTxPrice = 'tx_price';
  static const columnTxTotal = 'tx_total';
  // Trade-specific columns (NULL for transactions)
  static const columnTradeSoldInvestmentId = 'trade_sold_investment_id';
  static const columnTradeSoldAmount = 'trade_sold_amount';
  static const columnTradeSoldPrice = 'trade_sold_price';
  static const columnTradeSoldTotal = 'trade_sold_total';
  static const columnTradeBoughtInvestmentId = 'trade_bought_investment_id';
  static const columnTradeBoughtAmount = 'trade_bought_amount';
  static const columnTradeBoughtPrice = 'trade_bought_price';
  static const columnTradeBoughtTotal = 'trade_bought_total';

  // Portfolio Snapshots table columns
  static const columnSnapshotId = 'snapshot_id';
  static const columnSnapshotInvestmentId = 'snapshot_investment_id';
  static const columnSnapshotDate = 'snapshot_date';
  static const columnSnapshotUnitPrice = 'snapshot_unit_price';
  static const columnSnapshotIsManualPrice = 'snapshot_is_manual_price';
  static const columnSnapshotEntryType = 'snapshot_entry_type';
  static const columnSnapshotActivityId = 'snapshot_activity_id';
  static const columnSnapshotNote = 'snapshot_note';
  static const columnSnapshotCreatedAt = 'snapshot_created_at';
  static const columnSnapshotUpdatedAt = 'snapshot_updated_at';

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

    // Seed the default N/A hashtag group
    await _seedNAGroup(db);

    // Create Transactions table
    await _createTransactionsTable(db);

    // Create Investment tables
    await _createInvestmentsTable(db);
    await _createInvestmentActivitiesTable(db);
    await _createPortfolioSnapshotsTable(db);

    // Create App Settings table
    await _createAppSettingsTable(db);
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

  /// Create investments table
  Future<void> _createInvestmentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableInvestments (
        $columnInvestmentId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnInvestmentName TEXT NOT NULL,
        $columnInvestmentTicker TEXT NOT NULL,
        $columnInvestmentColor INTEGER NOT NULL,
        $columnInvestmentImagePath TEXT NOT NULL,
        $columnInvestmentCreatedAt TEXT NOT NULL,
        $columnInvestmentUpdatedAt TEXT NOT NULL
      )
    ''');
    debugPrint('[DatabaseHelper] ✅ Investments table created');
  }

  /// Create investment activities table (unified for transactions and trades)
  Future<void> _createInvestmentActivitiesTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableInvestmentActivities (
        $columnActivityId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnActivityType TEXT NOT NULL,
        $columnActivityDate TEXT NOT NULL,
        $columnActivityDescription TEXT,
        $columnActivityCreatedAt TEXT NOT NULL,
        $columnActivityUpdatedAt TEXT NOT NULL,

        -- Transaction-specific fields (NULL for trades)
        $columnTxIsWithdraw INTEGER,
        $columnTxInvestmentId INTEGER,
        $columnTxAmount REAL,
        $columnTxPrice REAL,
        $columnTxTotal REAL,

        -- Trade-specific fields (NULL for transactions)
        $columnTradeSoldInvestmentId INTEGER,
        $columnTradeSoldAmount REAL,
        $columnTradeSoldPrice REAL,
        $columnTradeSoldTotal REAL,
        $columnTradeBoughtInvestmentId INTEGER,
        $columnTradeBoughtAmount REAL,
        $columnTradeBoughtPrice REAL,
        $columnTradeBoughtTotal REAL,

        FOREIGN KEY ($columnTxInvestmentId) REFERENCES $tableInvestments ($columnInvestmentId),
        FOREIGN KEY ($columnTradeSoldInvestmentId) REFERENCES $tableInvestments ($columnInvestmentId),
        FOREIGN KEY ($columnTradeBoughtInvestmentId) REFERENCES $tableInvestments ($columnInvestmentId)
      )
    ''');

    // Create index for faster date-based queries
    await db.execute('''
      CREATE INDEX idx_activities_date ON $tableInvestmentActivities ($columnActivityDate DESC)
    ''');

    debugPrint('[DatabaseHelper] ✅ Investment activities table created');
  }

  /// Create portfolio snapshots table
  Future<void> _createPortfolioSnapshotsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tablePortfolioSnapshots (
        $columnSnapshotId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnSnapshotInvestmentId INTEGER NOT NULL,
        $columnSnapshotDate TEXT NOT NULL,
        $columnSnapshotUnitPrice REAL NOT NULL,
        $columnSnapshotIsManualPrice INTEGER NOT NULL DEFAULT 0,
        $columnSnapshotEntryType TEXT NOT NULL,
        $columnSnapshotActivityId INTEGER,
        $columnSnapshotNote TEXT,
        $columnSnapshotCreatedAt TEXT NOT NULL,
        $columnSnapshotUpdatedAt TEXT NOT NULL,

        FOREIGN KEY ($columnSnapshotInvestmentId) REFERENCES $tableInvestments ($columnInvestmentId) ON DELETE RESTRICT,
        FOREIGN KEY ($columnSnapshotActivityId) REFERENCES $tableInvestmentActivities ($columnActivityId) ON DELETE SET NULL
      )
    ''');

    // Create indexes for faster queries
    await db.execute('''
      CREATE INDEX idx_snapshots_investment ON $tablePortfolioSnapshots ($columnSnapshotInvestmentId)
    ''');
    await db.execute('''
      CREATE INDEX idx_snapshots_date ON $tablePortfolioSnapshots ($columnSnapshotDate DESC)
    ''');

    debugPrint('[DatabaseHelper] ✅ Portfolio snapshots table created');
  }

  /// Create app settings table (key-value store)
  Future<void> _createAppSettingsTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableAppSettings (
        $columnSettingKey TEXT PRIMARY KEY,
        $columnSettingValue TEXT NOT NULL
      )
    ''');
    debugPrint('[DatabaseHelper] App settings table created');
  }

  /// Seed the default N/A hashtag group
  Future<void> _seedNAGroup(Database db) async {
    final now = DateTime.now().toIso8601String();
    await db.insert(tableHashtagGroups, {
      columnHashtagGroupName: 'N/A',
      columnHashtagGroupParentId: null,
      columnHashtagGroupOrder: 999,
      columnHashtagGroupIsCustom: 0,
      columnHashtagGroupCreatedAt: now,
      columnHashtagGroupUpdatedAt: now,
    });
    debugPrint('[DatabaseHelper] ✅ N/A hashtag group seeded');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint(
      '[DatabaseHelper] Upgrading database from version $oldVersion to $newVersion',
    );

    // Migration from version 1 to 2: Add investment tables
    if (oldVersion < 2) {
      debugPrint(
        '[DatabaseHelper] Migrating to version 2: Adding investment tables',
      );
      await _createInvestmentsTable(db);
      await _createInvestmentActivitiesTable(db);
      await _createPortfolioSnapshotsTable(db);
    }

    // Migration from version 2 to 3: Redesign portfolio snapshots for per-investment tracking
    if (oldVersion < 3) {
      debugPrint(
        '[DatabaseHelper] Migrating to version 3: Redesigning portfolio snapshots',
      );
      // Drop and recreate portfolio_snapshots table (clears old data)
      await db.execute('DROP TABLE IF EXISTS $tablePortfolioSnapshots');
      await _createPortfolioSnapshotsTable(db);
      debugPrint('[DatabaseHelper] ✅ Portfolio snapshots table recreated');
    }

    // Migration from version 3 to 4: Add app settings table
    if (oldVersion < 4) {
      debugPrint(
        '[DatabaseHelper] Migrating to version 4: Adding app settings table',
      );
      await _createAppSettingsTable(db);
    }

    // Migration from version 4 to 5: Seed N/A hashtag group
    if (oldVersion < 5) {
      debugPrint(
        '[DatabaseHelper] Migrating to version 5: Seeding N/A hashtag group',
      );
      final existing = await db.query(
        tableHashtagGroups,
        where: '$columnHashtagGroupName = ?',
        whereArgs: ['N/A'],
      );
      if (existing.isEmpty) {
        await _seedNAGroup(db);
      }
    }
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
      // Clear investment tables (order matters due to foreign keys)
      await db.delete(tablePortfolioSnapshots);
      await db.delete(tableInvestmentActivities);
      await db.delete(tableInvestments);
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
