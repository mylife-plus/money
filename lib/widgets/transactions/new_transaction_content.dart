import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/utils/date_picker_helper.dart';
import 'package:moneyapp/widgets/common/category_chip.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/common/search_field_with_suggestions.dart';

class NewTransactionContent extends StatefulWidget {
  const NewTransactionContent({super.key, required this.isExpenseSelected});
  final bool isExpenseSelected;

  @override
  State<NewTransactionContent> createState() => _EditSpendingContentState();
}

class _EditSpendingContentState extends State<NewTransactionContent> {
  DateTime? selectedDate;
  bool isAddingIncome = false;

  bool isHashtagSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _filteredRecommendations = [];
  final GlobalKey _searchFieldKey = GlobalKey();

  // Sample recommendations - replace with your actual data
  final List<String> _allRecommendations = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Healthcare',
    'Bills & Utilities',
    'Travel',
    'Education',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(_onFocusChanged);
    isAddingIncome = !widget.isExpenseSelected;
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredRecommendations = [];
      } else {
        _filteredRecommendations = _allRecommendations
            .where(
              (item) => item.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  void _onFocusChanged() {
    // Show all recommendations when focused and field is empty
    if (_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
      setState(() {
        _filteredRecommendations = _allRecommendations;
      });
    } else if (!_searchFocusNode.hasFocus) {
      // Delay to allow tap on recommendations
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _filteredRecommendations = [];
          });
        }
      });
    }
  }

  void _selectRecommendation(String value) {
    _searchController.text = value;
    _filteredRecommendations = [];
    _searchFocusNode.unfocus();
  }

  void _addNewItem() {
    // TODO: Implement add new item logic
    print('Add new item: ${_searchController.text}');
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  void _seeAll() {
    // TODO: Implement see all logic
    print('See all recommendations');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w),
      child: Column(
        children: [
          8.verticalSpace,

          Row(
            children: [
              InkWell(
                onTap: () {
                  DatePickerHelper.showStyledDatePicker(
                    context,
                    initialDate: selectedDate,
                  ).then((pickedDate) {
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  });
                },
                child: Container(
                  height: 35.h,
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),

                  child: Center(
                    child: CustomText(
                      selectedDate == null
                          ? 'select Date'
                          : DateFormat('dd/MM/yyyy').format(selectedDate!),
                      size: 16.sp,
                      color: selectedDate == null
                          ? Color(0xffB4B4B4)
                          : Colors.black,
                    ),
                  ),
                ),
              ),
              7.horizontalSpace,
              Container(
                height: 35.h,
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                decoration: BoxDecoration(
                  color: isHashtagSearchActive
                      ? Color(0xff0088FF)
                      : Colors.white,
                  border: Border.all(color: Color(0xffDFDFDF)),
                  borderRadius: BorderRadius.circular(6.r),
                ),

                child: InkWell(
                  onTap: () {
                    setState(() {
                      isHashtagSearchActive = !isHashtagSearchActive;
                    });
                  },
                  child: Row(
                    children: [
                      CustomText(
                        '#',
                        size: 16.sp,
                        color: isHashtagSearchActive
                            ? Colors.white
                            : Color(0xffA0A0A0),
                      ),
                    ],
                  ),
                ),
              ),
              6.horizontalSpace,
              CategoryChip(category: 'Travel'),
            ],
          ),
          7.verticalSpace,
          if (isHashtagSearchActive) ...[
            SearchFieldWithSuggestions(
              suggestions: _allRecommendations,
              controller: _searchController,
              hintText: 'Search...',
              onAdd: _addNewItem,
              onSeeAll: _seeAll,
              onSelected: (value) {
                print('Selected: $value');
              },
            ),
            7.verticalSpace,
          ],
          Row(
            children: [
              Container(
                height: 35.h,
                width: 35.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xffDFDFDF)),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Center(
                  child: Image.asset(AppIcons.atm, height: 20.r, width: 20.r),
                ),
              ),
              7.horizontalSpace,

              Expanded(
                flex: 215,
                child: Container(
                  height: 35.h,

                  padding: EdgeInsets.symmetric(horizontal: 7.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText('Description', size: 10.sp),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: TextField(
                            textAlign: TextAlign.end,
                            decoration: InputDecoration(
                              border: InputBorder.none,

                              hintText: 'Description',
                              hintStyle: TextStyle(
                                color: Color(0xffB4B4B4),
                                fontSize: 16.sp,
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              6.horizontalSpace,
              Expanded(
                flex: 116,
                child: Container(
                  height: 35.h,
                  padding: EdgeInsets.symmetric(
                    horizontal: 7.w,
                    // vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isAddingIncome
                        ? Color(0xffE5FFE5)
                        : Color(0xffFFE5E5),
                    border: Border.all(color: const Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          CustomText('Amount', size: 10.sp),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isAddingIncome = !isAddingIncome;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(2.r),
                              width: 16.w,
                              height: 14.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(color: Color(0xffDFDFDF)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                isAddingIncome ? AppIcons.plus : AppIcons.minus,
                                color: isAddingIncome
                                    ? Color(0xff00C00D)
                                    : Color(0xffFFE5E5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: TextField(
                            cursorHeight: 15.r,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '€ 0,00',
                              hintStyle: TextStyle(
                                color: Color(0xffB4B4B4),
                                fontSize: 16.sp,
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: isAddingIncome
                                  ? Color(0xff00C00D)
                                  : Color(0xffFF0000),
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          28.verticalSpace,
          // Add more content here as you build the design
        ],
      ),
    );
  }
}
