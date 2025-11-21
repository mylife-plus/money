import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/common/filter_fileds.dart';
import 'package:moneyapp/widgets/common/searchable_hashtag_widget.dart';

class FilterTopSheet extends StatefulWidget {
  final bool isOpenedFromMap;

  const FilterTopSheet({super.key, required this.isOpenedFromMap});

  static Future<T?> show<T>({
    required BuildContext context,
    bool isOpenedFromMap = false,
    VoidCallback? onClose,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FilterTopSheet(isOpenedFromMap: isOpenedFromMap);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }

  @override
  State<FilterTopSheet> createState() => _FilterTopSheetState();
}

class _FilterTopSheetState extends State<FilterTopSheet> {
  // Focus nodes for each search field
  final FocusNode _categoryFocusNode = FocusNode();
  final FocusNode _hashtagFocusNode = FocusNode();
  final FocusNode _contactFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _categoryFocusNode.dispose();
    _hashtagFocusNode.dispose();
    _contactFocusNode.dispose();
    super.dispose();
  }

  DateTime? fromDate;
  DateTime? toDate;

  Future<void> _pickFromDate(BuildContext context) async {
    final uiController = Get.find<UiController>();

    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: toDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            useMaterial3: true,
            colorScheme: uiController.darkMode.value
                ? ColorScheme.dark(
                    primary: uiController.currentMainColor,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: uiController.currentMainColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        fromDate = picked;
      });
    }
  }

  Future<void> _pickToDate(BuildContext context) async {
    final uiController = Get.find<UiController>();

    final picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: fromDate ?? DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            useMaterial3: true,
            colorScheme: uiController.darkMode.value
                ? ColorScheme.dark(
                    primary: uiController.currentMainColor,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: uiController.currentMainColor,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        toDate = picked;
      });
    }
  }

  /// Handle focus shifting when a field loses focus
  void _handleFocusShift(String fieldName) {
    // Small delay to ensure focus change is processed
    Future.delayed(const Duration(milliseconds: 50), () {
      // Check if any field still has focus
      if (!_categoryFocusNode.hasFocus &&
          !_hashtagFocusNode.hasFocus &&
          !_contactFocusNode.hasFocus) {
        // Shift focus to the next available field
        switch (fieldName) {
          case 'category':
            _hashtagFocusNode.requestFocus();
            debugPrint(
              '[FilterTopSheet] Focus shifted from category to hashtag',
            );
            break;
          case 'hashtag':
            _contactFocusNode.requestFocus();
            debugPrint(
              '[FilterTopSheet] Focus shifted from hashtag to contact',
            );
            break;
          case 'contact':
            _categoryFocusNode.requestFocus();
            debugPrint(
              '[FilterTopSheet] Focus shifted from contact to category',
            );
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final uiController = Get.put(UiController());
    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8.r),
              bottomRight: Radius.circular(8.r),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppIcons.filter, height: 28.r, width: 28.r),
                    ],
                  ),
                ),
                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Column(
                      children: [
                        // Date range filters
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => _pickFromDate(context),
                                child: Container(
                                  padding: EdgeInsets.all(9.r),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Color(0xffDFDFDF),
                                    ),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        AppIcons.dateIcon,
                                        height: 24.r,
                                        width: 24.r,
                                      ),
                                      10.horizontalSpace,
                                      CustomText(
                                        fromDate == null
                                            ? 'from date'
                                            : DateFormat(
                                                'dd.MM.yyyy',
                                              ).format(fromDate!),
                                        size: fromDate == null ? 20.sp : 20.sp,
                                        textAlign: TextAlign.center,
                                        color: fromDate == null
                                            ? Color(0xffB4B4B4)
                                            : Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            5.horizontalSpace,
                            Expanded(
                              child: InkWell(
                                onTap: () => _pickToDate(context),
                                child: Container(
                                  padding: EdgeInsets.all(9.r),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Color(0xffDFDFDF),
                                    ),
                                    borderRadius: BorderRadius.circular(6.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        AppIcons.dateIcon,
                                        height: 24.r,
                                        width: 24.r,
                                      ),
                                      10.horizontalSpace,
                                      CustomText(
                                        toDate == null
                                            ? 'to date'
                                            : DateFormat(
                                                'dd.MM.yyyy',
                                              ).format(toDate!),
                                        size: toDate == null ? 20.sp : 20.sp,
                                        textAlign: TextAlign.center,
                                        color: toDate == null
                                            ? Color(0xffB4B4B4)
                                            : Colors.black,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        4.verticalSpace,
                        Container(
                          height: 36.h,
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            // vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xffDFDFDF)),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                AppIcons.categoryIcon,
                                height: 20.r,
                                width: 20.r,
                              ),
                              11.horizontalSpace,
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: TextField(
                                    cursorHeight: 15.r,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'filter Categories',
                                      hintStyle: TextStyle(
                                        color: Color(0xffB4B4B4),
                                      ),
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    style: TextStyle(fontSize: 16.sp),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        4.verticalSpace,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SearchableHashtagWidget(
                              title: 'filter Hashtags',
                              onHashtagSelected: (hashtag) {
                                // controller.addHashtag(hashtag);
                                debugPrint(
                                  '[FilterTopSheet] Added hashtag: $hashtag',
                                );
                              },
                              onGroupSelected: (group) {
                                // controller.addHashtagGroup(group);
                                debugPrint(
                                  '[FilterTopSheet] Added hashtag group: ${group.name}',
                                );
                              },
                              onMultipleGroupsSelectedFromPicker: (groups) {
                                // Replace entire selection when coming back from picker
                                // controller.replaceSelectedHashtags(groups);
                                debugPrint(
                                  '[FilterTopSheet] Replaced hashtags with ${groups.length} new groups',
                                );
                              },
                              onFocusChanged: (isFocused) {
                                if (!isFocused) {
                                  _handleFocusShift('hashtag');
                                }
                              },
                              // previouslySelectedHashtags: controller.selectedHashtags
                              //     .toList(), // Pass previously selected hashtags
                              isInFilterMode:
                                  true, // Remove bottom padding in filter mode
                              backgroundColor: uiController.darkMode.value
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : Colors.white,
                            ),

                            // Selected hashtags chips
                            // Obx(() {
                            //   if (controller.selectedHashtags.isEmpty) {
                            //     return const SizedBox.shrink();
                            //   }
                            //
                            //   return Container(
                            //     padding: const EdgeInsets.all(8),
                            //     child: Wrap(
                            //       spacing: 8,
                            //       runSpacing: 4,
                            //       children: controller.displayHashtags.map((hashtag) {
                            //         return Chip(
                            //           label: Text(
                            //             '#$hashtag',
                            //             style: GoogleFonts.kumbhSans(
                            //               fontSize: 12,
                            //               fontWeight: FontWeight.w400,
                            //             ),
                            //           ),
                            //           deleteIcon: const Icon(Icons.close, size: 16),
                            //           onDeleted: () {
                            //             debugPrint('Removing hashtag: $hashtag');
                            //             controller.removeHashtag(hashtag);
                            //           },
                            //           backgroundColor: uiController.darkMode.value
                            //               ? Colors.white.withValues(alpha: 0.2)
                            //               : Colors.blue.withValues(alpha: 0.1),
                            //         );
                            //       }).toList(),
                            //     ),
                            //   );
                            // }),
                          ],
                        ),
                        25.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: 44.h,
                              width: 144.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 4.0,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomText(
                                  'reset',
                                  size: 20.sp,
                                  color: Color(0xffFF0000),
                                ),
                              ),
                            ),
                            Container(
                              height: 44.h,
                              width: 144.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(13.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 4.0,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: CustomText(
                                  'filter',
                                  size: 20.sp,
                                  color: Color(0xff0071FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
