import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_colors.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? selectedLanguage;

  Future<void> _onGetStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenWelcome', true);
    Get.offAllNamed(AppRoutes.currencySelection.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Welcome text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText('😸', size: 32.sp),
                  8.horizontalSpace,
                  CustomText(
                    'Welcome to the',
                    size: 32.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText('🤑', size: 28.sp),
                  8.horizontalSpace,
                  CustomText(
                    'money app',
                    size: 32.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),

              30.verticalSpace,

              // 100% open source
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 24.sp, color: Color(0xFF4CAF50)),
                  children: [
                    TextSpan(text: '100% '),
                    TextSpan(
                      text: 'open source',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              4.verticalSpace,
              // 100% offline
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 24.sp, color: Color(0xFF2196F3)),
                  children: [
                    TextSpan(text: '100%  '),
                    TextSpan(
                      text: 'offline',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              4.verticalSpace,
              // 100% community
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 24.sp, color: Color(0xFF4CAF50)),
                  children: [
                    TextSpan(text: '100% '),
                    TextSpan(
                      text: 'community',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Language selector
              Container(
                height: 41.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.greyBorder),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedLanguage,
                    isExpanded: true,
                    hint: Row(
                      children: [
                        CustomText(
                          'choose your ',

                          size: 16.sp,
                          color: AppColors.greyColor,
                        ),
                        CustomText('🌐', size: 16.sp),
                        CustomText(
                          ' Language',
                          size: 16.sp,
                          color: AppColors.greyColor,
                        ),
                      ],
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.greyColor,
                    ),
                    style: TextStyle(fontSize: 16.sp, color: Colors.black),
                    items: [
                      DropdownMenuItem(
                        value: 'en',
                        child: Row(
                          children: [
                            CustomText('🇬🇧', size: 20.sp),
                            12.horizontalSpace,
                            Text(
                              'English',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'de',
                        child: Row(
                          children: [
                            Text('🇩🇪', style: TextStyle(fontSize: 20.sp)),
                            12.horizontalSpace,
                            Text(
                              'Deutsch',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedLanguage = value;
                      });
                    },
                  ),
                ),
              ),

              20.verticalSpace,

              // Get Started button (only visible after language selection)
              AnimatedOpacity(
                opacity: selectedLanguage != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: selectedLanguage == null,
                  child: InkWell(
                    onTap: _onGetStarted,
                    child: Container(
                      height: 41.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 4.0,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Get Started',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Color(0xff0071FF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
