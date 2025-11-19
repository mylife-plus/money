import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hashtag_group_model.dart';

/// Service for managing recent hashtag selections in SharedPreferences
class HashtagRecentService {
  static const String _recentHashtagsKey = 'recent_hashtags_filter';
  static const String _recentGroupsKey = 'recent_hashtag_groups_filter';
  static const int _maxRecentHashtags = 10;
  static const int _maxRecentGroups = 6;

  /// Load recent hashtags and groups (combined, max 6 items)
  Future<HashtagRecentData> loadRecentItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentHashtagsJson = prefs.getStringList(_recentHashtagsKey) ?? [];
      final recentGroupsJson = prefs.getStringList(_recentGroupsKey) ?? [];

      // Parse hashtags
      final recentHashtags = <String>[];
      for (final hashtagJson in recentHashtagsJson) {
        try {
          final hashtagData = json.decode(hashtagJson);
          if (hashtagData is Map<String, dynamic> &&
              hashtagData.containsKey('name')) {
            recentHashtags.add(hashtagData['name']);
          }
        } catch (e) {
          debugPrint('[HashtagRecentService] Error parsing recent hashtag: $e');
        }
      }

      // Parse groups
      final recentGroups = <String>[];
      final mainCategoryGroups = <String>[];
      for (final groupJson in recentGroupsJson) {
        try {
          final groupData = json.decode(groupJson);
          if (groupData is Map<String, dynamic> &&
              groupData.containsKey('name')) {
            recentGroups.add(groupData['name']);
            // Check if this is a main category (parentId is null)
            if (groupData['parentId'] == null) {
              mainCategoryGroups.add(groupData['name']);
            }
          }
        } catch (e) {
          debugPrint('[HashtagRecentService] Error parsing recent hashtag group: $e');
        }
      }

      // Combine recent hashtags and groups, prioritizing groups (max 6 items total)
      final combinedRecent = <String>[];
      final groupNames = <String>[];

      combinedRecent.addAll(recentGroups.take(6)); // Max 6 groups
      groupNames.addAll(
        mainCategoryGroups.take(6),
      ); // Track which are MAIN CATEGORY groups

      if (combinedRecent.length < 6) {
        combinedRecent.addAll(
          recentHashtags.take(6 - combinedRecent.length),
        ); // Fill remaining with hashtags
      }

      debugPrint(
        '[HashtagRecentService] Loaded ${combinedRecent.length} recent items (${groupNames.length} main category groups)',
      );

      return HashtagRecentData(
        recentItems: combinedRecent,
        mainCategoryGroups: groupNames,
      );
    } catch (e) {
      debugPrint('[HashtagRecentService] Error loading recent hashtags: $e');
      return HashtagRecentData(recentItems: [], mainCategoryGroups: []);
    }
  }

  /// Save a recent hashtag
  Future<void> saveRecentHashtag(String hashtag) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentHashtagsJson = prefs.getStringList(_recentHashtagsKey) ?? [];

      // Create hashtag data
      final hashtagData = {
        'name': hashtag,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Remove if already exists
      recentHashtagsJson.removeWhere((item) {
        try {
          final data = json.decode(item);
          return data['name'] == hashtag;
        } catch (e) {
          return false;
        }
      });

      // Add to beginning
      recentHashtagsJson.insert(0, json.encode(hashtagData));

      // Keep only last N items
      if (recentHashtagsJson.length > _maxRecentHashtags) {
        recentHashtagsJson.removeRange(
          _maxRecentHashtags,
          recentHashtagsJson.length,
        );
      }

      await prefs.setStringList(_recentHashtagsKey, recentHashtagsJson);
      debugPrint('[HashtagRecentService] Saved recent hashtag: $hashtag');
    } catch (e) {
      debugPrint('[HashtagRecentService] Error saving recent hashtag: $e');
    }
  }

  /// Save a recent hashtag group
  Future<void> saveRecentHashtagGroup(HashtagGroup group) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentGroupsJson = prefs.getStringList(_recentGroupsKey) ?? [];

      // Create group data
      final groupData = {
        'id': group.id,
        'name': group.name,
        'parentId': group.parentId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Remove if already exists
      recentGroupsJson.removeWhere((item) {
        try {
          final data = json.decode(item);
          return data['id'] == group.id;
        } catch (e) {
          return false;
        }
      });

      // Add to beginning
      recentGroupsJson.insert(0, json.encode(groupData));

      // Keep only last N items
      if (recentGroupsJson.length > _maxRecentGroups) {
        recentGroupsJson.removeRange(_maxRecentGroups, recentGroupsJson.length);
      }

      await prefs.setStringList(_recentGroupsKey, recentGroupsJson);
      debugPrint(
        '[HashtagRecentService] Saved recent hashtag group: ${group.name}',
      );
    } catch (e) {
      debugPrint('[HashtagRecentService] Error saving recent hashtag group: $e');
    }
  }

  /// Remove a hashtag from recent hashtags
  Future<void> removeFromRecentHashtags(String hashtagName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentHashtagsJson = prefs.getStringList(_recentHashtagsKey) ?? [];

      final originalLength = recentHashtagsJson.length;
      recentHashtagsJson.removeWhere((item) {
        try {
          final data = json.decode(item);
          return data['name'] == hashtagName;
        } catch (e) {
          return false;
        }
      });

      if (recentHashtagsJson.length != originalLength) {
        await prefs.setStringList(_recentHashtagsKey, recentHashtagsJson);
        debugPrint(
          '[HashtagRecentService] Removed hashtag "$hashtagName" from recent hashtags',
        );
      }
    } catch (e) {
      debugPrint(
        '[HashtagRecentService] Error removing hashtag from recent: $e',
      );
    }
  }

  /// Remove a hashtag group from recent hashtag groups
  Future<void> removeFromRecentHashtagGroups(int groupId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentGroupsJson = prefs.getStringList(_recentGroupsKey) ?? [];

      final originalLength = recentGroupsJson.length;
      recentGroupsJson.removeWhere((item) {
        try {
          final data = json.decode(item);
          return data['id'] == groupId;
        } catch (e) {
          return false;
        }
      });

      if (recentGroupsJson.length != originalLength) {
        await prefs.setStringList(_recentGroupsKey, recentGroupsJson);
        debugPrint(
          '[HashtagRecentService] Removed group ID $groupId from recent hashtag groups',
        );
      }
    } catch (e) {
      debugPrint(
        '[HashtagRecentService] Error removing group from recent: $e',
      );
    }
  }

  /// Remove hashtag group and all its subgroups from recent hashtag groups
  Future<void> removeGroupAndSubgroupsFromRecentHashtagGroups(
    int mainGroupId,
    List<int> subgroupIds,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentGroupsJson = prefs.getStringList(_recentGroupsKey) ?? [];

      final originalLength = recentGroupsJson.length;
      recentGroupsJson.removeWhere((item) {
        try {
          final data = json.decode(item);
          final itemId = data['id'];
          // Remove if it's the main group or any of its subgroups
          if (itemId == mainGroupId) return true;
          return subgroupIds.contains(itemId);
        } catch (e) {
          return false;
        }
      });

      if (recentGroupsJson.length != originalLength) {
        await prefs.setStringList(_recentGroupsKey, recentGroupsJson);
        debugPrint(
          '[HashtagRecentService] Removed main group ID $mainGroupId and ${subgroupIds.length} subgroups from recent hashtag groups',
        );
      }
    } catch (e) {
      debugPrint(
        '[HashtagRecentService] Error removing group and subgroups from recent: $e',
      );
    }
  }

  /// Update hashtag group name in recent hashtag groups
  Future<void> updateHashtagGroupInRecents(int groupId, String newName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentGroupsJson = prefs.getStringList(_recentGroupsKey) ?? [];

      bool updated = false;
      final updatedList = recentGroupsJson.map((item) {
        try {
          final data = json.decode(item);
          if (data['id'] == groupId) {
            data['name'] = newName;
            data['timestamp'] = DateTime.now().millisecondsSinceEpoch;
            updated = true;
            return json.encode(data);
          }
          return item;
        } catch (e) {
          return item;
        }
      }).toList();

      if (updated) {
        await prefs.setStringList(_recentGroupsKey, updatedList);
        debugPrint(
          '[HashtagRecentService] Updated hashtag group ID $groupId to "$newName" in recent hashtag groups',
        );
      }
    } catch (e) {
      debugPrint(
        '[HashtagRecentService] Error updating hashtag group in recents: $e',
      );
    }
  }
}

/// Data class for recent hashtag items
class HashtagRecentData {
  final List<String> recentItems;
  final List<String> mainCategoryGroups;

  HashtagRecentData({
    required this.recentItems,
    required this.mainCategoryGroups,
  });
}
