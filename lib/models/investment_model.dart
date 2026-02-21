import 'package:flutter/material.dart';
import 'package:moneyapp/services/database/database_helper.dart';

/// Investment Model
/// Contains investment details including name, ticker, color, and image path
class Investment {
  final int? id;
  final String name;
  final String ticker;
  final int colorValue; // Stored as int in database
  final String imagePath; // Copied to app folder, NOT nullable
  final DateTime createdAt;
  final DateTime updatedAt;

  Investment({
    this.id,
    required this.name,
    required this.ticker,
    required this.colorValue,
    required this.imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Get color as Flutter Color object
  Color get color => Color(colorValue);

  /// Create Investment with Color object
  factory Investment.withColor({
    int? id,
    required String name,
    required String ticker,
    required Color color,
    required String imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Investment(
      id: id,
      name: name,
      ticker: ticker,
      colorValue: color.toARGB32(),
      imagePath: imagePath,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnInvestmentId: id,
      DatabaseHelper.columnInvestmentName: name,
      DatabaseHelper.columnInvestmentTicker: ticker,
      DatabaseHelper.columnInvestmentColor: colorValue,
      DatabaseHelper.columnInvestmentImagePath: imagePath,
      DatabaseHelper.columnInvestmentCreatedAt: createdAt.toIso8601String(),
      DatabaseHelper.columnInvestmentUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory Investment.fromMap(Map<String, dynamic> map) {
    return Investment(
      id: map[DatabaseHelper.columnInvestmentId] as int?,
      name: map[DatabaseHelper.columnInvestmentName] as String,
      ticker: map[DatabaseHelper.columnInvestmentTicker] as String,
      colorValue: map[DatabaseHelper.columnInvestmentColor] as int,
      imagePath: map[DatabaseHelper.columnInvestmentImagePath] as String,
      createdAt: DateTime.parse(
        map[DatabaseHelper.columnInvestmentCreatedAt] as String,
      ),
      updatedAt: DateTime.parse(
        map[DatabaseHelper.columnInvestmentUpdatedAt] as String,
      ),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ticker': ticker,
      'colorValue': colorValue,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Investment.fromJson(Map<String, dynamic> json) {
    return Investment(
      id: json['id'] as int?,
      name: json['name'] as String,
      ticker: json['ticker'] as String,
      colorValue: json['colorValue'] as int,
      imagePath: json['imagePath'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Create a copy with updated fields
  Investment copyWith({
    int? id,
    String? name,
    String? ticker,
    int? colorValue,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Investment(
      id: id ?? this.id,
      name: name ?? this.name,
      ticker: ticker ?? this.ticker,
      colorValue: colorValue ?? this.colorValue,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create a copy with Color object
  Investment copyWithColor({Color? color}) {
    return copyWith(colorValue: color?.toARGB32());
  }

  /// Create a copy with updated timestamp
  Investment copyWithUpdatedTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  @override
  String toString() {
    return 'Investment{id: $id, name: $name, ticker: $ticker, colorValue: $colorValue}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Investment &&
        other.id == id &&
        other.name == name &&
        other.ticker == ticker;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ ticker.hashCode;
  }
}

/// Helper class for investment operations
class InvestmentHelper {
  /// Convert list of database maps to list of Investment objects
  static List<Investment> fromMapList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => Investment.fromMap(map)).toList();
  }

  /// Find investment by ID
  static Investment? findById(List<Investment> investments, int id) {
    try {
      return investments.firstWhere((i) => i.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Find investment by ticker
  static Investment? findByTicker(List<Investment> investments, String ticker) {
    try {
      return investments.firstWhere(
        (i) => i.ticker.toLowerCase() == ticker.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Search investments by name or ticker
  static List<Investment> search(List<Investment> investments, String query) {
    final lowerQuery = query.toLowerCase();
    return investments
        .where(
          (i) =>
              i.name.toLowerCase().contains(lowerQuery) ||
              i.ticker.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Sort investments by name
  static List<Investment> sortByName(List<Investment> investments) {
    final sorted = List<Investment>.from(investments);
    sorted.sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  /// Sort investments by ticker
  static List<Investment> sortByTicker(List<Investment> investments) {
    final sorted = List<Investment>.from(investments);
    sorted.sort((a, b) => a.ticker.compareTo(b.ticker));
    return sorted;
  }

  /// Sort investments by created date (newest first)
  static List<Investment> sortByCreatedDesc(List<Investment> investments) {
    final sorted = List<Investment>.from(investments);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }
}
