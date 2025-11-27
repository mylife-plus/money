import 'dart:ui';

import 'package:moneyapp/constants/app_constants.dart';
import 'package:moneyapp/constants/app_icons.dart';

class InvestmentData {
  final String image;
  final String name;
  final String amount;
  final String symbol;
  final String unitPrice;
  final String totalValue;
  final Color backgroundColor;

  InvestmentData({
    required this.image,
    required this.name,
    required this.amount,
    required this.symbol,
    required this.unitPrice,
    required this.totalValue,
    required this.backgroundColor,
  });

  static List<InvestmentData> getSampleData() {
    return [
      InvestmentData(
        image: AppIcons.digitalCurrency,
        name: 'Bitcoin',
        amount: '1',
        symbol: 'BTC',
        unitPrice: '100,34k',
        totalValue: '100,000,000',
        backgroundColor: const Color(0xffFFD4A3),
      ),
      InvestmentData(
        image: AppIcons.digitalCurrency,
        name: 'Ethereum',
        amount: '10',
        symbol: 'ETH',
        unitPrice: '10.100',
        totalValue: '110,000',
        backgroundColor: const Color(0xffB7DDFF),
      ),
      InvestmentData(
        image: AppIcons.home,
        name: 'Haus',
        amount: '1 🏡',
        symbol: '',
        unitPrice: '30.000',
        totalValue: '30,000',
        backgroundColor: const Color(0xffA3FFD4),
      ),
      InvestmentData(
        image: AppIcons.car,
        name: 'Car',
        amount: '1 🚙',
        symbol: '',
        unitPrice: '12.000',
        totalValue: '12,000',
        backgroundColor: const Color(0xffFFD4A3),
      ),
      InvestmentData(
        image: AppIcons.digitalCurrency,
        name: 'Euro',
        amount: '100',
        symbol: 'EUR',
        unitPrice: '0.92',
        totalValue: '120',
        backgroundColor: const Color(0xffFFD4A3),
      ),
      InvestmentData(
        image: AppIcons.atm,
        name: 'Apple',
        amount: '50',
        symbol: 'AAPL',
        unitPrice: '175.30',
        totalValue: '8,765',
        backgroundColor: const Color(0xffFFD4A3),
      ),
      InvestmentData(
        image: AppIcons.cart,
        name: 'Amazon',
        amount: '10',
        symbol: 'AMZN',
        unitPrice: '3,200',
        totalValue: '32,005',
        backgroundColor: const Color(0xffFFD4A3),
      ),

      InvestmentData(
        image: AppIcons.digitalCurrency,
        name: 'S&P 500 ETF',
        amount: '100',
        symbol: 'SPY',
        unitPrice: '450.75',
        totalValue: '45,075',
        backgroundColor: const Color(0xffFFD4A3),
      ),
    ];
  }
}
