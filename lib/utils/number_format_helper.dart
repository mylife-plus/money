import 'package:intl/intl.dart';
import 'package:moneyapp/services/currency_service.dart';

/// Centralized number formatting — locale-aware based on selected currency.
///
/// Each method accepts an optional [locale] parameter.
/// If omitted, the cashflow currency's locale is used by default.
/// For portfolio/investment amounts, pass [CurrencyService.instance.portfolioLocale].
class NumberFormatHelper {
  // Locale-keyed caches (lazily populated)
  static final Map<String, NumberFormat> _currencyFormats = {};
  static final Map<String, NumberFormat> _currencyNoDecFormats = {};
  static final Map<String, NumberFormat> _amountFormats = {};
  static final Map<String, String> _decimalSeparators = {};

  static String _defaultLocale() => CurrencyService.instance.cashflowLocale;

  static NumberFormat _getCurrencyFormat(String locale) {
    return _currencyFormats.putIfAbsent(
      locale,
      () => NumberFormat('#,##0.00', locale),
    );
  }

  static NumberFormat _getCurrencyNoDecFormat(String locale) {
    return _currencyNoDecFormats.putIfAbsent(
      locale,
      () => NumberFormat('#,##0', locale),
    );
  }

  static NumberFormat _getAmountFormat(String locale) {
    return _amountFormats.putIfAbsent(
      locale,
      () => NumberFormat('#,##0.########', locale),
    );
  }

  static String _getDecimalSeparator(String locale) {
    return _decimalSeparators.putIfAbsent(
      locale,
      () => NumberFormat('#', locale).symbols.DECIMAL_SEP,
    );
  }

  /// Clear all cached formatters (call when currency changes)
  static void clearCache() {
    _currencyFormats.clear();
    _currencyNoDecFormats.clear();
    _amountFormats.clear();
    _decimalSeparators.clear();
  }

  /// Format monetary value with 2 decimals: 1.234,56 (de) or 1,234.56 (en)
  static String formatCurrency(double value, {String? locale}) {
    final l = locale ?? _defaultLocale();
    return _getCurrencyFormat(l).format(value);
  }

  /// Format monetary value with no decimals: 1.235 (de) or 1,235 (en)
  static String formatCurrencyNoDecimals(double value, {String? locale}) {
    final l = locale ?? _defaultLocale();
    return _getCurrencyNoDecFormat(l).format(value);
  }

  /// Format compact currency (M/k abbreviations): 1,23M (de) or 1.23M (en)
  static String formatCurrencyCompact(double value, {String? locale}) {
    final l = locale ?? _defaultLocale();
    if (value.abs() >= 1000000) {
      return '${_formatDecimal(value / 1000000, 2, l)}M';
    } else if (value.abs() >= 1000) {
      return '${_formatDecimal(value / 1000, 1, l)}k';
    }
    return formatCurrency(value, locale: l);
  }

  /// Format quantity/amount (up to 4 decimal places, trailing zeros removed)
  static String formatAmount(double value, {String? locale}) {
    final l = locale ?? _defaultLocale();
    if (value == value.roundToDouble()) {
      return _getCurrencyNoDecFormat(l).format(value);
    }
    final formatted = value
        .toStringAsFixed(4)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    // Parse back and format with thousand separators
    final parsed = double.tryParse(formatted) ?? value;
    return _getAmountFormat(l).format(parsed);
  }

  /// Format for chart Y-axis labels (compact: 1k, 2.5k/2,5k, 1m)
  static String formatYAxisLabel(double value, {String? locale}) {
    final l = locale ?? _defaultLocale();
    if (value.abs() >= 1000) {
      final kValue = value / 1000;
      if (kValue % 1 == 0) {
        return '${kValue.toInt()}k';
      }
      return '${_formatDecimal(kValue, 1, l)}k';
    }
    return value.toInt().toString();
  }

  /// Helper: format a double with the locale's decimal separator
  static String _formatDecimal(double value, int decimals, String locale) {
    final decSep = _getDecimalSeparator(locale);
    return value.toStringAsFixed(decimals).replaceAll('.', decSep);
  }
}
