import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'local_database.g.dart';

class CareLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get eventId => text()();
  TextColumn get eventType => text()();
  TextColumn get operatorName => text().named('operator')(); // 'operator' is a reserved keyword in Dart, so we use operatorName mapped to DB column 'operator'
  RealColumn get value => real().nullable()();
  TextColumn get unit => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get eventTimestamp => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
}

class WeightLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get weightKg => real()();
  DateTimeColumn get recordedAt => dateTime()();
}

class DailySummaries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().unique()();
  RealColumn get totalWaterIntakeMl => real()();
  RealColumn get totalFoodIntakeG => real()();
  RealColumn get averageWeightKg => real()();
}

@DriftDatabase(tables: [CareLogs, WeightLogs, DailySummaries])
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pet_health.db'));
    return NativeDatabase.createInBackground(file);
  });
}

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  final db = LocalDatabase();
  ref.onDispose(() => db.close());
  return db;
});
