# Investment Feature - Implementation Tasks

## Overview
Database-backed investment tracking with unified transactions/trades table and auto-portfolio snapshots.

## Key Design Decisions
1. **Image Storage**: Images copied to app's documents folder (`{appDocDir}/investments/`) - NOT nullable, persists even if deleted from gallery
2. **Deletion Protection**: Cannot delete investment if ANY activity references it (same pattern as hashtags)
3. **Unified Table**: Single `investment_activities` table with type field ('transaction' or 'trade')
4. **Auto-Snapshot**: When trade/transaction is created, automatically creates linked portfolio_snapshot

---

## Task Checklist

### Phase 1: Database Foundation
- [x] **1.1** Add table constants to `database_helper.dart`
- [x] **1.2** Add column constants for `investments` table
- [x] **1.3** Add column constants for `investment_activities` table
- [x] **1.4** Add column constants for `portfolio_snapshots` table
- [x] **1.5** Bump `_databaseVersion` from 1 to 2
- [x] **1.6** Add `_createInvestmentsTable(Database db)` method
- [x] **1.7** Add `_createInvestmentActivitiesTable(Database db)` method
- [x] **1.8** Add `_createPortfolioSnapshotsTable(Database db)` method
- [x] **1.9** Update `_onUpgrade()` with migration logic for version 1 → 2

---

### Phase 2: Models
- [x] **2.1** Create `lib/models/investment_model.dart`
- [x] **2.2** Create `lib/models/investment_activity_model.dart`
- [x] **2.3** Create `InvestmentActivityHelper` class
- [x] **2.4** Create `lib/models/portfolio_snapshot_model.dart`

---

### Phase 3: Repositories
- [x] **3.1** Create `lib/services/database/repositories/investment_repository.dart`
- [x] **3.2** Create `lib/services/database/repositories/investment_activity_repository.dart`
- [x] **3.3** Create `lib/services/database/repositories/portfolio_snapshot_repository.dart`

---

### Phase 4: Service Layer
- [x] **4.1** Create `lib/services/investment_service.dart`
- [x] **4.2** Implement Investment CRUD in service (with image copying to app folder)
- [x] **4.3** Implement Activity CRUD with auto-snapshot
- [x] **4.4** Implement Portfolio methods

---

### Phase 5: Controller Migration
- [x] **5.1** Update `InvestmentController` - remove in-memory data
- [x] **5.2** Add service integration
- [x] **5.3** Update `onInit()` to load from database
- [x] **5.4** Update grouping methods for InvestmentActivity
- [x] **5.5** Add CRUD methods to controller
- [x] **5.6** Add legacy compatibility methods for existing UI code

---

## Testing Checklist

- [ ] Create new investment with gallery image (image should be copied to app folder)
- [ ] Create investment transaction (deposit)
- [ ] Create investment transaction (withdraw)
- [ ] Create trade (sell one investment, buy another)
- [ ] Verify auto-snapshot created for each activity
- [ ] Add manual portfolio snapshot
- [ ] View unified activity list sorted by date
- [ ] Filter activities by type (transactions only / trades only)
- [ ] Try to delete investment with activities (should fail with error)
- [ ] Delete all activities for an investment, then delete the investment (should succeed)
- [ ] App upgrade from version 1 to 2 - verify migration works

---

## File Summary

### New Files (7)
```
lib/models/investment_model.dart
lib/models/investment_activity_model.dart
lib/models/portfolio_snapshot_model.dart
lib/services/database/repositories/investment_repository.dart
lib/services/database/repositories/investment_activity_repository.dart
lib/services/database/repositories/portfolio_snapshot_repository.dart
lib/services/investment_service.dart
```

### Modified Files (4)
```
lib/services/database/database_helper.dart
lib/controllers/investment_controller.dart
lib/services/test_data_service.dart  (added generateInvestmentTestData method)
lib/screens/setting/settings_screen.dart  (added Load Investment Test Data option)
```

---

## Database Schema

### investments table
```sql
CREATE TABLE investments (
  investment_id INTEGER PRIMARY KEY AUTOINCREMENT,
  investment_name TEXT NOT NULL,
  investment_ticker TEXT NOT NULL,
  investment_color INTEGER NOT NULL,
  investment_image_path TEXT NOT NULL,  -- Copied to app folder
  investment_created_at TEXT NOT NULL,
  investment_updated_at TEXT NOT NULL
);
```

### investment_activities table
```sql
CREATE TABLE investment_activities (
  activity_id INTEGER PRIMARY KEY AUTOINCREMENT,
  activity_type TEXT NOT NULL,          -- 'transaction' or 'trade'
  activity_date TEXT NOT NULL,
  activity_description TEXT,
  activity_created_at TEXT NOT NULL,
  activity_updated_at TEXT NOT NULL,

  -- Transaction fields (NULL for trades)
  tx_is_withdraw INTEGER,
  tx_investment_id INTEGER,
  tx_amount REAL,
  tx_price REAL,
  tx_total REAL,

  -- Trade fields (NULL for transactions)
  trade_sold_investment_id INTEGER,
  trade_sold_amount REAL,
  trade_sold_price REAL,
  trade_sold_total REAL,
  trade_bought_investment_id INTEGER,
  trade_bought_amount REAL,
  trade_bought_price REAL,
  trade_bought_total REAL,

  FOREIGN KEY (tx_investment_id) REFERENCES investments (investment_id),
  FOREIGN KEY (trade_sold_investment_id) REFERENCES investments (investment_id),
  FOREIGN KEY (trade_bought_investment_id) REFERENCES investments (investment_id)
);
```

### portfolio_snapshots table
```sql
CREATE TABLE portfolio_snapshots (
  snapshot_id INTEGER PRIMARY KEY AUTOINCREMENT,
  snapshot_date TEXT NOT NULL,
  snapshot_current_value REAL NOT NULL,
  snapshot_entry_type TEXT NOT NULL,    -- 'trade', 'transaction', 'manual'
  snapshot_activity_id INTEGER,
  snapshot_note TEXT,
  snapshot_created_at TEXT NOT NULL,
  snapshot_updated_at TEXT NOT NULL,

  FOREIGN KEY (snapshot_activity_id) REFERENCES investment_activities (activity_id) ON DELETE SET NULL
);
```

---

## Usage Examples

### Add Investment
```dart
final controller = Get.find<InvestmentController>();
await controller.addInvestment(
  name: 'Bitcoin',
  ticker: 'BTC',
  color: Colors.orange,
  imageFile: File('/path/to/image.jpg'),  // Will be copied to app folder
);
```

### Add Transaction (Deposit)
```dart
await controller.addTransaction(
  investmentId: 1,
  direction: TransactionDirection.deposit,
  amount: 0.5,
  price: 50000.0,
  total: 25000.0,
  date: DateTime.now(),
  description: 'Bought 0.5 BTC',
);
```

### Add Trade
```dart
await controller.addTrade(
  soldInvestmentId: 1,  // BTC
  soldAmount: 1.0,
  soldPrice: 50000.0,
  soldTotal: 50000.0,
  boughtInvestmentId: 2,  // ETH
  boughtAmount: 20.0,
  boughtPrice: 2500.0,
  boughtTotal: 50000.0,
  date: DateTime.now(),
  description: 'Traded BTC for ETH',
);
```

### Add Manual Portfolio Snapshot
```dart
await controller.addManualPortfolioEntry(
  currentValue: 100000.0,
  date: DateTime.now(),
  note: 'End of month valuation',
);
```
