import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/models/mcc_model.dart';

/// MCC Controller
/// Manages MCC categories and items
class MCCController extends GetxController {
  // Observable lists
  final RxList<MCCCategory> categories = <MCCCategory>[].obs;
  final RxList<MCCItem> mccItems = <MCCItem>[].obs;

  // Selected MCC
  final Rx<MCCItem?> selectedMCC = Rx<MCCItem?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadSampleData();
  }

  /// Load sample MCC data
  void _loadSampleData() {
    // Sample categories
    categories.value = [
      MCCCategory(id: 1, name: 'Food & Dining', iconPath: AppIcons.cart),
      MCCCategory(id: 2, name: 'Transportation', iconPath: AppIcons.car),
      MCCCategory(id: 3, name: 'Shopping', iconPath: AppIcons.cart),
      MCCCategory(id: 4, name: 'Entertainment', iconPath: AppIcons.investment),
      MCCCategory(id: 5, name: 'Bills & Utilities', iconPath: AppIcons.file),
      MCCCategory(id: 6, name: 'Healthcare', iconPath: AppIcons.security),
      MCCCategory(id: 7, name: 'Travel', iconPath: AppIcons.car),
      MCCCategory(id: 8, name: 'Education', iconPath: AppIcons.file),
    ];

    // Sample MCC items
    mccItems.value = [
      // Food & Dining
      MCCItem(
        id: 1,
        name: 'Restaurants',
        iconPath: AppIcons.cart,
        categoryId: 1,
        categoryName: 'Food & Dining',
      ),
      MCCItem(
        id: 2,
        name: 'Fast Food',
        iconPath: AppIcons.cart,
        categoryId: 1,
        categoryName: 'Food & Dining',
      ),
      MCCItem(
        id: 3,
        name: 'Cafes',
        iconPath: AppIcons.cart,
        categoryId: 1,
        categoryName: 'Food & Dining',
      ),
      MCCItem(
        id: 4,
        name: 'Grocery Stores',
        iconPath: AppIcons.cart,
        categoryId: 1,
        categoryName: 'Food & Dining',
      ),

      // Transportation
      MCCItem(
        id: 5,
        name: 'Gas Stations',
        iconPath: AppIcons.car,
        categoryId: 2,
        categoryName: 'Transportation',
      ),
      MCCItem(
        id: 6,
        name: 'Public Transport',
        iconPath: AppIcons.car,
        categoryId: 2,
        categoryName: 'Transportation',
      ),
      MCCItem(
        id: 7,
        name: 'Taxi & Rideshare',
        iconPath: AppIcons.car,
        categoryId: 2,
        categoryName: 'Transportation',
      ),
      MCCItem(
        id: 8,
        name: 'Parking',
        iconPath: AppIcons.car,
        categoryId: 2,
        categoryName: 'Transportation',
      ),

      // Shopping
      MCCItem(
        id: 9,
        name: 'Clothing',
        iconPath: AppIcons.cart,
        categoryId: 3,
        categoryName: 'Shopping',
      ),
      MCCItem(
        id: 10,
        name: 'Electronics',
        iconPath: AppIcons.digitalCurrency,
        categoryId: 3,
        categoryName: 'Shopping',
      ),
      MCCItem(
        id: 11,
        name: 'Home & Garden',
        iconPath: AppIcons.cart,
        categoryId: 3,
        categoryName: 'Shopping',
      ),
      MCCItem(
        id: 12,
        name: 'Online Shopping',
        iconPath: AppIcons.cart,
        categoryId: 3,
        categoryName: 'Shopping',
      ),

      // Entertainment
      MCCItem(
        id: 13,
        name: 'Movies & Cinema',
        iconPath: AppIcons.investment,
        categoryId: 4,
        categoryName: 'Entertainment',
      ),
      MCCItem(
        id: 14,
        name: 'Sports & Fitness',
        iconPath: AppIcons.investment,
        categoryId: 4,
        categoryName: 'Entertainment',
      ),
      MCCItem(
        id: 15,
        name: 'Music & Concerts',
        iconPath: AppIcons.investment,
        categoryId: 4,
        categoryName: 'Entertainment',
      ),

      // Bills & Utilities
      MCCItem(
        id: 16,
        name: 'Electricity',
        iconPath: AppIcons.file,
        categoryId: 5,
        categoryName: 'Bills & Utilities',
      ),
      MCCItem(
        id: 17,
        name: 'Water',
        iconPath: AppIcons.file,
        categoryId: 5,
        categoryName: 'Bills & Utilities',
      ),
      MCCItem(
        id: 18,
        name: 'Internet',
        iconPath: AppIcons.file,
        categoryId: 5,
        categoryName: 'Bills & Utilities',
      ),
      MCCItem(
        id: 19,
        name: 'Phone',
        iconPath: AppIcons.file,
        categoryId: 5,
        categoryName: 'Bills & Utilities',
      ),

      // Healthcare
      MCCItem(
        id: 20,
        name: 'Doctor Visits',
        iconPath: AppIcons.security,
        categoryId: 6,
        categoryName: 'Healthcare',
      ),
      MCCItem(
        id: 21,
        name: 'Pharmacy',
        iconPath: AppIcons.security,
        categoryId: 6,
        categoryName: 'Healthcare',
      ),
      MCCItem(
        id: 22,
        name: 'Dental',
        iconPath: AppIcons.security,
        categoryId: 6,
        categoryName: 'Healthcare',
      ),

      // Travel
      MCCItem(
        id: 23,
        name: 'Hotels',
        iconPath: AppIcons.car,
        categoryId: 7,
        categoryName: 'Travel',
      ),
      MCCItem(
        id: 24,
        name: 'Airlines',
        iconPath: AppIcons.car,
        categoryId: 7,
        categoryName: 'Travel',
      ),
      MCCItem(
        id: 25,
        name: 'Travel Agencies',
        iconPath: AppIcons.car,
        categoryId: 7,
        categoryName: 'Travel',
      ),

      // Education
      MCCItem(
        id: 26,
        name: 'Tuition',
        iconPath: AppIcons.file,
        categoryId: 8,
        categoryName: 'Education',
      ),
      MCCItem(
        id: 27,
        name: 'Books & Supplies',
        iconPath: AppIcons.file,
        categoryId: 8,
        categoryName: 'Education',
      ),
      MCCItem(
        id: 28,
        name: 'Online Courses',
        iconPath: AppIcons.file,
        categoryId: 8,
        categoryName: 'Education',
      ),
    ];
  }

  /// Add new category
  void addCategory(MCCCategory category) {
    final newId = categories.isEmpty
        ? 1
        : categories.map((c) => c.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    categories.add(category.copyWith(id: newId));
  }

  /// Add new MCC item
  void addMCCItem(MCCItem mccItem) {
    final newId = mccItems.isEmpty
        ? 1
        : mccItems.map((m) => m.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    mccItems.add(mccItem.copyWith(id: newId));
  }

  /// Update category
  void updateCategory(MCCCategory category) {
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
    }
  }

  /// Update MCC item
  void updateMCCItem(MCCItem mccItem) {
    final index = mccItems.indexWhere((m) => m.id == mccItem.id);
    if (index != -1) {
      mccItems[index] = mccItem;
    }
  }

  /// Delete category
  void deleteCategory(int categoryId) {
    categories.removeWhere((c) => c.id == categoryId);
    // Also delete all MCC items in this category
    mccItems.removeWhere((m) => m.categoryId == categoryId);
  }

  /// Delete MCC item
  void deleteMCCItem(int mccId) {
    mccItems.removeWhere((m) => m.id == mccId);
  }

  /// Get MCCs by category
  List<MCCItem> getMCCsByCategory(int categoryId) {
    return MCCHelper.filterByCategory(mccItems, categoryId);
  }

  /// Search MCCs
  List<MCCItem> searchMCCs(String query) {
    return MCCHelper.searchByName(mccItems, query);
  }

  /// Get category by ID
  MCCCategory? getCategoryById(int categoryId) {
    try {
      return categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Get MCC by ID
  MCCItem? getMCCById(int mccId) {
    try {
      return mccItems.firstWhere((m) => m.id == mccId);
    } catch (e) {
      return null;
    }
  }

  /// Select MCC
  void selectMCC(MCCItem? mcc) {
    selectedMCC.value = mcc;
  }
}
