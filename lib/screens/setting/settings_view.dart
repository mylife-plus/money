import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/screens/hashtag/hashtag_group_screen.dart';
import 'package:moneyapp/screens/setting/settings_spacer.dart';
import 'package:moneyapp/screens/setting/settings_tile.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(
      //   title: AppTexts.settings,
      //   icon: Image.asset(AppImages.settings),
      // ),
      body: ListView(
        children: [
          Container(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            child: Column(
              children: [
                SettingsTile(
                  icon: Image.asset(AppIcons.search),
                  title: 'abc',
                  showDivider: true,
                  onTap: () {
                    // Get.to(() => SecurityView());
                  },
                ),

                Container(
                  color: Theme.of(context).textTheme.bodyMedium?.color,

                  child: Column(
                    children: [
                      SettingsTile(
                        icon: Image.asset(AppIcons.atm),
                        title: 'Hashtag',
                        showDivider: true,
                        onTap: () {
                          Get.toNamed(AppRoutes.hashtagGroups.path);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
