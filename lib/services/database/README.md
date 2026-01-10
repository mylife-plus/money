# Database Architecture

This directory contains the modular database architecture for the Money App.

## Structure

```
database/
├── database_helper.dart          # Core database management
└── repositories/                 # Data access layer
    ├── hashtag_repository.dart   # Hashtag CRUD operations
    ├── transaction_repository.dart (TODO)
    ├── mcc_repository.dart       (TODO)
    └── asset_repository.dart     (TODO)
```

## Architecture Pattern

This project uses the **Repository Pattern** for database operations:

- **DatabaseHelper**: Manages database connection, schema creation, and migrations
- **Repositories**: Handle CRUD operations for specific entities

## Current Implementation

### DatabaseHelper (`database_helper.dart`)

Core responsibilities:
- Database connection management (singleton pattern)
- Schema creation and migrations
- Database health checks
- Recovery from corrupted databases

**Tables (v1)**:
- `hashtag_groups` - Hashtag groups for transaction categorization

**Future tables** (add as needed):
- `transactions` - Financial transactions
- `mcc_categories` - Merchant category code categories
- `mcc_items` - Individual MCC items
- `assets` - Investment assets

### HashtagRepository (`repositories/hashtag_repository.dart`)

Operations:
- **Create**: `insert(Map<String, dynamic> group)`
- **Read**:
  - `getAll()` - All groups
  - `getMainGroups()` - Main groups only
  - `getSubgroups(int mainGroupId)` - Subgroups for a main group
  - `getById(int groupId)` - Single group by ID
  - `getByName(String name)` - Single group by name
- **Update**: `update(int groupId, Map<String, dynamic> updates)`
- **Delete**:
  - `delete(int groupId)` - Delete single group
  - `deleteAll()` - Delete all groups

Helper methods:
- `countSubgroups(int mainGroupId)` - Count subgroups
- `hasData()` - Check if data exists
- `nameExists(String name, {int? excludeId})` - Check for duplicates

## Adding a New Repository

### 1. Create the repository file

Example: `repositories/transaction_repository.dart`

```dart
import 'package:flutter/foundation.dart';
import '../database_helper.dart';

class TransactionRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Create
  Future<int> insert(Map<String, dynamic> transaction) async {
    final db = await _dbHelper.database;
    return await db.insert(
      DatabaseHelper.tableTransactions,
      transaction,
    );
  }

  // Read
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await _dbHelper.database;
    return await db.query(DatabaseHelper.tableTransactions);
  }

  // Update
  Future<int> update(int id, Map<String, dynamic> updates) async {
    final db = await _dbHelper.database;
    return await db.update(
      DatabaseHelper.tableTransactions,
      updates,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      DatabaseHelper.tableTransactions,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```

### 2. Add table definition to DatabaseHelper

In `database_helper.dart`:

```dart
// Add table name constant
static const tableTransactions = 'transactions';

// Add in _onCreate method
await db.execute('''
  CREATE TABLE $tableTransactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount REAL NOT NULL,
    date TEXT NOT NULL,
    -- Add more columns as needed
  )
''');
```

### 3. Create service layer

Example: `services/transaction_service.dart`

```dart
import 'database/repositories/transaction_repository.dart';

class TransactionService {
  final TransactionRepository _repository = TransactionRepository();

  Future<void> addTransaction(Transaction transaction) async {
    await _repository.insert(transaction.toMap());
  }

  // Add business logic methods
}
```

## Schema Migration

When updating the database schema:

1. **Increment version** in `database_helper.dart`:
   ```dart
   static const _databaseVersion = 2; // Increment
   ```

2. **Add migration logic** in `_onUpgrade`:
   ```dart
   Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
     if (oldVersion < 2) {
       // Add new column
       await db.execute('ALTER TABLE hashtag_groups ADD COLUMN new_field TEXT');
     }
   }
   ```

## Best Practices

1. **Repositories handle ONLY database operations** - No business logic
2. **Services handle business logic** - Use repositories for data access
3. **Always use prepared statements** to prevent SQL injection
4. **Use transactions for multi-step operations**:
   ```dart
   final db = await _dbHelper.database;
   await db.transaction((txn) async {
     await txn.insert(...);
     await txn.update(...);
   });
   ```
5. **Add proper error handling and logging**
6. **Keep database methods simple and focused**

## Testing Database Operations

```dart
// Clear all data for testing
await DatabaseHelper.instance.clearAllData();

// Delete database file completely
await DatabaseHelper.instance.deleteDatabase();

// Check database health
bool healthy = await DatabaseHelper.instance.isHealthy();

// Reset connection (useful for recovery)
await DatabaseHelper.instance.resetConnection();
```

## Future Enhancements

- [ ] Add TransactionRepository for financial transactions
- [ ] Add MCCRepository for merchant category codes
- [ ] Add AssetRepository for investment assets
- [ ] Add database encryption for sensitive data
- [ ] Add database backup/restore functionality
- [ ] Add database export to CSV/JSON
- [ ] Add query builder for complex queries
- [ ] Add caching layer for frequently accessed data
