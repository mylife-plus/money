/// App Routes Enum
/// Define all route names here
enum AppRoutes {
  home,
  settings,
  // Add more routes here as needed
  // example: login, profile, etc.
}

/// Extension to get route path from enum
extension AppRoutesExtension on AppRoutes {
  String get path {
    switch (this) {
      case AppRoutes.home:
        return '/home';
      case AppRoutes.settings:
        return '/settings';
      // Add more cases here
    }
  }
}
