import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/models/investment_model.dart';
import 'package:moneyapp/widgets/common/custom_text.dart';

class InvestmentEntryRow extends StatefulWidget {
  final Investment? initialData;
  final bool initialIsEditable;
  final bool isNewEntry;

  const InvestmentEntryRow({
    super.key,
    this.initialData,
    this.initialIsEditable = false,
    this.isNewEntry = false,
  });

  @override
  State<InvestmentEntryRow> createState() => _InvestmentEntryRowState();
}

class _InvestmentEntryRowState extends State<InvestmentEntryRow> {
  late bool isEditable;
  late TextEditingController nameController;
  late TextEditingController tickerController;
  String? selectedAssetPath;
  Color? selectedColor;
  final InvestmentController _controller = Get.find();

  // Predefined icons for selection
  final List<String> predefinedIcons = [
    AppIcons.digitalCurrency,
    AppIcons.bitcoinConvert,
    AppIcons.investment,
    AppIcons.car,
    AppIcons.atm,
    AppIcons.cart,
  ];

  // Predefined colors for selection
  final List<Color> predefinedColors = [
    Color(0xffFFE5E5), // Light pink
    Color(0xffFFD4A3), // Light orange
    Color(0xffFFE5A3), // Light yellow
    Color(0xffE5FFE5), // Light green
    Color(0xffA3D4FF), // Light blue
    Color(0xffD4A3FF), // Light purple
    Color(0xffFFA3D4), // Light magenta
    Color(0xffA3FFD4), // Light cyan
  ];

  @override
  void initState() {
    super.initState();
    isEditable = widget.initialIsEditable || widget.isNewEntry;
    nameController = TextEditingController(
      text: widget.initialData?.name ?? '',
    );
    tickerController = TextEditingController(
      text: widget.initialData?.ticker ?? '',
    );
    selectedAssetPath = widget.initialData?.imagePath;
    selectedColor = widget.initialData?.color;
  }

  @override
  void dispose() {
    nameController.dispose();
    tickerController.dispose();
    super.dispose();
  }

  Future<void> _showImageSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),

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
              // Predefined icons grid
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
                        selectedAssetPath = predefinedIcons[index];
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: selectedAssetPath == predefinedIcons[index]
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

  Future<void> _showColorSelectionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        child: Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                'Select Color',
                size: 18.sp,
                fontWeight: FontWeight.w600,
              ),
              16.verticalSpace,
              // Predefined colors grid
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                ),
                itemCount: predefinedColors.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedColor = predefinedColors[index];
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: predefinedColors[index],
                        border: Border.all(
                          color: selectedColor == predefinedColors[index]
                              ? const Color(0xff0088FF)
                              : const Color(0xffDFDFDF),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      height: 40.h,
                      width: 40.w,
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

  /// Copy asset to temp file for use with the new Investment model
  Future<File?> _copyAssetToTempFile(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final ext = p.extension(assetPath);
      final tempFile = File(p.join(tempDir.path, 'temp_investment$ext'));
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      return tempFile;
    } catch (e) {
      debugPrint('[InvestmentEntryRow] Error copying asset: $e');
      return null;
    }
  }

  Future<void> _handleSave() async {
    if (nameController.text.isEmpty || tickerController.text.isEmpty) {
      return;
    }

    if (selectedAssetPath == null) {
      return;
    }

    // Limit ticker to 5 characters
    final ticker = tickerController.text.length > 5
        ? tickerController.text.substring(0, 5).toUpperCase()
        : tickerController.text.toUpperCase();

    final color = selectedColor ?? Colors.grey;

    if (widget.isNewEntry) {
      // Copy asset to temp file for the service to use
      final imageFile = await _copyAssetToTempFile(selectedAssetPath!);
      if (imageFile == null) return;

      await _controller.addInvestment(
        name: nameController.text,
        ticker: ticker,
        color: color,
        imageFile: imageFile,
      );

      // Clear fields after adding
      nameController.clear();
      tickerController.clear();
      setState(() {
        selectedAssetPath = null;
        selectedColor = null;
      });
    } else if (widget.initialData?.id != null) {
      // Update existing
      File? imageFile;
      if (selectedAssetPath != null &&
          selectedAssetPath!.startsWith('assets/')) {
        imageFile = await _copyAssetToTempFile(selectedAssetPath!);
      }

      await _controller.updateInvestment(
        widget.initialData!.id!,
        name: nameController.text,
        ticker: ticker,
        color: color,
        newImageFile: imageFile,
      );

      setState(() {
        isEditable = false;
      });
    }
  }

  Widget _buildImageWidget() {
    if (selectedAssetPath == null) {
      return Image.asset(
        AppIcons.plus,
        width: 16.w,
        height: 16.h,
        color: const Color(0xffB4B4B4),
      );
    }

    // Check if it's an asset path or file path
    if (selectedAssetPath!.startsWith('assets/')) {
      return Image.asset(selectedAssetPath!, width: 16.w, height: 16.h);
    } else {
      final file = File(selectedAssetPath!);
      if (file.existsSync()) {
        return Image.file(file, width: 16.w, height: 16.h, fit: BoxFit.cover);
      }
      return Image.asset(
        AppIcons.plus,
        width: 16.w,
        height: 16.h,
        color: const Color(0xffB4B4B4),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Image/Icon Container
        InkWell(
          onTap: isEditable ? _showImageSelectionDialog : null,
          child: Container(
            height: 35.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xffDFDFDF)),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(child: _buildImageWidget()),
          ),
        ),
        6.horizontalSpace,
        // Investment Name Field
        Expanded(
          child: Container(
            height: 35.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xffDFDFDF)),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Center(
              child: isEditable
                  ? TextField(
                      controller: nameController,
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Investment',
                        hintStyle: const TextStyle(
                          color: Color(0xffB4B4B4),
                          fontSize: 14,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: TextStyle(fontSize: 14.sp, color: Colors.black),
                    )
                  : CustomText(
                      nameController.text.isEmpty
                          ? 'Investment'
                          : nameController.text,
                      size: 14.sp,
                      color: nameController.text.isEmpty
                          ? const Color(0xffB4B4B4)
                          : Colors.black,
                    ),
            ),
          ),
        ),
        4.horizontalSpace,
        // Ticker Field
        Container(
          height: 35.h,
          width: 56.w,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xffDFDFDF)),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Center(
            child: isEditable
                ? TextField(
                    controller: tickerController,
                    textAlign: TextAlign.start,
                    maxLength: 5,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: '???',
                      hintStyle: const TextStyle(
                        color: Color(0xffB4B4B4),
                        fontSize: 14,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      counterText: '',
                    ),
                    style: TextStyle(fontSize: 14.sp, color: Colors.black),
                  )
                : CustomText(
                    tickerController.text.isEmpty
                        ? '???'
                        : tickerController.text,
                    size: 14.sp,
                    color: tickerController.text.isEmpty
                        ? const Color(0xffB4B4B4)
                        : Colors.black,
                  ),
          ),
        ),
        4.horizontalSpace,
        // Color Indicator/Selector
        InkWell(
          onTap: isEditable ? _showColorSelectionDialog : null,
          child: Container(
            height: 35.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: selectedColor ?? Colors.white,
              border: Border.all(color: const Color(0xffDFDFDF)),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: selectedColor == null
                ? Center(
                    child: Icon(
                      Icons.palette_outlined,
                      size: 18.r,
                      color: const Color(0xffB4B4B4),
                    ),
                  )
                : null,
          ),
        ),
        isEditable ? 12.horizontalSpace : 15.horizontalSpace,
        // Action Icon
        InkWell(
          onTap: () {
            if (isEditable) {
              _handleSave();
            } else {
              setState(() {
                isEditable = true;
              });
            }
          },
          child: Image.asset(
            isEditable ? AppIcons.tickCircle : AppIcons.edit,
            width: isEditable ? 25.r : 22.r,
            height: isEditable ? 25.r : 22.r,
          ),
        ),
      ],
    );
  }
}
