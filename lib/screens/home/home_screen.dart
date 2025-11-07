import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/home_controller.dart';
import 'package:moneyapp/widgets/custom_app_bar.dart';
import 'package:moneyapp/widgets/custom_toggle_switch.dart';

/// Home Screen
/// Main landing screen of the app
class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Transactions',
              leadingIconPath: AppIcons.transaction,
              actionIconPath: AppIcons.investment,
              onActionIconTap: () {
                // Handle investment icon tap
                Get.snackbar('Investment', 'Investment icon tapped');
              },
            ),
            27.verticalSpace,
            Obx(
              () => CustomToggleSwitch(
                option1IconPath: AppIcons.export,
                option1Text: 'Spending',
                option2IconPath: AppIcons.import,
                option2Text: 'Income',
                selectedOption: controller.selectedToggleOption.value,
                onOption1Tap: controller.selectSpending,
                onOption2Tap: controller.selectIncome,
              ),
            ),
            // Add more content here
          ],
        ),
      ),
    );
  }
}
