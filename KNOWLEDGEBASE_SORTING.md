# Transaction Sorting System - Knowledge Base

## Overview
The app implements a transaction sorting system that allows users to sort transactions by either **highest amount** or **most recent date**. The sorting is applied within each month's transactions while maintaining the year/month hierarchy.

**Key Characteristics**:
- ✅ Sorts transactions **within each month** only
- ✅ Year/month hierarchy always remains descending (newest first)
- ✅ Default sort: Most Recent (by date)
- ✅ Reactive: Auto-updates when sort option changes
- ✅ Works seamlessly with filters
- ⚠️ Sort preference does NOT persist across app restarts

**Visual Flow Diagram**: See "Transaction Sorting System Flow" Mermaid diagram for complete data flow.

## UI Component: TopSortSheet

### Location
`lib/widgets/transactions/top_sort_sheet.dart`

### Sort Options Enum
```dart
enum SortOption { 
  highestAmount,  // Sort by amount (descending)
  mostRecent      // Sort by date (descending) - DEFAULT
}
```

### Visual Behavior
- **Popup Animation**: Slides down from top of screen
- **Option Display**: Selected option moves to the bottom position
- **Visual Indicators**:
  - Selected option: Blue background (#0088FF) with yellow "top" text (#FFFB00)
  - Unselected option: White background with blue "top" text (#0088FF)
- **Icons**:
  - `highestAmount`: Transaction icon (AppIcons.transaction)
  - `mostRecent`: Clock icon (AppIcons.clock)

### Key Methods
- `_getSortedOptions()`: Moves selected option to bottom of list
- `_onOptionTapped()`: Updates selection and triggers callback
- `TopSortSheet.show()`: Static method to display the sheet

## Controller: HomeController

### Location
`lib/controllers/home_controller.dart`

### State Management
```dart
// Default sort option
final Rx<SortOption> selectedSortOption = SortOption.mostRecent.obs;

// Update method
void updateSortOption(SortOption option) {
  selectedSortOption.value = option;
}
```

### Reactive Sorting
The controller uses GetX's `debounce` to automatically re-sort when the option changes:

```dart
debounce(
  selectedSortOption,
  (_) => _rebuildCacheAndItems(),
  time: const Duration(milliseconds: 50),
);
```

## Sorting Logic Implementation

### Location
`lib/controllers/home_controller.dart` - `_rebuildCacheAndItems()` method (lines 655-674)

### Sorting Algorithm

#### 1. Year Sorting (Always Descending)
```dart
_cachedSortedYears = _cachedGroupedData.keys.toList()
  ..sort((a, b) => b.compareTo(a));
```
- Years are ALWAYS sorted newest to oldest
- Independent of user's sort option

#### 2. Month Sorting (Always Descending)
- Months within each year are sorted newest to oldest (12 → 1)
- Independent of user's sort option

#### 3. Transaction Sorting (User-Controlled)
```dart
for (var year in _cachedGroupedData.keys) {
  for (var month in _cachedGroupedData[year]!.keys) {
    var monthTransactions = _cachedGroupedData[year]![month]!;
    
    if (selectedSortOption.value == SortOption.highestAmount) {
      // Highest Amount First
      monthTransactions.sort((a, b) => b.amount.compareTo(a.amount));
    } else {
      // Most Recent First (Date Descending)
      monthTransactions.sort((a, b) => b.date.compareTo(a.date));
    }
  }
}
```

### Sorting Behavior

#### Option 1: Most Recent (Default)
- **Hierarchy**: Year (desc) → Month (desc) → Date (desc)
- **Example**:
  ```
  2024
    December
      Dec 25, 2024 - Transaction A
      Dec 20, 2024 - Transaction B
      Dec 15, 2024 - Transaction C
    November
      Nov 30, 2024 - Transaction D
  ```

#### Option 2: Highest Amount
- **Hierarchy**: Year (desc) → Month (desc) → Amount (desc)
- **Example**:
  ```
  2024
    December
      $500.00 - Transaction B (Dec 20)
      $300.00 - Transaction A (Dec 25)
      $100.00 - Transaction C (Dec 15)
    November
      $450.00 - Transaction D (Nov 30)
  ```

## Integration Points

### Home Screen
**Location**: `lib/screens/home/home_screen.dart` (lines 384-394)

```dart
InkWell(
  onTap: () async {
    await TopSortSheet.show(
      context: context,
      title: 'Sorting',
      selectedOption: controller.selectedSortOption.value,
      onOptionSelected: (result) {
        controller.updateSortOption(result);
      },
    );
  },
  child: Image.asset(AppIcons.sort, height: 24.r, width: 24.r),
)
```

### Trades Section
**Location**: `lib/widgets/trades/trades_section.dart` (lines 69-80)
- Similar implementation but with TODO comment for applying sorting logic
- Currently displays the sheet but doesn't apply sorting to trades

## Helper Methods (TransactionHelper)

### Location
`lib/models/transaction_model.dart` (lines 255-281)

### Available Sorting Methods
```dart
// Date sorting
static List<Transaction> sortByDateDesc(List<Transaction> transactions)
static List<Transaction> sortByDateAsc(List<Transaction> transactions)

// Amount sorting  
static List<Transaction> sortByAmountDesc(List<Transaction> transactions)
static List<Transaction> sortByAmountAsc(List<Transaction> transactions)
```

These are utility methods but NOT currently used by the main sorting logic. The sorting is done inline in the controller.

## Data Flow

1. **User Action**: Taps sort icon → Opens TopSortSheet
2. **Selection**: User selects sort option → Calls `onOptionSelected` callback
3. **Controller Update**: `updateSortOption()` updates `selectedSortOption.value`
4. **Reactive Trigger**: GetX `debounce` detects change after 50ms
5. **Rebuild**: `_rebuildCacheAndItems()` is called
6. **Re-sort**: Transactions within each month are re-sorted
7. **UI Update**: `_updateVisibleItems()` flattens data for display
8. **Render**: UI automatically updates via Obx observers

## Performance Considerations

- **Debouncing**: 50ms delay prevents excessive re-sorting
- **In-place Sorting**: Sorts existing cached data, doesn't reload from database
- **Scope**: Only sorts transactions within each month, not across months
- **Efficiency**: O(n log n) per month, where n = transactions in that month

## UI Display Logic

### Option Ordering in Popup
The popup uses a clever UX pattern: **selected option always appears at the bottom**.

**Enum Definition Order**:
```dart
enum SortOption {
  highestAmount,  // Index 0
  mostRecent      // Index 1
}
```

**Display Logic** (`_getSortedOptions()`):
```dart
final options = List<SortOption>.from(SortOption.values);
options.remove(_selectedOption);  // Remove selected
options.add(_selectedOption);     // Add to end
```

**Visual Examples**:

When "Most Recent" is selected (default):
```
┌─────────────────────────────┐
│  💰 highest amount     top  │ ← White background, blue "top"
├─────────────────────────────┤
│  🕐 most recent        top  │ ← Blue background, yellow "top" (SELECTED)
└─────────────────────────────┘
```

When "Highest Amount" is selected:
```
┌─────────────────────────────┐
│  🕐 most recent        top  │ ← White background, blue "top"
├─────────────────────────────┤
│  💰 highest amount     top  │ ← Blue background, yellow "top" (SELECTED)
└─────────────────────────────┘
```

### Why This Pattern?
- **Visual Emphasis**: Selected option gets prominent bottom position
- **Consistency**: User always knows where to find their current selection
- **Animation**: Smooth transition when options swap positions

## Verification & Testing

### How to Test Sorting

1. **Open Home Screen** → Tap sort icon (filter icon with lines)
2. **Select "highest amount"**:
   - Verify transactions within each month are sorted by amount (largest first)
   - Verify year/month hierarchy remains unchanged
3. **Select "most recent"**:
   - Verify transactions within each month are sorted by date (newest first)
   - Verify year/month hierarchy remains unchanged

### Expected Behavior Checklist
- ✅ Sort icon opens TopSortSheet with slide-down animation
- ✅ Currently selected option appears at bottom with blue background
- ✅ Tapping an option updates selection immediately
- ✅ Options swap positions with smooth animation
- ✅ Transactions re-sort within 50ms (debounced)
- ✅ Year/month headers remain in descending order
- ✅ Sorting persists during session (not across app restarts)
- ✅ Sorting works with filtered data

## Edge Cases & Handling

### Empty Data
- **No transactions**: Sort sheet still opens and works
- **Empty month**: No transactions to sort, no errors
- **Single transaction**: Sorting works (trivial case)

### Equal Values
- **Same amount**: When sorting by amount, transactions with equal amounts maintain their relative order (stable sort)
- **Same date**: When sorting by date, transactions with same date maintain their relative order

### Data Integrity
- **Null safety**: All transaction lists are non-null (empty lists used instead)
- **Missing dates**: All transactions must have valid dates (enforced by model)
- **Negative amounts**: Handled correctly (larger negative = smaller value)

### Performance
- **Large datasets**: Sorting is O(n log n) per month, efficient even with 1000+ transactions
- **Rapid changes**: Debouncing prevents excessive re-sorting
- **Memory**: In-place sorting on cached data, no duplication

## Known Issues & Limitations

1. **No Persistence**: Sort preference resets to "most recent" on app restart
2. **Trades Section**: Has UI but sorting logic not implemented (TODO comment)
3. **No Ascending Options**: Only descending sorts available
4. **Month Scope**: Cannot sort across months (by design)
5. **Stable Sort**: Dart's sort is not guaranteed to be stable, but in practice it is

## Future Enhancements

1. **Trades Sorting**: Implement sorting logic for trades section
2. **Additional Options**: Add ascending variants (lowest amount, oldest first)
3. **Persistence**: Save sort preference to SharedPreferences
4. **Cross-Month Sorting**: Option to sort all transactions globally
5. **Custom Sorting**: Allow sorting by hashtag, MCC, or description
6. **Sort Indicators**: Show sort direction arrows in UI

---

## Quick Reference

### Files Modified for Sorting Feature
- `lib/widgets/transactions/top_sort_sheet.dart` - UI component
- `lib/controllers/home_controller.dart` - Sorting logic
- `lib/screens/home/home_screen.dart` - Integration point

### Key Classes & Enums
- `SortOption` enum - Defines available sort options
- `TopSortSheet` widget - Popup UI for selecting sort option
- `HomeController` - Contains sorting logic in `_rebuildCacheAndItems()`

### Important Methods
- `TopSortSheet.show()` - Display sort popup
- `updateSortOption(SortOption)` - Update sort preference
- `_rebuildCacheAndItems()` - Apply sorting to cached data
- `_getSortedOptions()` - Reorder options for display

### Default Values
- Default sort: `SortOption.mostRecent`
- Debounce delay: 50ms
- Sort scope: Within each month only

### Testing Commands
```dart
// To test sorting programmatically:
final controller = Get.find<HomeController>();
controller.updateSortOption(SortOption.highestAmount);
// Wait 50ms for debounce
await Future.delayed(Duration(milliseconds: 100));
// Verify transactions are sorted by amount
```

---

**Last Updated**: 2026-01-17
**Version**: 1.0
**Status**: ✅ Verified and Documented

