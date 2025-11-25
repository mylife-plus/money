class InvestmentData {
  final String icon;
  final String name;
  final String amount;
  final String symbol;
  final String unitPrice;
  final String totalValue;

  InvestmentData({
    required this.icon,
    required this.name,
    required this.amount,
    required this.symbol,
    required this.unitPrice,
    required this.totalValue,
  });

  static List<InvestmentData> getSampleData() {
    return [
      InvestmentData(
        icon: '🪙',
        name: 'Bitcoin',
        amount: '1',
        symbol: 'BTC',
        unitPrice: '\$ 100,34k',
        totalValue: '\$ 100,000,000',
      ),
      InvestmentData(
        icon: '🪙',
        name: 'Ethereum',
        amount: '10',
        symbol: 'ETH',
        unitPrice: '\$ 10.100',
        totalValue: '\$ 110,000',
      ),
      InvestmentData(
        icon: '🏡',
        name: 'Haus',
        amount: '1 🏡',
        symbol: '',
        unitPrice: '\$ 30.000',
        totalValue: '\$ 30,000',
      ),
      InvestmentData(
        icon: '🚙',
        name: 'Car',
        amount: '1 🚙',
        symbol: '',
        unitPrice: '\$ 12.000',
        totalValue: '\$ 12,000',
      ),
      InvestmentData(
        icon: '🪙',
        name: 'Euro',
        amount: '100',
        symbol: 'EUR',
        unitPrice: '\$ 0.92',
        totalValue: '\$ 120',
      ),
      InvestmentData(
        icon: '📱',
        name: 'Apple',
        amount: '50',
        symbol: 'AAPL',
        unitPrice: '\$ 175.30',
        totalValue: '\$ 8,765',
      ),
      InvestmentData(
        icon: '📦',
        name: 'Amazon',
        amount: '10',
        symbol: 'AMZN',
        unitPrice: '\$ 3,200',
        totalValue: '\$ 32,005',
      ),

      InvestmentData(
        icon: '📈',
        name: 'S&P 500 ETF',
        amount: '100',
        symbol: 'SPY',
        unitPrice: '\$ 450.75',
        totalValue: '\$ 45,075',
      ),
    ];
  }
}
