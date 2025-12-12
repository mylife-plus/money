import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/mcc_controller.dart';
import 'package:moneyapp/models/mcc_model.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class AddMCCScreen extends StatefulWidget {
  const AddMCCScreen({super.key});

  @override
  State<AddMCCScreen> createState() => _AddMCCScreenState();
}

class _AddMCCScreenState extends State<AddMCCScreen> {
  final MCCController mccController = Get.find<MCCController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController newCategoryController = TextEditingController();

  int? selectedCategoryId;
  String? selectedIcon;
  bool isCreatingNewCategory = false;
  MCCItem? existingMCC;

  // Predefined icons for selection
  final List<String> predefinedIcons = [
    AppIcons.digitalCurrency,
    AppIcons.bitcoinConvert,
    AppIcons.investment,
    AppIcons.car,
    AppIcons.atm,
    AppIcons.cart,
    AppIcons.transaction,
    AppIcons.file,
    AppIcons.security,
    AppIcons.hashtag,
    AppIcons.home,
    AppIcons.plus,
  ];

  @override
  void initState() {
    super.initState();
    // Check if editing existing MCC
    existingMCC = Get.arguments as MCCItem?;
    if (existingMCC != null) {
      nameController.text = existingMCC!.name;
      selectedIcon = existingMCC!.iconPath;
      selectedCategoryId = existingMCC!.categoryId;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    newCategoryController.dispose();
    super.dispose();
  }

  Future<void> _showIconSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                'Select Icon',
                size: 18.sp,
                fontWeight: FontWeight.w600,
              ),
              16.verticalSpace,
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                ),
                itemCount: predefinedIcons.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedIcon = predefinedIcons[index];
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedIcon == predefinedIcons[index]
                              ? const Color(0xff0088FF)
                              : const Color(0xffDFDFDF),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      padding: EdgeInsets.all(8.w),
                      child: Image.asset(
                        predefinedIcons[index],
                        width: 24.w,
                        height: 24.h,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMCC() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter MCC name',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    int? categoryId = selectedCategoryId;
    String categoryName = '';

    if (isCreatingNewCategory) {
      if (newCategoryController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter category name',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Create new category
      final newCategory = MCCCategory(
        name: newCategoryController.text.trim(),
        iconPath: selectedIcon ?? AppIcons.categoryIcon,
      );
      mccController.addCategory(newCategory);
      categoryId = newCategory.id;
      categoryName = newCategory.name;
    } else {
      if (selectedCategoryId == null) {
        Get.snackbar(
          'Error',
          'Please select a category',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final category = mccController.getCategoryById(selectedCategoryId!);
      if (category != null) {
        categoryName = category.name;
      }
    }

    if (existingMCC != null) {
      // Update existing MCC
      final updatedMCC = existingMCC!.copyWith(
        name: nameController.text.trim(),
        iconPath: selectedIcon ?? AppIcons.categoryIcon,
        categoryId: categoryId!,
        categoryName: categoryName,
      );

      mccController.updateMCCItem(updatedMCC);

      Get.snackbar(
        'Success',
        'MCC updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      // Create new MCC item
      final newMCC = MCCItem(
        name: nameController.text.trim(),
        iconPath: selectedIcon ?? AppIcons.categoryIcon,
        categoryId: categoryId!,
        categoryName: categoryName,
      );

      mccController.addMCCItem(newMCC);

      Get.snackbar(
        'Success',
        'MCC added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: Image.asset(
                      AppIcons.backArrow,
                      width: 21.h,
                      height: 21.h,
                    ),
                  ),
                  CustomText(
                    existingMCC != null ? 'Edit MCC' : 'Add New MCC',
                    size: 16.sp,
                    color: Colors.black,
                  ),
                  SizedBox(width: 21.w),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 33.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      20.verticalSpace,

                      // MCC Name
                      CustomText(
                        'MCC Name',
                        size: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      8.verticalSpace,
                      Container(
                        height: 41.h,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xffDFDFDF)),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Enter MCC name',
                            labelText: 'MCC Name',
                            labelStyle: TextStyle(
                              color: const Color(0xffB4B4B4),
                              fontSize: 14.sp,
                            ),
                            hintStyle: TextStyle(
                              color: const Color(0xffB4B4B4),
                              fontSize: 14.sp,
                            ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),

                      20.verticalSpace,

                      // Icon Selection
                      CustomText(
                        'Icon',
                        size: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      8.verticalSpace,
                      InkWell(
                        onTap: _showIconSelectionDialog,
                        child: Container(
                          height: 60.h,
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xffDFDFDF)),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36.w,
                                height: 36.h,
                                decoration: BoxDecoration(
                                  color: const Color(0xffF5F5F5),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Center(
                                  child: Image.asset(
                                    selectedIcon ?? AppIcons.plus,
                                    width: 20.w,
                                    height: 20.h,
                                    color: selectedIcon == null
                                        ? const Color(0xffB4B4B4)
                                        : null,
                                  ),
                                ),
                              ),
                              12.horizontalSpace,
                              CustomText(
                                selectedIcon == null
                                    ? 'Select an icon'
                                    : 'Icon selected',
                                size: 14.sp,
                                color: selectedIcon == null
                                    ? const Color(0xffB4B4B4)
                                    : Colors.black87,
                              ),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right,
                                size: 20.sp,
                                color: const Color(0xffB4B4B4),
                              ),
                            ],
                          ),
                        ),
                      ),

                      20.verticalSpace,

                      // Category Selection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            'Category',
                            size: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                isCreatingNewCategory = !isCreatingNewCategory;
                                if (isCreatingNewCategory) {
                                  selectedCategoryId = null;
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: isCreatingNewCategory
                                    ? const Color(0xff0088FF)
                                    : Colors.white,
                                border: Border.all(
                                  color: isCreatingNewCategory
                                      ? const Color(0xff0088FF)
                                      : const Color(0xffDFDFDF),
                                ),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 14.sp,
                                    color: isCreatingNewCategory
                                        ? Colors.white
                                        : const Color(0xff0088FF),
                                  ),
                                  4.horizontalSpace,
                                  CustomText(
                                    'New Category',
                                    size: 12.sp,
                                    color: isCreatingNewCategory
                                        ? Colors.white
                                        : const Color(0xff0088FF),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      8.verticalSpace,

                      if (isCreatingNewCategory) ...[
                        // New Category Input
                        Container(
                          height: 41.h,
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xffDFDFDF)),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: TextField(
                            controller: newCategoryController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Enter new category name',
                              labelText: 'Category Name',
                              labelStyle: TextStyle(
                                color: const Color(0xffB4B4B4),
                                fontSize: 16.sp,
                              ),
                              hintStyle: TextStyle(
                                color: const Color(0xffB4B4B4),
                                fontSize: 16.sp,
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                      ] else ...[
                        // Category Dropdown
                        Obx(
                          () => Container(
                            height: 41.h,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: const Color(0xffDFDFDF),
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedCategoryId,
                                hint: CustomText(
                                  'Select category',
                                  size: 14.sp,
                                  color: const Color(0xffB4B4B4),
                                ),
                                isExpanded: true,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: const Color(0xffB4B4B4),
                                ),
                                items: mccController.categories
                                    .map(
                                      (category) => DropdownMenuItem<int>(
                                        value: category.id,
                                        child: CustomText(
                                          category.name,
                                          size: 14.sp,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategoryId = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      ],

                      40.verticalSpace,

                      // Save Button
                      Center(
                        child: InkWell(
                          onTap: _saveMCC,
                          child: Container(
                            width: 136.w,
                            height: 41.h,
                            decoration: BoxDecoration(
                              color: const Color(0xffFFFFFF),
                              borderRadius: BorderRadius.circular(13.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 4,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Center(
                              child: CustomText(
                                existingMCC != null ? 'Update' : 'Save',
                                size: 16.sp,
                                color: const Color(0xff0071FF),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
