import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  UiController uiController = Get.find<UiController>();
  bool isDataUpload = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffDEEDFF),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),

        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(AppIcons.hashtag, width: 22.r, height: 22.r),
            // 13.horizontalSpace,
            CustomText(
              '📥 Upload 💸Spending',
              size: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            35.horizontalSpace,
          ],
        ),
        centerTitle: true,
        backgroundColor: uiController.currentMainColor,
        foregroundColor: uiController.darkMode.value
            ? Colors.white
            : Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(
          color: uiController.darkMode.value ? Colors.white : Colors.white,
        ),
        actions: [
          // Hide add button in filter mode
          // if (!widget.allowMultipleSelection)
          Padding(
            padding: EdgeInsets.only(right: 16.0.w),
            child: InkWell(
              onTap: () {
                setState(() {
                  isDataUpload = !isDataUpload;
                });
              },
              child: Image.asset(
                isDataUpload ? AppIcons.tickLight : AppIcons.plusThin,
                width: 21.r,
                height: 21.r,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: isDataUpload
          ? SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 27.0.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    39.verticalSpace,
                    Row(
                      children: [
                        CustomText(
                          '12.12.2023-12.12.2025.csv',
                          size: 16.sp,
                          color: Colors.black,
                        ),
                        21.horizontalSpace,
                        Image.asset(AppIcons.edit, width: 21.r, height: 21.r),
                        21.horizontalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          height: 33.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.r),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: CustomText(
                              'Preview',
                              color: Color(0xff7D7D7D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    33.verticalSpace,
                    CustomText(
                      'Transaction Details',
                      color: Color(0xff0088FF),
                      size: 16.sp,
                    ),
                    22.verticalSpace,

                    // Date row
                    _buildTransactionRow(
                      label: 'Date',
                      hasQuestionIcon: true,
                      columnController: TextEditingController(text: 'A'),
                      formatController: TextEditingController(
                        text: 'DD.MM.JJJJ',
                      ),
                      hasFormat: true,
                    ),
                    14.verticalSpace,

                    // Description row
                    _buildTransactionRow(
                      label: 'Description',
                      hasQuestionIcon: true,
                      columnController: TextEditingController(text: 'B'),
                      hasFormat: false,
                    ),
                    14.verticalSpace,

                    // Amount row
                    _buildTransactionRow(
                      label: 'Amount',
                      hasQuestionIcon: true,
                      columnController: TextEditingController(text: 'C'),
                      formatController: TextEditingController(text: '1,000.00'),
                      hasFormat: true,
                    ),
                    14.verticalSpace,

                    // Spending row
                    _buildTransactionRow(
                      label: 'Spending',
                      hasQuestionIcon: true,
                      formatController: TextEditingController(text: '-100'),
                      hasFormat: true,
                      formatOnly: true,
                      isHighlighted: true,
                    ),
                    14.verticalSpace,

                    // Income row
                    _buildTransactionRow(
                      label: 'Income',
                      hasQuestionIcon: true,
                      formatController: TextEditingController(text: '100'),
                      hasFormat: true,
                      formatOnly: true,
                    ),
                    14.verticalSpace,

                    // MCC Code row
                    _buildTransactionRow(
                      label: 'MCC Code',
                      hasQuestionIcon: true,
                      columnController: TextEditingController(),
                      hasFormat: false,
                    ),
                    33.verticalSpace,

                    // Ignore Transactions section
                    Row(
                      children: [
                        CustomText(
                          'Ignore Transactions',
                          color: Colors.red,
                          size: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        5.horizontalSpace,
                        Image.asset(
                          AppIcons.questionIcon,
                          width: 15.r,
                          height: 15.r,
                        ),
                      ],
                    ),
                    22.verticalSpace,

                    // Ignore transaction row 1
                    _buildIgnoreRow(
                      columnController: TextEditingController(),
                      textController: TextEditingController(),
                      showCheckmark: true,
                    ),
                    14.verticalSpace,

                    // Ignore transaction row 2
                    _buildIgnoreRow(
                      columnController: TextEditingController(text: 'D'),
                      textController: TextEditingController(text: 'Refund'),
                      showCheckmark: false,
                    ),
                    40.verticalSpace,
                  ],
                ),
              ),
            )
          : Center(
              child: CustomText('empty', size: 16.sp, color: Color(0xff8C8C8C)),
            ),
    );
  }

  Widget _buildTransactionRow({
    required String label,
    bool hasQuestionIcon = false,
    TextEditingController? columnController,
    TextEditingController? formatController,
    bool hasFormat = false,
    bool formatOnly = false,
    bool isHighlighted = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              CustomText(label, size: 16.sp),
              if (hasQuestionIcon)
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h, left: 2.w),
                  child: Image.asset(
                    AppIcons.questionIcon,
                    width: 15.r,
                    height: 15.r,
                  ),
                ),
            ],
          ),
        ),
        7.horizontalSpace,
        if (!formatOnly)
          Expanded(
            child: Container(
              height: 36.h,
              padding: EdgeInsets.symmetric(horizontal: 7.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xffDFDFDF)),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText('Column', size: 10.sp),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: TextField(
                        controller: columnController,
                        cursorHeight: 15.r,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '',
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
        if (!formatOnly) 7.horizontalSpace,
        if (hasFormat)
          Expanded(
            child: Container(
              height: 36.h,
              padding: EdgeInsets.symmetric(horizontal: 7.w),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xffDFDFDF)),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText('Format', size: 10.sp),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: TextField(
                        controller: formatController,
                        cursorHeight: 15.r,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '',
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
          )
        else
          Spacer(),
        if (formatOnly) Spacer(),
      ],
    );
  }

  Widget _buildIgnoreRow({
    required TextEditingController columnController,
    required TextEditingController textController,
    required bool showCheckmark,
  }) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: 7.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xffDFDFDF)),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [CustomText('Column', size: 10.sp)],
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: TextField(
                      controller: columnController,
                      cursorHeight: 15.r,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '',
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
        7.horizontalSpace,
        Expanded(
          flex: 2,
          child: Container(
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: 7.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xffDFDFDF)),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [CustomText('with text', size: 10.sp)],
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: TextField(
                      controller: textController,
                      cursorHeight: 15.r,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '',
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
        7.horizontalSpace,
        if (showCheckmark)
          Image.asset(
            AppIcons.tickLight,
            width: 21.r,
            height: 21.r,
            color: Colors.green,
          )
        else
          Image.asset(
            AppIcons.delete,
            width: 21.r,
            height: 21.r,
            color: Colors.red,
          ),
      ],
    );
  }
}
