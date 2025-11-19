import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:moneyapp/widgets/investments/investment_entry_row.dart';

class InvestmentListScreen extends StatelessWidget {
  const InvestmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InvestmentController controller = Get.find();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            8.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 21.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      AppIcons.backArrow,
                      width: 21.h,
                      height: 21.h,
                    ),
                  ),
                  CustomText('Investments', size: 16.sp, color: Colors.black),
                  21.horizontalSpace,
                ],
              ),
            ),
            30.verticalSpace,

            Expanded(
              child: Obx(
                () => ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  itemCount: controller.recommendations.length + 1,
                  separatorBuilder: (context, index) => 8.verticalSpace,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // New entry row
                      return InvestmentEntryRow(isNewEntry: true);
                    }
                    // Existing entry
                    return InvestmentEntryRow(
                      initialData: controller.recommendations[index - 1],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
