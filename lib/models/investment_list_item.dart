import 'package:moneyapp/models/investment_activity_model.dart';

/// Base class for items in the investment activities list
sealed class InvestmentListItem {}

/// Year header item
class InvestmentYearHeaderItem extends InvestmentListItem {
  final int year;
  final bool isExpanded;

  InvestmentYearHeaderItem({required this.year, required this.isExpanded});
}

/// Month header item
class InvestmentMonthHeaderItem extends InvestmentListItem {
  final int year;
  final int month;
  final String monthName;
  final bool isExpanded;

  InvestmentMonthHeaderItem({
    required this.year,
    required this.month,
    required this.monthName,
    required this.isExpanded,
  });
}

/// Day header item
class InvestmentDayHeaderItem extends InvestmentListItem {
  final int day;
  final String monthAbbr;
  final bool showHeaders;

  InvestmentDayHeaderItem({
    required this.day,
    required this.monthAbbr,
    required this.showHeaders,
  });
}

/// Activity item (trade or transaction)
class InvestmentActivityItem extends InvestmentListItem {
  final InvestmentActivity activity;
  final String? soldSymbol;
  final String? boughtSymbol;
  final String? transactionSymbol;
  final String? soldAmount;
  final String? soldPrice;
  final String? soldTotal;
  final String? boughtAmount;
  final String? boughtPrice;
  final String? boughtTotal;
  final String? transactionAmount;
  final String? transactionPrice;
  final String? transactionTotal;

  InvestmentActivityItem({
    required this.activity,
    this.soldSymbol,
    this.boughtSymbol,
    this.transactionSymbol,
    this.soldAmount,
    this.soldPrice,
    this.soldTotal,
    this.boughtAmount,
    this.boughtPrice,
    this.boughtTotal,
    this.transactionAmount,
    this.transactionPrice,
    this.transactionTotal,
  });
}

/// Spacer item for vertical spacing
class InvestmentSpacerItem extends InvestmentListItem {
  final double height;

  InvestmentSpacerItem(this.height);
}
