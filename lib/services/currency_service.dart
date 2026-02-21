import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:moneyapp/constants/app_currencies.dart';
import 'package:moneyapp/services/database/database_helper.dart';

/// Service to read/write currency settings from the database
class CurrencyService {
  CurrencyService._();
  static final CurrencyService instance = CurrencyService._();

  static const _keyCashflowCurrency = 'cashflow_currency';
  static const _keyPortfolioCurrency = 'portfolio_currency';

  AppCurrency? _cachedCashflowCurrency;
  AppCurrency? _cachedPortfolioCurrency;

  /// Get the cashflow currency (cached after first read)
  Future<AppCurrency?> getCashflowCurrency() async {
    if (_cachedCashflowCurrency != null) return _cachedCashflowCurrency;

    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        DatabaseHelper.tableAppSettings,
        where: '${DatabaseHelper.columnSettingKey} = ?',
        whereArgs: [_keyCashflowCurrency],
      );

      if (result.isNotEmpty) {
        final code = result.first[DatabaseHelper.columnSettingValue] as String;
        _cachedCashflowCurrency = AppCurrencies.fromCode(code);
        return _cachedCashflowCurrency;
      }
    } catch (e) {
      debugPrint('[CurrencyService] Error reading cashflow currency: $e');
    }
    return null;
  }

  /// Save the cashflow currency
  Future<void> setCashflowCurrency(AppCurrency currency) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert(
        DatabaseHelper.tableAppSettings,
        {
          DatabaseHelper.columnSettingKey: _keyCashflowCurrency,
          DatabaseHelper.columnSettingValue: currency.code,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _cachedCashflowCurrency = currency;
      debugPrint('[CurrencyService] Cashflow currency set to ${currency.code}');
    } catch (e) {
      debugPrint('[CurrencyService] Error saving cashflow currency: $e');
      rethrow;
    }
  }

  /// Check if a cashflow currency has been selected
  Future<bool> hasCashflowCurrency() async {
    final currency = await getCashflowCurrency();
    return currency != null;
  }

  /// Get the cashflow currency symbol (sync, uses cache)
  String get cashflowSymbol =>
      _cachedCashflowCurrency?.symbol ?? AppCurrencies.defaultCashflow.symbol;

  /// Get the cashflow currency code (sync, uses cache)
  String get cashflowCode =>
      _cachedCashflowCurrency?.code ?? AppCurrencies.defaultCashflow.code;

  /// Get the portfolio currency (cached after first read)
  Future<AppCurrency?> getPortfolioCurrency() async {
    if (_cachedPortfolioCurrency != null) return _cachedPortfolioCurrency;

    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.query(
        DatabaseHelper.tableAppSettings,
        where: '${DatabaseHelper.columnSettingKey} = ?',
        whereArgs: [_keyPortfolioCurrency],
      );

      if (result.isNotEmpty) {
        final code = result.first[DatabaseHelper.columnSettingValue] as String;
        _cachedPortfolioCurrency = AppCurrencies.fromCode(code);
        return _cachedPortfolioCurrency;
      }
    } catch (e) {
      debugPrint('[CurrencyService] Error reading portfolio currency: $e');
    }
    return null;
  }

  /// Save the portfolio currency
  Future<void> setPortfolioCurrency(AppCurrency currency) async {
    try {
      final db = await DatabaseHelper.instance.database;
      await db.insert(
        DatabaseHelper.tableAppSettings,
        {
          DatabaseHelper.columnSettingKey: _keyPortfolioCurrency,
          DatabaseHelper.columnSettingValue: currency.code,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _cachedPortfolioCurrency = currency;
      debugPrint(
        '[CurrencyService] Portfolio currency set to ${currency.code}',
      );
    } catch (e) {
      debugPrint('[CurrencyService] Error saving portfolio currency: $e');
      rethrow;
    }
  }

  /// Check if a portfolio currency has been selected
  Future<bool> hasPortfolioCurrency() async {
    final currency = await getPortfolioCurrency();
    return currency != null;
  }

  /// Check if a portfolio currency has been explicitly set (sync, uses cache)
  bool get hasPortfolioCurrencySync => _cachedPortfolioCurrency != null;

  /// Get the portfolio currency symbol (sync, uses cache)
  String get portfolioSymbol =>
      _cachedPortfolioCurrency?.symbol ?? AppCurrencies.defaultCashflow.symbol;

  /// Get the portfolio currency code (sync, uses cache)
  String get portfolioCode =>
      _cachedPortfolioCurrency?.code ?? AppCurrencies.defaultCashflow.code;

  /// Clear cache (for testing)
  void clearCache() {
    _cachedCashflowCurrency = null;
    _cachedPortfolioCurrency = null;
  }
}
