import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/widgets/common/category_chip.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/transactions/transaction_item.dart';
import 'package:moneyapp/widgets/common/search_field_with_suggestions.dart';

class SplitSpendingContent extends StatefulWidget {
  final String label;
  final String title;
  final String category;
  final String amount;

  const SplitSpendingContent({
    super.key,
    required this.label,
    required this.title,
    required this.category,
    required this.amount,
  });

  @override
  State<SplitSpendingContent> createState() => _SplitSpendingContentState();
}

class _SplitSpendingContentState extends State<SplitSpendingContent> {
  DateTime? selectedDate;
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
          6.verticalSpace,
          TransactionItem(
            label: widget.label,
            title: widget.title,
            category: widget.category,
            amount: widget.amount,
          ),
          21.verticalSpace,
          Row(
            children: [
              8.horizontalSpace,
              Expanded(child: CustomText('into', size: 16.sp)),
              InkWell(
                child: Image.asset(AppIcons.plus, height: 21.r, width: 21.r),
              ),

              13.horizontalSpace,
            ],
          ),
          19.verticalSpace,

          Row(
            children: [
              InkWell(
                onTap: () {
                  showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
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
                        '0',
                        size: 16.sp,
                        color: isHashtagSearchActive
                            ? Colors.white
                            : Color(0xff0088FF),
                      ),
                      CustomText(
                        ' #',
                        size: 16.sp,
                        color: isHashtagSearchActive
                            ? Colors.white
                            : Color(0xffA0A0A0),
                      ),
                    ],
                  ),
                ),
              ),
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
                  child: Image.asset(
                    AppIcons.plus,
                    height: 21.r,
                    width: 21.r,
                    color: const Color(0xffA0A0A0),
                  ),
                ),
              ),
              7.horizontalSpace,

              Expanded(
                flex: 215,
                child: Container(
                  height: 35.h,

                  padding: EdgeInsets.symmetric(
                    horizontal: 15.w,
                    // vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: TextField(
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Description',
                        hintStyle: TextStyle(color: Color(0xffB4B4B4)),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(fontSize: 16.sp),
                    ),
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
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText('Amount', size: 10.sp),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: TextField(
                            cursorHeight: 15.r,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '€ 0,00',
                              hintStyle: TextStyle(color: Color(0xffB4B4B4)),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(fontSize: 16.sp),
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

          24.verticalSpace,
          // Add more content here as you build the design
        ],
      ),
    );
  }
}
