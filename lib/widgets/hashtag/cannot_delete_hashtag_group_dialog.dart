import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart' as gfonts;
import 'package:moneyapp/controllers/ui_controller.dart';

/// Dialog shown when a hashtag group cannot be deleted due to existing memories
class CannotDeleteHashtagGroupDialog extends StatelessWidget {
  final String groupName;
  final int memoryCount;

  const CannotDeleteHashtagGroupDialog({
    super.key,
    required this.groupName,
    required this.memoryCount,
  });

  @override
  Widget build(BuildContext context) {
    final uiController = Get.find<UiController>();

    return Obx(
      () => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: uiController.darkMode.value
                ? Colors.grey[900]
                : Colors.white,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with icon
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cannot Delete Hashtag Group',
                      style: gfonts.GoogleFonts.kumbhSans(
                        color: uiController.darkMode.value
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Message
              Text(
                'The hashtag group "$groupName" cannot be deleted because it is being used by $memoryCount ${memoryCount == 1 ? 'memory' : 'memories'}.',
                style: gfonts.GoogleFonts.kumbhSans(
                  color: uiController.darkMode.value
                      ? Colors.white70
                      : Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              // Info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'To delete this hashtag group, first remove the hashtags from all memories that use them, or delete those memories.',
                        style: gfonts.GoogleFonts.kumbhSans(
                          color: Colors.orange[700],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // OK button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: gfonts.GoogleFonts.kumbhSans(
                      color: uiController.currentMainColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
