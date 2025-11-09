import 'package:get/get.dart';

/// Home Screen Controller
/// Manages state and business logic for Home Screen
class HomeController extends GetxController {
  // Observable variables
  final RxInt selectedToggleOption = 1.obs; // 1 = Spending, 2 = Income
  final RxInt selectedChartDurationOption = 1.obs; // 1 = Year, 2 = Month

  // Getter
  bool get isExpenseSelected => selectedToggleOption.value == 1;

  // Methods
  void selectSpending() {
    selectedToggleOption.value = 1;
  }

  void selectIncome() {
    selectedToggleOption.value = 2;
  }

  void selectYear() {
    selectedChartDurationOption.value = 1;
  }

  void selectMonth() {
    selectedChartDurationOption.value = 2;
  }
}
