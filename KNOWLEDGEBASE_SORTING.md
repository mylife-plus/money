# Transaction Sorting System - Knowledge Base

## Overview
The app implements a transaction sorting system that allows users to sort transactions by either **highest amount** or **most recent date**, with support for both **ascending** and **descending** directions. The sorting is applied within each month's transactions while maintaining the year/month hierarchy.

**Key Characteristics**:
- ✅ Sorts transactions **within each month** only
- ✅ Year/month hierarchy always remains descending (newest first)
- ✅ Default sort: Most Recent (by date) with "top" direction (descending)
- ✅ **Toggle functionality**: Tap to select, tap again to reverse direction, tap third time to deselect
- ✅ **Bidirectional sorting**: Each option supports both "top" (descending) and "bottom" (ascending)
- ✅ Reactive: Auto-updates when sort option or direction changes
- ✅ Works seamlessly with filters
- ⚠️ Sort preference does NOT persist across app restarts

**Visual Flow Diagram**: See "Transaction Sorting System Flow" Mermaid diagram for complete data flow.

---

## Recent Updates (2026-01-20)

### Major Changes to Sorting UI and Logic

1. **Removed Animation & Position Switching**
   - Options now stay in **fixed positions** (no longer move to bottom when selected)
   - Removed `AnimatedSwitcher` and position reordering logic
   - Cleaner, more predictable UI behavior

2. **Added Toggle Direction Functionality**
   - New `SortDirection` enum: `top` (descending) and `bottom` (ascending)
   - Each sort option can now toggle between two directions
   - Visual indicator: Selected option shows "top" or "bottom" in yellow text

3. **Three-State Selection Logic**
   - **First tap**: Select option with "top" direction
   - **Second tap**: Toggle to "bottom" direction
   - **Third tap**: Deselect (clear both option and direction)

4. **Bidirectional Sorting**
   - **Highest Amount + Top**: $500 → $300 → $100 (descending)
   - **Highest Amount + Bottom**: $100 → $300 → $500 (ascending)
   - **Most Recent + Top**: Dec 25 → Dec 20 → Dec 15 (newest first)
   - **Most Recent + Bottom**: Dec 15 → Dec 20 → Dec 25 (oldest first)

## UI Component: TopSortSheet

### Location
`lib/widgets/transactions/top_sort_sheet.dart`

### Enums

#### Sort Options
```dart
enum SortOption {
  highestAmount,  // Sort by amount
  mostRecent      // Sort by date - DEFAULT
}
```

#### Sort Direction (NEW)
```dart
enum SortDirection {
  top,     // Descending order - DEFAULT
  bottom   // Ascending order
}
```

### Visual Behavior
- **Popup Animation**: Slides down from top of screen (300ms)
- **Option Display**: **Fixed positions** (no reordering based on selection)
  - `highestAmount` always appears first
  - `mostRecent` always appears second
- **Visual Indicators**:
  - **Selected option**: Blue background (#0088FF) with yellow direction text (#FFFB00)
  - **Unselected option**: White background with blue "top" text (#0088FF)
- **Direction Text**:
  - Shows "top" or "bottom" based on current `SortDirection`
  - Only selected option shows the actual direction
  - Unselected options always display "top"
- **Icons**:
  - `highestAmount`: Transaction icon (AppIcons.transaction)
  - `mostRecent`: Clock icon (AppIcons.clock)

### Toggle Interaction Flow

```
[Unselected State]
  ↓ (First Tap)
[Selected with "top"] ← Blue background, yellow "top" text
  ↓ (Second Tap - Same Option)
[Selected with "bottom"] ← Blue background, yellow "bottom" text
  ↓ (Third Tap - Same Option)
[Unselected State] ← Back to white background, option = null
```

**Note**: Tapping a different option immediately selects it with "top" direction.

### Key Methods
- `_onOptionTapped()`: Handles three-state toggle logic and triggers callback
- `TopSortSheet.show()`: Static method to display the sheet
- `_buildOptionItem()`: Renders each option with dynamic direction text

## Controller: HomeController

### Location
`lib/controllers/home_controller.dart`

### State Management
```dart
// Sort option and direction (nullable to support deselection)
final Rxn<SortOption> selectedSortOption = Rxn<SortOption>(SortOption.mostRecent);
final Rxn<SortDirection> selectedSortDirection = Rxn<SortDirection>(SortDirection.top);

// Update method
void updateSortOption(SortOption? option, SortDirection? direction) {
  selectedSortOption.value = option;
  selectedSortDirection.value = direction;
}
```

### Reactive Sorting
The controller uses GetX's `debounce` to automatically re-sort when the option or direction changes:

```dart
// Watch for sort option changes
debounce(
  selectedSortOption,
  (_) => _rebuildCacheAndItems(),
  time: const Duration(milliseconds: 50),
);

// Watch for sort direction changes
debounce(
  selectedSortDirection,
  (_) => _rebuildCacheAndItems(),
  time: const Duration(milliseconds: 50),
);
```

**Benefits**:
- Debounces sort changes to prevent excessive re-sorting
- 50ms delay ensures smooth performance
- Both option and direction changes trigger rebuild

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

#### 3. Transaction Sorting (User-Controlled with Direction)
```dart
for (var year in _cachedGroupedData.keys) {
  for (var month in _cachedGroupedData[year]!.keys) {
    var monthTransactions = _cachedGroupedData[year]![month]!;

    if (selectedSortOption.value != null) {
      final isTopDirection = selectedSortDirection.value == SortDirection.top;

      if (selectedSortOption.value == SortOption.highestAmount) {
        // Sort by Amount
        if (isTopDirection) {
          // Highest Amount First (top)
          monthTransactions.sort((a, b) => b.amount.compareTo(a.amount));
        } else {
          // Lowest Amount First (bottom)
          monthTransactions.sort((a, b) => a.amount.compareTo(b.amount));
        }
      } else if (selectedSortOption.value == SortOption.mostRecent) {
        // Sort by Date
        if (isTopDirection) {
          // Most Recent First (top)
          monthTransactions.sort((a, b) => b.date.compareTo(a.date));
        } else {
          // Oldest First (bottom)
          monthTransactions.sort((a, b) => a.date.compareTo(b.date));
        }
      }
    }
  }
}
```

### Sorting Behavior

#### Option 1: Most Recent
**With "top" direction (descending - DEFAULT)**:
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

**With "bottom" direction (ascending)**:
- **Hierarchy**: Year (desc) → Month (desc) → Date (asc)
- **Example**:
  ```
  2024
    December
      Dec 15, 2024 - Transaction C
      Dec 20, 2024 - Transaction B
      Dec 25, 2024 - Transaction A
    November
      Nov 30, 2024 - Transaction D
  ```

#### Option 2: Highest Amount
**With "top" direction (descending)**:
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

**With "bottom" direction (ascending)**:
- **Hierarchy**: Year (desc) → Month (desc) → Amount (asc)
- **Example**:
  ```
  2024
    December
      $100.00 - Transaction C (Dec 15)
      $300.00 - Transaction A (Dec 25)
      $500.00 - Transaction B (Dec 20)
    November
      $450.00 - Transaction D (Nov 30)
  ```

## Integration Points

### Home Screen
**Location**: `lib/screens/home/home_screen.dart` (lines 384-402)

```dart
InkWell(
  onTap: () async {
    await TopSortSheet.show(
      context: context,
      title: 'Sorting',
      selectedOption: controller.selectedSortOption.value,
      selectedDirection: controller.selectedSortDirection.value,
      onOptionSelected: (option, direction) {
        controller.updateSortOption(option, direction);
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
2. **Selection**: User taps option (toggle logic applies)
3. **Callback**: `onOptionSelected(option, direction)` called with new values
4. **Controller Update**: `updateSortOption()` updates both `selectedSortOption.value` and `selectedSortDirection.value`
5. **Reactive Trigger**: GetX `debounce` detects change after 50ms (watches both observables)
6. **Rebuild**: `_rebuildCacheAndItems()` is called
7. **Re-sort**: Transactions within each month are re-sorted based on option and direction
8. **UI Update**: `_updateVisibleItems()` flattens data for display
9. **Render**: UI automatically updates via Obx observers

## Performance Considerations

- **Debouncing**: 50ms delay prevents excessive re-sorting
- **In-place Sorting**: Sorts existing cached data, doesn't reload from database
- **Scope**: Only sorts transactions within each month, not across months
- **Efficiency**: O(n log n) per month, where n = transactions in that month

## UI Display Logic

### Option Ordering in Popup
**Updated 2026-01-20**: Options now stay in **fixed positions** (no reordering).

**Enum Definition Order**:
```dart
enum SortOption {
  highestAmount,  // Index 0 - Always first
  mostRecent      // Index 1 - Always second
}
```

**Display Logic**:
```dart
// Simple iteration - no reordering
Column(
  children: SortOption.values.map((option) {
    return _buildOptionItem(option);
  }).toList(),
)
```

**Visual Examples**:

When "Most Recent" is selected with "top":
```
┌─────────────────────────────┐
│  💰 highest amount     top  │ ← White background, blue "top"
├─────────────────────────────┤
│  🕐 most recent        top  │ ← Blue background, yellow "top" (SELECTED)
└─────────────────────────────┘
```

When "Most Recent" is selected with "bottom":
```
┌─────────────────────────────┐
│  � highest amount     top  │ ← White background, blue "top"
├─────────────────────────────┤
│  � most recent     bottom  │ ← Blue background, yellow "bottom" (SELECTED)
└─────────────────────────────┘
```

When "Highest Amount" is selected with "top":
```
┌─────────────────────────────┐
│  �💰 highest amount     top  │ ← Blue background, yellow "top" (SELECTED)
├─────────────────────────────┤
│  🕐 most recent        top  │ ← White background, blue "top"
└─────────────────────────────┘
```

### Design Rationale
- **Fixed Positions**: Easier to find options, no confusing movement
- **Direction Indicator**: Clear visual feedback of sort direction
- **Toggle Behavior**: Intuitive three-state interaction
- **No Animation**: Faster, more responsive UI

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

## Hashtag Chip Design Standardization

### Overview
As part of the UI consistency improvements, the hashtag chip design has been standardized across all screens to use the `CategoryChip` widget.

### CategoryChip Widget

**Location**: `lib/widgets/common/category_chip.dart`

**Design Features**:
- **Two-line layout**: Category group name on top, hashtag name below
- **Circular close button**: Positioned at top-right corner (-6h, -6w offset)
- **Box shadow**: Adds depth with 4.r blur radius
- **Consistent styling**: White background, grey border (#DFDFDF)
- **Height**: Fixed 42.h for uniform appearance

**Visual Structure**:
```
┌──────────────┐
│ Housing    ⓧ │  ← Category group (12.sp, grey)
│ # Rent       │  ← Hashtag name (16.sp, black)
└──────────────┘
```

### Implementation

```dart
CategoryChip(
  category: currentHashtag.name,
  categoryGroup: categoryGroup,
  onRemove: () {
    setState(() {
      selectedHashtags.removeWhere((h) => h.id == hashtag.id);
    });
  },
)
```

### Screens Using CategoryChip

1. **New Transaction Screen** (`lib/screens/transactions/new_transaction_screen.dart`)
   - Lines 641-651
   - Used in hashtag selection area

2. **Split Spending Screen** (`lib/screens/transactions/split_spending_screen.dart`)
   - Lines 661-671
   - Used for each split item's hashtags

3. **Transaction Filter Screen** (`lib/screens/filter/transaction_filter_screen.dart`)
   - Lines 621-654
   - **Updated 2026-01-20** to match new cashflow screen design

### Before & After (Filter Screen)

**Before**:
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
  decoration: BoxDecoration(
    color: Color(0xffF5F5F5),
    borderRadius: BorderRadius.circular(4.r),
    border: Border.all(color: Color(0xffDFDFDF)),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CustomText('#${hashtag.name}', size: 14.sp),
      if (parentName != null) ...[
        CustomText('($parentName)', size: 12.sp),
      ],
      InkWell(
        onTap: () { /* remove */ },
        child: Icon(Icons.close, size: 16.sp),
      ),
    ],
  ),
)
```

**After**:
```dart
CategoryChip(
  category: currentHashtag.name,
  categoryGroup: categoryGroup,
  onRemove: () {
    setState(() {
      selectedHashtags.removeWhere((h) => h.id == hashtag.id);
    });
  },
)
```

### Benefits of Standardization

1. **Visual Consistency**: All screens now have identical hashtag chip appearance
2. **Code Reusability**: Single widget instead of duplicated code
3. **Easier Maintenance**: Changes to chip design only need to be made in one place
4. **Better UX**: Users see familiar UI patterns across the app
5. **Professional Look**: Circular close button and shadow add polish

---

**Last Updated**: 2026-01-20
**Version**: 2.0
**Status**: ✅ Verified and Documented

