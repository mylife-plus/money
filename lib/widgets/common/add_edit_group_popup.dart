import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';

/// Popup dialog for adding or editing hashtag/contact groups and subgroups
class AddEditGroupPopup extends StatefulWidget {
  final bool isHashtagMode; // true for hashtags, false for contacts
  final String? initialName; // For editing or pre-filled name
  final int? editItemId; // If editing, the ID of the item
  final int? parentId; // For subgroups, the parent group ID
  final bool isMainGroup; // true for main groups, false for subgroups
  final Function(String name, int? parentId)? onSave; // Callback when saved
  final VoidCallback? onCancel; // Callback when cancelled
  final List<HashtagGroup>? groupList;

  const AddEditGroupPopup({
    super.key,
    required this.isHashtagMode,
    this.initialName,
    this.editItemId,
    this.parentId,
    this.isMainGroup = false,
    this.onSave,
    this.onCancel,
    this.groupList,
  });

  @override
  State<AddEditGroupPopup> createState() => _AddEditGroupPopupState();
}

class _AddEditGroupPopupState extends State<AddEditGroupPopup> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final TextEditingController _newCategoryController = TextEditingController();
  final FocusNode _newCategoryFocusNode = FocusNode();
  int? selectedParentGroup;
  bool isAddingNewCategory = false;

  // Special values for dropdown
  static const int _selectCategoryValue = -1;
  static const int _addCategoryValue = -2;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    if (widget.groupList != null && widget.groupList!.isNotEmpty) {
      selectedParentGroup = widget.parentId ?? _selectCategoryValue;
    }

    // Auto-focus name field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.groupList == null || widget.groupList!.isEmpty) {
        _nameFocusNode.requestFocus();
      }

      // Position cursor at the end
      _nameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _nameController.text.length),
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    _newCategoryController.dispose();
    _newCategoryFocusNode.dispose();
    super.dispose();
  }

  void _handleSave() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter a name',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // If adding new category, validate and use the new category name
    if (isAddingNewCategory) {
      final newCategoryName = _newCategoryController.text.trim();
      if (newCategoryName.isEmpty) {
        Get.snackbar(
          'Validation Error',
          'Please enter a category name',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      // For new category, we'll pass null as parentId
      // and the caller should handle creating the new category
      widget.onSave?.call(name, null);
    } else if (selectedParentGroup == _selectCategoryValue) {
      Get.snackbar(
        'Validation Error',
        'Please select a category',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    } else {
      widget.onSave?.call(name, selectedParentGroup);
    }

    Navigator.of(context).pop();
  }

  void _handleCancel() {
    widget.onCancel?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UiController>();
    final prefixChar = widget.isHashtagMode ? '#' : '@';

    String title;
    if (widget.editItemId != null) {
      // Editing mode
      title = widget.isMainGroup
          ? '$prefixChar Edit ${widget.isHashtagMode ? 'Hashtag' : 'Contact'} Group'
          : '$prefixChar Edit ${widget.isHashtagMode ? 'Hashtag' : 'Contact'}';
    } else {
      // Adding mode
      title = widget.isMainGroup
          ? '$prefixChar New ${widget.isHashtagMode ? 'Hashtag' : 'Contact'} Group'
          : '$prefixChar New ${widget.isHashtagMode ? 'Hashtag' : 'Contact'}';
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: uiController.darkMode.value ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close and check buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close button
                GestureDetector(
                  onTap: _handleCancel,
                  child: const Icon(Icons.close, color: Colors.red, size: 28),
                ),
                // Title
                Text(
                  title,
                  style: GoogleFonts.kumbhSans(
                    color: uiController.darkMode.value
                        ? Colors.white
                        : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Check button
                GestureDetector(
                  onTap: _handleSave,
                  child: const Icon(Icons.check, color: Colors.green, size: 28),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (widget.groupList != null && widget.groupList!.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: selectedParentGroup,
                    isExpanded: true,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: uiController.currentMainColor,
                    ),
                    items: [
                      // "Select category" option
                      DropdownMenuItem<int?>(
                        value: _selectCategoryValue,
                        child: Text(
                          'Select category',
                          style: GoogleFonts.kumbhSans(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      // "Add category" option
                      DropdownMenuItem<int?>(
                        value: _addCategoryValue,
                        child: Text(
                          'Add category',
                          style: GoogleFonts.kumbhSans(
                            color: uiController.currentMainColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Existing categories
                      ...widget.groupList!.map(
                        (group) => DropdownMenuItem<int?>(
                          value: group.id,
                          child: Text(
                            group.name,
                            style: GoogleFonts.kumbhSans(
                              color: uiController.darkMode.value
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        selectedParentGroup = val;
                        isAddingNewCategory = val == _addCategoryValue;

                        // Focus on new category field when "Add category" is selected
                        if (isAddingNewCategory) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _newCategoryFocusNode.requestFocus();
                          });
                        }
                      });
                    },
                  ),
                ),
              ),
              6.verticalSpace,

              // New category text field (shown when "Add category" is selected)
              if (isAddingNewCategory) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextSelectionTheme(
                    data: TextSelectionThemeData(
                      cursorColor: uiController.currentMainColor,
                      selectionColor: uiController.currentMainColor.withValues(
                        alpha: 0.3,
                      ),
                      selectionHandleColor: uiController.currentMainColor,
                    ),
                    child: TextField(
                      controller: _newCategoryController,
                      focusNode: _newCategoryFocusNode,
                      style: GoogleFonts.kumbhSans(
                        color: uiController.darkMode.value
                            ? Colors.white
                            : Colors.black,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter new category name',
                        hintStyle: GoogleFonts.kumbhSans(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                6.verticalSpace,
              ],
            ],
            // Name input field
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextSelectionTheme(
                data: TextSelectionThemeData(
                  cursorColor: uiController.currentMainColor,
                  selectionColor: uiController.currentMainColor.withValues(
                    alpha: 0.3,
                  ),
                  selectionHandleColor: uiController.currentMainColor,
                ),
                child: TextField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  style: GoogleFonts.kumbhSans(
                    color: uiController.darkMode.value
                        ? Colors.white
                        : Colors.black,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.isMainGroup
                        ? '${widget.isHashtagMode ? 'Hashtag' : 'Contact'} Group Name'
                        : '${widget.isHashtagMode ? 'Hashtag' : 'Contact'} Name',
                    hintStyle: GoogleFonts.kumbhSans(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _handleSave(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
