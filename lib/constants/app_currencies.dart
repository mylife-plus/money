/// Currency model for display and storage
class AppCurrency {
  final String code; // e.g. 'EUR'
  final String symbol; // e.g. '€'
  final String name; // e.g. 'Euro'
  final String flag; // e.g. '🇪🇺'
  final String
  locale; // e.g. 'de_DE' — controls number format (thousand/decimal separators)

  const AppCurrency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
    required this.locale,
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

  // ── de_DE locale: 1.234,56 ──
  static const AppCurrency eur = AppCurrency(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    flag: '🇪🇺',
    locale: 'de_DE',
  );
  static const AppCurrency brl = AppCurrency(
    code: 'BRL',
    symbol: 'R\$',
    name: 'Brazilian Real',
    flag: '🇧🇷',
    locale: 'de_DE',
  );
  static const AppCurrency try_ = AppCurrency(
    code: 'TRY',
    symbol: '₺',
    name: 'Turkish Lira',
    flag: '🇹🇷',
    locale: 'de_DE',
  );
  static const AppCurrency vnd = AppCurrency(
    code: 'VND',
    symbol: '₫',
    name: 'Vietnamese Dong',
    flag: '🇻🇳',
    locale: 'de_DE',
  );
  static const AppCurrency ars = AppCurrency(
    code: 'ARS',
    symbol: 'AR\$',
    name: 'Argentine Peso',
    flag: '🇦🇷',
    locale: 'de_DE',
  );
  static const AppCurrency clp = AppCurrency(
    code: 'CLP',
    symbol: 'CL\$',
    name: 'Chilean Peso',
    flag: '🇨🇱',
    locale: 'de_DE',
  );
  static const AppCurrency cop = AppCurrency(
    code: 'COP',
    symbol: 'CO\$',
    name: 'Colombian Peso',
    flag: '🇨🇴',
    locale: 'de_DE',
  );
  static const AppCurrency pen = AppCurrency(
    code: 'PEN',
    symbol: 'S/',
    name: 'Peruvian Sol',
    flag: '🇵🇪',
    locale: 'de_DE',
  );
  static const AppCurrency hrk = AppCurrency(
    code: 'HRK',
    symbol: 'kn',
    name: 'Croatian Kuna',
    flag: '🇭🇷',
    locale: 'de_DE',
  );

  // ── en_US locale: 1,234.56 ──
  static const AppCurrency usd = AppCurrency(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    flag: '🇺🇸',
    locale: 'en_US',
  );
  static const AppCurrency gbp = AppCurrency(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
    flag: '🇬🇧',
    locale: 'en_US',
  );
  static const AppCurrency jpy = AppCurrency(
    code: 'JPY',
    symbol: '¥',
    name: 'Japanese Yen',
    flag: '🇯🇵',
    locale: 'en_US',
  );
  static const AppCurrency cny = AppCurrency(
    code: 'CNY',
    symbol: '¥',
    name: 'Chinese Yuan',
    flag: '🇨🇳',
    locale: 'en_US',
  );
  static const AppCurrency cad = AppCurrency(
    code: 'CAD',
    symbol: 'C\$',
    name: 'Canadian Dollar',
    flag: '🇨🇦',
    locale: 'en_US',
  );
  static const AppCurrency aud = AppCurrency(
    code: 'AUD',
    symbol: 'A\$',
    name: 'Australian Dollar',
    flag: '🇦🇺',
    locale: 'en_US',
  );
  static const AppCurrency inr = AppCurrency(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
    flag: '🇮🇳',
    locale: 'en_US',
  );
  static const AppCurrency krw = AppCurrency(
    code: 'KRW',
    symbol: '₩',
    name: 'South Korean Won',
    flag: '🇰🇷',
    locale: 'en_US',
  );
  static const AppCurrency mxn = AppCurrency(
    code: 'MXN',
    symbol: 'MX\$',
    name: 'Mexican Peso',
    flag: '🇲🇽',
    locale: 'en_US',
  );
  static const AppCurrency zar = AppCurrency(
    code: 'ZAR',
    symbol: 'R',
    name: 'South African Rand',
    flag: '🇿🇦',
    locale: 'en_US',
  );
  static const AppCurrency aed = AppCurrency(
    code: 'AED',
    symbol: 'د.إ',
    name: 'UAE Dirham',
    flag: '🇦🇪',
    locale: 'en_US',
  );
  static const AppCurrency sar = AppCurrency(
    code: 'SAR',
    symbol: '﷼',
    name: 'Saudi Riyal',
    flag: '🇸🇦',
    locale: 'en_US',
  );
  static const AppCurrency nzd = AppCurrency(
    code: 'NZD',
    symbol: 'NZ\$',
    name: 'New Zealand Dollar',
    flag: '🇳🇿',
    locale: 'en_US',
  );
  static const AppCurrency sgd = AppCurrency(
    code: 'SGD',
    symbol: 'S\$',
    name: 'Singapore Dollar',
    flag: '🇸🇬',
    locale: 'en_US',
  );
  static const AppCurrency hkd = AppCurrency(
    code: 'HKD',
    symbol: 'HK\$',
    name: 'Hong Kong Dollar',
    flag: '🇭🇰',
    locale: 'en_US',
  );
  static const AppCurrency thb = AppCurrency(
    code: 'THB',
    symbol: '฿',
    name: 'Thai Baht',
    flag: '🇹🇭',
    locale: 'en_US',
  );
  static const AppCurrency idr = AppCurrency(
    code: 'IDR',
    symbol: 'Rp',
    name: 'Indonesian Rupiah',
    flag: '🇮🇩',
    locale: 'en_US',
  );
  static const AppCurrency myr = AppCurrency(
    code: 'MYR',
    symbol: 'RM',
    name: 'Malaysian Ringgit',
    flag: '🇲🇾',
    locale: 'en_US',
  );
  static const AppCurrency php = AppCurrency(
    code: 'PHP',
    symbol: '₱',
    name: 'Philippine Peso',
    flag: '🇵🇭',
    locale: 'en_US',
  );
  static const AppCurrency egp = AppCurrency(
    code: 'EGP',
    symbol: 'E£',
    name: 'Egyptian Pound',
    flag: '🇪🇬',
    locale: 'en_US',
  );
  static const AppCurrency ngn = AppCurrency(
    code: 'NGN',
    symbol: '₦',
    name: 'Nigerian Naira',
    flag: '🇳🇬',
    locale: 'en_US',
  );
  static const AppCurrency pkr = AppCurrency(
    code: 'PKR',
    symbol: 'Rs',
    name: 'Pakistani Rupee',
    flag: '🇵🇰',
    locale: 'en_US',
  );
  static const AppCurrency bdt = AppCurrency(
    code: 'BDT',
    symbol: '৳',
    name: 'Bangladeshi Taka',
    flag: '🇧🇩',
    locale: 'en_US',
  );
  static const AppCurrency ils = AppCurrency(
    code: 'ILS',
    symbol: '₪',
    name: 'Israeli Shekel',
    flag: '🇮🇱',
    locale: 'en_US',
  );
  static const AppCurrency kes = AppCurrency(
    code: 'KES',
    symbol: 'KSh',
    name: 'Kenyan Shilling',
    flag: '🇰🇪',
    locale: 'en_US',
  );
  static const AppCurrency ghs = AppCurrency(
    code: 'GHS',
    symbol: 'GH₵',
    name: 'Ghanaian Cedi',
    flag: '🇬🇭',
    locale: 'en_US',
  );

  // ── fr_FR locale: 1 234,56 (space thousand, comma decimal) ──
  static const AppCurrency sek = AppCurrency(
    code: 'SEK',
    symbol: 'kr',
    name: 'Swedish Krona',
    flag: '🇸🇪',
    locale: 'fr_FR',
  );
  static const AppCurrency nok = AppCurrency(
    code: 'NOK',
    symbol: 'kr',
    name: 'Norwegian Krone',
    flag: '🇳🇴',
    locale: 'fr_FR',
  );
  static const AppCurrency dkk = AppCurrency(
    code: 'DKK',
    symbol: 'kr',
    name: 'Danish Krone',
    flag: '🇩🇰',
    locale: 'fr_FR',
  );
  static const AppCurrency pln = AppCurrency(
    code: 'PLN',
    symbol: 'zł',
    name: 'Polish Zloty',
    flag: '🇵🇱',
    locale: 'fr_FR',
  );
  static const AppCurrency czk = AppCurrency(
    code: 'CZK',
    symbol: 'Kč',
    name: 'Czech Koruna',
    flag: '🇨🇿',
    locale: 'fr_FR',
  );
  static const AppCurrency huf = AppCurrency(
    code: 'HUF',
    symbol: 'Ft',
    name: 'Hungarian Forint',
    flag: '🇭🇺',
    locale: 'fr_FR',
  );
  static const AppCurrency ron = AppCurrency(
    code: 'RON',
    symbol: 'lei',
    name: 'Romanian Leu',
    flag: '🇷🇴',
    locale: 'fr_FR',
  );
  static const AppCurrency bgn = AppCurrency(
    code: 'BGN',
    symbol: 'лв',
    name: 'Bulgarian Lev',
    flag: '🇧🇬',
    locale: 'fr_FR',
  );
  static const AppCurrency rub = AppCurrency(
    code: 'RUB',
    symbol: '₽',
    name: 'Russian Ruble',
    flag: '🇷🇺',
    locale: 'fr_FR',
  );
  static const AppCurrency uah = AppCurrency(
    code: 'UAH',
    symbol: '₴',
    name: 'Ukrainian Hryvnia',
    flag: '🇺🇦',
    locale: 'fr_FR',
  );

  // ── de_CH locale: 1'234.56 (apostrophe thousand, period decimal) ──
  static const AppCurrency chf = AppCurrency(
    code: 'CHF',
    symbol: 'CHF',
    name: 'Swiss Franc',
    flag: '🇨🇭',
    locale: 'de_CH',
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
