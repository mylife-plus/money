import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsGroupSpacer extends StatelessWidget {
  const SettingsGroupSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(height: 8));
  }
}
