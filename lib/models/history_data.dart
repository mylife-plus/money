import 'package:moneyapp/services/currency_service.dart';

class HistoryData {
  final String type; // 'sold' or 'bought'
  final String amount;
  final String symbol;
  final String price;
  final String priceSymbol;
  final String total;
  final String totalSymbol;

  HistoryData({
    required this.type,
    required this.amount,
    required this.symbol,
    required this.price,
    required this.priceSymbol,
    required this.total,
    required this.totalSymbol,
  });
}

class TradeGroup {
  final String date;
  final List<HistoryData> trades;

  TradeGroup({required this.date, required this.trades});

  static List<TradeGroup> getSampleData() {
    return [
      TradeGroup(
        date: '12. Dec.',
        trades: [
          HistoryData(
            type: 'sold',
            amount: '1',
            symbol: 'BTC',
            price: '120.000',
            priceSymbol: CurrencyService.instance.portfolioCode,
            total: '120,000',
            totalSymbol: CurrencyService.instance.portfolioCode,
          ),
          HistoryData(
            type: 'bought',
            amount: '10',
            symbol: 'ETH',
            price: '10.100',
            priceSymbol: CurrencyService.instance.portfolioCode,
            total: '120,000',
            totalSymbol: CurrencyService.instance.portfolioCode,
          ),
        ],
      ),
      TradeGroup(
        date: '1. Dec.',
        trades: [
          HistoryData(
            type: 'sold',
            amount: '30,000',
            symbol: 'EUR',
            price: '120.000',
            priceSymbol: CurrencyService.instance.portfolioCode,
            total: '10.100',
            totalSymbol: CurrencyService.instance.portfolioCode,
          ),
          HistoryData(
            type: 'bought',
            amount: '1 🏠',
            symbol: '',
            price: '10.100',
            priceSymbol: CurrencyService.instance.portfolioCode,
            total: '10.100',
            totalSymbol: CurrencyService.instance.portfolioCode,
          ),
          HistoryData(
            type: 'sold',
            amount: '30,000',
            symbol: 'EUR',
            price: '120.000',
            priceSymbol: CurrencyService.instance.portfolioCode,
            total: '120,000',
            totalSymbol: CurrencyService.instance.portfolioCode,
          ),
          HistoryData(
            type: 'bought',
            amount: '1 🚙',
            symbol: '',
            price: '10.100',
            priceSymbol: CurrencyService.instance.portfolioCode,
            total: '120,000',
            totalSymbol: CurrencyService.instance.portfolioCode,
          ),
        ],
      ),
    ];
  }
}
