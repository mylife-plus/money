import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class SettingsTile extends StatelessWidget {
  final Widget icon;
  final String title;
  final VoidCallback? onTap;
  final bool showDivider;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            leading: SizedBox(
              width: 24,
              height: 24,
              child: Center(child: icon),
            ),
            title: Text(
              title,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: onTap,
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.black.withOpacity(0.1),
              indent: 16,
              endIndent: 16,
            ),
        ],
      ),
    );
  }
}
