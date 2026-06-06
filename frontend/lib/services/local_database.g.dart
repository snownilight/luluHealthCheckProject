// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $CareLogsTable extends CareLogs with TableInfo<$CareLogsTable, CareLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CareLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _eventIdMeta =
      const VerificationMeta('eventId');
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
      'event_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operatorNameMeta =
      const VerificationMeta('operatorName');
  @override
  late final GeneratedColumn<String> operatorName = GeneratedColumn<String>(
      'operator', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
      'value', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _eventTimestampMeta =
      const VerificationMeta('eventTimestamp');
  @override
  late final GeneratedColumn<DateTime> eventTimestamp =
      GeneratedColumn<DateTime>('event_timestamp', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        eventId,
        eventType,
        operatorName,
        value,
        unit,
        note,
        eventTimestamp,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'care_logs';
  @override
  VerificationContext validateIntegrity(Insertable<CareLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_id')) {
      context.handle(_eventIdMeta,
          eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta));
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('operator')) {
      context.handle(
          _operatorNameMeta,
          operatorName.isAcceptableOrUnknown(
              data['operator']!, _operatorNameMeta));
    } else if (isInserting) {
      context.missing(_operatorNameMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('event_timestamp')) {
      context.handle(
          _eventTimestampMeta,
          eventTimestamp.isAcceptableOrUnknown(
              data['event_timestamp']!, _eventTimestampMeta));
    } else if (isInserting) {
      context.missing(_eventTimestampMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CareLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CareLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      eventId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_id'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      operatorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operator'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}value']),
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      eventTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}event_timestamp'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CareLogsTable createAlias(String alias) {
    return $CareLogsTable(attachedDatabase, alias);
  }
}

class CareLog extends DataClass implements Insertable<CareLog> {
  final int id;
  final String eventId;
  final String eventType;
  final String operatorName;
  final double? value;
  final String? unit;
  final String? note;
  final DateTime eventTimestamp;
  final DateTime createdAt;
  const CareLog(
      {required this.id,
      required this.eventId,
      required this.eventType,
      required this.operatorName,
      this.value,
      this.unit,
      this.note,
      required this.eventTimestamp,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_id'] = Variable<String>(eventId);
    map['event_type'] = Variable<String>(eventType);
    map['operator'] = Variable<String>(operatorName);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<double>(value);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['event_timestamp'] = Variable<DateTime>(eventTimestamp);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CareLogsCompanion toCompanion(bool nullToAbsent) {
    return CareLogsCompanion(
      id: Value(id),
      eventId: Value(eventId),
      eventType: Value(eventType),
      operatorName: Value(operatorName),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      eventTimestamp: Value(eventTimestamp),
      createdAt: Value(createdAt),
    );
  }

  factory CareLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CareLog(
      id: serializer.fromJson<int>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      operatorName: serializer.fromJson<String>(json['operatorName']),
      value: serializer.fromJson<double?>(json['value']),
      unit: serializer.fromJson<String?>(json['unit']),
      note: serializer.fromJson<String?>(json['note']),
      eventTimestamp: serializer.fromJson<DateTime>(json['eventTimestamp']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventId': serializer.toJson<String>(eventId),
      'eventType': serializer.toJson<String>(eventType),
      'operatorName': serializer.toJson<String>(operatorName),
      'value': serializer.toJson<double?>(value),
      'unit': serializer.toJson<String?>(unit),
      'note': serializer.toJson<String?>(note),
      'eventTimestamp': serializer.toJson<DateTime>(eventTimestamp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CareLog copyWith(
          {int? id,
          String? eventId,
          String? eventType,
          String? operatorName,
          Value<double?> value = const Value.absent(),
          Value<String?> unit = const Value.absent(),
          Value<String?> note = const Value.absent(),
          DateTime? eventTimestamp,
          DateTime? createdAt}) =>
      CareLog(
        id: id ?? this.id,
        eventId: eventId ?? this.eventId,
        eventType: eventType ?? this.eventType,
        operatorName: operatorName ?? this.operatorName,
        value: value.present ? value.value : this.value,
        unit: unit.present ? unit.value : this.unit,
        note: note.present ? note.value : this.note,
        eventTimestamp: eventTimestamp ?? this.eventTimestamp,
        createdAt: createdAt ?? this.createdAt,
      );
  CareLog copyWithCompanion(CareLogsCompanion data) {
    return CareLog(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      operatorName: data.operatorName.present
          ? data.operatorName.value
          : this.operatorName,
      value: data.value.present ? data.value.value : this.value,
      unit: data.unit.present ? data.unit.value : this.unit,
      note: data.note.present ? data.note.value : this.note,
      eventTimestamp: data.eventTimestamp.present
          ? data.eventTimestamp.value
          : this.eventTimestamp,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CareLog(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('eventType: $eventType, ')
          ..write('operatorName: $operatorName, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('note: $note, ')
          ..write('eventTimestamp: $eventTimestamp, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, eventId, eventType, operatorName, value,
      unit, note, eventTimestamp, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CareLog &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.eventType == this.eventType &&
          other.operatorName == this.operatorName &&
          other.value == this.value &&
          other.unit == this.unit &&
          other.note == this.note &&
          other.eventTimestamp == this.eventTimestamp &&
          other.createdAt == this.createdAt);
}

class CareLogsCompanion extends UpdateCompanion<CareLog> {
  final Value<int> id;
  final Value<String> eventId;
  final Value<String> eventType;
  final Value<String> operatorName;
  final Value<double?> value;
  final Value<String?> unit;
  final Value<String?> note;
  final Value<DateTime> eventTimestamp;
  final Value<DateTime> createdAt;
  const CareLogsCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.operatorName = const Value.absent(),
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.note = const Value.absent(),
    this.eventTimestamp = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CareLogsCompanion.insert({
    this.id = const Value.absent(),
    required String eventId,
    required String eventType,
    required String operatorName,
    this.value = const Value.absent(),
    this.unit = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime eventTimestamp,
    required DateTime createdAt,
  })  : eventId = Value(eventId),
        eventType = Value(eventType),
        operatorName = Value(operatorName),
        eventTimestamp = Value(eventTimestamp),
        createdAt = Value(createdAt);
  static Insertable<CareLog> custom({
    Expression<int>? id,
    Expression<String>? eventId,
    Expression<String>? eventType,
    Expression<String>? operatorName,
    Expression<double>? value,
    Expression<String>? unit,
    Expression<String>? note,
    Expression<DateTime>? eventTimestamp,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (eventType != null) 'event_type': eventType,
      if (operatorName != null) 'operator': operatorName,
      if (value != null) 'value': value,
      if (unit != null) 'unit': unit,
      if (note != null) 'note': note,
      if (eventTimestamp != null) 'event_timestamp': eventTimestamp,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CareLogsCompanion copyWith(
      {Value<int>? id,
      Value<String>? eventId,
      Value<String>? eventType,
      Value<String>? operatorName,
      Value<double?>? value,
      Value<String?>? unit,
      Value<String?>? note,
      Value<DateTime>? eventTimestamp,
      Value<DateTime>? createdAt}) {
    return CareLogsCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventType: eventType ?? this.eventType,
      operatorName: operatorName ?? this.operatorName,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      note: note ?? this.note,
      eventTimestamp: eventTimestamp ?? this.eventTimestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (operatorName.present) {
      map['operator'] = Variable<String>(operatorName.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (eventTimestamp.present) {
      map['event_timestamp'] = Variable<DateTime>(eventTimestamp.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CareLogsCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('eventType: $eventType, ')
          ..write('operatorName: $operatorName, ')
          ..write('value: $value, ')
          ..write('unit: $unit, ')
          ..write('note: $note, ')
          ..write('eventTimestamp: $eventTimestamp, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WeightLogsTable extends WeightLogs
    with TableInfo<$WeightLogsTable, WeightLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, weightKg, recordedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_logs';
  @override
  VerificationContext validateIntegrity(Insertable<WeightLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg'])!,
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
    );
  }

  @override
  $WeightLogsTable createAlias(String alias) {
    return $WeightLogsTable(attachedDatabase, alias);
  }
}

class WeightLog extends DataClass implements Insertable<WeightLog> {
  final int id;
  final double weightKg;
  final DateTime recordedAt;
  const WeightLog(
      {required this.id, required this.weightKg, required this.recordedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['weight_kg'] = Variable<double>(weightKg);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  WeightLogsCompanion toCompanion(bool nullToAbsent) {
    return WeightLogsCompanion(
      id: Value(id),
      weightKg: Value(weightKg),
      recordedAt: Value(recordedAt),
    );
  }

  factory WeightLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightLog(
      id: serializer.fromJson<int>(json['id']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weightKg': serializer.toJson<double>(weightKg),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  WeightLog copyWith({int? id, double? weightKg, DateTime? recordedAt}) =>
      WeightLog(
        id: id ?? this.id,
        weightKg: weightKg ?? this.weightKg,
        recordedAt: recordedAt ?? this.recordedAt,
      );
  WeightLog copyWithCompanion(WeightLogsCompanion data) {
    return WeightLog(
      id: data.id.present ? data.id.value : this.id,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightLog(')
          ..write('id: $id, ')
          ..write('weightKg: $weightKg, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, weightKg, recordedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightLog &&
          other.id == this.id &&
          other.weightKg == this.weightKg &&
          other.recordedAt == this.recordedAt);
}

class WeightLogsCompanion extends UpdateCompanion<WeightLog> {
  final Value<int> id;
  final Value<double> weightKg;
  final Value<DateTime> recordedAt;
  const WeightLogsCompanion({
    this.id = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.recordedAt = const Value.absent(),
  });
  WeightLogsCompanion.insert({
    this.id = const Value.absent(),
    required double weightKg,
    required DateTime recordedAt,
  })  : weightKg = Value(weightKg),
        recordedAt = Value(recordedAt);
  static Insertable<WeightLog> custom({
    Expression<int>? id,
    Expression<double>? weightKg,
    Expression<DateTime>? recordedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weightKg != null) 'weight_kg': weightKg,
      if (recordedAt != null) 'recorded_at': recordedAt,
    });
  }

  WeightLogsCompanion copyWith(
      {Value<int>? id, Value<double>? weightKg, Value<DateTime>? recordedAt}) {
    return WeightLogsCompanion(
      id: id ?? this.id,
      weightKg: weightKg ?? this.weightKg,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightLogsCompanion(')
          ..write('id: $id, ')
          ..write('weightKg: $weightKg, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }
}

class $DailySummariesTable extends DailySummaries
    with TableInfo<$DailySummariesTable, DailySummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailySummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _totalWaterIntakeMlMeta =
      const VerificationMeta('totalWaterIntakeMl');
  @override
  late final GeneratedColumn<double> totalWaterIntakeMl =
      GeneratedColumn<double>('total_water_intake_ml', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalFoodIntakeGMeta =
      const VerificationMeta('totalFoodIntakeG');
  @override
  late final GeneratedColumn<double> totalFoodIntakeG = GeneratedColumn<double>(
      'total_food_intake_g', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _averageWeightKgMeta =
      const VerificationMeta('averageWeightKg');
  @override
  late final GeneratedColumn<double> averageWeightKg = GeneratedColumn<double>(
      'average_weight_kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, totalWaterIntakeMl, totalFoodIntakeG, averageWeightKg];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_summaries';
  @override
  VerificationContext validateIntegrity(Insertable<DailySummary> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('total_water_intake_ml')) {
      context.handle(
          _totalWaterIntakeMlMeta,
          totalWaterIntakeMl.isAcceptableOrUnknown(
              data['total_water_intake_ml']!, _totalWaterIntakeMlMeta));
    } else if (isInserting) {
      context.missing(_totalWaterIntakeMlMeta);
    }
    if (data.containsKey('total_food_intake_g')) {
      context.handle(
          _totalFoodIntakeGMeta,
          totalFoodIntakeG.isAcceptableOrUnknown(
              data['total_food_intake_g']!, _totalFoodIntakeGMeta));
    } else if (isInserting) {
      context.missing(_totalFoodIntakeGMeta);
    }
    if (data.containsKey('average_weight_kg')) {
      context.handle(
          _averageWeightKgMeta,
          averageWeightKg.isAcceptableOrUnknown(
              data['average_weight_kg']!, _averageWeightKgMeta));
    } else if (isInserting) {
      context.missing(_averageWeightKgMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DailySummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailySummary(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      totalWaterIntakeMl: attachedDatabase.typeMapping.read(DriftSqlType.double,
          data['${effectivePrefix}total_water_intake_ml'])!,
      totalFoodIntakeG: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_food_intake_g'])!,
      averageWeightKg: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}average_weight_kg'])!,
    );
  }

  @override
  $DailySummariesTable createAlias(String alias) {
    return $DailySummariesTable(attachedDatabase, alias);
  }
}

class DailySummary extends DataClass implements Insertable<DailySummary> {
  final int id;
  final DateTime date;
  final double totalWaterIntakeMl;
  final double totalFoodIntakeG;
  final double averageWeightKg;
  const DailySummary(
      {required this.id,
      required this.date,
      required this.totalWaterIntakeMl,
      required this.totalFoodIntakeG,
      required this.averageWeightKg});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['total_water_intake_ml'] = Variable<double>(totalWaterIntakeMl);
    map['total_food_intake_g'] = Variable<double>(totalFoodIntakeG);
    map['average_weight_kg'] = Variable<double>(averageWeightKg);
    return map;
  }

  DailySummariesCompanion toCompanion(bool nullToAbsent) {
    return DailySummariesCompanion(
      id: Value(id),
      date: Value(date),
      totalWaterIntakeMl: Value(totalWaterIntakeMl),
      totalFoodIntakeG: Value(totalFoodIntakeG),
      averageWeightKg: Value(averageWeightKg),
    );
  }

  factory DailySummary.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailySummary(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      totalWaterIntakeMl:
          serializer.fromJson<double>(json['totalWaterIntakeMl']),
      totalFoodIntakeG: serializer.fromJson<double>(json['totalFoodIntakeG']),
      averageWeightKg: serializer.fromJson<double>(json['averageWeightKg']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'totalWaterIntakeMl': serializer.toJson<double>(totalWaterIntakeMl),
      'totalFoodIntakeG': serializer.toJson<double>(totalFoodIntakeG),
      'averageWeightKg': serializer.toJson<double>(averageWeightKg),
    };
  }

  DailySummary copyWith(
          {int? id,
          DateTime? date,
          double? totalWaterIntakeMl,
          double? totalFoodIntakeG,
          double? averageWeightKg}) =>
      DailySummary(
        id: id ?? this.id,
        date: date ?? this.date,
        totalWaterIntakeMl: totalWaterIntakeMl ?? this.totalWaterIntakeMl,
        totalFoodIntakeG: totalFoodIntakeG ?? this.totalFoodIntakeG,
        averageWeightKg: averageWeightKg ?? this.averageWeightKg,
      );
  DailySummary copyWithCompanion(DailySummariesCompanion data) {
    return DailySummary(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      totalWaterIntakeMl: data.totalWaterIntakeMl.present
          ? data.totalWaterIntakeMl.value
          : this.totalWaterIntakeMl,
      totalFoodIntakeG: data.totalFoodIntakeG.present
          ? data.totalFoodIntakeG.value
          : this.totalFoodIntakeG,
      averageWeightKg: data.averageWeightKg.present
          ? data.averageWeightKg.value
          : this.averageWeightKg,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailySummary(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('totalWaterIntakeMl: $totalWaterIntakeMl, ')
          ..write('totalFoodIntakeG: $totalFoodIntakeG, ')
          ..write('averageWeightKg: $averageWeightKg')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, date, totalWaterIntakeMl, totalFoodIntakeG, averageWeightKg);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailySummary &&
          other.id == this.id &&
          other.date == this.date &&
          other.totalWaterIntakeMl == this.totalWaterIntakeMl &&
          other.totalFoodIntakeG == this.totalFoodIntakeG &&
          other.averageWeightKg == this.averageWeightKg);
}

class DailySummariesCompanion extends UpdateCompanion<DailySummary> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double> totalWaterIntakeMl;
  final Value<double> totalFoodIntakeG;
  final Value<double> averageWeightKg;
  const DailySummariesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.totalWaterIntakeMl = const Value.absent(),
    this.totalFoodIntakeG = const Value.absent(),
    this.averageWeightKg = const Value.absent(),
  });
  DailySummariesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required double totalWaterIntakeMl,
    required double totalFoodIntakeG,
    required double averageWeightKg,
  })  : date = Value(date),
        totalWaterIntakeMl = Value(totalWaterIntakeMl),
        totalFoodIntakeG = Value(totalFoodIntakeG),
        averageWeightKg = Value(averageWeightKg);
  static Insertable<DailySummary> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? totalWaterIntakeMl,
    Expression<double>? totalFoodIntakeG,
    Expression<double>? averageWeightKg,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (totalWaterIntakeMl != null)
        'total_water_intake_ml': totalWaterIntakeMl,
      if (totalFoodIntakeG != null) 'total_food_intake_g': totalFoodIntakeG,
      if (averageWeightKg != null) 'average_weight_kg': averageWeightKg,
    });
  }

  DailySummariesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<double>? totalWaterIntakeMl,
      Value<double>? totalFoodIntakeG,
      Value<double>? averageWeightKg}) {
    return DailySummariesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      totalWaterIntakeMl: totalWaterIntakeMl ?? this.totalWaterIntakeMl,
      totalFoodIntakeG: totalFoodIntakeG ?? this.totalFoodIntakeG,
      averageWeightKg: averageWeightKg ?? this.averageWeightKg,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (totalWaterIntakeMl.present) {
      map['total_water_intake_ml'] = Variable<double>(totalWaterIntakeMl.value);
    }
    if (totalFoodIntakeG.present) {
      map['total_food_intake_g'] = Variable<double>(totalFoodIntakeG.value);
    }
    if (averageWeightKg.present) {
      map['average_weight_kg'] = Variable<double>(averageWeightKg.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailySummariesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('totalWaterIntakeMl: $totalWaterIntakeMl, ')
          ..write('totalFoodIntakeG: $totalFoodIntakeG, ')
          ..write('averageWeightKg: $averageWeightKg')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $CareLogsTable careLogs = $CareLogsTable(this);
  late final $WeightLogsTable weightLogs = $WeightLogsTable(this);
  late final $DailySummariesTable dailySummaries = $DailySummariesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [careLogs, weightLogs, dailySummaries];
}

typedef $$CareLogsTableCreateCompanionBuilder = CareLogsCompanion Function({
  Value<int> id,
  required String eventId,
  required String eventType,
  required String operatorName,
  Value<double?> value,
  Value<String?> unit,
  Value<String?> note,
  required DateTime eventTimestamp,
  required DateTime createdAt,
});
typedef $$CareLogsTableUpdateCompanionBuilder = CareLogsCompanion Function({
  Value<int> id,
  Value<String> eventId,
  Value<String> eventType,
  Value<String> operatorName,
  Value<double?> value,
  Value<String?> unit,
  Value<String?> note,
  Value<DateTime> eventTimestamp,
  Value<DateTime> createdAt,
});

class $$CareLogsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $CareLogsTable,
    CareLog,
    $$CareLogsTableFilterComposer,
    $$CareLogsTableOrderingComposer,
    $$CareLogsTableCreateCompanionBuilder,
    $$CareLogsTableUpdateCompanionBuilder> {
  $$CareLogsTableTableManager(_$LocalDatabase db, $CareLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CareLogsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CareLogsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> eventId = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<String> operatorName = const Value.absent(),
            Value<double?> value = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime> eventTimestamp = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              CareLogsCompanion(
            id: id,
            eventId: eventId,
            eventType: eventType,
            operatorName: operatorName,
            value: value,
            unit: unit,
            note: note,
            eventTimestamp: eventTimestamp,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String eventId,
            required String eventType,
            required String operatorName,
            Value<double?> value = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<String?> note = const Value.absent(),
            required DateTime eventTimestamp,
            required DateTime createdAt,
          }) =>
              CareLogsCompanion.insert(
            id: id,
            eventId: eventId,
            eventType: eventType,
            operatorName: operatorName,
            value: value,
            unit: unit,
            note: note,
            eventTimestamp: eventTimestamp,
            createdAt: createdAt,
          ),
        ));
}

class $$CareLogsTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $CareLogsTable> {
  $$CareLogsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get eventId => $state.composableBuilder(
      column: $state.table.eventId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get eventType => $state.composableBuilder(
      column: $state.table.eventType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get operatorName => $state.composableBuilder(
      column: $state.table.operatorName,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get unit => $state.composableBuilder(
      column: $state.table.unit,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get note => $state.composableBuilder(
      column: $state.table.note,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get eventTimestamp => $state.composableBuilder(
      column: $state.table.eventTimestamp,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$CareLogsTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $CareLogsTable> {
  $$CareLogsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get eventId => $state.composableBuilder(
      column: $state.table.eventId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get eventType => $state.composableBuilder(
      column: $state.table.eventType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get operatorName => $state.composableBuilder(
      column: $state.table.operatorName,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get value => $state.composableBuilder(
      column: $state.table.value,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get unit => $state.composableBuilder(
      column: $state.table.unit,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get note => $state.composableBuilder(
      column: $state.table.note,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get eventTimestamp => $state.composableBuilder(
      column: $state.table.eventTimestamp,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$WeightLogsTableCreateCompanionBuilder = WeightLogsCompanion Function({
  Value<int> id,
  required double weightKg,
  required DateTime recordedAt,
});
typedef $$WeightLogsTableUpdateCompanionBuilder = WeightLogsCompanion Function({
  Value<int> id,
  Value<double> weightKg,
  Value<DateTime> recordedAt,
});

class $$WeightLogsTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $WeightLogsTable,
    WeightLog,
    $$WeightLogsTableFilterComposer,
    $$WeightLogsTableOrderingComposer,
    $$WeightLogsTableCreateCompanionBuilder,
    $$WeightLogsTableUpdateCompanionBuilder> {
  $$WeightLogsTableTableManager(_$LocalDatabase db, $WeightLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$WeightLogsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$WeightLogsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<double> weightKg = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
          }) =>
              WeightLogsCompanion(
            id: id,
            weightKg: weightKg,
            recordedAt: recordedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required double weightKg,
            required DateTime recordedAt,
          }) =>
              WeightLogsCompanion.insert(
            id: id,
            weightKg: weightKg,
            recordedAt: recordedAt,
          ),
        ));
}

class $$WeightLogsTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $WeightLogsTable> {
  $$WeightLogsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get weightKg => $state.composableBuilder(
      column: $state.table.weightKg,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get recordedAt => $state.composableBuilder(
      column: $state.table.recordedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$WeightLogsTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $WeightLogsTable> {
  $$WeightLogsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get weightKg => $state.composableBuilder(
      column: $state.table.weightKg,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get recordedAt => $state.composableBuilder(
      column: $state.table.recordedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$DailySummariesTableCreateCompanionBuilder = DailySummariesCompanion
    Function({
  Value<int> id,
  required DateTime date,
  required double totalWaterIntakeMl,
  required double totalFoodIntakeG,
  required double averageWeightKg,
});
typedef $$DailySummariesTableUpdateCompanionBuilder = DailySummariesCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  Value<double> totalWaterIntakeMl,
  Value<double> totalFoodIntakeG,
  Value<double> averageWeightKg,
});

class $$DailySummariesTableTableManager extends RootTableManager<
    _$LocalDatabase,
    $DailySummariesTable,
    DailySummary,
    $$DailySummariesTableFilterComposer,
    $$DailySummariesTableOrderingComposer,
    $$DailySummariesTableCreateCompanionBuilder,
    $$DailySummariesTableUpdateCompanionBuilder> {
  $$DailySummariesTableTableManager(
      _$LocalDatabase db, $DailySummariesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DailySummariesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DailySummariesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> totalWaterIntakeMl = const Value.absent(),
            Value<double> totalFoodIntakeG = const Value.absent(),
            Value<double> averageWeightKg = const Value.absent(),
          }) =>
              DailySummariesCompanion(
            id: id,
            date: date,
            totalWaterIntakeMl: totalWaterIntakeMl,
            totalFoodIntakeG: totalFoodIntakeG,
            averageWeightKg: averageWeightKg,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required double totalWaterIntakeMl,
            required double totalFoodIntakeG,
            required double averageWeightKg,
          }) =>
              DailySummariesCompanion.insert(
            id: id,
            date: date,
            totalWaterIntakeMl: totalWaterIntakeMl,
            totalFoodIntakeG: totalFoodIntakeG,
            averageWeightKg: averageWeightKg,
          ),
        ));
}

class $$DailySummariesTableFilterComposer
    extends FilterComposer<_$LocalDatabase, $DailySummariesTable> {
  $$DailySummariesTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get totalWaterIntakeMl => $state.composableBuilder(
      column: $state.table.totalWaterIntakeMl,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get totalFoodIntakeG => $state.composableBuilder(
      column: $state.table.totalFoodIntakeG,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get averageWeightKg => $state.composableBuilder(
      column: $state.table.averageWeightKg,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$DailySummariesTableOrderingComposer
    extends OrderingComposer<_$LocalDatabase, $DailySummariesTable> {
  $$DailySummariesTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get date => $state.composableBuilder(
      column: $state.table.date,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get totalWaterIntakeMl => $state.composableBuilder(
      column: $state.table.totalWaterIntakeMl,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get totalFoodIntakeG => $state.composableBuilder(
      column: $state.table.totalFoodIntakeG,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get averageWeightKg => $state.composableBuilder(
      column: $state.table.averageWeightKg,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$CareLogsTableTableManager get careLogs =>
      $$CareLogsTableTableManager(_db, _db.careLogs);
  $$WeightLogsTableTableManager get weightLogs =>
      $$WeightLogsTableTableManager(_db, _db.weightLogs);
  $$DailySummariesTableTableManager get dailySummaries =>
      $$DailySummariesTableTableManager(_db, _db.dailySummaries);
}
