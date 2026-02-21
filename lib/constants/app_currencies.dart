/// Currency model for display and storage
class AppCurrency {
  final String code; // e.g. 'EUR'
  final String symbol; // e.g. '€'
  final String name; // e.g. 'Euro'
  final String flag; // e.g. '🇪🇺'

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
  });

  /// Display string for dropdowns: "Euro €"
  String get displayName => '$name $symbol';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppCurrency && other.code == code;

  @override
  int get hashCode => code.hashCode;
}

/// All available currencies
class AppCurrencies {
  AppCurrencies._();

  static const AppCurrency eur = AppCurrency(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    flag: '🇪🇺',
  );
  static const AppCurrency usd = AppCurrency(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    flag: '🇺🇸',
  );
  static const AppCurrency gbp = AppCurrency(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
    flag: '🇬🇧',
  );
  static const AppCurrency chf = AppCurrency(
    code: 'CHF',
    symbol: 'CHF',
    name: 'Swiss Franc',
    flag: '🇨🇭',
  );
  static const AppCurrency jpy = AppCurrency(
    code: 'JPY',
    symbol: '¥',
    name: 'Japanese Yen',
    flag: '🇯🇵',
  );
  static const AppCurrency cny = AppCurrency(
    code: 'CNY',
    symbol: '¥',
    name: 'Chinese Yuan',
    flag: '🇨🇳',
  );
  static const AppCurrency cad = AppCurrency(
    code: 'CAD',
    symbol: 'C\$',
    name: 'Canadian Dollar',
    flag: '🇨🇦',
  );
  static const AppCurrency aud = AppCurrency(
    code: 'AUD',
    symbol: 'A\$',
    name: 'Australian Dollar',
    flag: '🇦🇺',
  );
  static const AppCurrency inr = AppCurrency(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
    flag: '🇮🇳',
  );
  static const AppCurrency krw = AppCurrency(
    code: 'KRW',
    symbol: '₩',
    name: 'South Korean Won',
    flag: '🇰🇷',
  );
  static const AppCurrency try_ = AppCurrency(
    code: 'TRY',
    symbol: '₺',
    name: 'Turkish Lira',
    flag: '🇹🇷',
  );
  static const AppCurrency brl = AppCurrency(
    code: 'BRL',
    symbol: 'R\$',
    name: 'Brazilian Real',
    flag: '🇧🇷',
  );
  static const AppCurrency mxn = AppCurrency(
    code: 'MXN',
    symbol: 'MX\$',
    name: 'Mexican Peso',
    flag: '🇲🇽',
  );
  static const AppCurrency sek = AppCurrency(
    code: 'SEK',
    symbol: 'kr',
    name: 'Swedish Krona',
    flag: '🇸🇪',
  );
  static const AppCurrency nok = AppCurrency(
    code: 'NOK',
    symbol: 'kr',
    name: 'Norwegian Krone',
    flag: '🇳🇴',
  );
  static const AppCurrency dkk = AppCurrency(
    code: 'DKK',
    symbol: 'kr',
    name: 'Danish Krone',
    flag: '🇩🇰',
  );
  static const AppCurrency pln = AppCurrency(
    code: 'PLN',
    symbol: 'zł',
    name: 'Polish Zloty',
    flag: '🇵🇱',
  );
  static const AppCurrency czk = AppCurrency(
    code: 'CZK',
    symbol: 'Kč',
    name: 'Czech Koruna',
    flag: '🇨🇿',
  );
  static const AppCurrency huf = AppCurrency(
    code: 'HUF',
    symbol: 'Ft',
    name: 'Hungarian Forint',
    flag: '🇭🇺',
  );
  static const AppCurrency ron = AppCurrency(
    code: 'RON',
    symbol: 'lei',
    name: 'Romanian Leu',
    flag: '🇷🇴',
  );
  static const AppCurrency bgn = AppCurrency(
    code: 'BGN',
    symbol: 'лв',
    name: 'Bulgarian Lev',
    flag: '🇧🇬',
  );
  static const AppCurrency hrk = AppCurrency(
    code: 'HRK',
    symbol: 'kn',
    name: 'Croatian Kuna',
    flag: '🇭🇷',
  );
  static const AppCurrency rub = AppCurrency(
    code: 'RUB',
    symbol: '₽',
    name: 'Russian Ruble',
    flag: '🇷🇺',
  );
  static const AppCurrency uah = AppCurrency(
    code: 'UAH',
    symbol: '₴',
    name: 'Ukrainian Hryvnia',
    flag: '🇺🇦',
  );
  static const AppCurrency zar = AppCurrency(
    code: 'ZAR',
    symbol: 'R',
    name: 'South African Rand',
    flag: '🇿🇦',
  );
  static const AppCurrency aed = AppCurrency(
    code: 'AED',
    symbol: 'د.إ',
    name: 'UAE Dirham',
    flag: '🇦🇪',
  );
  static const AppCurrency sar = AppCurrency(
    code: 'SAR',
    symbol: '﷼',
    name: 'Saudi Riyal',
    flag: '🇸🇦',
  );
  static const AppCurrency nzd = AppCurrency(
    code: 'NZD',
    symbol: 'NZ\$',
    name: 'New Zealand Dollar',
    flag: '🇳🇿',
  );
  static const AppCurrency sgd = AppCurrency(
    code: 'SGD',
    symbol: 'S\$',
    name: 'Singapore Dollar',
    flag: '🇸🇬',
  );
  static const AppCurrency hkd = AppCurrency(
    code: 'HKD',
    symbol: 'HK\$',
    name: 'Hong Kong Dollar',
    flag: '🇭🇰',
  );
  static const AppCurrency thb = AppCurrency(
    code: 'THB',
    symbol: '฿',
    name: 'Thai Baht',
    flag: '🇹🇭',
  );
  static const AppCurrency idr = AppCurrency(
    code: 'IDR',
    symbol: 'Rp',
    name: 'Indonesian Rupiah',
    flag: '🇮🇩',
  );
  static const AppCurrency myr = AppCurrency(
    code: 'MYR',
    symbol: 'RM',
    name: 'Malaysian Ringgit',
    flag: '🇲🇾',
  );
  static const AppCurrency php = AppCurrency(
    code: 'PHP',
    symbol: '₱',
    name: 'Philippine Peso',
    flag: '🇵🇭',
  );
  static const AppCurrency egp = AppCurrency(
    code: 'EGP',
    symbol: 'E£',
    name: 'Egyptian Pound',
    flag: '🇪🇬',
  );
  static const AppCurrency ngn = AppCurrency(
    code: 'NGN',
    symbol: '₦',
    name: 'Nigerian Naira',
    flag: '🇳🇬',
  );
  static const AppCurrency pkr = AppCurrency(
    code: 'PKR',
    symbol: 'Rs',
    name: 'Pakistani Rupee',
    flag: '🇵🇰',
  );
  static const AppCurrency bdt = AppCurrency(
    code: 'BDT',
    symbol: '৳',
    name: 'Bangladeshi Taka',
    flag: '🇧🇩',
  );
  static const AppCurrency vnd = AppCurrency(
    code: 'VND',
    symbol: '₫',
    name: 'Vietnamese Dong',
    flag: '🇻🇳',
  );
  static const AppCurrency ars = AppCurrency(
    code: 'ARS',
    symbol: 'AR\$',
    name: 'Argentine Peso',
    flag: '🇦🇷',
  );
  static const AppCurrency clp = AppCurrency(
    code: 'CLP',
    symbol: 'CL\$',
    name: 'Chilean Peso',
    flag: '🇨🇱',
  );
  static const AppCurrency cop = AppCurrency(
    code: 'COP',
    symbol: 'CO\$',
    name: 'Colombian Peso',
    flag: '🇨🇴',
  );
  static const AppCurrency pen = AppCurrency(
    code: 'PEN',
    symbol: 'S/',
    name: 'Peruvian Sol',
    flag: '🇵🇪',
  );
  static const AppCurrency ils = AppCurrency(
    code: 'ILS',
    symbol: '₪',
    name: 'Israeli Shekel',
    flag: '🇮🇱',
  );
  static const AppCurrency kes = AppCurrency(
    code: 'KES',
    symbol: 'KSh',
    name: 'Kenyan Shilling',
    flag: '🇰🇪',
  );
  static const AppCurrency ghs = AppCurrency(
    code: 'GHS',
    symbol: 'GH₵',
    name: 'Ghanaian Cedi',
    flag: '🇬🇭',
  );

  /// Complete list of all available currencies
  static const List<AppCurrency> all = [
    eur,
    usd,
    gbp,
    chf,
    jpy,
    cny,
    cad,
    aud,
    inr,
    krw,
    try_,
    brl,
    mxn,
    sek,
    nok,
    dkk,
    pln,
    czk,
    huf,
    ron,
    bgn,
    hrk,
    rub,
    uah,
    zar,
    aed,
    sar,
    nzd,
    sgd,
    hkd,
    thb,
    idr,
    myr,
    php,
    egp,
    ngn,
    pkr,
    bdt,
    vnd,
    ars,
    clp,
    cop,
    pen,
    ils,
    kes,
    ghs,
  ];

  /// Default cashflow currency
  static const AppCurrency defaultCashflow = eur;

  /// Find currency by code
  static AppCurrency? fromCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }
}
