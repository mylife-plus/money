import 'package:flutter/foundation.dart';

import '../models/hashtag_group_model.dart';
import 'database/repositories/hashtag_repository.dart';

import 'database/repositories/transaction_repository.dart';

// ... (keep existing imports)

// ...

class HashtagGroupService {
  static final HashtagGroupService _instance = HashtagGroupService._internal();
  factory HashtagGroupService() => _instance;
  HashtagGroupService._internal();

  final HashtagRepository _repository = HashtagRepository();
  final TransactionRepository _transactionRepository = TransactionRepository();

  /// Update an existing hashtag group
  Future<bool> updateGroup(int groupId, String name, {int? newParentId}) async {
    try {
      debugPrint(
        '[HashtagGroupService][updateGroup] ===== UPDATE GROUP STARTED =====',
      );
      debugPrint('[HashtagGroupService][updateGroup] Input parameters:');
      debugPrint('  - Group ID: $groupId');
      debugPrint('  - Name: "$name"');
      debugPrint('  - Parent ID New: $newParentId');

      // Get the old name before updating
      final oldGroup = await getGroupById(groupId);
      final oldName = oldGroup?.name;
      final newName = name.trim();

      debugPrint('[HashtagGroupService][updateGroup] Old name: "$oldName"');
      debugPrint('[HashtagGroupService][updateGroup] New name: "$newName"');

      // Check for duplicate hashtag name across all groups (case-insensitive) if name is being changed
      if (oldName != null && newName.toLowerCase() != oldName.toLowerCase()) {
        final allGroups = await getAllGroupsFlat();
        final nameLower = newName.toLowerCase();

        for (final group in allGroups) {
          // Skip the current group being edited
          if (group.id != groupId && group.name.toLowerCase() == nameLower) {
            debugPrint(
              '[HashtagGroupService][updateGroup] Duplicate hashtag name found: ${group.name}',
            );
            throw Exception('DUPLICATE_HASHTAG_NAME');
          }
        }

        // Additional check: If editing a main group, check if name conflicts with any subgroup
        // If editing a subgroup, check if name conflicts with its parent group
        final currentGroup = await getGroupById(groupId);
        if (currentGroup != null) {
          if (currentGroup.parentId == null) {
            // Editing a main group - check if this name exists as any subgroup
            for (final group in allGroups) {
              if (group.id != groupId &&
                  group.parentId != null &&
                  group.name.toLowerCase() == nameLower) {
                debugPrint(
                  '[HashtagGroupService][updateGroup] Main group name conflicts with existing subgroup: ${group.name}',
                );
                throw Exception('MAIN_GROUP_CONFLICTS_WITH_SUBGROUP');
              }
            }
          } else {
            // Editing a subgroup - check if name conflicts with parent group
            final parentGroup = await getGroupById(currentGroup.parentId!);
            if (parentGroup != null &&
                parentGroup.name.toLowerCase() == nameLower) {
              debugPrint(
                '[HashtagGroupService][updateGroup] Subgroup name conflicts with parent group: ${parentGroup.name}',
              );
              throw Exception('SUBGROUP_CONFLICTS_WITH_PARENT');
            }
          }
        }
      }

      // Handle parent ID change if provided (for moving subgroups between parents)
      if (newParentId != null && oldGroup != null) {
        debugPrint(
          '[HashtagGroupService][updateGroup] Parent ID change requested: ${oldGroup.parentId} -> $newParentId',
        );

        // Verify this is a subgroup being moved
        if (oldGroup.parentId == null) {
          debugPrint(
            '[HashtagGroupService][updateGroup] Cannot change parent of main group',
          );
          throw Exception('CANNOT_CHANGE_MAIN_GROUP_PARENT');
        }

        // Verify new parent exists and is a main group
        final newParent = await getGroupById(newParentId);
        if (newParent == null) {
          debugPrint(
            '[HashtagGroupService][updateGroup] New parent ID $newParentId not found',
          );
          throw Exception('PARENT_NOT_FOUND');
        }

        if (newParent.parentId != null) {
          debugPrint(
            '[HashtagGroupService][updateGroup] New parent must be a main group, but $newParentId is a subgroup',
          );
          throw Exception('INVALID_PARENT_NOT_MAIN_GROUP');
        }

        // Check name conflict with new parent
        if (newName.toLowerCase() == newParent.name.toLowerCase()) {
          debugPrint(
            '[HashtagGroupService][updateGroup] Subgroup name conflicts with new parent: ${newParent.name}',
          );
          throw Exception('SUBGROUP_CONFLICTS_WITH_PARENT');
        }

        // Check if new parent already has a subgroup with this name
        final newParentSubgroups = await getSubgroups(newParentId);
        for (final subgroup in newParentSubgroups) {
          if (subgroup.id != groupId &&
              subgroup.name.toLowerCase() == newName.toLowerCase()) {
            debugPrint(
              '[HashtagGroupService][updateGroup] New parent already has subgroup with name: ${subgroup.name}',
            );
            throw Exception('DUPLICATE_HASHTAG_NAME');
          }
        }

        debugPrint(
          '[HashtagGroupService][updateGroup] ✅ Parent ID validation passed',
        );
      }

      final updateData = {
        'hashtag_group_name': newName,
        'hashtag_group_updated_at': DateTime.now().toIso8601String(),
      };

      // Add parent ID to update if provided
      if (newParentId != null) {
        updateData['hashtag_group_parent_id'] = newParentId.toString();
      }

      final updatedRows = await _repository.update(groupId, updateData);

      final success = updatedRows > 0;

      if (success) {
        // Retroactively update all transactions using this hashtag
        await _updateTransactionsWithNewHashtagName(groupId, newName);

        if (oldGroup != null && oldGroup.isMainGroup) {
          await _updateTransactionsForSubgroups(groupId);
        }
      }

      return success;
    } catch (e) {
      debugPrint('[HashtagGroupService][updateGroup] Error: $e');
      if (e.toString().contains('DUPLICATE_HASHTAG_NAME') ||
          e.toString().contains('CANNOT_CHANGE_MAIN_GROUP_PARENT') ||
          e.toString().contains('PARENT_NOT_FOUND') ||
          e.toString().contains('INVALID_PARENT_NOT_MAIN_GROUP') ||
          e.toString().contains('SUBGROUP_CONFLICTS_WITH_PARENT')) {
        rethrow;
      }
      return false;
    }
  }

  Future<void> _updateTransactionsWithNewHashtagName(
    int groupId,
    String newName,
  ) async {
    try {
      final allTransactions = await _transactionRepository.getAllTransactions();
      for (final transaction in allTransactions) {
        bool needsUpdate = false;
        final updatedHashtags = transaction.hashtags.map((h) {
          if (h.id == groupId) {
            needsUpdate = true;
            return h.copyWith(name: newName);
          }
          return h;
        }).toList();

        if (needsUpdate) {
          await _transactionRepository.updateTransaction(
            transaction.copyWith(hashtags: updatedHashtags),
          );
        }
      }
    } catch (e) {
      debugPrint(
        '[HashtagGroupService] Error updating transactions for hashtag rename: $e',
      );
    }
  }

  Future<void> _updateTransactionsForSubgroups(int mainGroupId) async {
    // No-op: Subgroups cached in transactions only store their own 'name' and 'parentId'.
    // They do NOT store the parent's name.
    // The UI handles resolving the parent name dynamically using the parentId.
    // Therefore, renaming a parent group does not require updating transactions that use its subgroups,
    // as long as the parentId remains valid (which it does, as we only changed the name).
    return;
  }

  /// Add a new custom hashtag group
  Future<HashtagGroup?> addCustomGroup(String name, {int? parentId}) async {
    try {
      debugPrint(
        '[HashtagGroupService][addCustomGroup] Adding custom group: $name, parentId: $parentId',
      );

      // Check for duplicate hashtag name across all groups (case-insensitive)
      final allGroups = await getAllGroupsFlat();
      final nameLower = name.trim().toLowerCase();

      for (final group in allGroups) {
        if (group.name.toLowerCase() == nameLower) {
          debugPrint(
            '[HashtagGroupService][addCustomGroup] Duplicate hashtag name found: ${group.name}',
          );
          // Return a special marker to indicate duplicate
          // We'll use a group with id = -1 to signal duplicate
          return HashtagGroup(
            id: -1,
            name: name.trim(),
            parentId: parentId,
            isCustom: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }

      // Additional check: If adding a main group, check if name conflicts with any subgroup
      // If adding a subgroup, check if name conflicts with its parent group
      if (parentId == null) {
        // Adding a main group - check if this name exists as any subgroup
        for (final group in allGroups) {
          if (group.parentId != null && group.name.toLowerCase() == nameLower) {
            debugPrint(
              '[HashtagGroupService][addCustomGroup] Main group name conflicts with existing subgroup: ${group.name}',
            );
            // Return id = -3 to signal main group conflicts with subgroup
            return HashtagGroup(
              id: -3,
              name: name.trim(),
              parentId: parentId,
              isCustom: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
          }
        }
      } else {
        // Adding a subgroup - check if name conflicts with parent group
        final parentGroup = await getGroupById(parentId);
        if (parentGroup != null &&
            parentGroup.name.toLowerCase() == nameLower) {
          debugPrint(
            '[HashtagGroupService][addCustomGroup] Subgroup name conflicts with parent group: ${parentGroup.name}',
          );
          // Return id = -4 to signal subgroup conflicts with parent group
          return HashtagGroup(
            id: -4,
            name: name.trim(),
            parentId: parentId,
            isCustom: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }
      }

      final now = DateTime.now();
      final group = HashtagGroup(
        name: name.trim(),
        parentId: parentId,
        isCustom: true,
        createdAt: now,
        updatedAt: now,
      );

      final groupId = await _repository.insert(group.toMap());

      if (groupId > 0) {
        final createdGroup = group.copyWith(id: groupId);
        debugPrint(
          '[HashtagGroupService][addCustomGroup] Successfully added group with ID: $groupId',
        );
        return createdGroup;
      } else {
        debugPrint('[HashtagGroupService][addCustomGroup] Failed to add group');
        return null;
      }
    } catch (e) {
      debugPrint('[HashtagGroupService][addCustomGroup] Error: $e');
      return null;
    }
  }

  /// Delete a hashtag group
  /// Returns: true if deleted, false if failed
  /// Delete a hashtag group
  /// Returns: true if deleted, false if failed
  Future<bool> deleteGroup(int groupId) async {
    try {
      debugPrint(
        '[HashtagGroupService][deleteGroup] Deleting group ID: $groupId',
      );

      // First, get the group to check its name
      final group = await getGroupById(groupId);
      if (group == null) {
        debugPrint(
          '[HashtagGroupService][deleteGroup] Group not found for ID: $groupId',
        );
        return false;
      }

      // Check if any transactions are using this hashtag
      final isUsed = await _isHashtagInUse(groupId);
      if (isUsed) {
        debugPrint(
          '[HashtagGroupService][deleteGroup] Cannot delete group: currently in use by transactions',
        );
        throw Exception('CANNOT_DELETE_HASHTAG_IN_USE');
      }

      final deletedRows = await _repository.delete(groupId);
      final success = deletedRows > 0;

      debugPrint(
        '[HashtagGroupService][deleteGroup] Delete ${success ? 'successful' : 'failed'}, rows affected: $deletedRows',
      );

      return success;
    } catch (e) {
      debugPrint('[HashtagGroupService][deleteGroup] Error: $e');
      if (e.toString().contains('CANNOT_DELETE_HASHTAG_IN_USE')) {
        rethrow;
      }
      return false;
    }
  }

  Future<bool> _isHashtagInUse(int groupId) async {
    try {
      final allTransactions = await _transactionRepository.getAllTransactions();
      for (final transaction in allTransactions) {
        for (final hashtag in transaction.hashtags) {
          if (hashtag.id == groupId) {
            return true;
          }
        }
      }

      // If it's a main group, ensure no transaction uses it OR its subgroups.
      final group = await getGroupById(groupId);
      if (group != null && group.isMainGroup) {
        final subgroups = await getSubgroups(groupId);
        for (final subgroup in subgroups) {
          if (await _isHashtagInUse(subgroup.id!)) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      debugPrint('[HashtagGroupService] Error checking hashtag usage: $e');
      return false;
    }
  }

  /// Get all hashtag groups in hierarchical structure
  Future<List<HashtagGroup>> getAllGroupsHierarchical() async {
    try {
      debugPrint(
        '[HashtagGroupService][getAllGroupsHierarchical] Fetching hierarchical groups',
      );

      // Get main groups only (without subgroups)
      final mainGroupMaps = await _repository.getMainGroups();
      debugPrint(
        '[HashtagGroupService][getAllGroupsHierarchical] Got ${mainGroupMaps.length} main group maps',
      );

      final List<HashtagGroup> hierarchicalGroups = [];

      for (final mainGroupMap in mainGroupMaps) {
        final mainGroup = HashtagGroup.fromMap(mainGroupMap);
        debugPrint(
          '[HashtagGroupService][getAllGroupsHierarchical] Processing main group: ${mainGroup.name} (ID: ${mainGroup.id})',
        );

        // Get subgroups for this main group
        final subgroupMaps = await _repository.getSubgroups(mainGroup.id!);
        debugPrint(
          '[HashtagGroupService][getAllGroupsHierarchical] Got ${subgroupMaps.length} subgroups for ${mainGroup.name}',
        );

        final subgroups = HashtagGroupHelper.fromMapList(subgroupMaps);

        // Create main group with subgroups
        final mainGroupWithSubgroups = mainGroup.copyWith(subgroups: subgroups);
        hierarchicalGroups.add(mainGroupWithSubgroups);
      }

      debugPrint(
        '[HashtagGroupService][getAllGroupsHierarchical] Built ${hierarchicalGroups.length} hierarchical groups',
      );

      return hierarchicalGroups;
    } catch (e) {
      debugPrint('[HashtagGroupService][getAllGroupsHierarchical] Error: $e');
      return [];
    }
  }

  /// Get all hashtag groups as flat list
  Future<List<HashtagGroup>> getAllGroupsFlat() async {
    try {
      debugPrint('[HashtagGroupService][getAllGroupsFlat] Fetching all groups');

      final groupMaps = await _repository.getAll();
      final groups = HashtagGroupHelper.fromMapList(groupMaps);

      debugPrint(
        '[HashtagGroupService][getAllGroupsFlat] Retrieved ${groups.length} groups',
      );

      return groups;
    } catch (e) {
      debugPrint('[HashtagGroupService][getAllGroupsFlat] Error: $e');
      return [];
    }
  }

  /// Get main hashtag groups only
  Future<List<HashtagGroup>> getMainGroups() async {
    try {
      debugPrint('[HashtagGroupService][getMainGroups] Fetching main groups');

      final groupMaps = await _repository.getMainGroups();
      final groups = HashtagGroupHelper.fromMapList(groupMaps);

      debugPrint(
        '[HashtagGroupService][getMainGroups] Retrieved ${groups.length} main groups',
      );

      return groups;
    } catch (e) {
      debugPrint('[HashtagGroupService][getMainGroups] Error: $e');
      return [];
    }
  }

  /// Get subgroups for a specific main group
  Future<List<HashtagGroup>> getSubgroups(int mainGroupId) async {
    try {
      debugPrint(
        '[HashtagGroupService][getSubgroups] Fetching subgroups for main group ID: $mainGroupId',
      );

      final subgroupMaps = await _repository.getSubgroups(mainGroupId);
      final subgroups = HashtagGroupHelper.fromMapList(subgroupMaps);

      debugPrint(
        '[HashtagGroupService][getSubgroups] Retrieved ${subgroups.length} subgroups',
      );

      return subgroups;
    } catch (e) {
      debugPrint('[HashtagGroupService][getSubgroups] Error: $e');
      return [];
    }
  }

  /// Get a specific hashtag group by ID
  Future<HashtagGroup?> getGroupById(int groupId) async {
    try {
      debugPrint(
        '[HashtagGroupService][getGroupById] Fetching group ID: $groupId',
      );

      final groupMap = await _repository.getById(groupId);
      if (groupMap == null) {
        debugPrint('[HashtagGroupService][getGroupById] Group not found');
        return null;
      }

      final group = HashtagGroup.fromMap(groupMap);
      debugPrint(
        '[HashtagGroupService][getGroupById] Retrieved group: ${group.name}',
      );

      return group;
    } catch (e) {
      debugPrint('[HashtagGroupService][getGroupById] Error: $e');
      return null;
    }
  }

  /// Initialize hashtag groups if needed
  Future<void> initializeGroupsIfNeeded() async {
    try {
      debugPrint(
        '[HashtagGroupService][initializeGroupsIfNeeded] Checking initialization status',
      );
      // Note: No predefined hashtag groups - users create their own as needed
      debugPrint(
        '[HashtagGroupService][initializeGroupsIfNeeded] No initialization needed - users create custom groups',
      );
    } catch (e) {
      debugPrint('[HashtagGroupService][initializeGroupsIfNeeded] Error: $e');
    }
  }

  /// Get groups suitable for dropdown/picker (with display text)
  Future<List<Map<String, dynamic>>> getGroupsForPicker({
    bool includeSubgroups = true,
    bool includeMainGroups =
        false, // Categories should not show as list items by default
  }) async {
    try {
      debugPrint(
        '[HashtagGroupService][getGroupsForPicker] Fetching groups for picker',
      );

      final List<Map<String, dynamic>> pickerItems = [];

      if (includeSubgroups) {
        // Get hierarchical structure
        final hierarchicalGroups = await getAllGroupsHierarchical();

        for (final mainGroup in hierarchicalGroups) {
          // Add main group only if requested (categories should not show as list items by default)
          if (includeMainGroups) {
            pickerItems.add({
              'id': mainGroup.id,
              'name': mainGroup.name,
              'displayText': mainGroup.name,
              'isMainGroup': true,
              'parentId': null,
            });
          }

          // Add subgroups
          if (mainGroup.subgroups != null) {
            for (final subgroup in mainGroup.subgroups!) {
              pickerItems.add({
                'id': subgroup.id,
                'name': subgroup.name,
                'displayText': includeMainGroups
                    ? '  ${subgroup.name}'
                    : subgroup.name, // Indent only if main groups are included
                'isMainGroup': false,
                'parentId': subgroup.parentId,
              });
            }
          }
        }
      } else {
        // Get main groups only
        final mainGroups = await getMainGroups();
        for (final group in mainGroups) {
          pickerItems.add({
            'id': group.id,
            'name': group.name,
            'displayText': group.name,
            'isMainGroup': true,
            'parentId': null,
          });
        }
      }

      debugPrint(
        '[HashtagGroupService][getGroupsForPicker] Prepared ${pickerItems.length} picker items',
      );

      return pickerItems;
    } catch (e) {
      debugPrint('[HashtagGroupService][getGroupsForPicker] Error: $e');
      return [];
    }
  }
}
