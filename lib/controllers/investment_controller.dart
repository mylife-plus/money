import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/models/investment_recommendation.dart';

class Trade {
  final int? id;
  final DateTime date;
  final String soldAmount;
  final String soldSymbol;
  final String soldPrice;
  final String soldPriceSymbol;
  final String soldTotal;
  final String soldTotalSymbol;
  final String boughtAmount;
  final String boughtSymbol;
  final String boughtPrice;
  final String boughtPriceSymbol;
  final String boughtTotal;
  final String boughtTotalSymbol;

  Trade({
    this.id,
    required this.date,
    required this.soldAmount,
    required this.soldSymbol,
    required this.soldPrice,
    required this.soldPriceSymbol,
    required this.soldTotal,
    required this.soldTotalSymbol,
    required this.boughtAmount,
    required this.boughtSymbol,
    required this.boughtPrice,
    required this.boughtPriceSymbol,
    required this.boughtTotal,
    required this.boughtTotalSymbol,
  });
}

/// Investment Controller
/// Manages state and business logic for Investment Screen
class InvestmentController extends GetxController {
  // Observable variables
  final RxInt selectedToggleOption = 1.obs; // 1 = Portfolio, 2 = Trades

  // Expandable state tracking for trades
  final RxSet<int> expandedYears = <int>{}.obs;
  final RxSet<String> expandedMonths = <String>{}.obs; // Format: "year-month"

  // Sample trades data
  final RxList<Trade> trades = <Trade>[
    Trade(
      id: 1,
      date: DateTime(2024, 12, 12),
      soldAmount: '1',
      soldSymbol: 'BTC',
      soldPrice: '120.000',
      soldPriceSymbol: 'USD',
      soldTotal: '120,000',
      soldTotalSymbol: 'USD',
      boughtAmount: '10',
      boughtSymbol: 'ETH',
      boughtPrice: '10.100',
      boughtPriceSymbol: 'USD',
      boughtTotal: '120,000',
      boughtTotalSymbol: 'USD',
    ),
    Trade(
      id: 2,
      date: DateTime(2024, 12, 1),
      soldAmount: '30,000',
      soldSymbol: 'EUR',
      soldPrice: '120.000',
      soldPriceSymbol: 'USD',
      soldTotal: '10.100',
      soldTotalSymbol: 'USD',
      boughtAmount: '1 🏠',
      boughtSymbol: '',
      boughtPrice: '10.100',
      boughtPriceSymbol: 'USD',
      boughtTotal: '10.100',
      boughtTotalSymbol: 'USD',
    ),
    Trade(
      id: 3,
      date: DateTime(2024, 12, 1),
      soldAmount: '30,000',
      soldSymbol: 'EUR',
      soldPrice: '120.000',
      soldPriceSymbol: 'USD',
      soldTotal: '120,000',
      soldTotalSymbol: 'USD',
      boughtAmount: '1 🚙',
      boughtSymbol: '',
      boughtPrice: '10.100',
      boughtPriceSymbol: 'USD',
      boughtTotal: '120,000',
      boughtTotalSymbol: 'USD',
    ),
    Trade(
      id: 4,
      date: DateTime(2023, 11, 15),
      soldAmount: '5',
      soldSymbol: 'ETH',
      soldPrice: '10.000',
      soldPriceSymbol: 'USD',
      soldTotal: '50,000',
      soldTotalSymbol: 'USD',
      boughtAmount: '50,000',
      boughtSymbol: 'EUR',
      boughtPrice: '1.0',
      boughtPriceSymbol: 'USD',
      boughtTotal: '50,000',
      boughtTotalSymbol: 'USD',
    ),
  ].obs;

  // Investment recommendations
  final RxList<InvestmentRecommendation> recommendations =
      <InvestmentRecommendation>[
        InvestmentRecommendation.fromAsset(
          assetPath: AppIcons.digitalCurrency,
          text: 'Bitcoin',
          shortText: 'BTC',
          color: const Color(0xffFFF1B8),
        ),
        InvestmentRecommendation.fromAsset(
          assetPath: AppIcons.bitcoinConvert,
          text: 'Ethereum',
          shortText: 'ETH',
          color: const Color(0xffFFA1EF),
        ),
        InvestmentRecommendation.fromAsset(
          assetPath: AppIcons.investment,
          text: 'Haus',
          shortText: '🏡',
          color: const Color(0xffB7DDFF),
        ),
        InvestmentRecommendation.fromAsset(
          assetPath: AppIcons.car,
          text: 'Car',
          shortText: '🚗',
          color: const Color(0xffA3FFD4),
        ),
        InvestmentRecommendation.fromAsset(
          assetPath: AppIcons.atm,
          text: 'Euro',
          shortText: 'EUR',
          color: const Color(0xffFFD4A3),
        ),
      ].obs;

  @override
  void onInit() {
    super.onInit();
    // Expand all years and months by default
    for (var year in sortedYears) {
      expandedYears.add(year);

      final months = getSortedMonths(year);
      for (var month in months) {
        expandedMonths.add('$year-$month');
      }
    }
  }

  // Getter
  bool get isPortfolioSelected => selectedToggleOption.value == 1;

  // Methods
  void selectPortfolio() {
    selectedToggleOption.value = 1;
  }

  void selectTrades() {
    selectedToggleOption.value = 2;
  }

  /// Add a new recommendation
  void addRecommendation(InvestmentRecommendation recommendation) {
    recommendations.add(recommendation);
  }

  /// Remove a recommendation
  void removeRecommendation(int index) {
    if (index >= 0 && index < recommendations.length) {
      recommendations.removeAt(index);
    }
  }

  /// Update a recommendation
  void updateRecommendation(
    int index,
    InvestmentRecommendation recommendation,
  ) {
    if (index >= 0 && index < recommendations.length) {
      recommendations[index] = recommendation;
    }
  }

  /// Group trades by year
  Map<int, List<Trade>> get tradesByYear {
    final Map<int, List<Trade>> grouped = {};
    for (var trade in trades) {
      final year = trade.date.year;
      if (!grouped.containsKey(year)) {
        grouped[year] = [];
      }
      grouped[year]!.add(trade);
    }
    return grouped;
  }

  /// Get sorted years (newest first)
  List<int> get sortedYears {
    return tradesByYear.keys.toList()..sort((a, b) => b.compareTo(a));
  }

  /// Get trades grouped by month for a specific year
  Map<int, List<Trade>> getTradesByMonth(int year) {
    final yearTrades = tradesByYear[year] ?? [];
    final Map<int, List<Trade>> grouped = {};
    for (var trade in yearTrades) {
      final month = trade.date.month;
      if (!grouped.containsKey(month)) {
        grouped[month] = [];
      }
      grouped[month]!.add(trade);
    }
    return grouped;
  }

  /// Get sorted months for a year (newest first)
  List<int> getSortedMonths(int year) {
    return getTradesByMonth(year).keys.toList()..sort((a, b) => b.compareTo(a));
  }

  /// Get trades for a specific month
  List<Trade> getTradesForMonth(int year, int month) {
    final monthTrades = getTradesByMonth(year)[month] ?? [];
    return monthTrades..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get trades grouped by day for a specific month
  Map<int, List<Trade>> getTradesByDay(int year, int month) {
    final monthTrades = getTradesForMonth(year, month);
    final Map<int, List<Trade>> grouped = {};
    for (var trade in monthTrades) {
      final day = trade.date.day;
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(trade);
    }
    return grouped;
  }

  /// Get sorted days for a month (newest first)
  List<int> getSortedDays(int year, int month) {
    return getTradesByDay(year, month).keys.toList()
      ..sort((a, b) => b.compareTo(a));
  }

  /// Get trades for a specific day
  List<Trade> getTradesForDay(int year, int month, int day) {
    final dayTrades = getTradesByDay(year, month)[day] ?? [];
    return dayTrades..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Toggle year expansion
  void toggleYearExpansion(int year) {
    if (expandedYears.contains(year)) {
      expandedYears.remove(year);
      // Also collapse all months in this year
      expandedMonths.removeWhere((key) => key.startsWith('$year-'));
    } else {
      expandedYears.add(year);
    }
  }

  /// Toggle month expansion
  void toggleMonthExpansion(int year, int month) {
    final key = '$year-$month';
    if (expandedMonths.contains(key)) {
      expandedMonths.remove(key);
    } else {
      expandedMonths.add(key);
    }
  }

  /// Check if year is expanded
  bool isYearExpanded(int year) {
    return expandedYears.contains(year);
  }

  /// Check if month is expanded
  bool isMonthExpanded(int year, int month) {
    return expandedMonths.contains('$year-$month');
  }

  /// Get month name from number
  String getMonthName(int month) {
    final date = DateTime(2024, month);
    return DateFormat('MMMM').format(date);
  }

  /// Delete trades by IDs
  void deleteTrades(List<int> tradeIds) {
    trades.removeWhere((trade) => trade.id != null && tradeIds.contains(trade.id));
  }
}
