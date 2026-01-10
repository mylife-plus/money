import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// MCC Category Model
/// Represents a category that contains multiple MCCs
class MCCCategory {
  final int? id;
  final String name;
  final String? emoji;

  MCCCategory({this.id, required this.name, this.emoji});

  MCCCategory copyWith({int? id, String? name, String? emoji}) {
    return MCCCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'emoji': emoji};
  }

  factory MCCCategory.fromJson(Map<String, dynamic> json) {
    return MCCCategory(
      id: json['id'],
      name: json['name'],
      emoji: json['emoji'],
    );
  }
}

/// MCC Item Model
/// Represents an individual MCC (subcategory under a category)
class MCCItem {
  final int? id;
  final String name;
  final int categoryId;
  final String categoryName;
  final String? mccCode; // The actual MCC code (e.g., "5812", "742")
  final String? emoji; // Emoji representation

  MCCItem({
    this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    this.mccCode,
    this.emoji,
  });

  MCCItem copyWith({
    int? id,
    String? name,
    int? categoryId,
    String? categoryName,
    String? mccCode,
    String? emoji,
  }) {
    return MCCItem(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      mccCode: mccCode ?? this.mccCode,
      emoji: emoji ?? this.emoji,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'mccCode': mccCode,
      'emoji': emoji,
    };
  }

  factory MCCItem.fromJson(Map<String, dynamic> json) {
    return MCCItem(
      id: json['id'],
      name: json['name'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      mccCode: json['mccCode'],
      emoji: json['emoji'],
    );
  }

  /// Get icon widget (returns emoji as text or default icon)
  Widget getIcon({double? size, Color? color}) {
    if (emoji != null && emoji!.isNotEmpty) {
      return Text(emoji!, style: TextStyle(fontSize: size ?? 17.sp));
    } else {
      return Icon(Icons.category, size: size, color: color);
    }
  }
}

/// Helper class for MCC operations
class MCCHelper {
  /// Filter MCCs by category
  static List<MCCItem> filterByCategory(List<MCCItem> mccs, int categoryId) {
    return mccs.where((mcc) => mcc.categoryId == categoryId).toList();
  }

  /// Search MCCs by name
  static List<MCCItem> searchByName(List<MCCItem> mccs, String query) {
    if (query.isEmpty) return mccs;
    return mccs
        .where(
          (mcc) =>
              mcc.name.toLowerCase().contains(query.toLowerCase()) ||
              (mcc.mccCode != null && mcc.mccCode!.contains(query)) ||
              mcc.categoryName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  /// Get unique categories from MCC list
  static List<MCCCategory> getCategories(
    List<MCCItem> mccs,
    List<MCCCategory> allCategories,
  ) {
    final categoryIds = mccs.map((mcc) => mcc.categoryId).toSet();
    return allCategories
        .where((category) => categoryIds.contains(category.id))
        .toList();
  }

  /// Sort MCCs by name
  static List<MCCItem> sortByName(List<MCCItem> mccs) {
    final sorted = List<MCCItem>.from(mccs);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  /// Sort categories by name
  static List<MCCCategory> sortCategoriesByName(List<MCCCategory> categories) {
    final sorted = List<MCCCategory>.from(categories);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }
}
