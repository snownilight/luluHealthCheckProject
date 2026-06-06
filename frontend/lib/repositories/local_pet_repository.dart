import 'package:drift/drift.dart';
import '../models/pet_status.dart';
import '../services/local_database.dart';
import 'pet_repository.dart';

class LocalPetRepository implements PetRepository {
  final LocalDatabase _db;

  LocalPetRepository(this._db);

  @override
  Future<bool> saveCareLog(Map<String, dynamic> careLogData) async {
    try {
      final eventId = careLogData['eventId'] ?? DateTime.now().millisecondsSinceEpoch.toString();
      final eventTypeStr = careLogData['eventType'];
      final operatorVal = careLogData['operator'] ?? 'Guest';
      final val = (careLogData['value'] as num?)?.toDouble();
      final unitVal = careLogData['unit'];
      final noteVal = careLogData['note'];
      final eventTimestamp = careLogData['eventTimestamp'] != null
          ? DateTime.parse(careLogData['eventTimestamp'] as String)
          : DateTime.now();
      final createdAt = DateTime.now();

      // 1. Insert into CareLogs table
      await _db.into(_db.careLogs).insert(
        CareLogsCompanion.insert(
          eventId: eventId,
          eventType: eventTypeStr,
          operatorName: operatorVal,
          value: Value(val),
          unit: Value(unitVal),
          note: Value(noteVal),
          eventTimestamp: eventTimestamp,
          createdAt: createdAt,
        ),
      );

      // 2. If it's a weight update, insert into WeightLogs
      if (eventTypeStr == 'WEIGHT_UPDATE' && val != null) {
        await _db.into(_db.weightLogs).insert(
          WeightLogsCompanion.insert(
            weightKg: val,
            recordedAt: eventTimestamp,
          ),
        );
      }

      // 3. Update daily summary for that date
      await _updateDailySummaryForDate(eventTimestamp);

      return true;
    } catch (e) {
      print('[LocalPetRepository] Error saving care log: $e');
      return false;
    }
  }

  Future<void> _updateDailySummaryForDate(DateTime timestamp) async {
    final dateOnly = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final startOfDay = dateOnly;
    final endOfDay = dateOnly.add(const Duration(days: 1));

    // Fetch care logs for that date
    final queryLogs = _db.select(_db.careLogs)
      ..where((t) => t.eventTimestamp.isBiggerOrEqualValue(startOfDay) & t.eventTimestamp.isSmallerThanValue(endOfDay));
    final dayLogs = await queryLogs.get();

    double waterSum = 0;
    double foodSum = 0;
    for (final cl in dayLogs) {
      if (cl.eventType == 'DRINKING' && cl.value != null) {
        waterSum += cl.value!;
      } else if (cl.eventType == 'FEEDING' && cl.value != null) {
        foodSum += cl.value!;
      }
    }

    // Fetch weight logs for that date
    final queryWeights = _db.select(_db.weightLogs)
      ..where((t) => t.recordedAt.isBiggerOrEqualValue(startOfDay) & t.recordedAt.isSmallerThanValue(endOfDay));
    final dayWeights = await queryWeights.get();

    double weightSum = 0;
    int weightCount = 0;
    for (final wl in dayWeights) {
      weightSum += wl.weightKg;
      weightCount++;
    }
    double avgWeight = weightCount > 0 ? (weightSum / weightCount) : 0.0;

    // Check if summary already exists
    final checkQuery = _db.select(_db.dailySummaries)..where((t) => t.date.equals(dateOnly));
    final existing = await checkQuery.getSingleOrNull();

    if (existing == null) {
      await _db.into(_db.dailySummaries).insert(
        DailySummariesCompanion.insert(
          date: dateOnly,
          totalWaterIntakeMl: waterSum,
          totalFoodIntakeG: foodSum,
          averageWeightKg: avgWeight,
        ),
      );
    } else {
      await _db.update(_db.dailySummaries).replace(
        existing.copyWith(
          totalWaterIntakeMl: waterSum,
          totalFoodIntakeG: foodSum,
          averageWeightKg: avgWeight,
        ),
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCareLogs() async {
    final query = _db.select(_db.careLogs)
      ..orderBy([(t) => OrderingTerm(expression: t.eventTimestamp, mode: OrderingMode.desc)]);
    final logs = await query.get();

    return logs.map((l) => {
      'eventId': l.eventId,
      'eventType': l.eventType,
      'operator': l.operatorName,
      'value': l.value,
      'unit': l.unit,
      'note': l.note,
      'eventTimestamp': l.eventTimestamp.toIso8601String(),
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getWeeklyWeightTrend() async {
    final query = _db.select(_db.weightLogs)
      ..orderBy([(t) => OrderingTerm(expression: t.recordedAt, mode: OrderingMode.desc)]);
    final logs = await query.get();

    return logs.map((l) => {
      'weightKg': l.weightKg,
      'recordedAt': l.recordedAt.toIso8601String(),
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getMonthlyDailySummary() async {
    final query = _db.select(_db.dailySummaries)
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]);
    final logs = await query.get();

    return logs.map((l) => {
      'date': l.date.toIso8601String(),
      'totalWaterIntakeMl': l.totalWaterIntakeMl,
      'totalFoodIntakeG': l.totalFoodIntakeG,
      'averageWeightKg': l.averageWeightKg,
    }).toList();
  }

  @override
  Future<PetStatus> getPetStatus() async {
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);

    // Fetch today's summary
    final querySummary = _db.select(_db.dailySummaries)..where((t) => t.date.equals(dateOnly));
    final summary = await querySummary.getSingleOrNull();

    // Fetch latest weight
    final queryWeight = _db.select(_db.weightLogs)
      ..orderBy([(t) => OrderingTerm(expression: t.recordedAt, mode: OrderingMode.desc)])
      ..limit(1);
    final latestWeight = await queryWeight.getSingleOrNull();

    // Fetch latest activity time
    final queryActive = _db.select(_db.careLogs)
      ..orderBy([(t) => OrderingTerm(expression: t.eventTimestamp, mode: OrderingMode.desc)])
      ..limit(1);
    final latestActive = await queryActive.getSingleOrNull();

    return PetStatus(
      lastWeightKg: latestWeight?.weightKg ?? 4.8,
      todayWaterIntakeMl: summary?.totalWaterIntakeMl ?? 0.0,
      todayFoodIntakeG: summary?.totalFoodIntakeG ?? 0.0,
      lastActiveTime: latestActive?.eventTimestamp ?? DateTime.now().subtract(const Duration(minutes: 15)),
    );
  }
}
