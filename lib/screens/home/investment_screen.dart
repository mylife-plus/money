import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/home_controller.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/widgets/common/custom_app_bar.dart';
import 'package:moneyapp/widgets/common/custom_toggle_switch.dart';
import 'package:moneyapp/widgets/common/custom_toggle_switch_small.dart';
import 'package:moneyapp/widgets/transactions/new_transaction_content.dart';
import 'package:moneyapp/widgets/investments/portfolio_section.dart';
import 'package:moneyapp/widgets/transactions/top_transaction_sheet.dart';
import 'package:moneyapp/widgets/trades/trades_section.dart';
import 'package:moneyapp/widgets/transactions/transaction_item.dart';

/// Home Screen
/// Main landing screen of the app
class InvestmentScreen extends GetView<InvestmentController> {
  const InvestmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Investments',
              leadingIconPath: AppIcons.investment,
              actionIconPath: AppIcons.transaction,
              onActionIconTap: () {
                Get.offNamed(AppRoutes.home.path);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    27.verticalSpace,
                    Obx(
                      () => CustomToggleSwitch(
                        option1IconPath: AppIcons.chartSquare,
                        option1Text: 'Portfolio',
                        option2IconPath: AppIcons.bitcoinConvert,
                        option2Text: 'Trades',
                        selectedOption: controller.selectedToggleOption.value,
                        onOption1Tap: controller.selectPortfolio,
                        onOption2Tap: controller.selectTrades,
                      ),
                    ),

                    Obx(() {
                      return controller.isPortfolioSelected
                          ? PortfolioSection(
                              isPortfolioSelected:
                                  controller.isPortfolioSelected,
                            )
                          : TradesSection();
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
