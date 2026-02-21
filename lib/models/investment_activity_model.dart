import 'package:moneyapp/services/database/database_helper.dart';

/// Activity type for investment activities
enum InvestmentActivityType {
  transaction,
  trade,
}

/// Direction for transaction type activities
enum TransactionDirection {
  withdraw,
  deposit,
}

/// Investment Activity Model
/// Unified model for both transactions (withdraw/deposit) and trades (sold/bought pairs)
class InvestmentActivity {
  final int? id;
  final InvestmentActivityType type;
  final DateTime date;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Transaction-specific fields (null for trades)
  final TransactionDirection? transactionDirection;
  final int? transactionInvestmentId;
  final double? transactionAmount;
  final double? transactionPrice;
  final double? transactionTotal;

  // Trade-specific fields (null for transactions)
  final int? tradeSoldInvestmentId;
  final double? tradeSoldAmount;
  final double? tradeSoldPrice;
  final double? tradeSoldTotal;
  final int? tradeBoughtInvestmentId;
  final double? tradeBoughtAmount;
  final double? tradeBoughtPrice;
  final double? tradeBoughtTotal;

  InvestmentActivity({
    this.id,
    required this.type,
    required this.date,
    this.description,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Transaction fields
    this.transactionDirection,
    this.transactionInvestmentId,
    this.transactionAmount,
    this.transactionPrice,
    this.transactionTotal,
    // Trade fields
    this.tradeSoldInvestmentId,
    this.tradeSoldAmount,
    this.tradeSoldPrice,
    this.tradeSoldTotal,
    this.tradeBoughtInvestmentId,
    this.tradeBoughtAmount,
    this.tradeBoughtPrice,
    this.tradeBoughtTotal,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Helper getters
  bool get isTransaction => type == InvestmentActivityType.transaction;
  bool get isTrade => type == InvestmentActivityType.trade;
  bool get isWithdraw => transactionDirection == TransactionDirection.withdraw;
  bool get isDeposit => transactionDirection == TransactionDirection.deposit;

  /// Factory constructor for creating a transaction activity
  factory InvestmentActivity.transaction({
    int? id,
    required DateTime date,
    String? description,
    required TransactionDirection direction,
    required int investmentId,
    required double amount,
    required double price,
    required double total,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvestmentActivity(
      id: id,
      type: InvestmentActivityType.transaction,
      date: date,
      description: description,
      transactionDirection: direction,
      transactionInvestmentId: investmentId,
      transactionAmount: amount,
      transactionPrice: price,
      transactionTotal: total,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Factory constructor for creating a trade activity
  factory InvestmentActivity.trade({
    int? id,
    required DateTime date,
    String? description,
    required int soldInvestmentId,
    required double soldAmount,
    required double soldPrice,
    required double soldTotal,
    required int boughtInvestmentId,
    required double boughtAmount,
    required double boughtPrice,
    required double boughtTotal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvestmentActivity(
      id: id,
      type: InvestmentActivityType.trade,
      date: date,
      description: description,
      tradeSoldInvestmentId: soldInvestmentId,
      tradeSoldAmount: soldAmount,
      tradeSoldPrice: soldPrice,
      tradeSoldTotal: soldTotal,
      tradeBoughtInvestmentId: boughtInvestmentId,
      tradeBoughtAmount: boughtAmount,
      tradeBoughtPrice: boughtPrice,
      tradeBoughtTotal: boughtTotal,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnActivityId: id,
      DatabaseHelper.columnActivityType: type.name,
      DatabaseHelper.columnActivityDate: date.toIso8601String(),
      DatabaseHelper.columnActivityDescription: description,
      DatabaseHelper.columnActivityCreatedAt: createdAt.toIso8601String(),
      DatabaseHelper.columnActivityUpdatedAt: updatedAt.toIso8601String(),
      // Transaction fields
      DatabaseHelper.columnTxIsWithdraw: transactionDirection != null
          ? (transactionDirection == TransactionDirection.withdraw ? 1 : 0)
          : null,
      DatabaseHelper.columnTxInvestmentId: transactionInvestmentId,
      DatabaseHelper.columnTxAmount: transactionAmount,
      DatabaseHelper.columnTxPrice: transactionPrice,
      DatabaseHelper.columnTxTotal: transactionTotal,
      // Trade fields
      DatabaseHelper.columnTradeSoldInvestmentId: tradeSoldInvestmentId,
      DatabaseHelper.columnTradeSoldAmount: tradeSoldAmount,
      DatabaseHelper.columnTradeSoldPrice: tradeSoldPrice,
      DatabaseHelper.columnTradeSoldTotal: tradeSoldTotal,
      DatabaseHelper.columnTradeBoughtInvestmentId: tradeBoughtInvestmentId,
      DatabaseHelper.columnTradeBoughtAmount: tradeBoughtAmount,
      DatabaseHelper.columnTradeBoughtPrice: tradeBoughtPrice,
      DatabaseHelper.columnTradeBoughtTotal: tradeBoughtTotal,
    };
  }

  /// Create from database map
  factory InvestmentActivity.fromMap(Map<String, dynamic> map) {
    final typeStr = map[DatabaseHelper.columnActivityType] as String;
    final type = InvestmentActivityType.values.firstWhere(
      (e) => e.name == typeStr,
    );

    TransactionDirection? direction;
    final txIsWithdraw = map[DatabaseHelper.columnTxIsWithdraw] as int?;
    if (txIsWithdraw != null) {
      direction = txIsWithdraw == 1
          ? TransactionDirection.withdraw
          : TransactionDirection.deposit;
    }

    return InvestmentActivity(
      id: map[DatabaseHelper.columnActivityId] as int?,
      type: type,
      date: DateTime.parse(map[DatabaseHelper.columnActivityDate] as String),
      description: map[DatabaseHelper.columnActivityDescription] as String?,
      createdAt: DateTime.parse(
        map[DatabaseHelper.columnActivityCreatedAt] as String,
      ),
      updatedAt: DateTime.parse(
        map[DatabaseHelper.columnActivityUpdatedAt] as String,
      ),
      // Transaction fields
      transactionDirection: direction,
      transactionInvestmentId:
          map[DatabaseHelper.columnTxInvestmentId] as int?,
      transactionAmount:
          (map[DatabaseHelper.columnTxAmount] as num?)?.toDouble(),
      transactionPrice:
          (map[DatabaseHelper.columnTxPrice] as num?)?.toDouble(),
      transactionTotal:
          (map[DatabaseHelper.columnTxTotal] as num?)?.toDouble(),
      // Trade fields
      tradeSoldInvestmentId:
          map[DatabaseHelper.columnTradeSoldInvestmentId] as int?,
      tradeSoldAmount:
          (map[DatabaseHelper.columnTradeSoldAmount] as num?)?.toDouble(),
      tradeSoldPrice:
          (map[DatabaseHelper.columnTradeSoldPrice] as num?)?.toDouble(),
      tradeSoldTotal:
          (map[DatabaseHelper.columnTradeSoldTotal] as num?)?.toDouble(),
      tradeBoughtInvestmentId:
          map[DatabaseHelper.columnTradeBoughtInvestmentId] as int?,
      tradeBoughtAmount:
          (map[DatabaseHelper.columnTradeBoughtAmount] as num?)?.toDouble(),
      tradeBoughtPrice:
          (map[DatabaseHelper.columnTradeBoughtPrice] as num?)?.toDouble(),
      tradeBoughtTotal:
          (map[DatabaseHelper.columnTradeBoughtTotal] as num?)?.toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'date': date.toIso8601String(),
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // Transaction fields
      'transactionDirection': transactionDirection?.name,
      'transactionInvestmentId': transactionInvestmentId,
      'transactionAmount': transactionAmount,
      'transactionPrice': transactionPrice,
      'transactionTotal': transactionTotal,
      // Trade fields
      'tradeSoldInvestmentId': tradeSoldInvestmentId,
      'tradeSoldAmount': tradeSoldAmount,
      'tradeSoldPrice': tradeSoldPrice,
      'tradeSoldTotal': tradeSoldTotal,
      'tradeBoughtInvestmentId': tradeBoughtInvestmentId,
      'tradeBoughtAmount': tradeBoughtAmount,
      'tradeBoughtPrice': tradeBoughtPrice,
      'tradeBoughtTotal': tradeBoughtTotal,
    };
  }

  /// Create from JSON
  factory InvestmentActivity.fromJson(Map<String, dynamic> json) {
    final type = InvestmentActivityType.values.firstWhere(
      (e) => e.name == json['type'],
    );

    TransactionDirection? direction;
    final directionStr = json['transactionDirection'] as String?;
    if (directionStr != null) {
      direction = TransactionDirection.values.firstWhere(
        (e) => e.name == directionStr,
      );
    }

    return InvestmentActivity(
      id: json['id'] as int?,
      type: type,
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      // Transaction fields
      transactionDirection: direction,
      transactionInvestmentId: json['transactionInvestmentId'] as int?,
      transactionAmount: (json['transactionAmount'] as num?)?.toDouble(),
      transactionPrice: (json['transactionPrice'] as num?)?.toDouble(),
      transactionTotal: (json['transactionTotal'] as num?)?.toDouble(),
      // Trade fields
      tradeSoldInvestmentId: json['tradeSoldInvestmentId'] as int?,
      tradeSoldAmount: (json['tradeSoldAmount'] as num?)?.toDouble(),
      tradeSoldPrice: (json['tradeSoldPrice'] as num?)?.toDouble(),
      tradeSoldTotal: (json['tradeSoldTotal'] as num?)?.toDouble(),
      tradeBoughtInvestmentId: json['tradeBoughtInvestmentId'] as int?,
      tradeBoughtAmount: (json['tradeBoughtAmount'] as num?)?.toDouble(),
      tradeBoughtPrice: (json['tradeBoughtPrice'] as num?)?.toDouble(),
      tradeBoughtTotal: (json['tradeBoughtTotal'] as num?)?.toDouble(),
    );
  }

  /// Create a copy with updated fields
  InvestmentActivity copyWith({
    int? id,
    InvestmentActivityType? type,
    DateTime? date,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    TransactionDirection? transactionDirection,
    int? transactionInvestmentId,
    double? transactionAmount,
    double? transactionPrice,
    double? transactionTotal,
    int? tradeSoldInvestmentId,
    double? tradeSoldAmount,
    double? tradeSoldPrice,
    double? tradeSoldTotal,
    int? tradeBoughtInvestmentId,
    double? tradeBoughtAmount,
    double? tradeBoughtPrice,
    double? tradeBoughtTotal,
  }) {
    return InvestmentActivity(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactionDirection: transactionDirection ?? this.transactionDirection,
      transactionInvestmentId:
          transactionInvestmentId ?? this.transactionInvestmentId,
      transactionAmount: transactionAmount ?? this.transactionAmount,
      transactionPrice: transactionPrice ?? this.transactionPrice,
      transactionTotal: transactionTotal ?? this.transactionTotal,
      tradeSoldInvestmentId:
          tradeSoldInvestmentId ?? this.tradeSoldInvestmentId,
      tradeSoldAmount: tradeSoldAmount ?? this.tradeSoldAmount,
      tradeSoldPrice: tradeSoldPrice ?? this.tradeSoldPrice,
      tradeSoldTotal: tradeSoldTotal ?? this.tradeSoldTotal,
      tradeBoughtInvestmentId:
          tradeBoughtInvestmentId ?? this.tradeBoughtInvestmentId,
      tradeBoughtAmount: tradeBoughtAmount ?? this.tradeBoughtAmount,
      tradeBoughtPrice: tradeBoughtPrice ?? this.tradeBoughtPrice,
      tradeBoughtTotal: tradeBoughtTotal ?? this.tradeBoughtTotal,
    );
  }

  /// Create a copy with updated timestamp
  InvestmentActivity copyWithUpdatedTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  @override
  String toString() {
    if (isTransaction) {
      return 'InvestmentActivity.transaction{id: $id, direction: $transactionDirection, '
          'investmentId: $transactionInvestmentId, amount: $transactionAmount, total: $transactionTotal}';
    } else {
      return 'InvestmentActivity.trade{id: $id, '
          'sold: $tradeSoldInvestmentId x$tradeSoldAmount, '
          'bought: $tradeBoughtInvestmentId x$tradeBoughtAmount}';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvestmentActivity &&
        other.id == id &&
        other.type == type &&
        other.date == date;
  }

  @override
  int get hashCode {
    return id.hashCode ^ type.hashCode ^ date.hashCode;
  }
}

/// Helper class for investment activity operations
class InvestmentActivityHelper {
  /// Convert list of database maps to list of InvestmentActivity objects
  static List<InvestmentActivity> fromMapList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => InvestmentActivity.fromMap(map)).toList();
  }

  /// Filter transactions only
  static List<InvestmentActivity> filterTransactions(
    List<InvestmentActivity> activities,
  ) {
    return activities.where((a) => a.isTransaction).toList();
  }

  /// Filter trades only
  static List<InvestmentActivity> filterTrades(
    List<InvestmentActivity> activities,
  ) {
    return activities.where((a) => a.isTrade).toList();
  }

  /// Filter by investment ID (checks both transaction and trade fields)
  static List<InvestmentActivity> filterByInvestmentId(
    List<InvestmentActivity> activities,
    int investmentId,
  ) {
    return activities.where((a) {
      if (a.isTransaction) {
        return a.transactionInvestmentId == investmentId;
      } else {
        return a.tradeSoldInvestmentId == investmentId ||
            a.tradeBoughtInvestmentId == investmentId;
      }
    }).toList();
  }

  /// Filter by date range
  static List<InvestmentActivity> filterByDateRange(
    List<InvestmentActivity> activities,
    DateTime startDate,
    DateTime endDate,
  ) {
    return activities
        .where(
          (a) =>
              a.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              a.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  /// Sort by date (newest first)
  static List<InvestmentActivity> sortByDateDesc(
    List<InvestmentActivity> activities,
  ) {
    final sorted = List<InvestmentActivity>.from(activities);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  /// Sort by date (oldest first)
  static List<InvestmentActivity> sortByDateAsc(
    List<InvestmentActivity> activities,
  ) {
    final sorted = List<InvestmentActivity>.from(activities);
    sorted.sort((a, b) => a.date.compareTo(b.date));
    return sorted;
  }

  /// Sort by total amount (highest first)
  /// For transactions, uses transactionTotal; for trades, uses tradeSoldTotal
  static List<InvestmentActivity> sortByAmountDesc(
    List<InvestmentActivity> activities,
  ) {
    final sorted = List<InvestmentActivity>.from(activities);
    sorted.sort((a, b) {
      final aTotal = a.isTransaction
          ? (a.transactionTotal ?? 0)
          : (a.tradeSoldTotal ?? 0);
      final bTotal = b.isTransaction
          ? (b.transactionTotal ?? 0)
          : (b.tradeSoldTotal ?? 0);
      return bTotal.compareTo(aTotal);
    });
    return sorted;
  }

  /// Group by date (day only)
  static Map<DateTime, List<InvestmentActivity>> groupByDate(
    List<InvestmentActivity> activities,
  ) {
    final Map<DateTime, List<InvestmentActivity>> grouped = {};
    for (final activity in activities) {
      final dateKey = DateTime(
        activity.date.year,
        activity.date.month,
        activity.date.day,
      );
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(activity);
    }
    return grouped;
  }

  /// Group by year
  static Map<int, List<InvestmentActivity>> groupByYear(
    List<InvestmentActivity> activities,
  ) {
    final Map<int, List<InvestmentActivity>> grouped = {};
    for (final activity in activities) {
      final year = activity.date.year;
      grouped.putIfAbsent(year, () => []);
      grouped[year]!.add(activity);
    }
    return grouped;
  }

  /// Group by month within a year
  static Map<int, List<InvestmentActivity>> groupByMonth(
    List<InvestmentActivity> activities,
    int year,
  ) {
    final yearActivities = activities.where((a) => a.date.year == year);
    final Map<int, List<InvestmentActivity>> grouped = {};
    for (final activity in yearActivities) {
      final month = activity.date.month;
      grouped.putIfAbsent(month, () => []);
      grouped[month]!.add(activity);
    }
    return grouped;
  }

  /// Calculate total transaction amount (deposits - withdraws)
  static double calculateNetTransactionAmount(
    List<InvestmentActivity> activities,
    int investmentId,
  ) {
    final transactions = filterTransactions(activities)
        .where((a) => a.transactionInvestmentId == investmentId);

    double total = 0;
    for (final t in transactions) {
      if (t.isDeposit) {
        total += t.transactionAmount ?? 0;
      } else {
        total -= t.transactionAmount ?? 0;
      }
    }
    return total;
  }
}
