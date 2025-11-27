import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moneyapp/constants/app_icons.dart';
import 'package:moneyapp/models/investment_recommendation.dart';

/// Home Screen Controller
/// Manages state and business logic for Home Screen
class InvestmentController extends GetxController {
  // Observable variables
  final RxInt selectedToggleOption = 1.obs; // 1 = Portfolio, 2 = Trades

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
}
