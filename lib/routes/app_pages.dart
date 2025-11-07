import 'package:get/get.dart';
import 'package:moneyapp/controllers/home_controller.dart';
import 'package:moneyapp/routes/app_routes.dart';
import 'package:moneyapp/screens/home/home_screen.dart';

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
      page: () => const HomeScreen(),
      binding: HomeBinding(),
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
