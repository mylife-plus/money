import 'dart:io';
import 'package:flutter/material.dart';

/// MCC Category Model
/// Represents a category that contains multiple MCCs
class MCCCategory {
  final int? id;
  final String name;
  final String? iconPath;
  final File? iconFile;
  final Color? color;
  final DateTime createdAt;
  final DateTime updatedAt;

  MCCCategory({
    this.id,
    required this.name,
    this.iconPath,
    this.iconFile,
    this.color,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  MCCCategory copyWith({
    int? id,
    String? name,
    String? iconPath,
    File? iconFile,
    Color? color,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MCCCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      iconFile: iconFile ?? this.iconFile,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'iconFile': iconFile?.path,
      'color': color?.value.toRadixString(16),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MCCCategory.fromJson(Map<String, dynamic> json) {
    return MCCCategory(
      id: json['id'],
      name: json['name'],
      iconPath: json['iconPath'],
      iconFile: json['iconFile'] != null ? File(json['iconFile']) : null,
      color: json['color'] != null ? Color(json['color']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

/// MCC Item Model
/// Represents an individual MCC (subcategory under a category)
class MCCItem {
  final int? id;
  final String name;
  final String? iconPath;
  final File? iconFile;
  final int categoryId;
  final String categoryName;
  final DateTime createdAt;
  final DateTime updatedAt;

  MCCItem({
    this.id,
    required this.name,
    this.iconPath,
    this.iconFile,
    required this.categoryId,
    required this.categoryName,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  MCCItem copyWith({
    int? id,
    String? name,
    String? iconPath,
    File? iconFile,
    int? categoryId,
    String? categoryName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MCCItem(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      iconFile: iconFile ?? this.iconFile,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconPath': iconPath,
      'iconFile': iconFile?.path,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MCCItem.fromJson(Map<String, dynamic> json) {
    return MCCItem(
      id: json['id'],
      name: json['name'],
      iconPath: json['iconPath'],
      iconFile: json['iconFile'] != null ? File(json['iconFile']) : null,
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Get icon widget (prioritize iconFile over iconPath)
  Widget getIcon({double? size, Color? color}) {
    if (iconFile != null) {
      return Image.file(
        iconFile!,
        width: size,
        height: size,
        color: color,
      );
    } else if (iconPath != null) {
      return Image.asset(
        iconPath!,
        width: size,
        height: size,
        color: color,
      );
    } else {
      return Icon(Icons.category, size: size, color: color);
    }
  }
}

/// Helper class for MCC operations
class MCCHelper {
  /// Filter MCCs by category
  static List<MCCItem> filterByCategory(
    List<MCCItem> mccs,
    int categoryId,
  ) {
    return mccs.where((mcc) => mcc.categoryId == categoryId).toList();
  }

  /// Search MCCs by name
  static List<MCCItem> searchByName(
    List<MCCItem> mccs,
    String query,
  ) {
    if (query.isEmpty) return mccs;
    return mccs
        .where((mcc) => mcc.name.toLowerCase().contains(query.toLowerCase()))
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
