import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/widgets/custom_text.dart';
import 'package:moneyapp/widgets/select_investment_field.dart';

class NewTradeContent extends StatefulWidget {
  const NewTradeContent({super.key});

  @override
  State<NewTradeContent> createState() => _NewTradeContentState();
}

class _NewTradeContentState extends State<NewTradeContent> {
  DateTime? selectedDate;

  bool isHashtagSearchActive = false;
  final TextEditingController _soldInvestmentTextController =
      TextEditingController();
  final TextEditingController _boughtInvestmentTextController =
      TextEditingController();
  final FocusNode _soldInvestmentFocusNode = FocusNode();
  final FocusNode _boughtInvestmentFocusNode = FocusNode();
  List<Map<String, String>> _filteredRecommendations = [];
  final GlobalKey _searchFieldKey = GlobalKey();

  // Sample recommendations - replace with your actual data
  final List<Map<String, String>> _allRecommendations = [
    {'emoji': '🪙', 'text': 'Bitcoin', 'shortText': 'BTC'},
    {'emoji': '🏡', 'text': 'Haus', 'shortText': '🏡'},
  ];

  @override
  void initState() {
    super.initState();
    _soldInvestmentTextController.addListener(_onSoldInvestmentSearchChanged);
    _boughtInvestmentTextController.addListener(
      _onBoughtInvestmentSearchChanged,
    );
    _soldInvestmentFocusNode.addListener(_onSoldInvestmentFocusChanged);
    _boughtInvestmentFocusNode.addListener(_onBoughtInvestmentFocusChanged);
  }

  @override
  void dispose() {
    _soldInvestmentTextController.removeListener(
      _onSoldInvestmentSearchChanged,
    );
    _soldInvestmentTextController.dispose();
    _boughtInvestmentTextController.removeListener(
      _onBoughtInvestmentSearchChanged,
    );
    _boughtInvestmentTextController.dispose();
    _soldInvestmentFocusNode.removeListener(_onSoldInvestmentFocusChanged);
    _soldInvestmentFocusNode.dispose();
    _boughtInvestmentFocusNode.removeListener(_onBoughtInvestmentFocusChanged);
    _boughtInvestmentFocusNode.dispose();
    super.dispose();
  }

  void _onSoldInvestmentSearchChanged() {
    setState(() {
      if (_soldInvestmentTextController.text.isEmpty) {
        _filteredRecommendations = [];
      } else {
        _filteredRecommendations = _allRecommendations
            .where(
              (item) => item['text']!.toLowerCase().contains(
                _soldInvestmentTextController.text.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  void _onBoughtInvestmentSearchChanged() {
    setState(() {
      if (_boughtInvestmentTextController.text.isEmpty) {
        _filteredRecommendations = [];
      } else {
        _filteredRecommendations = _allRecommendations
            .where(
              (item) => item['text']!.toLowerCase().contains(
                _boughtInvestmentTextController.text.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  void _onSoldInvestmentFocusChanged() {
    // Show all recommendations when focused and field is empty
    if (_soldInvestmentFocusNode.hasFocus &&
        _soldInvestmentTextController.text.isEmpty) {
      setState(() {
        _filteredRecommendations = _allRecommendations.toList();
      });
    } else if (!_soldInvestmentFocusNode.hasFocus) {
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

  void _onBoughtInvestmentFocusChanged() {
    // Show all recommendations when focused and field is empty
    if (_boughtInvestmentFocusNode.hasFocus &&
        _boughtInvestmentTextController.text.isEmpty) {
      setState(() {
        _filteredRecommendations = _allRecommendations.toList();
      });
    } else if (!_boughtInvestmentFocusNode.hasFocus) {
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

  void _selectSoldRecommendation(String value) {
    _soldInvestmentTextController.text = value;
    _filteredRecommendations = [];
    _soldInvestmentFocusNode.unfocus();
  }

  void _selectBoughtRecommendation(String value) {
    _boughtInvestmentTextController.text = value;
    _filteredRecommendations = [];
    _boughtInvestmentFocusNode.unfocus();
  }

  void _addNewItem() {
    // TODO: Implement add new item logic
    print('Add new item: ${_soldInvestmentTextController.text}');
    _soldInvestmentTextController.clear();
    _soldInvestmentFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w),
      child: Column(
        children: [
          Center(
            child: InkWell(
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
                // height: 35.h,
                width: 100,
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Color(0xffDFDFDF)),
                  borderRadius: BorderRadius.circular(6.r),
                ),

                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText('Date', color: Colors.black, size: 12.sp),
                      Row(
                        children: [
                          Expanded(
                            child: CustomText(
                              selectedDate == null
                                  ? 'select Date'
                                  : DateFormat(
                                      'dd.MM.yyyy',
                                    ).format(selectedDate!),
                              size: selectedDate == null ? 12.sp : 16.sp,
                              textAlign: TextAlign.center,
                              color: selectedDate == null
                                  ? Color(0xffB4B4B4)
                                  : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          16.verticalSpace,
          Column(
            children: [
              // Sold item
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Color(0xffFFEFEF),
                  border: Border.all(color: Color(0xffDFDFDF)),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(4.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText('sold', color: Color(0xffFF0000), size: 16.sp),
                    6.verticalSpace,
                    Row(
                      children: [
                        Expanded(child: buildTextField('Amount', '0')),
                        4.horizontalSpace,
                        Expanded(
                          child: SelectInvestmentField(
                            suggestions: [..._allRecommendations],
                            controller: _soldInvestmentTextController,
                            hintText: 'select',
                            onAdd: _addNewItem,
                            onSelected: (value) {
                              _selectSoldRecommendation(value['text'] ?? '');
                            },
                          ),
                        ),
                      ],
                    ),
                    6.verticalSpace,
                    Row(
                      children: [
                        Expanded(child: buildTextField('Price', '\$ 0.00')),
                        4.horizontalSpace,
                        Expanded(child: buildTextField('Total', '\$ 0.00')),
                      ],
                    ),

                    9.verticalSpace,
                  ],
                ),
              ),
              // Bought item
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Color(0xffE5FFE7),
                  border: Border.all(color: Color(0xffDFDFDF)),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(4.r),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText('bought', color: Color(0xff009E0B), size: 16.sp),
                    6.verticalSpace,
                    Row(
                      children: [
                        Expanded(child: buildTextField('Amount', '0')),
                        4.horizontalSpace,
                        Expanded(
                          child: SelectInvestmentField(
                            suggestions: [..._allRecommendations],
                            controller: _boughtInvestmentTextController,
                            hintText: 'select',
                            onAdd: _addNewItem,
                            onSelected: (value) {
                              _selectBoughtRecommendation(value['text'] ?? '');
                            },
                          ),
                        ),
                      ],
                    ),
                    6.verticalSpace,
                    Row(
                      children: [
                        Expanded(child: buildTextField('Price', '\$ 0.00')),
                        4.horizontalSpace,
                        Expanded(child: buildTextField('Total', '\$ 0.00')),
                      ],
                    ),

                    9.verticalSpace,
                  ],
                ),
              ),
            ],
          ),

          27.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  height: 44.r,
                  width: 44.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: Image.asset(AppIcons.tickBold),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  height: 44.r,
                  width: 44.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: Image.asset(AppIcons.closeBold),
                  ),
                ),
              ),
            ],
          ),
          33.verticalSpace,
        ],
      ),
    );
  }

  Widget buildTextField(String label, String hint) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(label, size: 10.sp),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: TextField(
                cursorHeight: 15.r,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hint,
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
    );
  }
}
