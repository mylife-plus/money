import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';
import 'package:moneyapp/screens/hashtag/hashtag_group_screen.dart';
import 'package:moneyapp/services/hashtag_group_service.dart';
import 'package:moneyapp/services/hashtag_recent_service.dart';
import 'package:moneyapp/widgets/hashtag/hashtag_item.dart';
import 'package:moneyapp/widgets/hashtag/hashtag_group_item.dart';
import 'package:moneyapp/widgets/hashtag/hashtag_search_field.dart';
import 'package:moneyapp/widgets/hashtag/hashtag_see_list_button.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class SearchableHashtagWidget extends StatefulWidget {
  final String title;
  final Function(String) onHashtagSelected;
  final Function(HashtagGroup)? onGroupSelected;
  final Function(bool isFocused)? onFocusChanged;
  final bool showActionButtons;
  final String? iconPath;
  final Color? backgroundColor;
  final bool isCompact;
  final List<String>? previouslySelectedHashtags;
  final Function(List<HashtagGroup> groups)? onMultipleGroupsSelectedFromPicker;
  final bool isInFilterMode;

  const SearchableHashtagWidget({
    super.key,
    this.title = 'filter Hashtags',
    required this.onHashtagSelected,
    this.onGroupSelected,
    this.onMultipleGroupsSelectedFromPicker,
    this.onFocusChanged,
    this.showActionButtons = false,
    this.iconPath,
    this.backgroundColor,
    this.isCompact = false,
    this.previouslySelectedHashtags,
    this.isInFilterMode = false,
  });

  @override
  State<SearchableHashtagWidget> createState() =>
      _SearchableHashtagWidgetState();
}

class _SearchableHashtagWidgetState extends State<SearchableHashtagWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final HashtagGroupService _hashtagGroupService = HashtagGroupService();
  final HashtagRecentService _recentService = HashtagRecentService();

  final RxBool _showResults = false.obs;
  final RxList<String> _searchResults = <String>[].obs;
  final RxList<HashtagGroup> _groupResults = <HashtagGroup>[].obs;
  final RxList<String> _recentHashtags = <String>[].obs;
  final RxList<String> _recentHashtagGroups = <String>[].obs;
  final RxBool _isLoading = false.obs;

  List<String> _allHashtags = [];
  List<HashtagGroup> _allGroups = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    final isFocused = _focusNode.hasFocus;
    if (isFocused) {
      _showResults.value = true;
    } else {
      _showResults.value = false;
      debugPrint('[SearchableHashtagWidget] Collapsed due to focus loss');
    }
    widget.onFocusChanged?.call(isFocused);
    debugPrint('[SearchableHashtagWidget] Focus changed: $isFocused');
  }

  Future<void> _loadData() async {
    _isLoading.value = true;
    try {
      _allGroups = await _hashtagGroupService.getAllGroupsHierarchical();
      await _loadRecentHashtags();
    } catch (e) {
      debugPrint('[SearchableHashtagWidget] Error loading data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadRecentHashtags() async {
    try {
      final recentData = await _recentService.loadRecentItems();
      _recentHashtags.value = recentData.recentItems;
      _recentHashtagGroups.value = recentData.mainCategoryGroups;
      debugPrint(
        '[SearchableHashtagWidget] Loaded ${recentData.recentItems.length} recent items',
      );
    } catch (e) {
      debugPrint('[SearchableHashtagWidget] Error loading recent hashtags: $e');
      _recentHashtags.value = [];
      _recentHashtagGroups.value = [];
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      _searchResults.clear();
      _groupResults.clear();
      return;
    }

    final lowerQuery = query.toLowerCase();

    // Search individual hashtags
    final hashtagResults = _allHashtags
        .where((hashtag) => hashtag.toLowerCase().contains(lowerQuery))
        .take(10)
        .toList();

    // Search groups
    final groupResults = <HashtagGroup>[];
    for (final group in _allGroups) {
      if (group.name.toLowerCase().contains(lowerQuery)) {
        groupResults.add(group);
      }
      if (group.subgroups != null) {
        for (final subgroup in group.subgroups!) {
          if (subgroup.name.toLowerCase().contains(lowerQuery)) {
            groupResults.add(subgroup);
          }
        }
      }
    }

    _searchResults.value = hashtagResults;
    _groupResults.value = groupResults.take(5).toList();
  }

  void _selectHashtag(String hashtag) {
    widget.onHashtagSelected(hashtag);
    _recentService.saveRecentHashtag(hashtag);
    _searchController.clear();
    _showResults.value = false;
    _focusNode.unfocus();
  }

  void _selectGroup(HashtagGroup group) {
    if (widget.onGroupSelected != null) {
      widget.onGroupSelected!(group);
    }
    _recentService.saveRecentHashtagGroup(group);
    _searchController.clear();
    _showResults.value = false;
    _focusNode.unfocus();
  }

  Widget _buildDisplayText(UiController uiController) {
    return CustomText(
      widget.title,
      size: 16.sp,
      color: uiController.darkMode.value ? Colors.white54 : Colors.grey[600]!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UiController>();

    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xffDFDFDF)),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main input row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  widget.iconPath ?? AppIcons.hashtagThinIcon,
                  width: 17.w,
                  height: 17.h,
                  color: Color(0xff3C3C3C),
                ),
                SizedBox(width: 11.w),
                Expanded(
                  child: _showResults.value
                      ? HashtagSearchField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          uiController: uiController,
                          hintText: widget.title,

                          onChanged: _performSearch,
                          onClear: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                      : GestureDetector(
                          onTap: () {
                            _showResults.value = true;
                            _focusNode.requestFocus();
                          },
                          child: _buildDisplayText(uiController),
                        ),
                ),
              ],
            ),

            // Search results
            if (_showResults.value) ...[
              SizedBox(height: 8.h),
              Container(
                constraints: BoxConstraints(maxHeight: 300.h),
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Column(
                  children: [
                    // Results list
                    Expanded(
                      child: _isLoading.value
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.r),
                                child: const CircularProgressIndicator(),
                              ),
                            )
                          : _buildResultsList(uiController),
                    ),

                    // Bottom "See List" button
                    HashtagSeeListButton(
                      uiController: uiController,
                      isInFilterMode: widget.isInFilterMode,
                      onTap: () => _navigateToHashtagGroupScreen(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(UiController uiController) {
    final hasSearchQuery = _searchController.text.isNotEmpty;
    final hasResults = _searchResults.isNotEmpty || _groupResults.isNotEmpty;
    final hasRecent = _recentHashtags.isNotEmpty;

    final allItems = <Widget>[];

    if (hasSearchQuery && !hasResults) {
      // No results message
      allItems.add(
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          child: CustomText(
            'No hashtags found',
            size: 14.sp,
            color: Colors.grey,
          ),
        ),
      );
    } else if (!hasSearchQuery && !hasRecent) {
      // No recent hashtags message
      allItems.add(
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.r),
          child: CustomText(
            'No recent hashtags',
            size: 14.sp,
            color: uiController.darkMode.value
                ? Colors.white54
                : Colors.grey[600]!,
          ),
        ),
      );
    } else {
      if (hasSearchQuery) {
        // Group results
        for (int i = 0; i < _groupResults.length; i++) {
          allItems.add(
            HashtagGroupItem(
              group: _groupResults[i],
              onTap: () => _selectGroup(_groupResults[i]),
              uiController: uiController,
            ),
          );
          if (i < _groupResults.length - 1 || _searchResults.isNotEmpty) {
            allItems.add(
              Divider(height: 1.h, color: Colors.grey.withValues(alpha: 0.3)),
            );
          }
        }
        // Individual hashtag results
        for (int i = 0; i < _searchResults.length; i++) {
          allItems.add(
            HashtagItem(
              hashtag: _searchResults[i],
              onTap: () => _selectHashtag(_searchResults[i]),
              uiController: uiController,
            ),
          );
          if (i < _searchResults.length - 1) {
            allItems.add(
              Divider(height: 1.h, color: Colors.grey.withValues(alpha: 0.3)),
            );
          }
        }
      } else {
        // Recent hashtags
        for (int i = 0; i < _recentHashtags.length; i++) {
          final isGroup = _recentHashtagGroups.contains(_recentHashtags[i]);
          allItems.add(
            HashtagItem(
              hashtag: _recentHashtags[i],
              onTap: () => _selectHashtag(_recentHashtags[i]),
              uiController: uiController,
              showFolderIcon: isGroup,
            ),
          );
          if (i < _recentHashtags.length - 1) {
            allItems.add(
              Divider(height: 1.h, color: Colors.grey.withValues(alpha: 0.3)),
            );
          }
        }
      }
    }

    return ListView(shrinkWrap: true, children: allItems);
  }

  Future<void> _navigateToHashtagGroupScreen() async {
    List<HashtagGroup>? previouslySelected;
    if (widget.previouslySelectedHashtags != null &&
        widget.previouslySelectedHashtags!.isNotEmpty) {
      previouslySelected = await _convertHashtagStringsToGroups(
        widget.previouslySelectedHashtags!,
      );
    }

    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HashtagGroupScreen(
          fromSettings: false,
          allowMultipleSelection: true,
          selectedHashtagGroups: previouslySelected,
          onMultipleHashtagGroupsSelected: (selectedGroups) {
            if (widget.onMultipleGroupsSelectedFromPicker != null) {
              widget.onMultipleGroupsSelectedFromPicker!(selectedGroups);
              for (final group in selectedGroups) {
                _recentService.saveRecentHashtagGroup(group);
              }
              _loadRecentHashtags();
            } else {
              for (final group in selectedGroups) {
                _selectGroup(group);
              }
            }
          },
        ),
      ),
    );

    if (result != null && result is List<HashtagGroup>) {
      if (widget.onMultipleGroupsSelectedFromPicker != null) {
        widget.onMultipleGroupsSelectedFromPicker!(result);
        for (final group in result) {
          _recentService.saveRecentHashtagGroup(group);
        }
        _loadRecentHashtags();
      } else {
        for (final group in result) {
          _selectGroup(group);
        }
      }
    }
  }

  Future<List<HashtagGroup>> _convertHashtagStringsToGroups(
    List<String> hashtagStrings,
  ) async {
    final List<HashtagGroup> groups = [];
    try {
      final allGroups = await _hashtagGroupService.getAllGroupsHierarchical();
      for (final hashtagString in hashtagStrings) {
        HashtagGroup? matchedGroup = _findGroupByName(allGroups, hashtagString);
        if (matchedGroup != null) {
          groups.add(matchedGroup);
        }
      }
    } catch (e) {
      debugPrint(
        '[SearchableHashtagWidget] Error converting hashtag strings: $e',
      );
    }
    return groups;
  }

  HashtagGroup? _findGroupByName(List<HashtagGroup> groups, String name) {
    for (final group in groups) {
      if (group.name == name) {
        return group;
      }
      if (group.subgroups != null) {
        final found = _findGroupByName(group.subgroups!, name);
        if (found != null) {
          return found;
        }
      }
    }
    return null;
  }
}
