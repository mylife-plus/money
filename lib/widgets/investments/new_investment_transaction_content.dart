import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/investment_recommendation.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/utils/date_picker_helper.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/investments/select_investment_field.dart';

class NewInvestmentTransactionContent extends StatefulWidget {
  const NewInvestmentTransactionContent({super.key});

  @override
  State<NewInvestmentTransactionContent> createState() =>
      _NewInvestmentTransactionContentState();
}

class _NewInvestmentTransactionContentState
    extends State<NewInvestmentTransactionContent> {
  DateTime? selectedDate;
  String? selectedIcon;
  bool isAddingInvestment = true;

  bool isHashtagSearchActive = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<InvestmentRecommendation> _filteredRecommendations = [];
  final GlobalKey _searchFieldKey = GlobalKey();
  final InvestmentController _investmentController = Get.find();

  // Predefined icons for selection
  final List<String> predefinedIcons = [
    AppIcons.digitalCurrency,
    AppIcons.bitcoinConvert,
    AppIcons.investment,
    AppIcons.car,
    AppIcons.atm,
    AppIcons.cart,
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
        _filteredRecommendations = _investmentController.recommendations
            .where(
              (item) => item.text.toLowerCase().contains(
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
        _filteredRecommendations = _investmentController.recommendations
            .toList();
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
    _searchController.clear();
    _searchFocusNode.unfocus();
    Get.toNamed(AppRoutes.investmentList.path);
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
    return GestureDetector(
      onTap: () {
        // Hide keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 7.w),
        child: Column(
          children: [
            Center(
              child: InkWell(
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
            10.verticalSpace,
            buildTextField('Description', ''),
            7.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 41.h,
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isAddingInvestment
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
                              isAddingInvestment = !isAddingInvestment;
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
                              isAddingInvestment ? AppIcons.plus : AppIcons.minus,
                              color: isAddingInvestment
                                  ? Color(0xff00C00D)
                                  : Color(0xffFF0000),
                            ),
                          ),
                        ),
                        6.horizontalSpace,
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0,00',
                              labelText: isAddingInvestment ? 'Income' : 'Spending',
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
                              color: isAddingInvestment
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
                4.horizontalSpace,
                Expanded(
                  child: SelectInvestmentField(
                    suggestions: _investmentController.recommendations,
                    controller: _searchController,
                    hintText: 'select',
                    onAdd: _addNewItem,
                    onSelected: (value) {
                      _searchController.text = value.text;
                      print('Selected: ${value.text}');
                    },
                  ),
                ),
              ],
            ),
            7.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: buildTextField(
                    'Price',
                    '0.00',
                    keyboardType: TextInputType.number,
                    showCurrency: true,
                  ),
                ),
                4.horizontalSpace,
                Expanded(
                  child: buildTextField(
                    'Total',
                    '0.00',
                    keyboardType: TextInputType.number,
                    showCurrency: true,
                  ),
                ),
              ],
            ),

            25.verticalSpace,
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
                      child: Image.asset(AppIcons.closeBold),
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
                      child: Image.asset(AppIcons.tickBold),
                    ),
                  ),
                ),
              ],
            ),
            27.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    String hint, {
    Color? backgroundColor,
    Widget? prefixWidget,
    TextInputType? keyboardType,
    bool showCurrency = false,
  }) {
    return Container(
      height: 41.h,
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        border: Border.all(color: const Color(0xffDFDFDF)),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: prefixWidget != null
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(label, size: 10.sp),
                    prefixWidget,
                  ],
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: TextField(
                      keyboardType: keyboardType,
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
            )
          : TextField(
              keyboardType: keyboardType,
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                labelText: label,
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
                suffixText: showCurrency ? 'EUR' : null,
                suffixStyle: TextStyle(
                  color: Color(0xffB4B4B4),
                  fontSize: 16.sp,
                ),
              ),
              style: TextStyle(fontSize: 16.sp),
            ),
    );
  }
}
