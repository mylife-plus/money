import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/widgets/custom_text.dart';

/// A reusable search field with dropdown suggestions using Flutter's Autocomplete
class SearchFieldWithSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onAdd;
  final VoidCallback? onSeeAll;
  final Function(String)? onSelected;

  const SearchFieldWithSuggestions({
    super.key,
    required this.suggestions,
    this.controller,
    this.hintText = 'Search...',
    this.onAdd,
    this.onSeeAll,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return suggestions; // Show all when empty
        }
        return suggestions.where((String option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      onSelected: (String selection) {
        onSelected?.call(selection);
      },
      fieldViewBuilder:
          (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            // Use provided controller or the one from fieldViewBuilder
            if (controller != null) {
              textEditingController.text = controller!.text;
              textEditingController.selection = controller!.selection;
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xffB6B6B6)),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 9.h),
                child: Row(
                  children: [
                    Image.asset(
                      AppIcons.search,
                      height: 18.r,
                      width: 18.r,
                      color: const Color(0xffA0A0A0),
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: TextField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: hintText,
                          hintStyle: const TextStyle(color: Color(0xffB4B4B4)),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(fontSize: 20.sp),
                        onChanged: (value) {
                          if (controller != null) {
                            controller!.text = value;
                          }
                        },
                      ),
                    ),
                    if (onAdd != null)
                      InkWell(
                        onTap: onAdd,
                        child: CustomText(
                          'add',
                          size: 16.sp,
                          color: const Color(0xff0088FF),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
      optionsViewBuilder:
          (
            BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options,
          ) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(6.r),
                child: Container(
                  constraints: BoxConstraints(maxHeight: 200.h),
                  width: MediaQuery.of(context).size.width - 14.w,
                  // margin: EdgeInsets.only(top: 4.h),
                  decoration: BoxDecoration(
                    color: Color(0xffEBF6FF),
                    border: Border.all(color: const Color(0xffB6B6B6)),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length + (onSeeAll != null ? 1 : 0),
                    separatorBuilder: (context, index) => Divider(
                      height: 1.h,
                      thickness: 1,
                      color: const Color(0xffDFDFDF),
                      indent: 0,
                      endIndent: 0,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      // Check if this is the "See All" button
                      if (onSeeAll != null && index == options.length) {
                        return InkWell(
                          onTap: onSeeAll,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15.w,
                              vertical: 12.h,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(
                                  'See All',
                                  size: 20.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final String option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(11.w, 11.h, 15.w, 18.h),
                          child: Row(
                            children: [
                              CustomText(
                                '#',
                                size: 20.sp,
                                color: Color(0xff9D9D9D),
                              ),
                              10.horizontalSpace,
                              Expanded(child: CustomText(option, size: 20.sp)),
                              CustomText('Shopping', size: 12.sp),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
    );
  }
}
