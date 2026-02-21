import 'package:moneyapp/services/database/database_helper.dart';

/// Entry type for portfolio snapshots
enum SnapshotEntryType { trade, transaction }

/// Portfolio Snapshot Model
/// Tracks per-investment price at specific points in time
/// Snapshots store only unit price - holdings amounts are calculated from activities
class PortfolioSnapshot {
  final int? id;
  final int investmentId; // Investment this snapshot belongs to
  final DateTime date;
  final double unitPrice; // Price per unit of investment at this date
  final bool
  isManualPrice; // True if user manually logged price, false if from activity
  final SnapshotEntryType entryType;
  final int?
  activityId; // Link to investment_activities (null for manual price entries)
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  PortfolioSnapshot({
    this.id,
    required this.investmentId,
    required this.date,
    required this.unitPrice,
    this.isManualPrice = false,
    required this.entryType,
    this.activityId,
    this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Helper getters
  bool get isFromTrade => entryType == SnapshotEntryType.trade;
  bool get isFromTransaction => entryType == SnapshotEntryType.transaction;
  bool get isLinkedToActivity => activityId != null;

  /// Factory constructor for creating a manual price snapshot
  factory PortfolioSnapshot.manualPrice({
    int? id,
    required int investmentId,
    required DateTime date,
    required double unitPrice,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PortfolioSnapshot(
      id: id,
      investmentId: investmentId,
      date: date,
      unitPrice: unitPrice,
      isManualPrice: true,
      entryType: SnapshotEntryType.transaction, // Default to transaction type
      activityId: null,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Factory constructor for creating a snapshot linked to a trade
  factory PortfolioSnapshot.fromTrade({
    int? id,
    required int investmentId,
    required DateTime date,
    required double unitPrice,
    required int activityId,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PortfolioSnapshot(
      id: id,
      investmentId: investmentId,
      date: date,
      unitPrice: unitPrice,
      isManualPrice: false,
      entryType: SnapshotEntryType.trade,
      activityId: activityId,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Factory constructor for creating a snapshot linked to a transaction
  factory PortfolioSnapshot.fromTransaction({
    int? id,
    required int investmentId,
    required DateTime date,
    required double unitPrice,
    required int activityId,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PortfolioSnapshot(
      id: id,
      investmentId: investmentId,
      date: date,
      unitPrice: unitPrice,
      isManualPrice: false,
      entryType: SnapshotEntryType.transaction,
      activityId: activityId,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnSnapshotId: id,
      DatabaseHelper.columnSnapshotInvestmentId: investmentId,
      DatabaseHelper.columnSnapshotDate: date.toIso8601String(),
      DatabaseHelper.columnSnapshotUnitPrice: unitPrice,
      DatabaseHelper.columnSnapshotIsManualPrice: isManualPrice ? 1 : 0,
      DatabaseHelper.columnSnapshotEntryType: entryType.name,
      DatabaseHelper.columnSnapshotActivityId: activityId,
      DatabaseHelper.columnSnapshotNote: note,
      DatabaseHelper.columnSnapshotCreatedAt: createdAt.toIso8601String(),
      DatabaseHelper.columnSnapshotUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  /// Create from database map
  factory PortfolioSnapshot.fromMap(Map<String, dynamic> map) {
    final entryTypeStr = map[DatabaseHelper.columnSnapshotEntryType] as String;
    final entryType = SnapshotEntryType.values.firstWhere(
      (e) => e.name == entryTypeStr,
    );

    return PortfolioSnapshot(
      id: map[DatabaseHelper.columnSnapshotId] as int?,
      investmentId: map[DatabaseHelper.columnSnapshotInvestmentId] as int,
      date: DateTime.parse(map[DatabaseHelper.columnSnapshotDate] as String),
      unitPrice: (map[DatabaseHelper.columnSnapshotUnitPrice] as num)
          .toDouble(),
      isManualPrice:
          (map[DatabaseHelper.columnSnapshotIsManualPrice] as int) == 1,
      entryType: entryType,
      activityId: map[DatabaseHelper.columnSnapshotActivityId] as int?,
      note: map[DatabaseHelper.columnSnapshotNote] as String?,
      createdAt: DateTime.parse(
        map[DatabaseHelper.columnSnapshotCreatedAt] as String,
      ),
      updatedAt: DateTime.parse(
        map[DatabaseHelper.columnSnapshotUpdatedAt] as String,
      ),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'investmentId': investmentId,
      'date': date.toIso8601String(),
      'unitPrice': unitPrice,
      'isManualPrice': isManualPrice,
      'entryType': entryType.name,
      'activityId': activityId,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory PortfolioSnapshot.fromJson(Map<String, dynamic> json) {
    final entryType = SnapshotEntryType.values.firstWhere(
      (e) => e.name == json['entryType'],
    );

    return PortfolioSnapshot(
      id: json['id'] as int?,
      investmentId: json['investmentId'] as int,
      date: DateTime.parse(json['date'] as String),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      isManualPrice: json['isManualPrice'] as bool,
      entryType: entryType,
      activityId: json['activityId'] as int?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Create a copy with updated fields
  PortfolioSnapshot copyWith({
    int? id,
    int? investmentId,
    DateTime? date,
    double? unitPrice,
    bool? isManualPrice,
    SnapshotEntryType? entryType,
    int? activityId,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PortfolioSnapshot(
      id: id ?? this.id,
      investmentId: investmentId ?? this.investmentId,
      date: date ?? this.date,
      unitPrice: unitPrice ?? this.unitPrice,
      isManualPrice: isManualPrice ?? this.isManualPrice,
      entryType: entryType ?? this.entryType,
      activityId: activityId ?? this.activityId,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create a copy with updated timestamp
  PortfolioSnapshot copyWithUpdatedTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Get formatted unit price with currency symbol
  String getFormattedUnitPrice({String currency = '€'}) {
    return '$currency ${unitPrice.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  String toString() {
    return 'PortfolioSnapshot{id: $id, investmentId: $investmentId, date: $date, unitPrice: $unitPrice, '
        'isManualPrice: $isManualPrice, entryType: $entryType, activityId: $activityId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PortfolioSnapshot &&
        other.id == id &&
        other.investmentId == investmentId &&
        other.date == date &&
        other.unitPrice == unitPrice;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        investmentId.hashCode ^
        date.hashCode ^
        unitPrice.hashCode;
  }
}

/// Helper class for portfolio snapshot operations
class PortfolioSnapshotHelper {
  /// Convert list of database maps to list of PortfolioSnapshot objects
  static List<PortfolioSnapshot> fromMapList(List<Map<String, dynamic>> maps) {
    return maps.map((map) => PortfolioSnapshot.fromMap(map)).toList();
  }

  /// Filter manual price snapshots only
  static List<PortfolioSnapshot> filterManualPrice(
    List<PortfolioSnapshot> snapshots,
  ) {
    return snapshots.where((s) => s.isManualPrice).toList();
  }

  /// Filter snapshots linked to activities
  static List<PortfolioSnapshot> filterLinked(
    List<PortfolioSnapshot> snapshots,
  ) {
    return snapshots.where((s) => s.isLinkedToActivity).toList();
  }

  /// Filter by investment ID
  static List<PortfolioSnapshot> filterByInvestment(
    List<PortfolioSnapshot> snapshots,
    int investmentId,
  ) {
    return snapshots.where((s) => s.investmentId == investmentId).toList();
  }

  /// Filter by date range
  static List<PortfolioSnapshot> filterByDateRange(
    List<PortfolioSnapshot> snapshots,
    DateTime startDate,
    DateTime endDate,
  ) {
    return snapshots
        .where(
          (s) =>
              s.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              s.date.isBefore(endDate.add(const Duration(days: 1))),
        )
        .toList();
  }

  /// Sort by date (newest first)
  static List<PortfolioSnapshot> sortByDateDesc(
    List<PortfolioSnapshot> snapshots,
  ) {
    final sorted = List<PortfolioSnapshot>.from(snapshots);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  /// Sort by date (oldest first)
  static List<PortfolioSnapshot> sortByDateAsc(
    List<PortfolioSnapshot> snapshots,
  ) {
    final sorted = List<PortfolioSnapshot>.from(snapshots);
    sorted.sort((a, b) => a.date.compareTo(b.date));
    return sorted;
  }

  /// Sort by unit price (highest first)
  static List<PortfolioSnapshot> sortByPriceDesc(
    List<PortfolioSnapshot> snapshots,
  ) {
    final sorted = List<PortfolioSnapshot>.from(snapshots);
    sorted.sort((a, b) => b.unitPrice.compareTo(a.unitPrice));
    return sorted;
  }

  /// Get latest snapshot
  static PortfolioSnapshot? getLatest(List<PortfolioSnapshot> snapshots) {
    if (snapshots.isEmpty) return null;
    return sortByDateDesc(snapshots).first;
  }

  /// Calculate price change between two snapshots
  static double calculatePriceChange(
    PortfolioSnapshot older,
    PortfolioSnapshot newer,
  ) {
    return newer.unitPrice - older.unitPrice;
  }

  /// Calculate percentage change between two snapshots
  static double calculatePercentageChange(
    PortfolioSnapshot older,
    PortfolioSnapshot newer,
  ) {
    if (older.unitPrice == 0) return 0;
    return ((newer.unitPrice - older.unitPrice) / older.unitPrice) * 100;
  }

  /// Group by date (day only)
  static Map<DateTime, List<PortfolioSnapshot>> groupByDate(
    List<PortfolioSnapshot> snapshots,
  ) {
    final Map<DateTime, List<PortfolioSnapshot>> grouped = {};
    for (final snapshot in snapshots) {
      final dateKey = DateTime(
        snapshot.date.year,
        snapshot.date.month,
        snapshot.date.day,
      );
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(snapshot);
    }
    return grouped;
  }
}
