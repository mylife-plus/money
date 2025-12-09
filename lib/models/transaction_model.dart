import 'dart:io';
import 'package:flutter/material.dart';
import 'package:moneyapp/models/hashtag_group_model.dart';

/// Merchant Category Code (MCC) model
/// Contains text, icon, and optional color for transaction categories
class MCC {
  final String? assetPath;
  final File? imageFile;
  final String text;
  final String shortText;
  final Color? color;

  MCC({
    this.assetPath,
    this.imageFile,
    required this.text,
    required this.shortText,
    this.color,
  }) : assert(
         assetPath != null || imageFile != null,
         'Either assetPath or imageFile must be provided',
       );

  /// Creates an MCC with an asset image
  factory MCC.fromAsset({
    required String assetPath,
    required String text,
    required String shortText,
    Color? color,
  }) {
    return MCC(
      assetPath: assetPath,
      text: text,
      shortText: shortText,
      color: color,
    );
  }

  /// Creates an MCC with a device image
  factory MCC.fromFile({
    required File imageFile,
    required String text,
    required String shortText,
    Color? color,
  }) {
    return MCC(
      imageFile: imageFile,
      text: text,
      shortText: shortText,
      color: color,
    );
  }

  /// Whether this MCC uses an asset image
  bool get isAssetImage => assetPath != null;

  /// Whether this MCC uses a device image
  bool get isFileImage => imageFile != null;

  /// Convert to Map for serialization
  Map<String, dynamic> toJson() {
    return {
      'assetPath': assetPath,
      'imagePath': imageFile?.path,
      'text': text,
      'shortText': shortText,
      'color': color?.toARGB32(),
    };
  }

  /// Create from Map for deserialization
  factory MCC.fromJson(Map<String, dynamic> json) {
    return MCC(
      assetPath: json['assetPath'] as String?,
      imageFile: json['imagePath'] != null
          ? File(json['imagePath'] as String)
          : null,
      text: json['text'] as String,
      shortText: json['shortText'] as String,
      color: json['color'] != null ? Color(json['color'] as int) : null,
    );
  }

  @override
  String toString() {
    return 'MCC(text: $text, shortText: $shortText, '
        'assetPath: $assetPath, imageFile: ${imageFile?.path}, color: $color)';
  }
}

/// Transaction Model
/// Contains all transaction details including expense/income, date, amount, MCC, notes, and hashtags
class Transaction {
  final int? id;
  final bool isExpense;
  final DateTime date;
  final double amount;
  final MCC mcc;
  final String recipient;
  final String note;
  final List<HashtagGroup> hashtags;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    this.id,
    required this.isExpense,
    required this.date,
    required this.amount,
    required this.mcc,
    this.recipient = '',
    this.note = '',
    this.hashtags = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Whether this is an income transaction
  bool get isIncome => !isExpense;

  /// Get formatted amount with currency symbol
  String getFormattedAmount({String currency = '€'}) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'transaction_id': id,
      'transaction_is_expense': isExpense ? 1 : 0,
      'transaction_date': date.toIso8601String(),
      'transaction_amount': amount,
      'transaction_mcc': mcc.toJson(),
      'transaction_recipient': recipient,
      'transaction_note': note,
      'transaction_hashtags': hashtags.map((h) => h.toJson()).toList(),
      'transaction_created_at': createdAt.toIso8601String(),
      'transaction_updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['transaction_id'] as int?,
      isExpense: (map['transaction_is_expense'] as int) == 1,
      date: DateTime.parse(map['transaction_date'] as String),
      amount: (map['transaction_amount'] as num).toDouble(),
      mcc: MCC.fromJson(map['transaction_mcc'] as Map<String, dynamic>),
      recipient: map['transaction_recipient'] as String? ?? '',
      note: map['transaction_note'] as String? ?? '',
      hashtags:
          (map['transaction_hashtags'] as List?)
              ?.map((h) => HashtagGroup.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(map['transaction_created_at'] as String),
      updatedAt: DateTime.parse(map['transaction_updated_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isExpense': isExpense,
      'date': date.toIso8601String(),
      'amount': amount,
      'mcc': mcc.toJson(),
      'recipient': recipient,
      'note': note,
      'hashtags': hashtags.map((h) => h.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int?,
      isExpense: json['isExpense'] as bool,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      mcc: MCC.fromJson(json['mcc'] as Map<String, dynamic>),
      recipient: json['recipient'] as String? ?? '',
      note: json['note'] as String? ?? '',
      hashtags:
          (json['hashtags'] as List?)
              ?.map((h) => HashtagGroup.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Create a copy with updated fields
  Transaction copyWith({
    int? id,
    bool? isExpense,
    DateTime? date,
    double? amount,
    MCC? mcc,
    String? recipient,
    String? note,
    List<HashtagGroup>? hashtags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      isExpense: isExpense ?? this.isExpense,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      mcc: mcc ?? this.mcc,
      recipient: recipient ?? this.recipient,
      note: note ?? this.note,
      hashtags: hashtags ?? this.hashtags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create a copy with updated timestamp
  Transaction copyWithUpdatedTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  @override
  String toString() {
    return 'Transaction{id: $id, isExpense: $isExpense, date: $date, '
        'amount: $amount, mcc: $mcc, recipient: $recipient, note: $note, hashtags: ${hashtags.length}}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.isExpense == isExpense &&
        other.date == date &&
        other.amount == amount &&
        other.note == note;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        isExpense.hashCode ^
        date.hashCode ^
        amount.hashCode ^
        note.hashCode;
  }
}

/// Helper class for transaction operations
class TransactionHelper {
  /// Convert list of database maps to list of Transaction objects
  static List<Transaction> fromMapList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  /// Filter transactions by date range
  static List<Transaction> filterByDateRange(
    List<Transaction> transactions,
    DateTime startDate,
    DateTime endDate,
  ) {
    return transactions
        .where(
          (t) =>
              t.date.isAfter(startDate.subtract(Duration(days: 1))) &&
              t.date.isBefore(endDate.add(Duration(days: 1))),
        )
        .toList();
  }

  /// Filter expenses only
  static List<Transaction> filterExpenses(List<Transaction> transactions) {
    return transactions.where((t) => t.isExpense).toList();
  }

  /// Filter income only
  static List<Transaction> filterIncome(List<Transaction> transactions) {
    return transactions.where((t) => t.isIncome).toList();
  }

  /// Calculate total amount
  static double calculateTotal(List<Transaction> transactions) {
    return transactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Calculate total expenses
  static double calculateTotalExpenses(List<Transaction> transactions) {
    return calculateTotal(filterExpenses(transactions));
  }

  /// Calculate total income
  static double calculateTotalIncome(List<Transaction> transactions) {
    return calculateTotal(filterIncome(transactions));
  }

  /// Get balance (income - expenses)
  static double getBalance(List<Transaction> transactions) {
    return calculateTotalIncome(transactions) -
        calculateTotalExpenses(transactions);
  }

  /// Group transactions by date
  static Map<DateTime, List<Transaction>> groupByDate(
    List<Transaction> transactions,
  ) {
    final Map<DateTime, List<Transaction>> grouped = {};
    for (final transaction in transactions) {
      final dateKey = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(transaction);
    }
    return grouped;
  }

  /// Sort transactions by date (newest first)
  static List<Transaction> sortByDateDesc(List<Transaction> transactions) {
    final sorted = List<Transaction>.from(transactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  /// Sort transactions by date (oldest first)
  static List<Transaction> sortByDateAsc(List<Transaction> transactions) {
    final sorted = List<Transaction>.from(transactions);
    sorted.sort((a, b) => a.date.compareTo(b.date));
    return sorted;
  }

  /// Sort transactions by amount (highest first)
  static List<Transaction> sortByAmountDesc(List<Transaction> transactions) {
    final sorted = List<Transaction>.from(transactions);
    sorted.sort((a, b) => b.amount.compareTo(a.amount));
    return sorted;
  }

  /// Sort transactions by amount (lowest first)
  static List<Transaction> sortByAmountAsc(List<Transaction> transactions) {
    final sorted = List<Transaction>.from(transactions);
    sorted.sort((a, b) => a.amount.compareTo(b.amount));
    return sorted;
  }
}
