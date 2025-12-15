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
  newTransaction,
  editTransaction,
  splitSpending,
  newTrade,
  newInvestmentTransaction,
  newPortfolioChange,
  addMCC,
  transactionFilter,
  bitcoinPrices,
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
      case AppRoutes.newTransaction:
        return '/newTransaction';
      case AppRoutes.editTransaction:
        return '/editTransaction';
      case AppRoutes.splitSpending:
        return '/splitSpending';
      case AppRoutes.newTrade:
        return '/newTrade';
      case AppRoutes.newInvestmentTransaction:
        return '/newInvestmentTransaction';
      case AppRoutes.newPortfolioChange:
        return '/newPortfolioChange';
      case AppRoutes.addMCC:
        return '/addMCC';
      case AppRoutes.transactionFilter:
        return '/filter';
      case AppRoutes.bitcoinPrices:
        return '/bitcoinPrices';
      // Add more cases here
    }
  }
}
