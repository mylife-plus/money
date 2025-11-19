import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';

/// Widget for inline editing of a subgroup hashtag
class InlineEditSubgroupWidget extends StatelessWidget {
  final HashtagGroup hashtagGroup;
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const InlineEditSubgroupWidget({
    super.key,
    required this.hashtagGroup,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UiController>();

    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: uiController.darkMode.value
              ? Colors.black
              : uiController.currentMainColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextSelectionTheme(
                    data: TextSelectionThemeData(
                      cursorColor: uiController.currentMainColor,
                      selectionColor: uiController.currentMainColor.withValues(
                        alpha: 0.3,
                      ),
                      selectionHandleColor: uiController.currentMainColor,
                    ),
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'edit Hashtag',
                        hintStyle: gfonts.GoogleFonts.kumbhSans(
                          color: uiController.darkMode.value
                              ? Colors.white.withValues(alpha: 0.5)
                              : Colors.grey[500],
                          fontSize: 18,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      style: gfonts.GoogleFonts.kumbhSans(
                        color: uiController.darkMode.value
                            ? Colors.white
                            : Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Save button
                IconButton(
                  onPressed: onSave,
                  icon: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.green,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      'assets/images/ic_tick.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  tooltip: 'Save',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                // Cancel button
                IconButton(
                  onPressed: onCancel,
                  icon: ColorFiltered(
                    colorFilter: ColorFilter.mode(Colors.red, BlendMode.srcIn),
                    child: Image.asset(
                      'assets/images/ic_cross.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  tooltip: 'Cancel',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
