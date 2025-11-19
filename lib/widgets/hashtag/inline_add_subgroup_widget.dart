import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;
import 'package:moneyapp/controllers/ui_controller.dart';

/// Widget for inline adding of a subgroup hashtag
class InlineAddSubgroupWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const InlineAddSubgroupWidget({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UiController>();

    return Obx(
      () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: BoxDecoration(
          color: uiController.darkMode.value
              ? Colors.grey[900]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(2),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
          dense: true,
          title: Row(
            children: [
              // Hash symbol to match subgroup tiles
              Text(
                '#  ',
                style: gfonts.GoogleFonts.kumbhSans(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
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
                      hintText: 'add Hashtag',
                      hintStyle: gfonts.GoogleFonts.kumbhSans(
                        color: uiController.darkMode.value
                            ? Colors.white.withValues(alpha: 0.5)
                            : Colors.grey[500],
                        fontSize: 18,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: gfonts.GoogleFonts.kumbhSans(
                      color: uiController.darkMode.value
                          ? Colors.white
                          : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Save button
              IconButton(
                onPressed: onSave,
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(Colors.green, BlendMode.srcIn),
                  child: Image.asset(
                    'assets/images/ic_tick.png',
                    width: 20,
                    height: 20,
                  ),
                ),
                tooltip: 'Save',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              // Cancel button
              IconButton(
                onPressed: onCancel,
                icon: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.red.withValues(alpha: 0.7),
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/images/ic_cross.png',
                    width: 20,
                    height: 20,
                  ),
                ),
                tooltip: 'Cancel',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
