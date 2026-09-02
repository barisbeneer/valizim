// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TripsTable extends Trips with TableInfo<$TripsTable, TripRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripTypeMeta = const VerificationMeta(
    'tripType',
  );
  @override
  late final GeneratedColumn<String> tripType = GeneratedColumn<String>(
    'trip_type',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 32),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationDaysMeta = const VerificationMeta(
    'durationDays',
  );
  @override
  late final GeneratedColumn<int> durationDays = GeneratedColumn<int>(
    'duration_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _travelerCountMeta = const VerificationMeta(
    'travelerCount',
  );
  @override
  late final GeneratedColumn<int> travelerCount = GeneratedColumn<int>(
    'traveler_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionsJsonMeta = const VerificationMeta(
    'optionsJson',
  );
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
    'options_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: schemaEpoch,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    tripType,
    startDate,
    durationDays,
    travelerCount,
    optionsJson,
    createdAt,
    updatedAt,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('trip_type')) {
      context.handle(
        _tripTypeMeta,
        tripType.isAcceptableOrUnknown(data['trip_type']!, _tripTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_tripTypeMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('duration_days')) {
      context.handle(
        _durationDaysMeta,
        durationDays.isAcceptableOrUnknown(
          data['duration_days']!,
          _durationDaysMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationDaysMeta);
    }
    if (data.containsKey('traveler_count')) {
      context.handle(
        _travelerCountMeta,
        travelerCount.isAcceptableOrUnknown(
          data['traveler_count']!,
          _travelerCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_travelerCountMeta);
    }
    if (data.containsKey('options_json')) {
      context.handle(
        _optionsJsonMeta,
        optionsJson.isAcceptableOrUnknown(
          data['options_json']!,
          _optionsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_optionsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      tripType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_type'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
      durationDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_days'],
      )!,
      travelerCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}traveler_count'],
      )!,
      optionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class TripRow extends DataClass implements Insertable<TripRow> {
  final String id;
  final String name;

  /// `TripType.id`. Stored as text so an unknown future value degrades to
  /// `general` instead of throwing.
  final String tripType;

  /// Calendar date of departure, as UTC midnight. Null when the user has not
  /// set one, in which case no reminder can be scheduled.
  final DateTime? startDate;
  final int durationDays;
  final int travelerCount;

  /// `TripSettings.encode()`.
  final String optionsJson;
  final DateTime createdAt;

  /// Added in schema v2.
  ///
  /// The default is a *constant* sentinel, not `CURRENT_TIMESTAMP`: SQLite
  /// rejects a non-constant default in `ALTER TABLE ADD COLUMN`, and declaring
  /// it here rather than only in the migration keeps a freshly created database
  /// byte-identical to a migrated one. Every insert supplies a real value, and
  /// the migration backfills existing rows, so the sentinel is never read.
  final DateTime updatedAt;

  /// Soft delete. Archived trips stay reusable and keep counting toward the
  /// free tier.
  final bool archived;
  const TripRow({
    required this.id,
    required this.name,
    required this.tripType,
    this.startDate,
    required this.durationDays,
    required this.travelerCount,
    required this.optionsJson,
    required this.createdAt,
    required this.updatedAt,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['trip_type'] = Variable<String>(tripType);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    map['duration_days'] = Variable<int>(durationDays);
    map['traveler_count'] = Variable<int>(travelerCount);
    map['options_json'] = Variable<String>(optionsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      name: Value(name),
      tripType: Value(tripType),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      durationDays: Value(durationDays),
      travelerCount: Value(travelerCount),
      optionsJson: Value(optionsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archived: Value(archived),
    );
  }

  factory TripRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      tripType: serializer.fromJson<String>(json['tripType']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
      durationDays: serializer.fromJson<int>(json['durationDays']),
      travelerCount: serializer.fromJson<int>(json['travelerCount']),
      optionsJson: serializer.fromJson<String>(json['optionsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'tripType': serializer.toJson<String>(tripType),
      'startDate': serializer.toJson<DateTime?>(startDate),
      'durationDays': serializer.toJson<int>(durationDays),
      'travelerCount': serializer.toJson<int>(travelerCount),
      'optionsJson': serializer.toJson<String>(optionsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  TripRow copyWith({
    String? id,
    String? name,
    String? tripType,
    Value<DateTime?> startDate = const Value.absent(),
    int? durationDays,
    int? travelerCount,
    String? optionsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? archived,
  }) => TripRow(
    id: id ?? this.id,
    name: name ?? this.name,
    tripType: tripType ?? this.tripType,
    startDate: startDate.present ? startDate.value : this.startDate,
    durationDays: durationDays ?? this.durationDays,
    travelerCount: travelerCount ?? this.travelerCount,
    optionsJson: optionsJson ?? this.optionsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archived: archived ?? this.archived,
  );
  TripRow copyWithCompanion(TripsCompanion data) {
    return TripRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      tripType: data.tripType.present ? data.tripType.value : this.tripType,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      durationDays: data.durationDays.present
          ? data.durationDays.value
          : this.durationDays,
      travelerCount: data.travelerCount.present
          ? data.travelerCount.value
          : this.travelerCount,
      optionsJson: data.optionsJson.present
          ? data.optionsJson.value
          : this.optionsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tripType: $tripType, ')
          ..write('startDate: $startDate, ')
          ..write('durationDays: $durationDays, ')
          ..write('travelerCount: $travelerCount, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    tripType,
    startDate,
    durationDays,
    travelerCount,
    optionsJson,
    createdAt,
    updatedAt,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.tripType == this.tripType &&
          other.startDate == this.startDate &&
          other.durationDays == this.durationDays &&
          other.travelerCount == this.travelerCount &&
          other.optionsJson == this.optionsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archived == this.archived);
}

class TripsCompanion extends UpdateCompanion<TripRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> tripType;
  final Value<DateTime?> startDate;
  final Value<int> durationDays;
  final Value<int> travelerCount;
  final Value<String> optionsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> archived;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.tripType = const Value.absent(),
    this.startDate = const Value.absent(),
    this.durationDays = const Value.absent(),
    this.travelerCount = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    required String name,
    required String tripType,
    this.startDate = const Value.absent(),
    required int durationDays,
    required int travelerCount,
    required String optionsJson,
    required DateTime createdAt,
    this.updatedAt = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       tripType = Value(tripType),
       durationDays = Value(durationDays),
       travelerCount = Value(travelerCount),
       optionsJson = Value(optionsJson),
       createdAt = Value(createdAt);
  static Insertable<TripRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? tripType,
    Expression<DateTime>? startDate,
    Expression<int>? durationDays,
    Expression<int>? travelerCount,
    Expression<String>? optionsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (tripType != null) 'trip_type': tripType,
      if (startDate != null) 'start_date': startDate,
      if (durationDays != null) 'duration_days': durationDays,
      if (travelerCount != null) 'traveler_count': travelerCount,
      if (optionsJson != null) 'options_json': optionsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? tripType,
    Value<DateTime?>? startDate,
    Value<int>? durationDays,
    Value<int>? travelerCount,
    Value<String>? optionsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      tripType: tripType ?? this.tripType,
      startDate: startDate ?? this.startDate,
      durationDays: durationDays ?? this.durationDays,
      travelerCount: travelerCount ?? this.travelerCount,
      optionsJson: optionsJson ?? this.optionsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tripType.present) {
      map['trip_type'] = Variable<String>(tripType.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (durationDays.present) {
      map['duration_days'] = Variable<int>(durationDays.value);
    }
    if (travelerCount.present) {
      map['traveler_count'] = Variable<int>(travelerCount.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tripType: $tripType, ')
          ..write('startDate: $startDate, ')
          ..write('durationDays: $durationDays, ')
          ..write('travelerCount: $travelerCount, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripItemsTable extends TripItems
    with TableInfo<$TripItemsTable, TripItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trips (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 32),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkedMeta = const VerificationMeta(
    'checked',
  );
  @override
  late final GeneratedColumn<bool> checked = GeneratedColumn<bool>(
    'checked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("checked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isEssentialMeta = const VerificationMeta(
    'isEssential',
  );
  @override
  late final GeneratedColumn<bool> isEssential = GeneratedColumn<bool>(
    'is_essential',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_essential" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleKeyMeta = const VerificationMeta(
    'ruleKey',
  );
  @override
  late final GeneratedColumn<String> ruleKey = GeneratedColumn<String>(
    'rule_key',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 64),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    label,
    category,
    quantity,
    checked,
    isEssential,
    sortOrder,
    ruleKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('checked')) {
      context.handle(
        _checkedMeta,
        checked.isAcceptableOrUnknown(data['checked']!, _checkedMeta),
      );
    }
    if (data.containsKey('is_essential')) {
      context.handle(
        _isEssentialMeta,
        isEssential.isAcceptableOrUnknown(
          data['is_essential']!,
          _isEssentialMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('rule_key')) {
      context.handle(
        _ruleKeyMeta,
        ruleKey.isAcceptableOrUnknown(data['rule_key']!, _ruleKeyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      checked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}checked'],
      )!,
      isEssential: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_essential'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      ruleKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_key'],
      ),
    );
  }

  @override
  $TripItemsTable createAlias(String alias) {
    return $TripItemsTable(attachedDatabase, alias);
  }
}

class TripItemRow extends DataClass implements Insertable<TripItemRow> {
  final String id;
  final String tripId;

  /// Display text as generated or typed. For generated rows this is the English
  /// fallback; [ruleKey] takes priority when resolving the label.
  final String label;

  /// `ItemCategory.id`.
  final String category;
  final int quantity;
  final bool checked;
  final bool isEssential;
  final int sortOrder;

  /// Added in schema v2. Non-null for generated rows, null for user-added ones.
  /// Lets the UI re-localize built-in labels when the device language changes
  /// without rewriting stored data.
  final String? ruleKey;
  const TripItemRow({
    required this.id,
    required this.tripId,
    required this.label,
    required this.category,
    required this.quantity,
    required this.checked,
    required this.isEssential,
    required this.sortOrder,
    this.ruleKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['label'] = Variable<String>(label);
    map['category'] = Variable<String>(category);
    map['quantity'] = Variable<int>(quantity);
    map['checked'] = Variable<bool>(checked);
    map['is_essential'] = Variable<bool>(isEssential);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || ruleKey != null) {
      map['rule_key'] = Variable<String>(ruleKey);
    }
    return map;
  }

  TripItemsCompanion toCompanion(bool nullToAbsent) {
    return TripItemsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      label: Value(label),
      category: Value(category),
      quantity: Value(quantity),
      checked: Value(checked),
      isEssential: Value(isEssential),
      sortOrder: Value(sortOrder),
      ruleKey: ruleKey == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleKey),
    );
  }

  factory TripItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripItemRow(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      label: serializer.fromJson<String>(json['label']),
      category: serializer.fromJson<String>(json['category']),
      quantity: serializer.fromJson<int>(json['quantity']),
      checked: serializer.fromJson<bool>(json['checked']),
      isEssential: serializer.fromJson<bool>(json['isEssential']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      ruleKey: serializer.fromJson<String?>(json['ruleKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'label': serializer.toJson<String>(label),
      'category': serializer.toJson<String>(category),
      'quantity': serializer.toJson<int>(quantity),
      'checked': serializer.toJson<bool>(checked),
      'isEssential': serializer.toJson<bool>(isEssential),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'ruleKey': serializer.toJson<String?>(ruleKey),
    };
  }

  TripItemRow copyWith({
    String? id,
    String? tripId,
    String? label,
    String? category,
    int? quantity,
    bool? checked,
    bool? isEssential,
    int? sortOrder,
    Value<String?> ruleKey = const Value.absent(),
  }) => TripItemRow(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    label: label ?? this.label,
    category: category ?? this.category,
    quantity: quantity ?? this.quantity,
    checked: checked ?? this.checked,
    isEssential: isEssential ?? this.isEssential,
    sortOrder: sortOrder ?? this.sortOrder,
    ruleKey: ruleKey.present ? ruleKey.value : this.ruleKey,
  );
  TripItemRow copyWithCompanion(TripItemsCompanion data) {
    return TripItemRow(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      label: data.label.present ? data.label.value : this.label,
      category: data.category.present ? data.category.value : this.category,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      checked: data.checked.present ? data.checked.value : this.checked,
      isEssential: data.isEssential.present
          ? data.isEssential.value
          : this.isEssential,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      ruleKey: data.ruleKey.present ? data.ruleKey.value : this.ruleKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripItemRow(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('label: $label, ')
          ..write('category: $category, ')
          ..write('quantity: $quantity, ')
          ..write('checked: $checked, ')
          ..write('isEssential: $isEssential, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('ruleKey: $ruleKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    label,
    category,
    quantity,
    checked,
    isEssential,
    sortOrder,
    ruleKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripItemRow &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.label == this.label &&
          other.category == this.category &&
          other.quantity == this.quantity &&
          other.checked == this.checked &&
          other.isEssential == this.isEssential &&
          other.sortOrder == this.sortOrder &&
          other.ruleKey == this.ruleKey);
}

class TripItemsCompanion extends UpdateCompanion<TripItemRow> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<String> label;
  final Value<String> category;
  final Value<int> quantity;
  final Value<bool> checked;
  final Value<bool> isEssential;
  final Value<int> sortOrder;
  final Value<String?> ruleKey;
  final Value<int> rowid;
  const TripItemsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.label = const Value.absent(),
    this.category = const Value.absent(),
    this.quantity = const Value.absent(),
    this.checked = const Value.absent(),
    this.isEssential = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.ruleKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripItemsCompanion.insert({
    required String id,
    required String tripId,
    required String label,
    required String category,
    required int quantity,
    this.checked = const Value.absent(),
    this.isEssential = const Value.absent(),
    required int sortOrder,
    this.ruleKey = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       label = Value(label),
       category = Value(category),
       quantity = Value(quantity),
       sortOrder = Value(sortOrder);
  static Insertable<TripItemRow> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<String>? label,
    Expression<String>? category,
    Expression<int>? quantity,
    Expression<bool>? checked,
    Expression<bool>? isEssential,
    Expression<int>? sortOrder,
    Expression<String>? ruleKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (label != null) 'label': label,
      if (category != null) 'category': category,
      if (quantity != null) 'quantity': quantity,
      if (checked != null) 'checked': checked,
      if (isEssential != null) 'is_essential': isEssential,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (ruleKey != null) 'rule_key': ruleKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<String>? label,
    Value<String>? category,
    Value<int>? quantity,
    Value<bool>? checked,
    Value<bool>? isEssential,
    Value<int>? sortOrder,
    Value<String?>? ruleKey,
    Value<int>? rowid,
  }) {
    return TripItemsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      label: label ?? this.label,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      checked: checked ?? this.checked,
      isEssential: isEssential ?? this.isEssential,
      sortOrder: sortOrder ?? this.sortOrder,
      ruleKey: ruleKey ?? this.ruleKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (checked.present) {
      map['checked'] = Variable<bool>(checked.value);
    }
    if (isEssential.present) {
      map['is_essential'] = Variable<bool>(isEssential.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (ruleKey.present) {
      map['rule_key'] = Variable<String>(ruleKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripItemsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('label: $label, ')
          ..write('category: $category, ')
          ..write('quantity: $quantity, ')
          ..write('checked: $checked, ')
          ..write('isEssential: $isEssential, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('ruleKey: $ruleKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomTemplatesTable extends CustomTemplates
    with TableInfo<$CustomTemplatesTable, CustomTemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripTypeMeta = const VerificationMeta(
    'tripType',
  );
  @override
  late final GeneratedColumn<String> tripType = GeneratedColumn<String>(
    'trip_type',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 32),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemsJsonMeta = const VerificationMeta(
    'itemsJson',
  );
  @override
  late final GeneratedColumn<String> itemsJson = GeneratedColumn<String>(
    'items_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: schemaEpoch,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    tripType,
    itemsJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomTemplateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('trip_type')) {
      context.handle(
        _tripTypeMeta,
        tripType.isAcceptableOrUnknown(data['trip_type']!, _tripTypeMeta),
      );
    }
    if (data.containsKey('items_json')) {
      context.handle(
        _itemsJsonMeta,
        itemsJson.isAcceptableOrUnknown(data['items_json']!, _itemsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_itemsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomTemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomTemplateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      tripType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_type'],
      ),
      itemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}items_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomTemplatesTable createAlias(String alias) {
    return $CustomTemplatesTable(attachedDatabase, alias);
  }
}

class CustomTemplateRow extends DataClass
    implements Insertable<CustomTemplateRow> {
  final String id;
  final String name;

  /// Optional `TripType.id` this template is associated with.
  final String? tripType;

  /// JSON array of template items.
  final String itemsJson;

  /// Added in schema v2. See the note on `Trips.updatedAt` for why this
  /// carries a constant SQL default.
  final DateTime createdAt;
  const CustomTemplateRow({
    required this.id,
    required this.name,
    this.tripType,
    required this.itemsJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || tripType != null) {
      map['trip_type'] = Variable<String>(tripType);
    }
    map['items_json'] = Variable<String>(itemsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomTemplatesCompanion toCompanion(bool nullToAbsent) {
    return CustomTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      tripType: tripType == null && nullToAbsent
          ? const Value.absent()
          : Value(tripType),
      itemsJson: Value(itemsJson),
      createdAt: Value(createdAt),
    );
  }

  factory CustomTemplateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomTemplateRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      tripType: serializer.fromJson<String?>(json['tripType']),
      itemsJson: serializer.fromJson<String>(json['itemsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'tripType': serializer.toJson<String?>(tripType),
      'itemsJson': serializer.toJson<String>(itemsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomTemplateRow copyWith({
    String? id,
    String? name,
    Value<String?> tripType = const Value.absent(),
    String? itemsJson,
    DateTime? createdAt,
  }) => CustomTemplateRow(
    id: id ?? this.id,
    name: name ?? this.name,
    tripType: tripType.present ? tripType.value : this.tripType,
    itemsJson: itemsJson ?? this.itemsJson,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomTemplateRow copyWithCompanion(CustomTemplatesCompanion data) {
    return CustomTemplateRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      tripType: data.tripType.present ? data.tripType.value : this.tripType,
      itemsJson: data.itemsJson.present ? data.itemsJson.value : this.itemsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomTemplateRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tripType: $tripType, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, tripType, itemsJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomTemplateRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.tripType == this.tripType &&
          other.itemsJson == this.itemsJson &&
          other.createdAt == this.createdAt);
}

class CustomTemplatesCompanion extends UpdateCompanion<CustomTemplateRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> tripType;
  final Value<String> itemsJson;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.tripType = const Value.absent(),
    this.itemsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomTemplatesCompanion.insert({
    required String id,
    required String name,
    this.tripType = const Value.absent(),
    required String itemsJson,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       itemsJson = Value(itemsJson);
  static Insertable<CustomTemplateRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? tripType,
    Expression<String>? itemsJson,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (tripType != null) 'trip_type': tripType,
      if (itemsJson != null) 'items_json': itemsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomTemplatesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? tripType,
    Value<String>? itemsJson,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      tripType: tripType ?? this.tripType,
      itemsJson: itemsJson ?? this.itemsJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tripType.present) {
      map['trip_type'] = Variable<String>(tripType.value);
    }
    if (itemsJson.present) {
      map['items_json'] = Variable<String>(itemsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('tripType: $tripType, ')
          ..write('itemsJson: $itemsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $TripItemsTable tripItems = $TripItemsTable(this);
  late final $CustomTemplatesTable customTemplates = $CustomTemplatesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    trips,
    tripItems,
    customTemplates,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trips',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('trip_items', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$TripsTableCreateCompanionBuilder = TripsCompanion Function({
  required String id,
  required String name,
  required String tripType,
  Value<DateTime?> startDate,
  required int durationDays,
  required int travelerCount,
  required String optionsJson,
  required DateTime createdAt,
  Value<DateTime> updatedAt,
  Value<bool> archived,
  Value<int> rowid,
});
typedef $$TripsTableUpdateCompanionBuilder = TripsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> tripType,
  Value<DateTime?> startDate,
  Value<int> durationDays,
  Value<int> travelerCount,
  Value<String> optionsJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> archived,
  Value<int> rowid,
});

final class $$TripsTableReferences
    extends BaseReferences<_$AppDatabase, $TripsTable, TripRow> {
  $$TripsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TripItemsTable, List<TripItemRow>>
  _tripItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tripItems,
    aliasName: 'trips__id__trip_items__trip_id',
  );

  $$TripItemsTableProcessedTableManager get tripItemsRefs {
    final manager = $$TripItemsTableTableManager(
      $_db,
      $_db.tripItems,
    ).filter((f) => f.tripId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tripItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripType => $composableBuilder(
    column: $table.tripType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get travelerCount => $composableBuilder(
    column: $table.travelerCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tripItemsRefs(
    Expression<bool> Function($$TripItemsTableFilterComposer f) f,
  ) {
    final $$TripItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripItems,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripItemsTableFilterComposer(
            $db: $db,
            $table: $db.tripItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripType => $composableBuilder(
    column: $table.tripType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get travelerCount => $composableBuilder(
    column: $table.travelerCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get tripType =>
      $composableBuilder(column: $table.tripType, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get durationDays => $composableBuilder(
    column: $table.durationDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get travelerCount => $composableBuilder(
    column: $table.travelerCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> tripItemsRefs<T extends Object>(
    Expression<T> Function($$TripItemsTableAnnotationComposer a) f,
  ) {
    final $$TripItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tripItems,
      getReferencedColumn: (t) => t.tripId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.tripItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTable,
          TripRow,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (TripRow, $$TripsTableReferences),
          TripRow,
          PrefetchHooks Function({bool tripItemsRefs})
        > {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> tripType = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<int> durationDays = const Value.absent(),
                Value<int> travelerCount = const Value.absent(),
                Value<String> optionsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                name: name,
                tripType: tripType,
                startDate: startDate,
                durationDays: durationDays,
                travelerCount: travelerCount,
                optionsJson: optionsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String tripType,
                Value<DateTime?> startDate = const Value.absent(),
                required int durationDays,
                required int travelerCount,
                required String optionsJson,
                required DateTime createdAt,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                name: name,
                tripType: tripType,
                startDate: startDate,
                durationDays: durationDays,
                travelerCount: travelerCount,
                optionsJson: optionsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TripsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({tripItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tripItemsRefs) db.tripItems],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tripItemsRefs)
                    await $_getPrefetchedData<
                      TripRow,
                      $TripsTable,
                      TripItemRow
                    >(
                      currentTable: table,
                      referencedTable: $$TripsTableReferences
                          ._tripItemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TripsTableReferences(db, table, p0).tripItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tripId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTable,
      TripRow,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (TripRow, $$TripsTableReferences),
      TripRow,
      PrefetchHooks Function({bool tripItemsRefs})
    >;
typedef $$TripItemsTableCreateCompanionBuilder = TripItemsCompanion Function({
  required String id,
  required String tripId,
  required String label,
  required String category,
  required int quantity,
  Value<bool> checked,
  Value<bool> isEssential,
  required int sortOrder,
  Value<String?> ruleKey,
  Value<int> rowid,
});
typedef $$TripItemsTableUpdateCompanionBuilder = TripItemsCompanion Function({
  Value<String> id,
  Value<String> tripId,
  Value<String> label,
  Value<String> category,
  Value<int> quantity,
  Value<bool> checked,
  Value<bool> isEssential,
  Value<int> sortOrder,
  Value<String?> ruleKey,
  Value<int> rowid,
});

final class $$TripItemsTableReferences
    extends BaseReferences<_$AppDatabase, $TripItemsTable, TripItemRow> {
  $$TripItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TripsTable _tripIdTable(_$AppDatabase db) =>
      db.trips.createAlias('trip_items__trip_id__trips__id');

  $$TripsTableProcessedTableManager get tripId {
    final $_column = $_itemColumn<String>('trip_id')!;

    final manager = $$TripsTableTableManager(
      $_db,
      $_db.trips,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tripIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TripItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TripItemsTable> {
  $$TripItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get checked => $composableBuilder(
    column: $table.checked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEssential => $composableBuilder(
    column: $table.isEssential,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleKey => $composableBuilder(
    column: $table.ruleKey,
    builder: (column) => ColumnFilters(column),
  );

  $$TripsTableFilterComposer get tripId {
    final $$TripsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableFilterComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripItemsTable> {
  $$TripItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get checked => $composableBuilder(
    column: $table.checked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEssential => $composableBuilder(
    column: $table.isEssential,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleKey => $composableBuilder(
    column: $table.ruleKey,
    builder: (column) => ColumnOrderings(column),
  );

  $$TripsTableOrderingComposer get tripId {
    final $$TripsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableOrderingComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripItemsTable> {
  $$TripItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<bool> get checked =>
      $composableBuilder(column: $table.checked, builder: (column) => column);

  GeneratedColumn<bool> get isEssential => $composableBuilder(
    column: $table.isEssential,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get ruleKey =>
      $composableBuilder(column: $table.ruleKey, builder: (column) => column);

  $$TripsTableAnnotationComposer get tripId {
    final $$TripsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tripId,
      referencedTable: $db.trips,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TripsTableAnnotationComposer(
            $db: $db,
            $table: $db.trips,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TripItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripItemsTable,
          TripItemRow,
          $$TripItemsTableFilterComposer,
          $$TripItemsTableOrderingComposer,
          $$TripItemsTableAnnotationComposer,
          $$TripItemsTableCreateCompanionBuilder,
          $$TripItemsTableUpdateCompanionBuilder,
          (TripItemRow, $$TripItemsTableReferences),
          TripItemRow,
          PrefetchHooks Function({bool tripId})
        > {
  $$TripItemsTableTableManager(_$AppDatabase db, $TripItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<bool> checked = const Value.absent(),
                Value<bool> isEssential = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> ruleKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripItemsCompanion(
                id: id,
                tripId: tripId,
                label: label,
                category: category,
                quantity: quantity,
                checked: checked,
                isEssential: isEssential,
                sortOrder: sortOrder,
                ruleKey: ruleKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required String label,
                required String category,
                required int quantity,
                Value<bool> checked = const Value.absent(),
                Value<bool> isEssential = const Value.absent(),
                required int sortOrder,
                Value<String?> ruleKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripItemsCompanion.insert(
                id: id,
                tripId: tripId,
                label: label,
                category: category,
                quantity: quantity,
                checked: checked,
                isEssential: isEssential,
                sortOrder: sortOrder,
                ruleKey: ruleKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TripItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tripId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tripId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tripId,
                        referencedTable: $$TripItemsTableReferences
                            ._tripIdTable(db),
                        referencedColumn: $$TripItemsTableReferences
                            ._tripIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TripItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripItemsTable,
      TripItemRow,
      $$TripItemsTableFilterComposer,
      $$TripItemsTableOrderingComposer,
      $$TripItemsTableAnnotationComposer,
      $$TripItemsTableCreateCompanionBuilder,
      $$TripItemsTableUpdateCompanionBuilder,
      (TripItemRow, $$TripItemsTableReferences),
      TripItemRow,
      PrefetchHooks Function({bool tripId})
    >;
typedef $$CustomTemplatesTableCreateCompanionBuilder =
    CustomTemplatesCompanion Function({
      required String id,
      required String name,
      Value<String?> tripType,
      required String itemsJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$CustomTemplatesTableUpdateCompanionBuilder =
    CustomTemplatesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> tripType,
      Value<String> itemsJson,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CustomTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomTemplatesTable> {
  $$CustomTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripType => $composableBuilder(
    column: $table.tripType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomTemplatesTable> {
  $$CustomTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripType => $composableBuilder(
    column: $table.tripType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemsJson => $composableBuilder(
    column: $table.itemsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomTemplatesTable> {
  $$CustomTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get tripType =>
      $composableBuilder(column: $table.tripType, builder: (column) => column);

  GeneratedColumn<String> get itemsJson =>
      $composableBuilder(column: $table.itemsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomTemplatesTable,
          CustomTemplateRow,
          $$CustomTemplatesTableFilterComposer,
          $$CustomTemplatesTableOrderingComposer,
          $$CustomTemplatesTableAnnotationComposer,
          $$CustomTemplatesTableCreateCompanionBuilder,
          $$CustomTemplatesTableUpdateCompanionBuilder,
          (
            CustomTemplateRow,
            BaseReferences<
              _$AppDatabase,
              $CustomTemplatesTable,
              CustomTemplateRow
            >,
          ),
          CustomTemplateRow,
          PrefetchHooks Function()
        > {
  $$CustomTemplatesTableTableManager(
    _$AppDatabase db,
    $CustomTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> tripType = const Value.absent(),
                Value<String> itemsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomTemplatesCompanion(
                id: id,
                name: name,
                tripType: tripType,
                itemsJson: itemsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> tripType = const Value.absent(),
                required String itemsJson,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomTemplatesCompanion.insert(
                id: id,
                name: name,
                tripType: tripType,
                itemsJson: itemsJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomTemplatesTable,
      CustomTemplateRow,
      $$CustomTemplatesTableFilterComposer,
      $$CustomTemplatesTableOrderingComposer,
      $$CustomTemplatesTableAnnotationComposer,
      $$CustomTemplatesTableCreateCompanionBuilder,
      $$CustomTemplatesTableUpdateCompanionBuilder,
      (
        CustomTemplateRow,
        BaseReferences<_$AppDatabase, $CustomTemplatesTable, CustomTemplateRow>,
      ),
      CustomTemplateRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$TripItemsTableTableManager get tripItems =>
      $$TripItemsTableTableManager(_db, _db.tripItems);
  $$CustomTemplatesTableTableManager get customTemplates =>
      $$CustomTemplatesTableTableManager(_db, _db.customTemplates);
}
