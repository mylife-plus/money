import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/models/transaction_model.dart';
import 'package:moneyapp/utils/date_picker_helper.dart';
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
  String? selectedIcon;
  bool isHashtagSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _filteredRecommendations = [];
  final GlobalKey _searchFieldKey = GlobalKey();
  bool isAddingIncome = false;

  // Predefined icons for selection
  final List<String> predefinedIcons = [
    AppIcons.digitalCurrency,
    AppIcons.bitcoinConvert,
    AppIcons.investment,
    AppIcons.car,
    AppIcons.atm,
    AppIcons.cart,
  ];

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

  Future<void> _showIconSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                'Select Icon',
                size: 18.sp,
                fontWeight: FontWeight.w600,
              ),
              16.verticalSpace,
              // Predefined icons grid
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                ),
                itemCount: predefinedIcons.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedIcon = predefinedIcons[index];
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedIcon == predefinedIcons[index]
                              ? const Color(0xff0088FF)
                              : const Color(0xffDFDFDF),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      padding: EdgeInsets.all(8.w),
                      child: Image.asset(
                        predefinedIcons[index],
                        width: 24.w,
                        height: 24.h,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          6.verticalSpace,
          TransactionItem(
            transaction: Transaction(
              id: 0,
              isExpense: true,
              date: DateTime.now(),
              amount: double.tryParse(widget.amount.replaceAll(',', '.')) ?? 0.0,
              mcc: MCC.fromAsset(
                assetPath: AppIcons.transaction,
                text: widget.title,
                shortText: widget.title.substring(0, 1),
              ),
              note: '',
            ),
            isSelected: false,
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
                  height: 41.h,
                  padding: EdgeInsets.only(left: 7.w, right: 12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),

                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (selectedDate != null)
                          CustomText(
                            'Date',
                            size: 12.sp,
                            color: Color(0xffC1C1C1),
                          ),
                        CustomText(
                          selectedDate == null
                              ? 'select Date'
                              : DateFormat('dd/MM/yyyy').format(selectedDate!),
                          size: 16.sp,
                          color: selectedDate == null
                              ? Color(0xffB4B4B4)
                              : Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              11.horizontalSpace,
              Expanded(
                flex: 204,
                child: Container(
                  height: 41.h,
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isAddingIncome
                        ? Color(0xffE5FFE5)
                        : Color(0xffFFE5E5),
                    border: Border.all(color: const Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            isAddingIncome = !isAddingIncome;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          width: 28.w,
                          height: 26.h,
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
                                : Color(0xffFF0000),
                          ),
                        ),
                      ),
                      6.horizontalSpace,
                      Expanded(
                        child: TextField(
                          // cursorHeight: 15.r,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '0,00',
                            labelText: isAddingIncome ? 'Income' : 'Spending',
                            labelStyle: TextStyle(
                              color: Color(0xffB4B4B4),
                              fontSize: 16.sp,
                            ),
                            hintStyle: TextStyle(
                              color: Color(0xffB4B4B4),
                              fontSize: 16.sp,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            suffixStyle: TextStyle(
                              color: Color(0xffB4B4B4),
                              fontSize: 16.sp,
                            ),
                            suffixText: 'EUR',
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
                    ],
                  ),
                ),
              ),
              Spacer(flex: 26),
            ],
          ),
          7.verticalSpace,

          Row(
            children: [
              InkWell(
                onTap: _showIconSelectionDialog,
                child: Container(
                  height: 41.h,
                  width: 37.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Column(
                    children: [
                      CustomText('Icon', size: 12.sp, color: Color(0xffC1C1C1)),
                      3.verticalSpace,
                      Center(
                        child: Image.asset(
                          selectedIcon ?? AppIcons.plus,
                          height: 17.r,
                          width: 19.r,
                          color: selectedIcon == null
                              ? Color(0xffC9C9C9)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              7.horizontalSpace,

              Expanded(
                flex: 228,
                child: Container(
                  height: 41.h,

                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xffDFDFDF)),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: TextField(
                    textAlign: TextAlign.end,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Description',
                      labelText: 'Description',
                      labelStyle: TextStyle(
                        color: Color(0xffB4B4B4),
                        fontSize: 16.sp,
                      ),
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
              Spacer(flex: 78),
            ],
          ),
          7.verticalSpace,
          InkWell(
            onTap: () {
              setState(() {
                isHashtagSearchActive = !isHashtagSearchActive;
              });
            },
            child: Container(
              height: 41.h,
              width: 37.h,
              decoration: BoxDecoration(
                color: isHashtagSearchActive ? Color(0xff0088FF) : Colors.white,
                border: Border.all(color: const Color(0xffDFDFDF)),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Column(
                children: [
                  CustomText('Add', size: 12.sp, color: Color(0xffC1C1C1)),
                  3.verticalSpace,
                  Center(
                    child: Image.asset(
                      AppIcons.hashtag,
                      height: 15.r,
                      width: 24.r,
                      color: !isHashtagSearchActive
                          ? Colors.black
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
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

          24.verticalSpace,
          // Add more content here as you build the design
        ],
      ),
    );
  }
}
