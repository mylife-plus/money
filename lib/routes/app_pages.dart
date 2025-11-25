import 'package:get/get.dart';
import 'package:moneyapp/controllers/hashtag_groups_controller.dart';
import 'package:moneyapp/controllers/home_controller.dart';
import 'package:moneyapp/controllers/investment_controller.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/screens/hashtag/hashtag_group_screen.dart';
import 'package:moneyapp/screens/home/home_screen.dart';
import 'package:moneyapp/screens/home/investment_list_screen.dart';
import 'package:moneyapp/screens/home/investment_screen.dart';
import 'package:moneyapp/screens/setting/settings_screen.dart';
import 'package:moneyapp/screens/uploads/upload_investments_screen.dart';
import 'package:moneyapp/screens/uploads/upload_transactions_screen.dart';

/// App Pages Configuration
/// Configure all GetX pages and their bindings here
class AppPages {
  AppPages._();

  /// Initial route when app starts
  static final initial = AppRoutes.home.path;

  /// List of all app pages with their routes and bindings
  static final routes = [
    GetPage(
      name: AppRoutes.home.path,
      page: () => HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.investment.path,
      page: () => const InvestmentScreen(),
      binding: InvestmentBinding(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: AppRoutes.investmentList.path,
      page: () => const InvestmentListScreen(),
      binding: InvestmentBinding(),
    ),
    GetPage(name: AppRoutes.settings.path, page: () => SettingsScreen()),
    GetPage(
      name: AppRoutes.hashtagGroups.path,
      page: () => const HashtagGroupScreen(),
      binding: HashtagGroupsBinding(),
    ),

    GetPage(
      name: AppRoutes.uploadTransaction.path,
      page: () => const UploadTransactionsScreen(),
    ),
    GetPage(
      name: AppRoutes.uploadInvestment.path,
      page: () => const UploadInvestmentsScreen(),
    ),
    // Add more pages here
  ];
}

/// Home Screen Binding
/// Initialize controllers for Home screen
class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

/// Investment Screen Binding
/// Initialize controllers for Investment screen
class InvestmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvestmentController>(() => InvestmentController());
  }
}

class HashtagGroupsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HashtagGroupsController>(() => HashtagGroupsController());
  }
}
