import 'package:get/get.dart';

/// Home Screen Controller
/// Manages state and business logic for Home Screen
class InvestmentController extends GetxController {
  // Observable variables
  final RxInt selectedToggleOption = 1.obs; // 1 = Portfolio, 2 = Trades

  // Getter
  bool get isPortfolioSelected => selectedToggleOption.value == 1;
  // Methods
  void selectPortfolio() {
    selectedToggleOption.value = 1;
  }

  void selectTrades() {
    selectedToggleOption.value = 2;
  }
}
