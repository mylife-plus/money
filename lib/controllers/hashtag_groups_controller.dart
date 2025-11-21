import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/hashtag_group_model.dart';
import '../services/hashtag_group_service.dart';

class HashtagGroupsController extends GetxController {
  final HashtagGroupService _hashtagGroupService = HashtagGroupService();

  final TextEditingController editController = TextEditingController();
  final RxBool isEditing = false.obs;
  final RxString editingItem = ''.obs;
  final RxString originalItem = ''.obs;

  // Hashtag groups data
  final RxList<HashtagGroup> _allGroups = <HashtagGroup>[].obs;
  final RxList<HashtagGroup> _selectedGroups = <HashtagGroup>[].obs;
  final RxBool isLoading = false.obs;

  // UI state management
  final RxMap<int, bool> expandedGroups = <int, bool>{}.obs;
  final RxMap<int, bool> addingToGroup = <int, bool>{}.obs;
  final RxMap<int, bool> editingGroup = <int, bool>{}.obs;
  final RxMap<int, bool> pendingAddingMode = <int, bool>{}.obs;
  final RxBool addingMainGroup = false.obs;

  // Controllers map for inline editing
  final RxMap<int, TextEditingController> inlineNameControllers =
      <int, TextEditingController>{}.obs;
  final RxMap<int, TextEditingController> editNameControllers =
      <int, TextEditingController>{}.obs;
  final RxMap<int, ExpansionTileController> expansionControllers =
      <int, ExpansionTileController>{}.obs;

  // Legacy sport hashtags for backward compatibility
  final RxList<String> sportHashtags = <String>[
    'football',
    'basketball',
    'tennis',
    'swimming',
    'running',
    'cycling',
  ].obs;

  // Getters
  List<HashtagGroup> get allGroups => _allGroups;
  List<HashtagGroup> get selectedGroups => _selectedGroups;

  // Setters for updating groups
  set allGroups(List<HashtagGroup> groups) => _allGroups.value = groups;
  set selectedGroups(List<HashtagGroup> groups) =>
      _selectedGroups.value = groups;

  @override
  void onInit() {
    super.onInit();
    ever(isEditing, (editing) {
      if (editing) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          editController.text = editingItem.value;
          editController.selection = TextSelection.fromPosition(
            TextPosition(offset: editController.text.length),
          );
        });
      }
    });

    // Load hashtag groups
    loadHashtagGroups();
  }

  /// Load all hashtag groups from database
  Future<void> loadHashtagGroups() async {
    try {
      isLoading.value = true;
      debugPrint(
        '[HashtagGroupsController][loadHashtagGroups] Loading groups from database',
      );

      final groups = await _hashtagGroupService.getAllGroupsHierarchical();
      _allGroups.assignAll(groups);

      debugPrint(
        '[HashtagGroupsController][loadHashtagGroups] Loaded ${groups.length} groups',
      );
    } catch (e) {
      debugPrint(
        '[HashtagGroupsController][loadHashtagGroups] Error loading groups: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh hashtag groups from database
  Future<void> refreshGroups() async {
    try {
      debugPrint('[HashtagGroupsController][refreshGroups] Refreshing groups');
      clearAllControllers();
      await loadHashtagGroups();
      debugPrint('[HashtagGroupsController][refreshGroups] Refresh completed');
    } catch (e) {
      debugPrint('[HashtagGroupsController][refreshGroups] Error: $e');
    }
  }

  /// Add a new custom hashtag group
  Future<bool> addCustomGroup(String name, {int? parentId}) async {
    try {
      debugPrint(
        '[HashtagGroupsController][addCustomGroup] Adding group: $name, parentId: $parentId',
      );

      final newGroup = await _hashtagGroupService.addCustomGroup(
        name,
        parentId: parentId,
      );

      if (newGroup != null) {
        await loadHashtagGroups(); // Reload to reflect changes
        debugPrint(
          '[HashtagGroupsController][addCustomGroup] Successfully added group with ID: ${newGroup.id}',
        );
        return true;
      } else {
        debugPrint(
          '[HashtagGroupsController][addCustomGroup] Failed to add group',
        );
        return false;
      }
    } catch (e) {
      debugPrint('[HashtagGroupsController][addCustomGroup] Error: $e');
      return false;
    }
  }

  /// Update an existing hashtag group
  Future<bool> updateGroup(int groupId, String name) async {
    try {
      debugPrint(
        '[HashtagGroupsController][updateGroup] Updating group ID: $groupId, name: $name',
      );

      final success = await _hashtagGroupService.updateGroup(groupId, name);

      if (success) {
        await loadHashtagGroups(); // Reload to reflect changes
        debugPrint(
          '[HashtagGroupsController][updateGroup] Successfully updated group',
        );
        return true;
      } else {
        debugPrint(
          '[HashtagGroupsController][updateGroup] Failed to update group',
        );
        return false;
      }
    } catch (e) {
      debugPrint('[HashtagGroupsController][updateGroup] Error: $e');
      return false;
    }
  }

  /// Delete a hashtag group
  /// Returns: true if deleted, false if failed, null if has memories (cannot delete)
  Future<bool?> deleteGroup(int groupId) async {
    try {
      debugPrint(
        '[HashtagGroupsController][deleteGroup] Deleting group ID: $groupId',
      );

      final result = await _hashtagGroupService.deleteGroup(groupId);

      if (result == true) {
        await loadHashtagGroups(); // Reload to reflect changes
        debugPrint(
          '[HashtagGroupsController][deleteGroup] Successfully deleted group',
        );
        return true;
      } else if (result == null) {
        debugPrint(
          '[HashtagGroupsController][deleteGroup] Cannot delete group - has associated memories',
        );
        return null; // Cannot delete due to memories
      } else {
        debugPrint(
          '[HashtagGroupsController][deleteGroup] Failed to delete group',
        );
        return false;
      }
    } catch (e) {
      debugPrint('[HashtagGroupsController][deleteGroup] Error: $e');
      return false;
    }
  }

  /// Get main groups only
  List<HashtagGroup> getMainGroups() {
    return _allGroups.where((group) => group.isMainGroup).toList();
  }

  /// Get subgroups for a specific main group
  List<HashtagGroup> getSubgroups(int mainGroupId) {
    final mainGroup = _allGroups.firstWhereOrNull(
      (group) => group.id == mainGroupId,
    );
    return mainGroup?.subgroups ?? [];
  }

  /// Find group by ID
  HashtagGroup? findGroupById(int groupId) {
    // Check main groups
    for (final mainGroup in _allGroups) {
      if (mainGroup.id == groupId) return mainGroup;

      // Check subgroups
      if (mainGroup.subgroups != null) {
        for (final subgroup in mainGroup.subgroups!) {
          if (subgroup.id == groupId) return subgroup;
        }
      }
    }
    return null;
  }

  /// Set selected groups
  void setSelectedGroups(List<HashtagGroup> groups) {
    _selectedGroups.assignAll(groups);
  }

  /// Add group to selection
  void addToSelection(HashtagGroup group) {
    if (!_selectedGroups.any((g) => g.id == group.id)) {
      _selectedGroups.add(group);
    }
  }

  /// Remove group from selection
  void removeFromSelection(HashtagGroup group) {
    _selectedGroups.removeWhere((g) => g.id == group.id);
  }

  /// Clear selection
  void clearSelection() {
    _selectedGroups.clear();
  }

  /// Clear all controllers and state
  void clearAllControllers() {
    // Dispose inline controllers
    for (final controller in inlineNameControllers.values) {
      try {
        controller.dispose();
      } catch (e) {
        debugPrint(
          '[HashtagGroupsController] Error disposing inline controller: $e',
        );
      }
    }
    inlineNameControllers.clear();

    // Dispose edit controllers
    for (final controller in editNameControllers.values) {
      try {
        controller.dispose();
      } catch (e) {
        debugPrint(
          '[HashtagGroupsController] Error disposing edit controller: $e',
        );
      }
    }
    editNameControllers.clear();

    // Clear other state
    expansionControllers.clear();
    expandedGroups.clear();
    addingToGroup.clear();
    pendingAddingMode.clear();
    editingGroup.clear();
  }

  /// Enable adding mode for a group
  void enableAddingMode(int groupId) {
    addingToGroup[groupId] = true;
    inlineNameControllers[groupId] = TextEditingController();
  }

  /// Cancel inline adding
  void cancelInlineAdding(int groupId) {
    addingToGroup[groupId] = false;
    inlineNameControllers[groupId]?.dispose();
    inlineNameControllers.remove(groupId);
  }

  /// Start inline editing
  void startInlineEditing(int groupId, String currentName) {
    editingGroup[groupId] = true;
    editNameControllers[groupId] = TextEditingController(text: currentName);
  }

  /// Cancel inline editing
  void cancelInlineEditing(int groupId) {
    editingGroup[groupId] = false;
    editNameControllers[groupId]?.dispose();
    editNameControllers.remove(groupId);
  }

  /// Toggle hashtag group selection for multiple selection mode
  void toggleGroupSelection(
    HashtagGroup hashtagGroup,
    List<HashtagGroup> currentSelection,
  ) {
    debugPrint(
      '[HashtagGroupsController][toggleGroupSelection] Toggling: ${hashtagGroup.name}',
    );

    bool isSelected;
    if (hashtagGroup.isMainGroup && hashtagGroup.hasSubgroups) {
      isSelected = hashtagGroup.subgroups!.every(
        (subgroup) => currentSelection.any((g) => g.id == subgroup.id),
      );
    } else {
      isSelected = currentSelection.any((g) => g.id == hashtagGroup.id);
    }

    if (isSelected) {
      // Deselect
      if (hashtagGroup.isMainGroup && hashtagGroup.hasSubgroups) {
        for (final subgroup in hashtagGroup.subgroups!) {
          removeFromSelection(subgroup);
        }
      } else {
        removeFromSelection(hashtagGroup);
      }
    } else {
      // Select
      if (hashtagGroup.isMainGroup && hashtagGroup.hasSubgroups) {
        for (final subgroup in hashtagGroup.subgroups!) {
          addToSelection(subgroup);
        }
      } else {
        addToSelection(hashtagGroup);
      }
    }
  }

  void startEditing(String item) {
    originalItem.value = item;
    editingItem.value = item;
    isEditing.value = true;
  }

  void cancelEditing() {
    isEditing.value = false;
    editingItem.value = '';
    originalItem.value = '';
  }

  void saveEditedItem(String newValue) {
    if (newValue.trim().isNotEmpty) {
      final oldItem = originalItem.value;
      final index = sportHashtags.indexOf(oldItem);
      if (index != -1) {
        sportHashtags[index] = newValue.trim();
      }
    }
    cancelEditing();
  }

  @override
  void onClose() {
    editController.dispose();
    clearAllControllers();
    super.onClose();
  }
}
