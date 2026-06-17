import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_health_tracker/repositories/local_pet_repository.dart';
import 'package:pet_health_tracker/services/local_database.dart';

void main() {
  late LocalDatabase database;
  late LocalPetRepository repository;

  setUp(() {
    database = LocalDatabase.forTesting(NativeDatabase.memory());
    repository = LocalPetRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('invalid timestamp returns false and leaves care logs empty', () async {
    final saved = await repository.saveCareLog({
      'eventId': 'bad-timestamp',
      'eventType': 'DRINKING',
      'operator': 'Tester',
      'value': 10,
      'unit': 'ml',
      'eventTimestamp': 'not-a-date',
    });

    expect(saved, isFalse);
    expect(await repository.getCareLogs(), isEmpty);
    expect(await repository.getMonthlyDailySummary(), isEmpty);
  });

  test('summaries are isolated by day boundaries', () async {
    final firstDay = DateTime(2026, 6, 1, 23, 59);
    final secondDay = DateTime(2026, 6, 2, 0, 0);

    expect(
      await repository.saveCareLog({
        'eventId': 'water-late',
        'eventType': 'DRINKING',
        'operator': 'Tester',
        'value': 100,
        'unit': 'ml',
        'eventTimestamp': firstDay.toIso8601String(),
      }),
      isTrue,
    );
    expect(
      await repository.saveCareLog({
        'eventId': 'food-midnight',
        'eventType': 'FEEDING',
        'operator': 'Tester',
        'value': 40,
        'unit': 'g',
        'eventTimestamp': secondDay.toIso8601String(),
      }),
      isTrue,
    );

    final summaries = await repository.getMonthlyDailySummary();

    expect(summaries, hasLength(2));
    final juneFirst = summaries.singleWhere(
      (summary) => summary['date'].toString().startsWith('2026-06-01'),
    );
    final juneSecond = summaries.singleWhere(
      (summary) => summary['date'].toString().startsWith('2026-06-02'),
    );

    expect(juneFirst['totalWaterIntakeMl'], 100.0);
    expect(juneFirst['totalFoodIntakeG'], 0.0);
    expect(juneSecond['totalWaterIntakeMl'], 0.0);
    expect(juneSecond['totalFoodIntakeG'], 40.0);
  });

  test('multiple weight updates on same day update average weight', () async {
    final timestamp = DateTime(2026, 6, 3, 8, 0);

    for (final entry in [
      ('weight-a', 4.0),
      ('weight-b', 5.0),
    ]) {
      expect(
        await repository.saveCareLog({
          'eventId': entry.$1,
          'eventType': 'WEIGHT_UPDATE',
          'operator': 'Tester',
          'value': entry.$2,
          'unit': 'kg',
          'eventTimestamp': timestamp.toIso8601String(),
        }),
        isTrue,
      );
    }

    final summaries = await repository.getMonthlyDailySummary();
    expect(summaries, hasLength(1));
    expect(summaries.single['averageWeightKg'], 4.5);
  });
}
