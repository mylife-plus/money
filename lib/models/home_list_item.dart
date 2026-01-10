import 'package:moneyapp/models/transaction_model.dart';

/// Base class for items in the Home Screen list
abstract class HomeListItem {}

/// Represents a Year Header (e.g., "2024")
class YearHeaderItem extends HomeListItem {
  final int year;
  final double totalAmount;
  final bool isExpanded;

  YearHeaderItem({
    required this.year,
    required this.totalAmount,
    required this.isExpanded,
  });
}

/// Represents a Month Header (e.g., "January")
class MonthHeaderItem extends HomeListItem {
  final int year;
  final int month;
  final String monthName;
  final double totalAmount;
  final bool isExpanded;

  MonthHeaderItem({
    required this.year,
    required this.month,
    required this.monthName,
    required this.totalAmount,
    required this.isExpanded,
  });
}

/// Represents a Transaction Item
class TransactionListItem extends HomeListItem {
  final Transaction transaction;

  TransactionListItem({required this.transaction});
}

/// Represents a generic vertical space
class SpacerItem extends HomeListItem {
  final double height;

  SpacerItem({required this.height});
}
