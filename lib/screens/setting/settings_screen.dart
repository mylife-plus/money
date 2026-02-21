import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/controllers/home_controller.dart';
import 'package:moneyapp/controllers/hashtag_groups_controller.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/services/database/database_helper.dart';
import 'package:moneyapp/services/test_data_service.dart';

import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/screens/setting/currency_settings_screen.dart';
import 'package:moneyapp/screens/setting/settings_tile.dart';
import 'package:moneyapp/services/currency_service.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final uiController = Get.put(UiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffDEEDFF),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppIcons.settingV2, width: 22.r, height: 22.r),
            13.horizontalSpace,
            CustomText(
              'Settings',
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
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.0.w, vertical: 18.h),
          child: Column(
            spacing: 24.h,
            children: [
              Column(
                spacing: 3.h,
                children: [
                  SettingsTile(
                    icon: Image.asset(AppIcons.writeHand),
                    title: 'Feedback',
                    onTap: () {},
                  ),

                  SettingsTile(
                    icon: Image.asset(AppIcons.hashtag),
                    title: 'Hashtag',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.hashtagGroups.path,
                        arguments: {'fromSettings': true},
                      );
                    },
                  ),
                ],
              ),
              _buildSectionTitle('Preferences', AppIcons.blackCheck),
              Column(
                spacing: 3.h,
                children: [
                  SettingsTile(
                    title: 'Language ',
                    titleSuffix: '(English)',
                    onTap: () {},
                  ),

                  SettingsTile(
                    title: 'Dark Mode',
                    trailing: Switch(
                      padding: EdgeInsets.zero,
                      activeTrackColor: Color(0xff0071FF),
                      thumbColor: WidgetStateProperty.all<Color>(Colors.white),
                      value: true,
                      onChanged: (value) {},
                    ),
                  ),
                  SettingsTile(
                    title: '💸 Cashflow Currency',
                    trailing: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: CustomText(
                        CurrencyService.instance.cashflowCode,
                        size: 16.sp,
                        color: Color(0xff838383),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CurrencySettingsScreen(
                            currencyType: CurrencyType.cashflow,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                  SettingsTile(
                    title: '📈 Investment Currency',
                    trailing: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: CustomText(
                        CurrencyService.instance.hasPortfolioCurrencySync
                            ? CurrencyService.instance.portfolioCode
                            : '',
                        size: 16.sp,
                        color: Color(0xff838383),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CurrencySettingsScreen(
                            currencyType: CurrencyType.portfolio,
                          ),
                        ),
                      );
                      setState(() {});
                    },
                  ),
                ],
              ),
              _buildSectionTitle('Security', AppIcons.security),
              Column(
                spacing: 3.h,
                children: [
                  SettingsTile(
                    title: 'Activate Phone Pin',
                    trailing: Switch(
                      activeTrackColor: Color(0xff0071FF),
                      thumbColor: WidgetStateProperty.all<Color>(Colors.white),
                      value: true,
                      onChanged: (value) {},
                    ),
                    onTap: null,
                  ),
                ],
              ),
              _buildSectionTitle('Data', AppIcons.file),
              Column(
                spacing: 3.h,
                children: [
                  SettingsTile(
                    title: '📥 Upload 💸Transactions ',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.uploadTransaction.path,
                      );
                    },
                  ),
                  SettingsTile(
                    title: '📥 Export 💸Transactions ',
                    onTap: () {},
                  ),
                  SettingsTile(
                    title: '📥 Upload 💰Investments',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.uploadInvestment.path,
                      );
                    },
                  ),
                  SettingsTile(title: '📤 Export 💰Investments ', onTap: () {}),
                  SettingsTile(
                    title: 'Erase All Data',
                    onTap: () => _showClearDataDialog(context),
                    titleColor: Color(0xffED1A2D),
                  ),
                  SettingsTile(
                    icon: Icon(Icons.bug_report_outlined, size: 24.r),
                    title: 'Load Test Data (Dev)',
                    onTap: () => _showLoadTestDataDialog(context),
                  ),
                  SettingsTile(
                    icon: Icon(Icons.trending_up_outlined, size: 24.r),
                    title: 'Load Investment Test Data (Dev)',
                    onTap: () => _showLoadInvestmentTestDataDialog(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String iconPath) {
    return Row(
      children: [
        7.horizontalSpace,
        Image.asset(iconPath, width: 24.r, height: 24.r),
        10.horizontalSpace,
        Expanded(
          child: CustomText(
            title,
            size: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Future<void> _showClearDataDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erase All Data'),
        content: const Text(
          '⚠️ DANGER: This will PERMANENTLY DELETE all your transactions, categories, and settings.\n\n'
          'This action cannot be undone.\n\n'
          'Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Erase Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Erasing data..."),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        // Clear DB
        await DatabaseHelper.instance.clearAllData();

        // Reload Controllers to refresh UI (will show empty list)
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().loadTransactions();
        }
        if (Get.isRegistered<HashtagGroupsController>()) {
          await Get.find<HashtagGroupsController>().loadHashtagGroups();
        }

        if (context.mounted) {
          Navigator.pop(context); // close progress
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All data erased successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // close progress
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _showLoadTestDataDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Test Data'),
        content: const Text(
          '⚠️ WARNING: This will DELETE all existing transactions and categories/hashtags.\n\n'
          'It will create random test data (2015-Now) with new categories.\n\n'
          'Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Load Data'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Generating data..."),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        await TestDataService().generateTestData();

        // Reload Controllers to refresh UI
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().loadTransactions();
        }
        if (Get.isRegistered<HashtagGroupsController>()) {
          await Get.find<HashtagGroupsController>().loadHashtagGroups();
        }
        if (context.mounted) {
          Navigator.pop(context); // close progress
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Test data loaded successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // close progress
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _showLoadInvestmentTestDataDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Investment Test Data'),
        content: const Text(
          '⚠️ WARNING: This will DELETE all existing investments, activities, and portfolio snapshots.\n\n'
          'It will create sample investments (BTC, ETH, AAPL, etc.) with random transactions and trades.\n\n'
          'Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Load Data'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Generating investment data..."),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        // Register controller BEFORE generating data so test service can use it
        InvestmentController controller;
        if (Get.isRegistered<InvestmentController>()) {
          controller = Get.find<InvestmentController>();
        } else {
          controller = Get.put(InvestmentController());
        }

        await TestDataService().generateInvestmentTestData();

        // Reload Controller to refresh UI with new data
        await controller.loadData();

        if (context.mounted) {
          Navigator.pop(context); // close progress
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Investment test data loaded successfully'),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // close progress
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
}
