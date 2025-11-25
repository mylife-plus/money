import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/ui_controller.dart';
import 'package:moneyapp/routes/app_pages.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/screens/setting/settings_tile.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
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
                      Get.toNamed(AppRoutes.hashtagGroups.path);
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
                    title: 'Currency',
                    trailing: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: CustomText(
                        'USD',
                        size: 16.sp,
                        color: Color(0xff838383),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
                      Get.toNamed(AppRoutes.uploadTransaction.path);
                    },
                  ),
                  SettingsTile(
                    title: '📥 Export 💸Transactions ',
                    onTap: () {},
                  ),
                  SettingsTile(
                    title: '📥 Upload 💰Investments',
                    onTap: () {
                      Get.toNamed(AppRoutes.uploadInvestment.path);
                    },
                  ),
                  SettingsTile(title: '📤 Export 💰Investments ', onTap: () {}),
                  SettingsTile(
                    title: 'Erase All Data',
                    onTap: () {},
                    titleColor: Color(0xffED1A2D),
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
}
