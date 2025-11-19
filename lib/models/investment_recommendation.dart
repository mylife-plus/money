import 'dart:io';

/// Model for investment recommendations
/// Supports both asset images and user-selected device images
class InvestmentRecommendation {
  final String? assetPath;
  final File? imageFile;
  final String text;
  final String shortText;

  InvestmentRecommendation({
    this.assetPath,
    this.imageFile,
    required this.text,
    required this.shortText,
  }) : assert(
          assetPath != null || imageFile != null,
          'Either assetPath or imageFile must be provided',
        );

  /// Creates a recommendation with an asset image
  factory InvestmentRecommendation.fromAsset({
    required String assetPath,
    required String text,
    required String shortText,
  }) {
    return InvestmentRecommendation(
      assetPath: assetPath,
      text: text,
      shortText: shortText,
    );
  }

  /// Creates a recommendation with a device image
  factory InvestmentRecommendation.fromFile({
    required File imageFile,
    required String text,
    required String shortText,
  }) {
    return InvestmentRecommendation(
      imageFile: imageFile,
      text: text,
      shortText: shortText,
    );
  }

  /// Whether this recommendation uses an asset image
  bool get isAssetImage => assetPath != null;

  /// Whether this recommendation uses a device image
  bool get isFileImage => imageFile != null;

  /// Convert to Map for serialization if needed
  Map<String, dynamic> toJson() {
    return {
      'assetPath': assetPath,
      'imagePath': imageFile?.path,
      'text': text,
      'shortText': shortText,
    };
  }

  /// Create from Map for deserialization if needed
  factory InvestmentRecommendation.fromJson(Map<String, dynamic> json) {
    return InvestmentRecommendation(
      assetPath: json['assetPath'] as String?,
      imageFile: json['imagePath'] != null
          ? File(json['imagePath'] as String)
          : null,
      text: json['text'] as String,
      shortText: json['shortText'] as String,
    );
  }

  @override
  String toString() {
    return 'InvestmentRecommendation(text: $text, shortText: $shortText, '
        'assetPath: $assetPath, imageFile: ${imageFile?.path})';
  }
}
