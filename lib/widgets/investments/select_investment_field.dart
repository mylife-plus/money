import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:moneyapp/models/investment_recommendation.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

/// A reusable search field with dropdown suggestions using Flutter's Autocomplete
class SelectInvestmentField extends StatelessWidget {
  final List<InvestmentRecommendation> suggestions;
  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onAdd;
  final Function(InvestmentRecommendation)? onSelected;

  const SelectInvestmentField({
    super.key,
    required this.suggestions,
    this.controller,
    this.hintText = 'select',
    this.onAdd,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<InvestmentRecommendation>(
      displayStringForOption: (InvestmentRecommendation option) => option.text,
      optionsBuilder: (TextEditingValue textEditingValue) {
        // Always return matching suggestions
        if (textEditingValue.text.isEmpty) {
          return suggestions;
        }
        final filtered = suggestions.where((InvestmentRecommendation option) {
          return option.text.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        }).toList();

        // Return at least one result to show the dropdown with "add new"
        return filtered;
      },
      onSelected: (InvestmentRecommendation selection) {
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
              height: 35.h,

              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xffDFDFDF)),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText('Investment', size: 10.sp),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          textAlign: TextAlign.end,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: hintText,

                            hintStyle: const TextStyle(
                              color: Color(0xffB4B4B4),
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(fontSize: 16.sp),
                          onChanged: (value) {
                            if (controller != null) {
                              controller!.text = value;
                            }
                          },
                          onTap: () {
                            // Clear and restore text to trigger optionsBuilder
                            final currentText = textEditingController.text;
                            if (currentText.isNotEmpty) {
                              textEditingController.clear();
                              // Use a microtask to restore the text immediately after
                              Future.microtask(() {
                                textEditingController.text = currentText;
                                textEditingController.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: currentText.length,
                                );
                              });
                            }
                          },
                        ),
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
            AutocompleteOnSelected<InvestmentRecommendation> onSelected,
            Iterable<InvestmentRecommendation> options,
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
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffB6B6B6)),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length + (onAdd != null ? 1 : 0),
                    separatorBuilder: (context, index) => Divider(
                      height: 1.h,
                      thickness: 1,
                      color: const Color(0xffDFDFDF),
                      indent: 0,
                      endIndent: 0,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      // Check if this is the "See All" button
                      if (onAdd != null && index == options.length) {
                        return InkWell(
                          onTap: onAdd,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15.w,
                              vertical: 12.h,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomText(
                                  'add new',
                                  size: 16.sp,
                                  color: Color(0xff0088FF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final InvestmentRecommendation option = options.elementAt(
                        index,
                      );
                      return InkWell(
                        onTap: () {
                          onSelected(option);
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(11.w, 11.h, 15.w, 18.h),
                          child: Row(
                            children: [
                              // Display image based on type
                              if (option.isAssetImage)
                                Image.asset(
                                  option.assetPath!,
                                  width: 16.w,
                                  height: 16.h,
                                )
                              else if (option.isFileImage)
                                Image.file(
                                  option.imageFile!,
                                  width: 16.w,
                                  height: 16.h,
                                ),
                              10.horizontalSpace,
                              Expanded(
                                child: CustomText.richText(
                                  children: [
                                    CustomText.span(
                                      option.text,
                                      color: Colors.black,
                                      size: 16.sp,
                                    ),
                                    CustomText.span(
                                      ' ${option.shortText}',
                                      color: Color(0xff999999),
                                      size: 10.sp,
                                    ),
                                  ],
                                ),
                              ),
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
