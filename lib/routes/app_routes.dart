/// App Routes Enum
/// Define all route names here
enum AppRoutes {
  home,
  investment,
  investmentList,
  settings,
  hashtagGroups,
  uploadTransaction,
  uploadInvestment,
  // Add more routes here as needed
  // example: login, profile, etc.
}

/// Extension to get route path from enum
extension AppRoutesExtension on AppRoutes {
  String get path {
    switch (this) {
      case AppRoutes.home:
        return '/home';
      case AppRoutes.investment:
        return '/investment';
      case AppRoutes.investmentList:
        return '/investmentList';
      case AppRoutes.settings:
        return '/settings';
      case AppRoutes.hashtagGroups:
        return '/hashtagGroups';
      case AppRoutes.uploadTransaction:
        return '/uploadTransactions';
      case AppRoutes.uploadInvestment:
        return '/uploadInvestments';
      // Add more cases here
    }
  }
}
