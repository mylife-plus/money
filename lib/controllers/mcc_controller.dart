import 'package:get/get.dart';
import 'package:moneyapp/constants/mcc_data.dart';
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

  /// Load MCC data from constants
  void _loadSampleData() {
    // Load categories from constant data
    categories.value = MCCData.getCategories();

    // Load MCC items from constant data
    mccItems.value = MCCData.getMCCItems();
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
