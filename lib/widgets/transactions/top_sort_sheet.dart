import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

enum SortOption { highestAmount, mostRecent }

class TopSortSheet extends StatefulWidget {
  final String title;
  final SortOption selectedOption;
  final Function(SortOption) onOptionSelected;

  const TopSortSheet({
    super.key,
    required this.title,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  static Future<SortOption?> show({
    required BuildContext context,
    required String title,
    required SortOption selectedOption,
  }) {
    return showGeneralDialog<SortOption>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        SortOption? result;
        return TopSortSheet(
          title: title,
          selectedOption: selectedOption,
          onOptionSelected: (option) {
            result = option;
            Navigator.of(context).pop(result);
          },
        );
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
  State<TopSortSheet> createState() => _TopSortSheetState();
}

class _TopSortSheetState extends State<TopSortSheet> {
  late SortOption _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.selectedOption;
  }

  String _getOptionLabel(SortOption option) {
    switch (option) {
      case SortOption.highestAmount:
        return 'highest amount';

      case SortOption.mostRecent:
        return 'most recent';
    }
  }

  String _getOptionIcon(SortOption option) {
    switch (option) {
      case SortOption.highestAmount:
        return AppIcons.transaction;

      case SortOption.mostRecent:
        return AppIcons.clock;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
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
                // Header
                Container(
                  padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppIcons.sort, height: 28.r, width: 28.r),
                    ],
                  ),
                ),
                // Sort Options
                Flexible(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 14.h,
                      ),
                      child: Column(
                        spacing: 5.h,
                        children: SortOption.values.map((option) {
                          final isSelected = _selectedOption == option;
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedOption = option;
                              });
                              widget.onOptionSelected(option);
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(
                                17.w,
                                10.h,
                                9.w,
                                10.h,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0088FF)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: AppColors.greyBorder),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    _getOptionIcon(option),
                                    height: 24.r,
                                    width: 24.r,
                                  ),
                                  28.horizontalSpace,
                                  Expanded(
                                    child: CustomText(
                                      _getOptionLabel(option),
                                      size: 20.sp,
                                      fontWeight: FontWeight.w400,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  CustomText(
                                    'top',
                                    size: 20.sp,
                                    fontWeight: FontWeight.w400,
                                    color: isSelected
                                        ? Color(0xffFFFB00)
                                        : Color(0xff0088FF),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                10.verticalSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
