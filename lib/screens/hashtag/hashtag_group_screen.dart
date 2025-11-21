import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/hashtag_groups_controller.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/services/hashtag_group_service.dart';
import 'package:moneyapp/services/hashtag_recent_service.dart';
import 'package:moneyapp/widgets/common/add_edit_group_popup.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/hashtag/hashtag_selection_indicator.dart';
import 'package:moneyapp/widgets/hashtag/inline_add_main_group_widget.dart';
import 'package:moneyapp/widgets/hashtag/inline_add_subgroup_widget.dart';
import 'package:moneyapp/widgets/hashtag/inline_edit_subgroup_widget.dart';
import 'package:moneyapp/widgets/hashtag/delete_hashtag_group_dialog.dart';
import 'package:moneyapp/widgets/hashtag/cannot_delete_hashtag_group_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HashtagGroupScreen extends StatefulWidget {
  final Function(HashtagGroup)? onHashtagGroupSelected;
  final HashtagGroup? selectedHashtagGroup;

  // Multiple selection mode parameters
  final bool allowMultipleSelection;
  final List<HashtagGroup>? selectedHashtagGroups;
  final Function(List<HashtagGroup>)? onMultipleHashtagGroupsSelected;

  const HashtagGroupScreen({
    super.key,
    this.onHashtagGroupSelected,
    this.selectedHashtagGroup,
    this.allowMultipleSelection = false,
    this.selectedHashtagGroups,
    this.onMultipleHashtagGroupsSelected,
  });

  @override
  State<HashtagGroupScreen> createState() => _HashtagGroupScreenState();
}

class _HashtagGroupScreenState extends State<HashtagGroupScreen> {
  final HashtagGroupService _hashtagGroupService = HashtagGroupService();
  late final HashtagGroupsController _controller;
  UiController uiController = Get.put<UiController>(UiController());

  // Keep only screen-specific state
  final TextEditingController _mainHashtagGroupNameController =
      TextEditingController();

  // Recently selected subgroups storage (max 6 items)
  static const String _recentSubgroupsKey = 'recent_subgroups';
  static const int _maxRecentItems = 6;

  // Global refresh notifier for external access
  final RxInt _globalRefreshNotifier = 0.obs;

  @override
  void initState() {
    super.initState();

    // Initialize or get controller
    if (Get.isRegistered<HashtagGroupsController>()) {
      _controller = Get.find<HashtagGroupsController>();
    } else {
      _controller = Get.put(HashtagGroupsController());
    }

    debugPrint(
      '[HashtagGroupsView][initState] HashtagGroupsView opened, initializing...',
    );
    debugPrint(
      '[HashtagGroupsView][initState] Multiple selection mode: ${widget.allowMultipleSelection}',
    );

    // Initialize selected hashtag groups for multiple selection mode
    if (widget.allowMultipleSelection && widget.selectedHashtagGroups != null) {
      _controller.setSelectedGroups(widget.selectedHashtagGroups!);
      debugPrint(
        '[HashtagGroupsView][initState] Initialized with ${_controller.selectedGroups.length} pre-selected hashtag groups',
      );
    }

    // Register global refresh notifier for external access
    try {
      Get.put(_globalRefreshNotifier, tag: 'hashtagGroupsRefresh');
      debugPrint(
        '[HashtagGroupsView][initState] Global refresh notifier registered',
      );
    } catch (e) {
      debugPrint(
        '[HashtagGroupsView][initState] Global refresh notifier already registered: $e',
      );
    }

    _controller.loadHashtagGroups();

    // Listen for global refresh triggers
    ever(_globalRefreshNotifier, (timestamp) {
      if (timestamp > 0) {
        debugPrint(
          '[HashtagGroupsView][initState] Global refresh triggered, refreshing hashtag groups...',
        );
        _controller.refreshGroups();
      }
    });

    debugPrint(
      '[HashtagGroupsView][initState] HashtagGroupsView initialization completed',
    );
  }

  @override
  void dispose() {
    _mainHashtagGroupNameController.dispose();

    // Clean up global refresh notifier
    try {
      Get.delete<RxInt>(tag: 'hashtagGroupsRefresh');
      debugPrint(
        '[HashtagGroupsView][dispose] Global refresh notifier cleaned up',
      );
    } catch (e) {
      debugPrint(
        '[HashtagGroupsView][dispose] Error cleaning up global refresh notifier: $e',
      );
    }

    super.dispose();
  }

  /// Refresh hashtag groups from database (used after CRUD operations)
  Future<void> _refreshHashtagGroupsFromDatabase() async {
    try {
      debugPrint(
        '[HashtagGroupsView][_refreshHashtagGroupsFromDatabase] ===== REFRESH STARTED =====',
      );

      // Clear all controllers and state before refreshing
      debugPrint(
        '[HashtagGroupsView][_refreshHashtagGroupsFromDatabase] 🧹 Clearing all controllers',
      );
      _clearAllControllers();

      debugPrint(
        '[HashtagGroupsView][_refreshHashtagGroupsFromDatabase] 🔄 Fetching hashtag groups from service',
      );
      final hashtagGroups = await _hashtagGroupService
          .getAllGroupsHierarchical();

      debugPrint(
        '[HashtagGroupsView][_refreshHashtagGroupsFromDatabase] Retrieved ${hashtagGroups.length} groups from service',
      );
      for (int i = 0; i < hashtagGroups.length; i++) {
        final group = hashtagGroups[i];
        debugPrint(
          '[HashtagGroupsView][_refreshHashtagGroupsFromDatabase] Group $i: ID=${group.id}, Name="${group.name}", Subgroups=${group.subgroups?.length ?? 0}',
        );
      }

      debugPrint(
        '[HashtagGroupsView][_refreshHashtagGroupsFromDatabase] 📝 Updating reactive list',
      );
      _controller.allGroups = hashtagGroups;

      debugPrint(
        '[HashtagGroupsView][_refreshHashtagGroupsFromDatabase] ✅ Successfully refreshed ${hashtagGroups.length} main hashtag groups',
      );
    } catch (e) {
      debugPrint(
        '[HashtagGroupsView][_refreshHashtagGroupsFromDatabase] ❌ Error refreshing hashtag groups: $e',
      );
      debugPrint(
        '[HashtagGroupsView][_refreshHashtagGroupsFromDatabase] Exception type: ${e.runtimeType}',
      );

      Get.snackbar(
        'Unable to Refresh',
        'Unable to refresh hashtag groups. Please try again.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
    debugPrint(
      '[HashtagGroupsView][_refreshHashtagGroupsFromDatabase] ===== REFRESH COMPLETED =====',
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(HashtagGroup hashtagGroup) {
    Get.dialog(
      DeleteHashtagGroupDialog(
        hashtagGroup: hashtagGroup,
        onConfirm: () => _deleteHashtagGroup(hashtagGroup.id!),
      ),
    );
  }

  /// Delete a hashtag group
  Future<void> _deleteHashtagGroup(int hashtagGroupId) async {
    try {
      debugPrint(
        '[HashtagGroupsView][_deleteHashtagGroup] Deleting hashtag group ID: $hashtagGroupId',
      );

      final result = await _hashtagGroupService.deleteGroup(hashtagGroupId);

      if (result == true) {
        // Successfully deleted
        Get.back(); // Close confirmation dialog

        // Remove from recent selections before refreshing
        final group = await _hashtagGroupService.getGroupById(hashtagGroupId);
        if (group != null) {
          if (group.parentId == null) {
            // Main group deleted - remove it and all its subgroups from recent selections
            final subgroups = await _hashtagGroupService.getSubgroups(
              hashtagGroupId,
            );
            await removeGroupAndSubgroupsFromRecent(hashtagGroupId, subgroups);

            // Also remove from searchable hashtag widget recent lists
            final subgroupIds = subgroups.map((s) => s.id!).toList();
            await HashtagRecentService()
                .removeGroupAndSubgroupsFromRecentHashtagGroups(
                  hashtagGroupId,
                  subgroupIds,
                );

            // Remove hashtag names from recent hashtags
            await HashtagRecentService().removeFromRecentHashtags(group.name);
            for (final subgroup in subgroups) {
              await HashtagRecentService().removeFromRecentHashtags(
                subgroup.name,
              );
            }
          } else {
            // Subgroup deleted - remove only this subgroup from recent selections
            await removeFromRecentlySelectedSubgroups(hashtagGroupId);

            // Also remove from searchable hashtag widget recent lists
            await HashtagRecentService().removeFromRecentHashtagGroups(
              hashtagGroupId,
            );
            await HashtagRecentService().removeFromRecentHashtags(group.name);
          }
        }

        // Refresh hashtag groups from database to show the deletion
        debugPrint(
          '[HashtagGroupsView][_deleteHashtagGroup] Refreshing hashtag groups from database after deletion',
        );
        await _refreshHashtagGroupsFromDatabase();

        Get.snackbar(
          'Success',
          'Hashtag group deleted successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (result == null) {
        // Cannot delete due to memories
        Get.back(); // Close confirmation dialog

        // Get the group name and memory count for the error dialog
        final group = await _hashtagGroupService.getGroupById(hashtagGroupId);
        final memoryCount = group != null
            ? await _hashtagGroupService.getMemoryCountForGroup(group.name)
            : 0;

        _showCannotDeleteDialog(group?.name ?? 'Unknown', memoryCount);
      } else {
        // Failed to delete
        Get.snackbar(
          'Unable to Delete',
          'Unable to delete hashtag group. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('[HashtagGroupsView][_deleteHashtagGroup] Error: $e');
      Get.snackbar(
        'Unable to Delete',
        'Unable to delete hashtag group. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Show dialog when hashtag group cannot be deleted due to existing memories
  void _showCannotDeleteDialog(String groupName, int memoryCount) {
    Get.dialog(
      CannotDeleteHashtagGroupDialog(
        groupName: groupName,
        memoryCount: memoryCount,
      ),
    );
  }

  /// Show edit hashtag group dialog using AddEditGroupPopup
  void _showEditHashtagGroupDialog(HashtagGroup hashtagGroup) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddEditGroupPopup(
          isHashtagMode: true,
          isMainGroup: hashtagGroup.parentId == null,
          initialName: hashtagGroup.name,
          editItemId: hashtagGroup.id,
          parentId: hashtagGroup.parentId,
          onSave: (newName, parentId) async {
            // Validate that name is provided
            if (newName.isEmpty) {
              Get.snackbar(
                'Validation Error',
                'Please enter a hashtag group name',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
              return;
            }

            if (newName == hashtagGroup.name) {
              // No changes, just close
              Navigator.of(context).pop();
              return;
            }

            try {
              final success = await _hashtagGroupService.updateGroup(
                hashtagGroup.id!,
                newName,
              );

              if (success) {
                Navigator.of(context).pop(); // Close dialog
                await _refreshHashtagGroupsFromDatabase();

                Get.snackbar(
                  'Success',
                  'Hashtag group "$newName" updated successfully!',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Unable to Update',
                  'Unable to update hashtag group. Please try again.',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            } catch (e) {
              debugPrint(
                '[HashtagGroupsView][EditDialog] Exception occurred: $e',
              );
              Get.snackbar(
                'Unable to Update',
                'Unable to update hashtag group. Please try again.',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
        );
      },
    );
  }

  /// Delete a subgroup (hashtag)
  Future<void> _deleteSubgroup(HashtagGroup subgroup) async {
    try {
      debugPrint(
        '[HashtagGroupsView][_deleteSubgroup] Deleting subgroup ID: ${subgroup.id}',
      );

      final result = await _hashtagGroupService.deleteGroup(subgroup.id!);

      if (result == true) {
        // Successfully deleted - also remove from recent selections
        await removeFromRecentlySelectedSubgroups(subgroup.id!);

        // Also remove from searchable hashtag widget recent lists
        await HashtagRecentService().removeFromRecentHashtagGroups(
          subgroup.id!,
        );
        await HashtagRecentService().removeFromRecentHashtags(subgroup.name);

        // Refresh hashtag groups from database to show the deletion
        debugPrint(
          '[HashtagGroupsView][_deleteSubgroup] Refreshing hashtag groups from database after deletion',
        );
        await _refreshHashtagGroupsFromDatabase();

        Get.snackbar(
          'Success',
          'Hashtag deleted successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (result == null) {
        // Cannot delete due to memories
        final memoryCount = await _hashtagGroupService.getMemoryCountForGroup(
          subgroup.name,
        );
        _showCannotDeleteDialog(subgroup.name, memoryCount);
      } else {
        // Failed to delete
        Get.snackbar(
          'Unable to Delete',
          'Unable to delete hashtag. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('[HashtagGroupsView][_deleteSubgroup] Error: $e');
      Get.snackbar(
        'Unable to Delete',
        'Unable to delete hashtag. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Clear all controllers and state to prevent disposed controller errors
  void _clearAllControllers() {
    // Dispose and clear inline name controllers
    for (final controller in _controller.inlineNameControllers.values) {
      try {
        controller.dispose();
      } catch (e) {
        debugPrint('[HashtagGroupsView] Error disposing inline controller: $e');
      }
    }
    _controller.inlineNameControllers.clear();

    // Dispose and clear edit name controllers
    for (final controller in _controller.editNameControllers.values) {
      try {
        controller.dispose();
      } catch (e) {
        debugPrint('[HashtagGroupsView] Error disposing edit controller: $e');
      }
    }
    _controller.editNameControllers.clear();

    // Clear expansion controllers (don't dispose as they're managed by ExpansionTile)
    _controller.expansionControllers.clear();

    // Clear all state maps
    _controller.expandedGroups.clear();
    _controller.addingToGroup.clear();
    _controller.pendingAddingMode.clear();
    _controller.editingGroup.clear();
  }

  /// Select a hashtag group and return to parent
  void _selectHashtagGroup(HashtagGroup hashtagGroup) {
    debugPrint(
      '[HashtagGroupsView][_selectHashtagGroup] Selected: ${hashtagGroup.name}',
    );

    // Save to recent subgroups if it's a subgroup
    if (hashtagGroup.isSubgroup) {
      _saveRecentlySelectedSubgroup(hashtagGroup);
    }

    if (widget.allowMultipleSelection) {
      // Multiple selection mode - toggle hashtag group selection
      _toggleHashtagGroupSelection(hashtagGroup);
    } else {
      // Single selection mode - original behavior
      if (widget.onHashtagGroupSelected != null) {
        widget.onHashtagGroupSelected!(hashtagGroup);
      }

      Get.back(result: hashtagGroup);
    }
  }

  /// Toggle hashtag group selection for multiple selection mode
  void _toggleHashtagGroupSelection(HashtagGroup hashtagGroup) {
    debugPrint(
      '[HashtagGroupsView][_toggleHashtagGroupSelection] Toggling: ${hashtagGroup.name} (isMainGroup: ${hashtagGroup.isMainGroup}, isSubgroup: ${hashtagGroup.isSubgroup})',
    );

    // Determine if the group is currently selected
    bool isSelected;
    if (hashtagGroup.isMainGroup && hashtagGroup.hasSubgroups) {
      // For main groups, check if ALL subgroups are selected
      isSelected = hashtagGroup.subgroups!.every(
        (subgroup) =>
            _controller.selectedGroups.any((g) => g.id == subgroup.id),
      );
    } else {
      // For subgroups, check if this specific group is selected
      isSelected = _controller.selectedGroups.any(
        (g) => g.id == hashtagGroup.id,
      );
    }

    debugPrint(
      '[HashtagGroupsView][_toggleHashtagGroupSelection] Current selection state: $isSelected',
    );

    if (isSelected) {
      // Deselecting
      if (hashtagGroup.isMainGroup && hashtagGroup.hasSubgroups) {
        // If this is a main group, remove all its subgroups
        for (final subgroup in hashtagGroup.subgroups!) {
          _controller.selectedGroups.removeWhere((g) => g.id == subgroup.id);
          debugPrint(
            '[HashtagGroupsView][_toggleHashtagGroupSelection] Removed subgroup: ${subgroup.name}',
          );
        }
        debugPrint(
          '[HashtagGroupsView][_toggleHashtagGroupSelection] Deselected main group: ${hashtagGroup.name} (removed all subgroups)',
        );
      } else {
        // For subgroups, remove them directly
        _controller.selectedGroups.removeWhere((g) => g.id == hashtagGroup.id);
        debugPrint(
          '[HashtagGroupsView][_toggleHashtagGroupSelection] Removed: ${hashtagGroup.name}',
        );
      }
    } else {
      // Selecting
      if (hashtagGroup.isMainGroup && hashtagGroup.hasSubgroups) {
        // If this is a main group, add all its subgroups (not the main group itself)
        for (final subgroup in hashtagGroup.subgroups!) {
          if (!_controller.selectedGroups.any((g) => g.id == subgroup.id)) {
            _controller.selectedGroups.add(subgroup);
            debugPrint(
              '[HashtagGroupsView][_toggleHashtagGroupSelection] Added subgroup: ${subgroup.name}',
            );
          }
        }
        debugPrint(
          '[HashtagGroupsView][_toggleHashtagGroupSelection] Selected main group: ${hashtagGroup.name} (added ${hashtagGroup.subgroups!.length} subgroups)',
        );
      } else {
        // For subgroups, add them directly
        _controller.selectedGroups.add(hashtagGroup);
        debugPrint(
          '[HashtagGroupsView][_toggleHashtagGroupSelection] Added: ${hashtagGroup.name}',
        );

        // Save to recent subgroups
        _saveRecentlySelectedSubgroup(hashtagGroup);
      }
    }

    debugPrint(
      '[HashtagGroupsView][_toggleHashtagGroupSelection] Total selected: ${_controller.selectedGroups.length}',
    );
  }

  /// Find the main group for a given subgroup
  /// Handle done button press for multiple selection mode
  void _onDonePressed() {
    debugPrint(
      '[HashtagGroupsView][_onDonePressed] Returning ${_controller.selectedGroups.length} selected hashtag groups',
    );

    if (widget.onMultipleHashtagGroupsSelected != null) {
      widget.onMultipleHashtagGroupsSelected!(
        _controller.selectedGroups.toList(),
      );
    }

    Get.back(result: _controller.selectedGroups.toList());
  }

  /// Show popup for adding subgroup to a hashtag group
  void _startInlineAdding(int hashtagGroupId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddEditGroupPopup(
          isHashtagMode: true,
          isMainGroup: false,
          parentId: hashtagGroupId,
          onSave: (name, parentId) async {
            // Use the existing save logic
            if (name.isEmpty) {
              Get.snackbar(
                'Invalid Name',
                'Hashtag name cannot be empty',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
              return;
            }

            try {
              final newSubgroup = await _hashtagGroupService.addCustomGroup(
                name,
                parentId: hashtagGroupId,
              );

              if (newSubgroup == null) {
                Get.snackbar(
                  'Unable to Add',
                  'Unable to add hashtag. Please try again.',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              } else if (newSubgroup.id == -1) {
                // Duplicate subgroup hashtag name
                Get.snackbar(
                  'Duplicate Hashtag',
                  'Hashtag with this name already exists.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              } else if (newSubgroup.id == -4) {
                // Subgroup name conflicts with parent group
                Get.snackbar(
                  'Name Conflict',
                  'This name is already used by the parent group.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }

              await _refreshHashtagGroupsFromDatabase();

              Get.snackbar(
                'Success',
                'Hashtag added successfully',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } catch (e) {
              debugPrint('[HashtagGroupsView] Error adding subgroup: $e');
              Get.snackbar(
                'Unable to Add',
                'Unable to add hashtag. Please try again.',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
        );
      },
    );
  }

  /// Helper method to enable adding mode
  void _enableAddingMode(int hashtagGroupId) {
    _controller.addingToGroup[hashtagGroupId] = true;

    // Initialize controllers
    _controller.inlineNameControllers[hashtagGroupId] = TextEditingController();
  }

  /// Cancel inline adding
  void _cancelInlineAdding(int hashtagGroupId) {
    _controller.addingToGroup[hashtagGroupId] = false;
    _controller.inlineNameControllers[hashtagGroupId]?.dispose();
    _controller.inlineNameControllers.remove(hashtagGroupId);
  }

  /// Save recently selected subgroup
  Future<void> _saveRecentlySelectedSubgroup(HashtagGroup subgroup) async {
    try {
      // Only save subgroups (not main groups)
      if (!subgroup.isSubgroup) return;

      final prefs = await SharedPreferences.getInstance();

      // Get existing recent subgroups
      final existingJson = prefs.getString(_recentSubgroupsKey);
      List<Map<String, dynamic>> recentList = [];

      if (existingJson != null) {
        final decoded = json.decode(existingJson) as List;
        recentList = decoded.cast<Map<String, dynamic>>();
      }

      // Remove if already exists (to move to front)
      recentList.removeWhere((item) => item['id'] == subgroup.id);

      // Add to front
      recentList.insert(0, subgroup.toJson());

      // Keep only max items
      if (recentList.length > _maxRecentItems) {
        recentList = recentList.take(_maxRecentItems).toList();
      }

      // Save back to preferences
      final updatedJson = json.encode(recentList);
      await prefs.setString(_recentSubgroupsKey, updatedJson);

      debugPrint(
        '[HashtagGroupsView] Saved recent subgroup: ${subgroup.name} (ID: ${subgroup.id})',
      );
      debugPrint(
        '[HashtagGroupsView] Total recent subgroups: ${recentList.length}',
      );
    } catch (e) {
      debugPrint('[HashtagGroupsView] Error saving recent subgroup: $e');
    }
  }

  /// Get recently selected subgroups
  /// Remove a specific hashtag group from recently selected subgroups
  static Future<void> removeFromRecentlySelectedSubgroups(int groupId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingJson = prefs.getString(_recentSubgroupsKey);

      if (existingJson == null) return;

      final decoded = json.decode(existingJson) as List;
      List<Map<String, dynamic>> recentList = decoded
          .cast<Map<String, dynamic>>();

      // Remove the deleted group from recent list
      final originalLength = recentList.length;
      recentList.removeWhere((item) => item['id'] == groupId);

      if (recentList.length != originalLength) {
        // Save updated list back to preferences
        final updatedJson = json.encode(recentList);
        await prefs.setString(_recentSubgroupsKey, updatedJson);
        debugPrint(
          '[HashtagGroupsView] Removed group ID $groupId from recent subgroups',
        );
      }
    } catch (e) {
      debugPrint(
        '[HashtagGroupsView] Error removing from recent subgroups: $e',
      );
    }
  }

  /// Remove hashtag group and all its subgroups from recently selected subgroups
  static Future<void> removeGroupAndSubgroupsFromRecent(
    int mainGroupId,
    List<HashtagGroup> subgroups,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingJson = prefs.getString(_recentSubgroupsKey);

      if (existingJson == null) return;

      final decoded = json.decode(existingJson) as List;
      List<Map<String, dynamic>> recentList = decoded
          .cast<Map<String, dynamic>>();

      // Remove main group and all its subgroups from recent list
      final originalLength = recentList.length;
      recentList.removeWhere((item) {
        final itemId = item['id'];
        // Remove if it's the main group or any of its subgroups
        if (itemId == mainGroupId) return true;
        return subgroups.any((subgroup) => subgroup.id == itemId);
      });

      if (recentList.length != originalLength) {
        // Save updated list back to preferences
        final updatedJson = json.encode(recentList);
        await prefs.setString(_recentSubgroupsKey, updatedJson);
        debugPrint(
          '[HashtagGroupsView] Removed main group ID $mainGroupId and ${subgroups.length} subgroups from recent subgroups',
        );
      }
    } catch (e) {
      debugPrint(
        '[HashtagGroupsView] Error removing group and subgroups from recent: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UiController>();

    return PopScope(
      canPop:
          !widget.allowMultipleSelection || _controller.selectedGroups.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop &&
            widget.allowMultipleSelection &&
            _controller.selectedGroups.isNotEmpty) {
          _onDonePressed();
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xffDEEDFF),
        appBar: AppBar(
          leading: widget.allowMultipleSelection
              ? Obx(
                  () => IconButton(
                    onPressed: _controller.selectedGroups.isNotEmpty
                        ? _onDonePressed
                        : () => Get.back(),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: _controller.selectedGroups.isNotEmpty
                        ? 'Done'
                        : 'Back',
                  ),
                )
              : null,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppIcons.hashtag, width: 22.r, height: 22.r),
              13.horizontalSpace,
              CustomText(
                'Settings',
                size: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              35.horizontalSpace,
            ],
          ),
          centerTitle: true,
          backgroundColor: uiController.currentMainColor,
          foregroundColor: uiController.darkMode.value
              ? Colors.white
              : Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(
            color: uiController.darkMode.value ? Colors.white : Colors.white,
          ),
          actions: [
            // Hide add button in filter mode
            if (!widget.allowMultipleSelection)
              IconButton(
                onPressed: () => _startInlineAddingMainHashtagGroup(),
                icon: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(AppIcons.plus, width: 25, height: 25),
                ),
                tooltip: 'Add New Hashtag Group',
              ),
          ],
        ),
        body: Column(
          children: [
            // Selection indicator when in filter mode
            if (widget.allowMultipleSelection)
              Obx(() {
                final selectedCount = _controller.selectedGroups
                    .where((g) => g.isSubgroup)
                    .length;
                if (selectedCount == 0) {
                  return const SizedBox.shrink();
                }
                return HashtagSelectionIndicator(
                  selectedCount: selectedCount,
                  onDone: _onDonePressed,
                );
              }),
            // Main content
            Expanded(
              child: Obx(() {
                if (_controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildMainContent(uiController);
              }),
            ),
          ],
        ),
      ),
    );
  }

  /// Build main content (hierarchical hashtag groups)
  Widget _buildMainContent(UiController uiController) {
    return Container(
      color: uiController.darkMode.value
          ? Colors.black
          : uiController.currentMainColor.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: _buildHierarchicalHashtagGroups(),
      ),
    );
  }

  /// Build hierarchical hashtag groups
  Widget _buildHierarchicalHashtagGroups() {
    final uiController = Get.find<UiController>();

    return Obx(() {
      // Check if any hashtag group is expanded
      final hasExpandedGroup = _controller.expandedGroups.values.any(
        (expanded) => expanded == true,
      );

      return ListView(
        children: [
          // Inline add widget for main hashtag groups (at the top)
          Obx(
            () => _controller.addingMainGroup.value
                ? InlineAddMainGroupWidget(
                    controller: _mainHashtagGroupNameController,
                    onSave: _saveInlineAddMainHashtagGroup,
                    onCancel: _cancelInlineAddingMainHashtagGroup,
                  )
                : const SizedBox.shrink(),
          ),

          // Show empty state message if no groups and not adding
          if (_controller.allGroups.isEmpty)
            Obx(
              () => !_controller.addingMainGroup.value
                  ? Container(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          'No hashtag groups found.\nTap + to add a new group.',
                          textAlign: TextAlign.center,
                          style: gfonts.GoogleFonts.kumbhSans(
                            fontSize: 16,
                            color: uiController.darkMode.value
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),

          // Main hashtag groups
          ..._controller.allGroups.map(
            (mainHashtagGroup) =>
                _buildMainHashtagGroupExpansionTile(mainHashtagGroup),
          ),

          // Add spacing at the end if any group is expanded
          if (hasExpandedGroup) const SizedBox(height: 15),
        ],
      );
    });
  }

  /// Build main hashtag group expansion tile
  Widget _buildMainHashtagGroupExpansionTile(HashtagGroup mainHashtagGroup) {
    final uiController = Get.find<UiController>();
    final isExpanded = _controller.expandedGroups[mainHashtagGroup.id] ?? false;

    // Create a new expansion controller for this group to avoid state conflicts
    final groupId = mainHashtagGroup.id!;
    _controller.expansionControllers[groupId] = ExpansionTileController();
    final controller = _controller.expansionControllers[groupId]!;

    return Obx(() {
      // Check if all subgroups are selected (for filter mode)
      final allSubgroupsSelected =
          widget.allowMultipleSelection &&
          mainHashtagGroup.subgroups != null &&
          mainHashtagGroup.subgroups!.isNotEmpty &&
          mainHashtagGroup.subgroups!.every(
            (subgroup) =>
                _controller.selectedGroups.any((g) => g.id == subgroup.id),
          );

      // Count selected subgroups
      final selectedSubgroupsCount =
          widget.allowMultipleSelection && mainHashtagGroup.subgroups != null
          ? mainHashtagGroup.subgroups!
                .where(
                  (subgroup) => _controller.selectedGroups.any(
                    (g) => g.id == subgroup.id,
                  ),
                )
                .length
          : 0;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
        decoration: BoxDecoration(
          color: uiController.darkMode.value ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(4.r),
          // Add border to entire container when all subgroups are selected (filter mode only)
          border: widget.allowMultipleSelection && allSubgroupsSelected
              ? Border.all(color: uiController.currentMainColor, width: 2)
              : null,
        ),
        child: Column(
          children: [
            // Grey container with border for the hashtag group header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              decoration: BoxDecoration(
                // Changed background color: white in light mode, grey in dark mode
                color: uiController.darkMode.value
                    ? Colors.grey[900]
                    : Colors.white,
                borderRadius: BorderRadius.circular(4.r),
                // No border on main group header since we only select subgroups
                border: null,
              ),
              child: ExpansionTile(
                key: ValueKey('hashtag_group_${mainHashtagGroup.id}'),
                controller: controller,
                initiallyExpanded: isExpanded,
                onExpansionChanged: (expanded) {
                  _controller.expandedGroups[mainHashtagGroup.id!] = expanded;

                  // Check if we need to enable adding mode after expansion
                  if (expanded &&
                      (_controller.pendingAddingMode[mainHashtagGroup.id!] ??
                          false)) {
                    _controller.pendingAddingMode[mainHashtagGroup.id!] = false;
                    _enableAddingMode(mainHashtagGroup.id!);
                  }
                },
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4.r)),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4.r)),
                ),
                // Show checkbox on the left when in filter mode
                leading: widget.allowMultipleSelection
                    ? GestureDetector(
                        onTap: () => _selectHashtagGroup(mainHashtagGroup),
                        child: Container(
                          width: 24,
                          height: 24,
                          margin: const EdgeInsets.only(left: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: allSubgroupsSelected
                                  ? uiController.currentMainColor
                                  : (uiController.darkMode.value
                                        ? Colors.white.withValues(alpha: 0.6)
                                        : Colors.grey[400]!),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            color: allSubgroupsSelected
                                ? uiController.currentMainColor
                                : Colors.transparent,
                          ),
                          child: allSubgroupsSelected
                              ? Icon(Icons.check, size: 18, color: Colors.white)
                              : null,
                        ),
                      )
                    : null,
                title: GestureDetector(
                  onTap: widget.allowMultipleSelection
                      ? () => _selectHashtagGroup(mainHashtagGroup)
                      : null,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: widget.allowMultipleSelection ? 8.0 : 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: mainHashtagGroup.name,
                                  style: gfonts.GoogleFonts.kumbhSans(
                                    color: uiController.darkMode.value
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                // Show selection count when in filter mode
                                if (widget.allowMultipleSelection)
                                  TextSpan(
                                    text: ' (',
                                    style: gfonts.GoogleFonts.kumbhSans(
                                      color: uiController.darkMode.value
                                          ? Colors.white.withValues(alpha: 0.6)
                                          : Colors.grey[600],
                                      fontSize: 15,
                                    ),
                                  ),
                                if (widget.allowMultipleSelection)
                                  TextSpan(
                                    text: '$selectedSubgroupsCount',
                                    style: gfonts.GoogleFonts.kumbhSans(
                                      color: uiController.currentMainColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (widget.allowMultipleSelection)
                                  TextSpan(
                                    text:
                                        '/${mainHashtagGroup.subgroups?.length ?? 0})',
                                    style: gfonts.GoogleFonts.kumbhSans(
                                      color: uiController.darkMode.value
                                          ? Colors.white.withValues(alpha: 0.6)
                                          : Colors.grey[600],
                                      fontSize: 15,
                                    ),
                                  )
                                else
                                  TextSpan(
                                    text:
                                        ' (${mainHashtagGroup.subgroups?.length ?? 0})',
                                    style: gfonts.GoogleFonts.kumbhSans(
                                      color: uiController.darkMode.value
                                          ? Colors.white.withValues(alpha: 0.6)
                                          : Colors.grey[600],
                                      fontSize: 15,
                                    ),
                                  ),
                              ],
                            ),
                            maxLines: null, // Allow unlimited lines
                            overflow: TextOverflow.visible, // Show all text
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hide edit/delete/add buttons when in filter mode
                    if (!widget.allowMultipleSelection) ...[
                      // Edit button for main hashtag group
                      IconButton(
                        icon: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            uiController.darkMode.value
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.grey[500] ?? Colors.grey,
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            AppIcons.editV2,
                            width: 25,
                            height: 25,
                          ),
                        ),
                        onPressed: () =>
                            _showEditHashtagGroupDialog(mainHashtagGroup),
                        tooltip: 'Edit Hashtag Group',
                      ),
                      // Delete button for main hashtag group (only show if no subgroups)
                      if ((mainHashtagGroup.subgroups?.isEmpty ?? true))
                        IconButton(
                          icon: ColorFiltered(
                            colorFilter: const ColorFilter.mode(
                              Colors.red,
                              BlendMode.srcIn,
                            ),
                            child: Image.asset(
                              AppIcons.delete,
                              width: 25,
                              height: 25,
                            ),
                          ),
                          onPressed: () =>
                              _showDeleteConfirmation(mainHashtagGroup),
                          tooltip: 'Delete Hashtag Group',
                        ),
                      // Add subgroup button
                      IconButton(
                        onPressed:
                            (_controller.addingToGroup[mainHashtagGroup.id] ??
                                false)
                            ? null
                            : () => _startInlineAdding(mainHashtagGroup.id!),
                        icon: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            uiController.darkMode.value
                                ? Colors.white
                                : uiController.currentMainColor,
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(
                            AppIcons.plusThin,
                            width: 21.r,
                            height: 21.r,
                          ),
                        ),
                        tooltip: 'Add Subgroup',
                      ),
                    ],
                    // Expansion/collapse icon
                    Obx(
                      () => ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          uiController.darkMode.value
                              ? Colors.white.withValues(alpha: 0.6)
                              : Colors.grey[600] ?? Colors.grey,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          (_controller.expandedGroups[mainHashtagGroup.id!] ??
                                  false)
                              ? AppIcons.arrowUp
                              : AppIcons.arrowDown,
                          width: 25,
                          height: 25,
                        ),
                      ),
                    ),
                    Container(width: 15),
                  ],
                ),
                children: [],
              ),
            ),
            // Subgroups section (outside the grey container)
            if (isExpanded) ...[
              // Subgroups list
              if (mainHashtagGroup.subgroups != null &&
                  mainHashtagGroup.subgroups!.isNotEmpty)
                ..._buildSubgroupsList(mainHashtagGroup, uiController),

              // Inline adding widget
              Obx(() {
                if (_controller.addingToGroup[mainHashtagGroup.id] ?? false) {
                  return InlineAddSubgroupWidget(
                    controller: _controller
                        .inlineNameControllers[mainHashtagGroup.id!]!,
                    onSave: () => _saveInlineSubgroup(mainHashtagGroup.id!),
                    onCancel: () => _cancelInlineAdding(mainHashtagGroup.id!),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ],
        ),
      );
    });
  }

  /// Build subgroups list
  List<Widget> _buildSubgroupsList(
    HashtagGroup mainHashtagGroup,
    UiController uiController,
  ) {
    return mainHashtagGroup.subgroups!.asMap().entries.map((entry) {
      final index = entry.key;
      final subgroup = entry.value;
      final isLast = index == mainHashtagGroup.subgroups!.length - 1;

      return Column(
        children: [
          _buildSubgroupTile(subgroup, uiController),
          // Add bottom padding after last subgroup when in filter mode
          if (isLast && widget.allowMultipleSelection)
            const SizedBox(height: 8),
        ],
      );
    }).toList();
  }

  /// Build individual subgroup tile
  Widget _buildSubgroupTile(HashtagGroup subgroup, UiController uiController) {
    final isSelected =
        widget.allowMultipleSelection &&
        _controller.selectedGroups.any((g) => g.id == subgroup.id);

    return Obx(() {
      final isEditing = _controller.editingGroup[subgroup.id] ?? false;

      if (isEditing) {
        return InlineEditSubgroupWidget(
          hashtagGroup: subgroup,
          controller: _controller.editNameControllers[subgroup.id!]!,
          onSave: () => _saveInlineEdit(subgroup),
          onCancel: () => _cancelInlineEdit(subgroup.id!),
        );
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          // Changed background color to #F1F1F1 in light mode
          color: uiController.darkMode.value
              ? Colors.grey[900]
              : const Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(4.r),
          border: isSelected
              ? Border.all(color: uiController.currentMainColor, width: 2)
              : null,
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 5),
          dense: true,
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '#  ',
                  style: gfonts.GoogleFonts.kumbhSans(
                    color: Colors.grey[400],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
                TextSpan(
                  text: subgroup.name,
                  style: gfonts.GoogleFonts.kumbhSans(
                    color: uiController.darkMode.value
                        ? Colors.white
                        : Colors.black,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          trailing: widget.allowMultipleSelection
              ? null // Hide edit/delete buttons in filter mode
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Edit button
                    IconButton(
                      onPressed: () => _startInlineEditing(subgroup),
                      icon: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          uiController.darkMode.value
                              ? Colors.white70
                              : Colors.black54,
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          AppIcons.editV2,
                          width: 20,
                          height: 20,
                        ),
                      ),
                      tooltip: 'Edit',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                    // Delete button
                    IconButton(
                      onPressed: () => _deleteSubgroup(subgroup),
                      icon: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.red.withValues(alpha: 0.7),
                          BlendMode.srcIn,
                        ),
                        child: Image.asset(
                          AppIcons.delete,
                          width: 20,
                          height: 20,
                        ),
                      ),
                      tooltip: 'Delete',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                  ],
                ),
          onTap: widget.allowMultipleSelection
              ? () => _selectHashtagGroup(subgroup)
              : () => _selectHashtagGroup(subgroup),
        ),
      );
    });
  }

  /// Build inline add widget for main hashtag groups
  /// Show popup for editing a subgroup
  void _startInlineEditing(HashtagGroup hashtagGroup) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddEditGroupPopup(
          isHashtagMode: true,
          isMainGroup: hashtagGroup.parentId == null,
          initialName: hashtagGroup.name,
          editItemId: hashtagGroup.id,
          parentId: hashtagGroup.parentId,
          groupList: _controller.allGroups,
          onSave: (newName, parentId) async {
            // Use the existing save logic
            if (newName.isEmpty) {
              Get.snackbar(
                'Invalid Name',
                'Hashtag group name cannot be empty',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
              return;
            }

            try {
              await _hashtagGroupService.updateGroup(
                hashtagGroup.id!,
                newName,
                newParentId: parentId,
              );

              // Update in recents if it exists
              await HashtagRecentService().updateHashtagGroupInRecents(
                hashtagGroup.id!,
                newName,
              );

              await _refreshHashtagGroupsFromDatabase();

              Get.snackbar(
                'Success',
                'Hashtag updated successfully',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } catch (e) {
              debugPrint(
                '[HashtagGroupsView] Error updating hashtag group: $e',
              );
              if (e.toString().contains('DUPLICATE_HASHTAG_NAME')) {
                final message = hashtagGroup.parentId == null
                    ? 'Hashtag Group with this name already exists.'
                    : 'Hashtag with this name already exists.';
                Get.snackbar(
                  'Duplicate Hashtag',
                  message,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              } else if (e.toString().contains(
                'MAIN_GROUP_CONFLICTS_WITH_SUBGROUP',
              )) {
                Get.snackbar(
                  'Name Conflict',
                  'This name is already used by a hashtag in another group.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              } else if (e.toString().contains(
                'SUBGROUP_CONFLICTS_WITH_PARENT',
              )) {
                Get.snackbar(
                  'Name Conflict',
                  'This name is already used by the parent group.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
              } else {
                Get.snackbar(
                  'Unable to Update',
                  'Unable to update hashtag group. Please try again.',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            }
          },
        );
      },
    );
  }

  /// Save inline edit
  Future<void> _saveInlineEdit(HashtagGroup hashtagGroup) async {
    final nameController = _controller.editNameControllers[hashtagGroup.id!]!;
    final newName = nameController.text.trim();

    if (newName.isEmpty) {
      Get.snackbar(
        'Invalid Name',
        'Hashtag group name cannot be empty',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await _hashtagGroupService.updateGroup(hashtagGroup.id!, newName);

      // Update in recents if it exists
      await HashtagRecentService().updateHashtagGroupInRecents(
        hashtagGroup.id!,
        newName,
      );

      _cancelInlineEdit(hashtagGroup.id!);
      await _refreshHashtagGroupsFromDatabase();

      Get.snackbar(
        'Success',
        'Hashtag updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('[HashtagGroupsView] Error updating hashtag group: $e');
      if (e.toString().contains('DUPLICATE_HASHTAG_NAME')) {
        final message = hashtagGroup.parentId == null
            ? 'Hashtag Group with this name already exists.'
            : 'Hashtag with this name already exists.';
        Get.snackbar(
          'Duplicate Hashtag',
          message,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else if (e.toString().contains('MAIN_GROUP_CONFLICTS_WITH_SUBGROUP')) {
        Get.snackbar(
          'Name Conflict',
          'This name is already used by a hashtag in another group.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else if (e.toString().contains('SUBGROUP_CONFLICTS_WITH_PARENT')) {
        Get.snackbar(
          'Name Conflict',
          'This name is already used by the parent group.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Unable to Update',
          'Unable to update hashtag group. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  /// Cancel inline edit
  void _cancelInlineEdit(int hashtagGroupId) {
    _controller.editingGroup[hashtagGroupId] = false;
    _controller.editNameControllers[hashtagGroupId]?.dispose();
    _controller.editNameControllers.remove(hashtagGroupId);
  }

  /// Show popup for adding main hashtag group
  void _startInlineAddingMainHashtagGroup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AddEditGroupPopup(
          isHashtagMode: true,
          isMainGroup: true,
          onSave: (name, parentId) async {
            // Use the existing save logic
            if (name.isEmpty) {
              Get.snackbar(
                'Invalid Name',
                'Hashtag group name cannot be empty',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
              return;
            }

            try {
              final newGroup = await _hashtagGroupService.addCustomGroup(name);

              if (newGroup == null) {
                Get.snackbar(
                  'Unable to Add',
                  'Unable to add hashtag group. Please try again.',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              } else if (newGroup.id == -1) {
                // Duplicate main hashtag group name
                Get.snackbar(
                  'Duplicate Hashtag',
                  'Hashtag Group with this name already exists.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              } else if (newGroup.id == -3) {
                // Main group name conflicts with existing subgroup
                Get.snackbar(
                  'Name Conflict',
                  'This name is already used by a hashtag in another group.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }

              await _refreshHashtagGroupsFromDatabase();

              Get.snackbar(
                'Success',
                'Hashtag group "$name" added successfully!',
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            } catch (e) {
              debugPrint(
                '[HashtagGroupsView] Error adding main hashtag group: $e',
              );
              Get.snackbar(
                'Error',
                'Failed to add hashtag group',
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
          },
        );
      },
    );
  }

  /// Cancel inline adding for main hashtag group
  void _cancelInlineAddingMainHashtagGroup() {
    _controller.addingMainGroup.value = false;
    _mainHashtagGroupNameController.clear();
  }

  /// Save inline add for main hashtag group
  Future<void> _saveInlineAddMainHashtagGroup() async {
    final name = _mainHashtagGroupNameController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Invalid Name',
        'Hashtag group name cannot be empty',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final newGroup = await _hashtagGroupService.addCustomGroup(name);

      if (newGroup == null) {
        Get.snackbar(
          'Unable to Add',
          'Unable to add hashtag group. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      } else if (newGroup.id == -1) {
        // Duplicate main hashtag group name
        Get.snackbar(
          'Duplicate Hashtag',
          'Hashtag Group with this name already exists.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      } else if (newGroup.id == -3) {
        // Main group name conflicts with existing subgroup
        Get.snackbar(
          'Name Conflict',
          'This name is already used by a hashtag in another group.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      _cancelInlineAddingMainHashtagGroup();
      await _refreshHashtagGroupsFromDatabase();

      Get.snackbar(
        'Success',
        'Hashtag group "$name" added successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('[HashtagGroupsView] Error adding main hashtag group: $e');
      Get.snackbar(
        'Unable to Add',
        'Unable to add hashtag group. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Save inline added subgroup
  Future<void> _saveInlineSubgroup(int parentHashtagGroupId) async {
    final nameController =
        _controller.inlineNameControllers[parentHashtagGroupId]!;
    final name = nameController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Invalid Name',
        'Hashtag name cannot be empty',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final newSubgroup = await _hashtagGroupService.addCustomGroup(
        name,
        parentId: parentHashtagGroupId,
      );

      if (newSubgroup == null) {
        Get.snackbar(
          'Unable to Add',
          'Unable to add hashtag. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      } else if (newSubgroup.id == -1) {
        // Duplicate subgroup hashtag name
        Get.snackbar(
          'Duplicate Hashtag',
          'Hashtag with this name already exists.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      } else if (newSubgroup.id == -4) {
        // Subgroup name conflicts with parent group
        Get.snackbar(
          'Name Conflict',
          'This name is already used by the parent group.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      _cancelInlineAdding(parentHashtagGroupId);
      await _refreshHashtagGroupsFromDatabase();

      Get.snackbar(
        'Success',
        'Hashtag added successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('[HashtagGroupsView] Error adding subgroup: $e');
      Get.snackbar(
        'Unable to Add',
        'Unable to add hashtag. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
