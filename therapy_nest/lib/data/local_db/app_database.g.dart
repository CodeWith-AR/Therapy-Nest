// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalExerciseItemsTable extends LocalExerciseItems
    with TableInfo<$LocalExerciseItemsTable, LocalExerciseItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalExerciseItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseTypeCodeMeta = const VerificationMeta(
    'exerciseTypeCode',
  );
  @override
  late final GeneratedColumn<String> exerciseTypeCode = GeneratedColumn<String>(
    'exercise_type_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discriminationMeta = const VerificationMeta(
    'discrimination',
  );
  @override
  late final GeneratedColumn<double> discrimination = GeneratedColumn<double>(
    'discrimination',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
    'locale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _stimulusJsonMeta = const VerificationMeta(
    'stimulusJson',
  );
  @override
  late final GeneratedColumn<String> stimulusJson = GeneratedColumn<String>(
    'stimulus_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acceptedAnswersJsonMeta =
      const VerificationMeta('acceptedAnswersJson');
  @override
  late final GeneratedColumn<String> acceptedAnswersJson =
      GeneratedColumn<String>(
        'accepted_answers_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _mediaUrlMeta = const VerificationMeta(
    'mediaUrl',
  );
  @override
  late final GeneratedColumn<String> mediaUrl = GeneratedColumn<String>(
    'media_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cuesJsonMeta = const VerificationMeta(
    'cuesJson',
  );
  @override
  late final GeneratedColumn<String> cuesJson = GeneratedColumn<String>(
    'cues_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    domain,
    exerciseTypeCode,
    difficulty,
    discrimination,
    locale,
    stimulusJson,
    acceptedAnswersJson,
    mediaUrl,
    cuesJson,
    isActive,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_exercise_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalExerciseItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('exercise_type_code')) {
      context.handle(
        _exerciseTypeCodeMeta,
        exerciseTypeCode.isAcceptableOrUnknown(
          data['exercise_type_code']!,
          _exerciseTypeCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseTypeCodeMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('discrimination')) {
      context.handle(
        _discriminationMeta,
        discrimination.isAcceptableOrUnknown(
          data['discrimination']!,
          _discriminationMeta,
        ),
      );
    }
    if (data.containsKey('locale')) {
      context.handle(
        _localeMeta,
        locale.isAcceptableOrUnknown(data['locale']!, _localeMeta),
      );
    }
    if (data.containsKey('stimulus_json')) {
      context.handle(
        _stimulusJsonMeta,
        stimulusJson.isAcceptableOrUnknown(
          data['stimulus_json']!,
          _stimulusJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stimulusJsonMeta);
    }
    if (data.containsKey('accepted_answers_json')) {
      context.handle(
        _acceptedAnswersJsonMeta,
        acceptedAnswersJson.isAcceptableOrUnknown(
          data['accepted_answers_json']!,
          _acceptedAnswersJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_acceptedAnswersJsonMeta);
    }
    if (data.containsKey('media_url')) {
      context.handle(
        _mediaUrlMeta,
        mediaUrl.isAcceptableOrUnknown(data['media_url']!, _mediaUrlMeta),
      );
    }
    if (data.containsKey('cues_json')) {
      context.handle(
        _cuesJsonMeta,
        cuesJson.isAcceptableOrUnknown(data['cues_json']!, _cuesJsonMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalExerciseItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalExerciseItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      exerciseTypeCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_type_code'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
      discrimination: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discrimination'],
      )!,
      locale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locale'],
      )!,
      stimulusJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stimulus_json'],
      )!,
      acceptedAnswersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accepted_answers_json'],
      )!,
      mediaUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_url'],
      ),
      cuesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cues_json'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $LocalExerciseItemsTable createAlias(String alias) {
    return $LocalExerciseItemsTable(attachedDatabase, alias);
  }
}

class LocalExerciseItem extends DataClass
    implements Insertable<LocalExerciseItem> {
  final String id;
  final String domain;
  final String exerciseTypeCode;
  final double difficulty;
  final double discrimination;
  final String locale;
  final String stimulusJson;
  final String acceptedAnswersJson;
  final String? mediaUrl;
  final String cuesJson;
  final bool isActive;
  final DateTime cachedAt;
  const LocalExerciseItem({
    required this.id,
    required this.domain,
    required this.exerciseTypeCode,
    required this.difficulty,
    required this.discrimination,
    required this.locale,
    required this.stimulusJson,
    required this.acceptedAnswersJson,
    this.mediaUrl,
    required this.cuesJson,
    required this.isActive,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['domain'] = Variable<String>(domain);
    map['exercise_type_code'] = Variable<String>(exerciseTypeCode);
    map['difficulty'] = Variable<double>(difficulty);
    map['discrimination'] = Variable<double>(discrimination);
    map['locale'] = Variable<String>(locale);
    map['stimulus_json'] = Variable<String>(stimulusJson);
    map['accepted_answers_json'] = Variable<String>(acceptedAnswersJson);
    if (!nullToAbsent || mediaUrl != null) {
      map['media_url'] = Variable<String>(mediaUrl);
    }
    map['cues_json'] = Variable<String>(cuesJson);
    map['is_active'] = Variable<bool>(isActive);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  LocalExerciseItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalExerciseItemsCompanion(
      id: Value(id),
      domain: Value(domain),
      exerciseTypeCode: Value(exerciseTypeCode),
      difficulty: Value(difficulty),
      discrimination: Value(discrimination),
      locale: Value(locale),
      stimulusJson: Value(stimulusJson),
      acceptedAnswersJson: Value(acceptedAnswersJson),
      mediaUrl: mediaUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaUrl),
      cuesJson: Value(cuesJson),
      isActive: Value(isActive),
      cachedAt: Value(cachedAt),
    );
  }

  factory LocalExerciseItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalExerciseItem(
      id: serializer.fromJson<String>(json['id']),
      domain: serializer.fromJson<String>(json['domain']),
      exerciseTypeCode: serializer.fromJson<String>(json['exerciseTypeCode']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      discrimination: serializer.fromJson<double>(json['discrimination']),
      locale: serializer.fromJson<String>(json['locale']),
      stimulusJson: serializer.fromJson<String>(json['stimulusJson']),
      acceptedAnswersJson: serializer.fromJson<String>(
        json['acceptedAnswersJson'],
      ),
      mediaUrl: serializer.fromJson<String?>(json['mediaUrl']),
      cuesJson: serializer.fromJson<String>(json['cuesJson']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'domain': serializer.toJson<String>(domain),
      'exerciseTypeCode': serializer.toJson<String>(exerciseTypeCode),
      'difficulty': serializer.toJson<double>(difficulty),
      'discrimination': serializer.toJson<double>(discrimination),
      'locale': serializer.toJson<String>(locale),
      'stimulusJson': serializer.toJson<String>(stimulusJson),
      'acceptedAnswersJson': serializer.toJson<String>(acceptedAnswersJson),
      'mediaUrl': serializer.toJson<String?>(mediaUrl),
      'cuesJson': serializer.toJson<String>(cuesJson),
      'isActive': serializer.toJson<bool>(isActive),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  LocalExerciseItem copyWith({
    String? id,
    String? domain,
    String? exerciseTypeCode,
    double? difficulty,
    double? discrimination,
    String? locale,
    String? stimulusJson,
    String? acceptedAnswersJson,
    Value<String?> mediaUrl = const Value.absent(),
    String? cuesJson,
    bool? isActive,
    DateTime? cachedAt,
  }) => LocalExerciseItem(
    id: id ?? this.id,
    domain: domain ?? this.domain,
    exerciseTypeCode: exerciseTypeCode ?? this.exerciseTypeCode,
    difficulty: difficulty ?? this.difficulty,
    discrimination: discrimination ?? this.discrimination,
    locale: locale ?? this.locale,
    stimulusJson: stimulusJson ?? this.stimulusJson,
    acceptedAnswersJson: acceptedAnswersJson ?? this.acceptedAnswersJson,
    mediaUrl: mediaUrl.present ? mediaUrl.value : this.mediaUrl,
    cuesJson: cuesJson ?? this.cuesJson,
    isActive: isActive ?? this.isActive,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  LocalExerciseItem copyWithCompanion(LocalExerciseItemsCompanion data) {
    return LocalExerciseItem(
      id: data.id.present ? data.id.value : this.id,
      domain: data.domain.present ? data.domain.value : this.domain,
      exerciseTypeCode: data.exerciseTypeCode.present
          ? data.exerciseTypeCode.value
          : this.exerciseTypeCode,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      discrimination: data.discrimination.present
          ? data.discrimination.value
          : this.discrimination,
      locale: data.locale.present ? data.locale.value : this.locale,
      stimulusJson: data.stimulusJson.present
          ? data.stimulusJson.value
          : this.stimulusJson,
      acceptedAnswersJson: data.acceptedAnswersJson.present
          ? data.acceptedAnswersJson.value
          : this.acceptedAnswersJson,
      mediaUrl: data.mediaUrl.present ? data.mediaUrl.value : this.mediaUrl,
      cuesJson: data.cuesJson.present ? data.cuesJson.value : this.cuesJson,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalExerciseItem(')
          ..write('id: $id, ')
          ..write('domain: $domain, ')
          ..write('exerciseTypeCode: $exerciseTypeCode, ')
          ..write('difficulty: $difficulty, ')
          ..write('discrimination: $discrimination, ')
          ..write('locale: $locale, ')
          ..write('stimulusJson: $stimulusJson, ')
          ..write('acceptedAnswersJson: $acceptedAnswersJson, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('cuesJson: $cuesJson, ')
          ..write('isActive: $isActive, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    domain,
    exerciseTypeCode,
    difficulty,
    discrimination,
    locale,
    stimulusJson,
    acceptedAnswersJson,
    mediaUrl,
    cuesJson,
    isActive,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalExerciseItem &&
          other.id == this.id &&
          other.domain == this.domain &&
          other.exerciseTypeCode == this.exerciseTypeCode &&
          other.difficulty == this.difficulty &&
          other.discrimination == this.discrimination &&
          other.locale == this.locale &&
          other.stimulusJson == this.stimulusJson &&
          other.acceptedAnswersJson == this.acceptedAnswersJson &&
          other.mediaUrl == this.mediaUrl &&
          other.cuesJson == this.cuesJson &&
          other.isActive == this.isActive &&
          other.cachedAt == this.cachedAt);
}

class LocalExerciseItemsCompanion extends UpdateCompanion<LocalExerciseItem> {
  final Value<String> id;
  final Value<String> domain;
  final Value<String> exerciseTypeCode;
  final Value<double> difficulty;
  final Value<double> discrimination;
  final Value<String> locale;
  final Value<String> stimulusJson;
  final Value<String> acceptedAnswersJson;
  final Value<String?> mediaUrl;
  final Value<String> cuesJson;
  final Value<bool> isActive;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const LocalExerciseItemsCompanion({
    this.id = const Value.absent(),
    this.domain = const Value.absent(),
    this.exerciseTypeCode = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.discrimination = const Value.absent(),
    this.locale = const Value.absent(),
    this.stimulusJson = const Value.absent(),
    this.acceptedAnswersJson = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.cuesJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalExerciseItemsCompanion.insert({
    required String id,
    required String domain,
    required String exerciseTypeCode,
    required double difficulty,
    this.discrimination = const Value.absent(),
    this.locale = const Value.absent(),
    required String stimulusJson,
    required String acceptedAnswersJson,
    this.mediaUrl = const Value.absent(),
    this.cuesJson = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       domain = Value(domain),
       exerciseTypeCode = Value(exerciseTypeCode),
       difficulty = Value(difficulty),
       stimulusJson = Value(stimulusJson),
       acceptedAnswersJson = Value(acceptedAnswersJson),
       cachedAt = Value(cachedAt);
  static Insertable<LocalExerciseItem> custom({
    Expression<String>? id,
    Expression<String>? domain,
    Expression<String>? exerciseTypeCode,
    Expression<double>? difficulty,
    Expression<double>? discrimination,
    Expression<String>? locale,
    Expression<String>? stimulusJson,
    Expression<String>? acceptedAnswersJson,
    Expression<String>? mediaUrl,
    Expression<String>? cuesJson,
    Expression<bool>? isActive,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (domain != null) 'domain': domain,
      if (exerciseTypeCode != null) 'exercise_type_code': exerciseTypeCode,
      if (difficulty != null) 'difficulty': difficulty,
      if (discrimination != null) 'discrimination': discrimination,
      if (locale != null) 'locale': locale,
      if (stimulusJson != null) 'stimulus_json': stimulusJson,
      if (acceptedAnswersJson != null)
        'accepted_answers_json': acceptedAnswersJson,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (cuesJson != null) 'cues_json': cuesJson,
      if (isActive != null) 'is_active': isActive,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalExerciseItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? domain,
    Value<String>? exerciseTypeCode,
    Value<double>? difficulty,
    Value<double>? discrimination,
    Value<String>? locale,
    Value<String>? stimulusJson,
    Value<String>? acceptedAnswersJson,
    Value<String?>? mediaUrl,
    Value<String>? cuesJson,
    Value<bool>? isActive,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return LocalExerciseItemsCompanion(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      exerciseTypeCode: exerciseTypeCode ?? this.exerciseTypeCode,
      difficulty: difficulty ?? this.difficulty,
      discrimination: discrimination ?? this.discrimination,
      locale: locale ?? this.locale,
      stimulusJson: stimulusJson ?? this.stimulusJson,
      acceptedAnswersJson: acceptedAnswersJson ?? this.acceptedAnswersJson,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      cuesJson: cuesJson ?? this.cuesJson,
      isActive: isActive ?? this.isActive,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (exerciseTypeCode.present) {
      map['exercise_type_code'] = Variable<String>(exerciseTypeCode.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (discrimination.present) {
      map['discrimination'] = Variable<double>(discrimination.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (stimulusJson.present) {
      map['stimulus_json'] = Variable<String>(stimulusJson.value);
    }
    if (acceptedAnswersJson.present) {
      map['accepted_answers_json'] = Variable<String>(
        acceptedAnswersJson.value,
      );
    }
    if (mediaUrl.present) {
      map['media_url'] = Variable<String>(mediaUrl.value);
    }
    if (cuesJson.present) {
      map['cues_json'] = Variable<String>(cuesJson.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalExerciseItemsCompanion(')
          ..write('id: $id, ')
          ..write('domain: $domain, ')
          ..write('exerciseTypeCode: $exerciseTypeCode, ')
          ..write('difficulty: $difficulty, ')
          ..write('discrimination: $discrimination, ')
          ..write('locale: $locale, ')
          ..write('stimulusJson: $stimulusJson, ')
          ..write('acceptedAnswersJson: $acceptedAnswersJson, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('cuesJson: $cuesJson, ')
          ..write('isActive: $isActive, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAttemptsTable extends LocalAttempts
    with TableInfo<$LocalAttemptsTable, LocalAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseItemIdMeta = const VerificationMeta(
    'exerciseItemId',
  );
  @override
  late final GeneratedColumn<String> exerciseItemId = GeneratedColumn<String>(
    'exercise_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseJsonMeta = const VerificationMeta(
    'responseJson',
  );
  @override
  late final GeneratedColumn<String> responseJson = GeneratedColumn<String>(
    'response_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _partialScoreMeta = const VerificationMeta(
    'partialScore',
  );
  @override
  late final GeneratedColumn<double> partialScore = GeneratedColumn<double>(
    'partial_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseTimeMsMeta = const VerificationMeta(
    'responseTimeMs',
  );
  @override
  late final GeneratedColumn<int> responseTimeMs = GeneratedColumn<int>(
    'response_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hintCountMeta = const VerificationMeta(
    'hintCount',
  );
  @override
  late final GeneratedColumn<int> hintCount = GeneratedColumn<int>(
    'hint_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thetaBeforeMeta = const VerificationMeta(
    'thetaBefore',
  );
  @override
  late final GeneratedColumn<double> thetaBefore = GeneratedColumn<double>(
    'theta_before',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thetaAfterMeta = const VerificationMeta(
    'thetaAfter',
  );
  @override
  late final GeneratedColumn<double> thetaAfter = GeneratedColumn<double>(
    'theta_after',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    exerciseItemId,
    domain,
    responseJson,
    isCorrect,
    partialScore,
    responseTimeMs,
    hintCount,
    thetaBefore,
    thetaAfter,
    createdAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_item_id')) {
      context.handle(
        _exerciseItemIdMeta,
        exerciseItemId.isAcceptableOrUnknown(
          data['exercise_item_id']!,
          _exerciseItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseItemIdMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('response_json')) {
      context.handle(
        _responseJsonMeta,
        responseJson.isAcceptableOrUnknown(
          data['response_json']!,
          _responseJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseJsonMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('partial_score')) {
      context.handle(
        _partialScoreMeta,
        partialScore.isAcceptableOrUnknown(
          data['partial_score']!,
          _partialScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partialScoreMeta);
    }
    if (data.containsKey('response_time_ms')) {
      context.handle(
        _responseTimeMsMeta,
        responseTimeMs.isAcceptableOrUnknown(
          data['response_time_ms']!,
          _responseTimeMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseTimeMsMeta);
    }
    if (data.containsKey('hint_count')) {
      context.handle(
        _hintCountMeta,
        hintCount.isAcceptableOrUnknown(data['hint_count']!, _hintCountMeta),
      );
    } else if (isInserting) {
      context.missing(_hintCountMeta);
    }
    if (data.containsKey('theta_before')) {
      context.handle(
        _thetaBeforeMeta,
        thetaBefore.isAcceptableOrUnknown(
          data['theta_before']!,
          _thetaBeforeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_thetaBeforeMeta);
    }
    if (data.containsKey('theta_after')) {
      context.handle(
        _thetaAfterMeta,
        thetaAfter.isAcceptableOrUnknown(data['theta_after']!, _thetaAfterMeta),
      );
    } else if (isInserting) {
      context.missing(_thetaAfterMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAttempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_item_id'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      responseJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_json'],
      )!,
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      partialScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}partial_score'],
      )!,
      responseTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}response_time_ms'],
      )!,
      hintCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hint_count'],
      )!,
      thetaBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}theta_before'],
      )!,
      thetaAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}theta_after'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $LocalAttemptsTable createAlias(String alias) {
    return $LocalAttemptsTable(attachedDatabase, alias);
  }
}

class LocalAttempt extends DataClass implements Insertable<LocalAttempt> {
  final String id;
  final String sessionId;
  final String exerciseItemId;
  final String domain;
  final String responseJson;
  final bool isCorrect;
  final double partialScore;
  final int responseTimeMs;
  final int hintCount;
  final double thetaBefore;
  final double thetaAfter;
  final DateTime createdAt;
  final bool isSynced;
  const LocalAttempt({
    required this.id,
    required this.sessionId,
    required this.exerciseItemId,
    required this.domain,
    required this.responseJson,
    required this.isCorrect,
    required this.partialScore,
    required this.responseTimeMs,
    required this.hintCount,
    required this.thetaBefore,
    required this.thetaAfter,
    required this.createdAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['exercise_item_id'] = Variable<String>(exerciseItemId);
    map['domain'] = Variable<String>(domain);
    map['response_json'] = Variable<String>(responseJson);
    map['is_correct'] = Variable<bool>(isCorrect);
    map['partial_score'] = Variable<double>(partialScore);
    map['response_time_ms'] = Variable<int>(responseTimeMs);
    map['hint_count'] = Variable<int>(hintCount);
    map['theta_before'] = Variable<double>(thetaBefore);
    map['theta_after'] = Variable<double>(thetaAfter);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LocalAttemptsCompanion toCompanion(bool nullToAbsent) {
    return LocalAttemptsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseItemId: Value(exerciseItemId),
      domain: Value(domain),
      responseJson: Value(responseJson),
      isCorrect: Value(isCorrect),
      partialScore: Value(partialScore),
      responseTimeMs: Value(responseTimeMs),
      hintCount: Value(hintCount),
      thetaBefore: Value(thetaBefore),
      thetaAfter: Value(thetaAfter),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
    );
  }

  factory LocalAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAttempt(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      exerciseItemId: serializer.fromJson<String>(json['exerciseItemId']),
      domain: serializer.fromJson<String>(json['domain']),
      responseJson: serializer.fromJson<String>(json['responseJson']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      partialScore: serializer.fromJson<double>(json['partialScore']),
      responseTimeMs: serializer.fromJson<int>(json['responseTimeMs']),
      hintCount: serializer.fromJson<int>(json['hintCount']),
      thetaBefore: serializer.fromJson<double>(json['thetaBefore']),
      thetaAfter: serializer.fromJson<double>(json['thetaAfter']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'exerciseItemId': serializer.toJson<String>(exerciseItemId),
      'domain': serializer.toJson<String>(domain),
      'responseJson': serializer.toJson<String>(responseJson),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'partialScore': serializer.toJson<double>(partialScore),
      'responseTimeMs': serializer.toJson<int>(responseTimeMs),
      'hintCount': serializer.toJson<int>(hintCount),
      'thetaBefore': serializer.toJson<double>(thetaBefore),
      'thetaAfter': serializer.toJson<double>(thetaAfter),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LocalAttempt copyWith({
    String? id,
    String? sessionId,
    String? exerciseItemId,
    String? domain,
    String? responseJson,
    bool? isCorrect,
    double? partialScore,
    int? responseTimeMs,
    int? hintCount,
    double? thetaBefore,
    double? thetaAfter,
    DateTime? createdAt,
    bool? isSynced,
  }) => LocalAttempt(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseItemId: exerciseItemId ?? this.exerciseItemId,
    domain: domain ?? this.domain,
    responseJson: responseJson ?? this.responseJson,
    isCorrect: isCorrect ?? this.isCorrect,
    partialScore: partialScore ?? this.partialScore,
    responseTimeMs: responseTimeMs ?? this.responseTimeMs,
    hintCount: hintCount ?? this.hintCount,
    thetaBefore: thetaBefore ?? this.thetaBefore,
    thetaAfter: thetaAfter ?? this.thetaAfter,
    createdAt: createdAt ?? this.createdAt,
    isSynced: isSynced ?? this.isSynced,
  );
  LocalAttempt copyWithCompanion(LocalAttemptsCompanion data) {
    return LocalAttempt(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseItemId: data.exerciseItemId.present
          ? data.exerciseItemId.value
          : this.exerciseItemId,
      domain: data.domain.present ? data.domain.value : this.domain,
      responseJson: data.responseJson.present
          ? data.responseJson.value
          : this.responseJson,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      partialScore: data.partialScore.present
          ? data.partialScore.value
          : this.partialScore,
      responseTimeMs: data.responseTimeMs.present
          ? data.responseTimeMs.value
          : this.responseTimeMs,
      hintCount: data.hintCount.present ? data.hintCount.value : this.hintCount,
      thetaBefore: data.thetaBefore.present
          ? data.thetaBefore.value
          : this.thetaBefore,
      thetaAfter: data.thetaAfter.present
          ? data.thetaAfter.value
          : this.thetaAfter,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttempt(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseItemId: $exerciseItemId, ')
          ..write('domain: $domain, ')
          ..write('responseJson: $responseJson, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('partialScore: $partialScore, ')
          ..write('responseTimeMs: $responseTimeMs, ')
          ..write('hintCount: $hintCount, ')
          ..write('thetaBefore: $thetaBefore, ')
          ..write('thetaAfter: $thetaAfter, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    exerciseItemId,
    domain,
    responseJson,
    isCorrect,
    partialScore,
    responseTimeMs,
    hintCount,
    thetaBefore,
    thetaAfter,
    createdAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAttempt &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseItemId == this.exerciseItemId &&
          other.domain == this.domain &&
          other.responseJson == this.responseJson &&
          other.isCorrect == this.isCorrect &&
          other.partialScore == this.partialScore &&
          other.responseTimeMs == this.responseTimeMs &&
          other.hintCount == this.hintCount &&
          other.thetaBefore == this.thetaBefore &&
          other.thetaAfter == this.thetaAfter &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced);
}

class LocalAttemptsCompanion extends UpdateCompanion<LocalAttempt> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> exerciseItemId;
  final Value<String> domain;
  final Value<String> responseJson;
  final Value<bool> isCorrect;
  final Value<double> partialScore;
  final Value<int> responseTimeMs;
  final Value<int> hintCount;
  final Value<double> thetaBefore;
  final Value<double> thetaAfter;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const LocalAttemptsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseItemId = const Value.absent(),
    this.domain = const Value.absent(),
    this.responseJson = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.partialScore = const Value.absent(),
    this.responseTimeMs = const Value.absent(),
    this.hintCount = const Value.absent(),
    this.thetaBefore = const Value.absent(),
    this.thetaAfter = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAttemptsCompanion.insert({
    required String id,
    required String sessionId,
    required String exerciseItemId,
    required String domain,
    required String responseJson,
    required bool isCorrect,
    required double partialScore,
    required int responseTimeMs,
    required int hintCount,
    required double thetaBefore,
    required double thetaAfter,
    required DateTime createdAt,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       exerciseItemId = Value(exerciseItemId),
       domain = Value(domain),
       responseJson = Value(responseJson),
       isCorrect = Value(isCorrect),
       partialScore = Value(partialScore),
       responseTimeMs = Value(responseTimeMs),
       hintCount = Value(hintCount),
       thetaBefore = Value(thetaBefore),
       thetaAfter = Value(thetaAfter),
       createdAt = Value(createdAt);
  static Insertable<LocalAttempt> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? exerciseItemId,
    Expression<String>? domain,
    Expression<String>? responseJson,
    Expression<bool>? isCorrect,
    Expression<double>? partialScore,
    Expression<int>? responseTimeMs,
    Expression<int>? hintCount,
    Expression<double>? thetaBefore,
    Expression<double>? thetaAfter,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseItemId != null) 'exercise_item_id': exerciseItemId,
      if (domain != null) 'domain': domain,
      if (responseJson != null) 'response_json': responseJson,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (partialScore != null) 'partial_score': partialScore,
      if (responseTimeMs != null) 'response_time_ms': responseTimeMs,
      if (hintCount != null) 'hint_count': hintCount,
      if (thetaBefore != null) 'theta_before': thetaBefore,
      if (thetaAfter != null) 'theta_after': thetaAfter,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAttemptsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? exerciseItemId,
    Value<String>? domain,
    Value<String>? responseJson,
    Value<bool>? isCorrect,
    Value<double>? partialScore,
    Value<int>? responseTimeMs,
    Value<int>? hintCount,
    Value<double>? thetaBefore,
    Value<double>? thetaAfter,
    Value<DateTime>? createdAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return LocalAttemptsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseItemId: exerciseItemId ?? this.exerciseItemId,
      domain: domain ?? this.domain,
      responseJson: responseJson ?? this.responseJson,
      isCorrect: isCorrect ?? this.isCorrect,
      partialScore: partialScore ?? this.partialScore,
      responseTimeMs: responseTimeMs ?? this.responseTimeMs,
      hintCount: hintCount ?? this.hintCount,
      thetaBefore: thetaBefore ?? this.thetaBefore,
      thetaAfter: thetaAfter ?? this.thetaAfter,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (exerciseItemId.present) {
      map['exercise_item_id'] = Variable<String>(exerciseItemId.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (responseJson.present) {
      map['response_json'] = Variable<String>(responseJson.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (partialScore.present) {
      map['partial_score'] = Variable<double>(partialScore.value);
    }
    if (responseTimeMs.present) {
      map['response_time_ms'] = Variable<int>(responseTimeMs.value);
    }
    if (hintCount.present) {
      map['hint_count'] = Variable<int>(hintCount.value);
    }
    if (thetaBefore.present) {
      map['theta_before'] = Variable<double>(thetaBefore.value);
    }
    if (thetaAfter.present) {
      map['theta_after'] = Variable<double>(thetaAfter.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseItemId: $exerciseItemId, ')
          ..write('domain: $domain, ')
          ..write('responseJson: $responseJson, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('partialScore: $partialScore, ')
          ..write('responseTimeMs: $responseTimeMs, ')
          ..write('hintCount: $hintCount, ')
          ..write('thetaBefore: $thetaBefore, ')
          ..write('thetaAfter: $thetaAfter, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAbilityEstimatesTable extends LocalAbilityEstimates
    with TableInfo<$LocalAbilityEstimatesTable, LocalAbilityEstimate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAbilityEstimatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  @override
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thetaMeta = const VerificationMeta('theta');
  @override
  late final GeneratedColumn<double> theta = GeneratedColumn<double>(
    'theta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _standardErrorMeta = const VerificationMeta(
    'standardError',
  );
  @override
  late final GeneratedColumn<double> standardError = GeneratedColumn<double>(
    'standard_error',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    domain,
    theta,
    standardError,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_ability_estimates';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAbilityEstimate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('theta')) {
      context.handle(
        _thetaMeta,
        theta.isAcceptableOrUnknown(data['theta']!, _thetaMeta),
      );
    } else if (isInserting) {
      context.missing(_thetaMeta);
    }
    if (data.containsKey('standard_error')) {
      context.handle(
        _standardErrorMeta,
        standardError.isAcceptableOrUnknown(
          data['standard_error']!,
          _standardErrorMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {domain};
  @override
  LocalAbilityEstimate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAbilityEstimate(
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      theta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}theta'],
      )!,
      standardError: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}standard_error'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalAbilityEstimatesTable createAlias(String alias) {
    return $LocalAbilityEstimatesTable(attachedDatabase, alias);
  }
}

class LocalAbilityEstimate extends DataClass
    implements Insertable<LocalAbilityEstimate> {
  final String domain;
  final double theta;
  final double standardError;
  final DateTime updatedAt;
  const LocalAbilityEstimate({
    required this.domain,
    required this.theta,
    required this.standardError,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['domain'] = Variable<String>(domain);
    map['theta'] = Variable<double>(theta);
    map['standard_error'] = Variable<double>(standardError);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalAbilityEstimatesCompanion toCompanion(bool nullToAbsent) {
    return LocalAbilityEstimatesCompanion(
      domain: Value(domain),
      theta: Value(theta),
      standardError: Value(standardError),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalAbilityEstimate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAbilityEstimate(
      domain: serializer.fromJson<String>(json['domain']),
      theta: serializer.fromJson<double>(json['theta']),
      standardError: serializer.fromJson<double>(json['standardError']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'domain': serializer.toJson<String>(domain),
      'theta': serializer.toJson<double>(theta),
      'standardError': serializer.toJson<double>(standardError),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalAbilityEstimate copyWith({
    String? domain,
    double? theta,
    double? standardError,
    DateTime? updatedAt,
  }) => LocalAbilityEstimate(
    domain: domain ?? this.domain,
    theta: theta ?? this.theta,
    standardError: standardError ?? this.standardError,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalAbilityEstimate copyWithCompanion(LocalAbilityEstimatesCompanion data) {
    return LocalAbilityEstimate(
      domain: data.domain.present ? data.domain.value : this.domain,
      theta: data.theta.present ? data.theta.value : this.theta,
      standardError: data.standardError.present
          ? data.standardError.value
          : this.standardError,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAbilityEstimate(')
          ..write('domain: $domain, ')
          ..write('theta: $theta, ')
          ..write('standardError: $standardError, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(domain, theta, standardError, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAbilityEstimate &&
          other.domain == this.domain &&
          other.theta == this.theta &&
          other.standardError == this.standardError &&
          other.updatedAt == this.updatedAt);
}

class LocalAbilityEstimatesCompanion
    extends UpdateCompanion<LocalAbilityEstimate> {
  final Value<String> domain;
  final Value<double> theta;
  final Value<double> standardError;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalAbilityEstimatesCompanion({
    this.domain = const Value.absent(),
    this.theta = const Value.absent(),
    this.standardError = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAbilityEstimatesCompanion.insert({
    required String domain,
    required double theta,
    this.standardError = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : domain = Value(domain),
       theta = Value(theta),
       updatedAt = Value(updatedAt);
  static Insertable<LocalAbilityEstimate> custom({
    Expression<String>? domain,
    Expression<double>? theta,
    Expression<double>? standardError,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (domain != null) 'domain': domain,
      if (theta != null) 'theta': theta,
      if (standardError != null) 'standard_error': standardError,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAbilityEstimatesCompanion copyWith({
    Value<String>? domain,
    Value<double>? theta,
    Value<double>? standardError,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalAbilityEstimatesCompanion(
      domain: domain ?? this.domain,
      theta: theta ?? this.theta,
      standardError: standardError ?? this.standardError,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (theta.present) {
      map['theta'] = Variable<double>(theta.value);
    }
    if (standardError.present) {
      map['standard_error'] = Variable<double>(standardError.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAbilityEstimatesCompanion(')
          ..write('domain: $domain, ')
          ..write('theta: $theta, ')
          ..write('standardError: $standardError, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSessionsTable extends LocalSessions
    with TableInfo<$LocalSessionsTable, LocalSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patientIdMeta = const VerificationMeta(
    'patientId',
  );
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
    'patient_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetDomainsJsonMeta = const VerificationMeta(
    'targetDomainsJson',
  );
  @override
  late final GeneratedColumn<String> targetDomainsJson =
      GeneratedColumn<String>(
        'target_domains_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _targetItemCountMeta = const VerificationMeta(
    'targetItemCount',
  );
  @override
  late final GeneratedColumn<int> targetItemCount = GeneratedColumn<int>(
    'target_item_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    patientId,
    startedAt,
    endedAt,
    targetDomainsJson,
    targetItemCount,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(
        _patientIdMeta,
        patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('target_domains_json')) {
      context.handle(
        _targetDomainsJsonMeta,
        targetDomainsJson.isAcceptableOrUnknown(
          data['target_domains_json']!,
          _targetDomainsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetDomainsJsonMeta);
    }
    if (data.containsKey('target_item_count')) {
      context.handle(
        _targetItemCountMeta,
        targetItemCount.isAcceptableOrUnknown(
          data['target_item_count']!,
          _targetItemCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetItemCountMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      patientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}patient_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      targetDomainsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_domains_json'],
      )!,
      targetItemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_item_count'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $LocalSessionsTable createAlias(String alias) {
    return $LocalSessionsTable(attachedDatabase, alias);
  }
}

class LocalSession extends DataClass implements Insertable<LocalSession> {
  final String id;
  final String patientId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String targetDomainsJson;
  final int targetItemCount;
  final bool isSynced;
  const LocalSession({
    required this.id,
    required this.patientId,
    required this.startedAt,
    this.endedAt,
    required this.targetDomainsJson,
    required this.targetItemCount,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['target_domains_json'] = Variable<String>(targetDomainsJson);
    map['target_item_count'] = Variable<int>(targetItemCount);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LocalSessionsCompanion toCompanion(bool nullToAbsent) {
    return LocalSessionsCompanion(
      id: Value(id),
      patientId: Value(patientId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      targetDomainsJson: Value(targetDomainsJson),
      targetItemCount: Value(targetItemCount),
      isSynced: Value(isSynced),
    );
  }

  factory LocalSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSession(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      targetDomainsJson: serializer.fromJson<String>(json['targetDomainsJson']),
      targetItemCount: serializer.fromJson<int>(json['targetItemCount']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'targetDomainsJson': serializer.toJson<String>(targetDomainsJson),
      'targetItemCount': serializer.toJson<int>(targetItemCount),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LocalSession copyWith({
    String? id,
    String? patientId,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    String? targetDomainsJson,
    int? targetItemCount,
    bool? isSynced,
  }) => LocalSession(
    id: id ?? this.id,
    patientId: patientId ?? this.patientId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    targetDomainsJson: targetDomainsJson ?? this.targetDomainsJson,
    targetItemCount: targetItemCount ?? this.targetItemCount,
    isSynced: isSynced ?? this.isSynced,
  );
  LocalSession copyWithCompanion(LocalSessionsCompanion data) {
    return LocalSession(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      targetDomainsJson: data.targetDomainsJson.present
          ? data.targetDomainsJson.value
          : this.targetDomainsJson,
      targetItemCount: data.targetItemCount.present
          ? data.targetItemCount.value
          : this.targetItemCount,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSession(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('targetDomainsJson: $targetDomainsJson, ')
          ..write('targetItemCount: $targetItemCount, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    patientId,
    startedAt,
    endedAt,
    targetDomainsJson,
    targetItemCount,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSession &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.targetDomainsJson == this.targetDomainsJson &&
          other.targetItemCount == this.targetItemCount &&
          other.isSynced == this.isSynced);
}

class LocalSessionsCompanion extends UpdateCompanion<LocalSession> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String> targetDomainsJson;
  final Value<int> targetItemCount;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const LocalSessionsCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.targetDomainsJson = const Value.absent(),
    this.targetItemCount = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSessionsCompanion.insert({
    required String id,
    required String patientId,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required String targetDomainsJson,
    required int targetItemCount,
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       patientId = Value(patientId),
       startedAt = Value(startedAt),
       targetDomainsJson = Value(targetDomainsJson),
       targetItemCount = Value(targetItemCount);
  static Insertable<LocalSession> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? targetDomainsJson,
    Expression<int>? targetItemCount,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (targetDomainsJson != null) 'target_domains_json': targetDomainsJson,
      if (targetItemCount != null) 'target_item_count': targetItemCount,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? patientId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String>? targetDomainsJson,
    Value<int>? targetItemCount,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return LocalSessionsCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      targetDomainsJson: targetDomainsJson ?? this.targetDomainsJson,
      targetItemCount: targetItemCount ?? this.targetItemCount,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (targetDomainsJson.present) {
      map['target_domains_json'] = Variable<String>(targetDomainsJson.value);
    }
    if (targetItemCount.present) {
      map['target_item_count'] = Variable<int>(targetItemCount.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSessionsCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('targetDomainsJson: $targetDomainsJson, ')
          ..write('targetItemCount: $targetItemCount, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAchievementsTable extends LocalAchievements
    with TableInfo<$LocalAchievementsTable, LocalAchievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAchievementsTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconCodePointMeta = const VerificationMeta(
    'iconCodePoint',
  );
  @override
  late final GeneratedColumn<int> iconCodePoint = GeneratedColumn<int>(
    'icon_code_point',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isUnlockedMeta = const VerificationMeta(
    'isUnlocked',
  );
  @override
  late final GeneratedColumn<bool> isUnlocked = GeneratedColumn<bool>(
    'is_unlocked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_unlocked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    iconCodePoint,
    category,
    isUnlocked,
    unlockedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAchievement> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('icon_code_point')) {
      context.handle(
        _iconCodePointMeta,
        iconCodePoint.isAcceptableOrUnknown(
          data['icon_code_point']!,
          _iconCodePointMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_iconCodePointMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('is_unlocked')) {
      context.handle(
        _isUnlockedMeta,
        isUnlocked.isAcceptableOrUnknown(data['is_unlocked']!, _isUnlockedMeta),
      );
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAchievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAchievement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      iconCodePoint: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon_code_point'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      isUnlocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_unlocked'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      ),
    );
  }

  @override
  $LocalAchievementsTable createAlias(String alias) {
    return $LocalAchievementsTable(attachedDatabase, alias);
  }
}

class LocalAchievement extends DataClass
    implements Insertable<LocalAchievement> {
  final String id;
  final String name;
  final String description;
  final int iconCodePoint;
  final String category;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  const LocalAchievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconCodePoint,
    required this.category,
    required this.isUnlocked,
    this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['icon_code_point'] = Variable<int>(iconCodePoint);
    map['category'] = Variable<String>(category);
    map['is_unlocked'] = Variable<bool>(isUnlocked);
    if (!nullToAbsent || unlockedAt != null) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    }
    return map;
  }

  LocalAchievementsCompanion toCompanion(bool nullToAbsent) {
    return LocalAchievementsCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      iconCodePoint: Value(iconCodePoint),
      category: Value(category),
      isUnlocked: Value(isUnlocked),
      unlockedAt: unlockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(unlockedAt),
    );
  }

  factory LocalAchievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAchievement(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      iconCodePoint: serializer.fromJson<int>(json['iconCodePoint']),
      category: serializer.fromJson<String>(json['category']),
      isUnlocked: serializer.fromJson<bool>(json['isUnlocked']),
      unlockedAt: serializer.fromJson<DateTime?>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'iconCodePoint': serializer.toJson<int>(iconCodePoint),
      'category': serializer.toJson<String>(category),
      'isUnlocked': serializer.toJson<bool>(isUnlocked),
      'unlockedAt': serializer.toJson<DateTime?>(unlockedAt),
    };
  }

  LocalAchievement copyWith({
    String? id,
    String? name,
    String? description,
    int? iconCodePoint,
    String? category,
    bool? isUnlocked,
    Value<DateTime?> unlockedAt = const Value.absent(),
  }) => LocalAchievement(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    category: category ?? this.category,
    isUnlocked: isUnlocked ?? this.isUnlocked,
    unlockedAt: unlockedAt.present ? unlockedAt.value : this.unlockedAt,
  );
  LocalAchievement copyWithCompanion(LocalAchievementsCompanion data) {
    return LocalAchievement(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      iconCodePoint: data.iconCodePoint.present
          ? data.iconCodePoint.value
          : this.iconCodePoint,
      category: data.category.present ? data.category.value : this.category,
      isUnlocked: data.isUnlocked.present
          ? data.isUnlocked.value
          : this.isUnlocked,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAchievement(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('category: $category, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    iconCodePoint,
    category,
    isUnlocked,
    unlockedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAchievement &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.iconCodePoint == this.iconCodePoint &&
          other.category == this.category &&
          other.isUnlocked == this.isUnlocked &&
          other.unlockedAt == this.unlockedAt);
}

class LocalAchievementsCompanion extends UpdateCompanion<LocalAchievement> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<int> iconCodePoint;
  final Value<String> category;
  final Value<bool> isUnlocked;
  final Value<DateTime?> unlockedAt;
  final Value<int> rowid;
  const LocalAchievementsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.iconCodePoint = const Value.absent(),
    this.category = const Value.absent(),
    this.isUnlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAchievementsCompanion.insert({
    required String id,
    required String name,
    required String description,
    required int iconCodePoint,
    required String category,
    this.isUnlocked = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       description = Value(description),
       iconCodePoint = Value(iconCodePoint),
       category = Value(category);
  static Insertable<LocalAchievement> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? iconCodePoint,
    Expression<String>? category,
    Expression<bool>? isUnlocked,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (iconCodePoint != null) 'icon_code_point': iconCodePoint,
      if (category != null) 'category': category,
      if (isUnlocked != null) 'is_unlocked': isUnlocked,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAchievementsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<int>? iconCodePoint,
    Value<String>? category,
    Value<bool>? isUnlocked,
    Value<DateTime?>? unlockedAt,
    Value<int>? rowid,
  }) {
    return LocalAchievementsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      category: category ?? this.category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (iconCodePoint.present) {
      map['icon_code_point'] = Variable<int>(iconCodePoint.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isUnlocked.present) {
      map['is_unlocked'] = Variable<bool>(isUnlocked.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAchievementsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('iconCodePoint: $iconCodePoint, ')
          ..write('category: $category, ')
          ..write('isUnlocked: $isUnlocked, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalExerciseItemsTable localExerciseItems =
      $LocalExerciseItemsTable(this);
  late final $LocalAttemptsTable localAttempts = $LocalAttemptsTable(this);
  late final $LocalAbilityEstimatesTable localAbilityEstimates =
      $LocalAbilityEstimatesTable(this);
  late final $LocalSessionsTable localSessions = $LocalSessionsTable(this);
  late final $LocalAchievementsTable localAchievements =
      $LocalAchievementsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localExerciseItems,
    localAttempts,
    localAbilityEstimates,
    localSessions,
    localAchievements,
  ];
}

typedef $$LocalExerciseItemsTableCreateCompanionBuilder =
    LocalExerciseItemsCompanion Function({
      required String id,
      required String domain,
      required String exerciseTypeCode,
      required double difficulty,
      Value<double> discrimination,
      Value<String> locale,
      required String stimulusJson,
      required String acceptedAnswersJson,
      Value<String?> mediaUrl,
      Value<String> cuesJson,
      Value<bool> isActive,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$LocalExerciseItemsTableUpdateCompanionBuilder =
    LocalExerciseItemsCompanion Function({
      Value<String> id,
      Value<String> domain,
      Value<String> exerciseTypeCode,
      Value<double> difficulty,
      Value<double> discrimination,
      Value<String> locale,
      Value<String> stimulusJson,
      Value<String> acceptedAnswersJson,
      Value<String?> mediaUrl,
      Value<String> cuesJson,
      Value<bool> isActive,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$LocalExerciseItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalExerciseItemsTable> {
  $$LocalExerciseItemsTableFilterComposer({
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

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseTypeCode => $composableBuilder(
    column: $table.exerciseTypeCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discrimination => $composableBuilder(
    column: $table.discrimination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stimulusJson => $composableBuilder(
    column: $table.stimulusJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get acceptedAnswersJson => $composableBuilder(
    column: $table.acceptedAnswersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaUrl => $composableBuilder(
    column: $table.mediaUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cuesJson => $composableBuilder(
    column: $table.cuesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalExerciseItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalExerciseItemsTable> {
  $$LocalExerciseItemsTableOrderingComposer({
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

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseTypeCode => $composableBuilder(
    column: $table.exerciseTypeCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discrimination => $composableBuilder(
    column: $table.discrimination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locale => $composableBuilder(
    column: $table.locale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stimulusJson => $composableBuilder(
    column: $table.stimulusJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get acceptedAnswersJson => $composableBuilder(
    column: $table.acceptedAnswersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaUrl => $composableBuilder(
    column: $table.mediaUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cuesJson => $composableBuilder(
    column: $table.cuesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalExerciseItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalExerciseItemsTable> {
  $$LocalExerciseItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get exerciseTypeCode => $composableBuilder(
    column: $table.exerciseTypeCode,
    builder: (column) => column,
  );

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discrimination => $composableBuilder(
    column: $table.discrimination,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get stimulusJson => $composableBuilder(
    column: $table.stimulusJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get acceptedAnswersJson => $composableBuilder(
    column: $table.acceptedAnswersJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaUrl =>
      $composableBuilder(column: $table.mediaUrl, builder: (column) => column);

  GeneratedColumn<String> get cuesJson =>
      $composableBuilder(column: $table.cuesJson, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$LocalExerciseItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalExerciseItemsTable,
          LocalExerciseItem,
          $$LocalExerciseItemsTableFilterComposer,
          $$LocalExerciseItemsTableOrderingComposer,
          $$LocalExerciseItemsTableAnnotationComposer,
          $$LocalExerciseItemsTableCreateCompanionBuilder,
          $$LocalExerciseItemsTableUpdateCompanionBuilder,
          (
            LocalExerciseItem,
            BaseReferences<
              _$AppDatabase,
              $LocalExerciseItemsTable,
              LocalExerciseItem
            >,
          ),
          LocalExerciseItem,
          PrefetchHooks Function()
        > {
  $$LocalExerciseItemsTableTableManager(
    _$AppDatabase db,
    $LocalExerciseItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalExerciseItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalExerciseItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalExerciseItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> exerciseTypeCode = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<double> discrimination = const Value.absent(),
                Value<String> locale = const Value.absent(),
                Value<String> stimulusJson = const Value.absent(),
                Value<String> acceptedAnswersJson = const Value.absent(),
                Value<String?> mediaUrl = const Value.absent(),
                Value<String> cuesJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalExerciseItemsCompanion(
                id: id,
                domain: domain,
                exerciseTypeCode: exerciseTypeCode,
                difficulty: difficulty,
                discrimination: discrimination,
                locale: locale,
                stimulusJson: stimulusJson,
                acceptedAnswersJson: acceptedAnswersJson,
                mediaUrl: mediaUrl,
                cuesJson: cuesJson,
                isActive: isActive,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String domain,
                required String exerciseTypeCode,
                required double difficulty,
                Value<double> discrimination = const Value.absent(),
                Value<String> locale = const Value.absent(),
                required String stimulusJson,
                required String acceptedAnswersJson,
                Value<String?> mediaUrl = const Value.absent(),
                Value<String> cuesJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalExerciseItemsCompanion.insert(
                id: id,
                domain: domain,
                exerciseTypeCode: exerciseTypeCode,
                difficulty: difficulty,
                discrimination: discrimination,
                locale: locale,
                stimulusJson: stimulusJson,
                acceptedAnswersJson: acceptedAnswersJson,
                mediaUrl: mediaUrl,
                cuesJson: cuesJson,
                isActive: isActive,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalExerciseItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalExerciseItemsTable,
      LocalExerciseItem,
      $$LocalExerciseItemsTableFilterComposer,
      $$LocalExerciseItemsTableOrderingComposer,
      $$LocalExerciseItemsTableAnnotationComposer,
      $$LocalExerciseItemsTableCreateCompanionBuilder,
      $$LocalExerciseItemsTableUpdateCompanionBuilder,
      (
        LocalExerciseItem,
        BaseReferences<
          _$AppDatabase,
          $LocalExerciseItemsTable,
          LocalExerciseItem
        >,
      ),
      LocalExerciseItem,
      PrefetchHooks Function()
    >;
typedef $$LocalAttemptsTableCreateCompanionBuilder =
    LocalAttemptsCompanion Function({
      required String id,
      required String sessionId,
      required String exerciseItemId,
      required String domain,
      required String responseJson,
      required bool isCorrect,
      required double partialScore,
      required int responseTimeMs,
      required int hintCount,
      required double thetaBefore,
      required double thetaAfter,
      required DateTime createdAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$LocalAttemptsTableUpdateCompanionBuilder =
    LocalAttemptsCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> exerciseItemId,
      Value<String> domain,
      Value<String> responseJson,
      Value<bool> isCorrect,
      Value<double> partialScore,
      Value<int> responseTimeMs,
      Value<int> hintCount,
      Value<double> thetaBefore,
      Value<double> thetaAfter,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$LocalAttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAttemptsTable> {
  $$LocalAttemptsTableFilterComposer({
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

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseItemId => $composableBuilder(
    column: $table.exerciseItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get partialScore => $composableBuilder(
    column: $table.partialScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hintCount => $composableBuilder(
    column: $table.hintCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get thetaBefore => $composableBuilder(
    column: $table.thetaBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get thetaAfter => $composableBuilder(
    column: $table.thetaAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAttemptsTable> {
  $$LocalAttemptsTableOrderingComposer({
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

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseItemId => $composableBuilder(
    column: $table.exerciseItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get partialScore => $composableBuilder(
    column: $table.partialScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hintCount => $composableBuilder(
    column: $table.hintCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get thetaBefore => $composableBuilder(
    column: $table.thetaBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get thetaAfter => $composableBuilder(
    column: $table.thetaAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAttemptsTable> {
  $$LocalAttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get exerciseItemId => $composableBuilder(
    column: $table.exerciseItemId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get responseJson => $composableBuilder(
    column: $table.responseJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<double> get partialScore => $composableBuilder(
    column: $table.partialScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hintCount =>
      $composableBuilder(column: $table.hintCount, builder: (column) => column);

  GeneratedColumn<double> get thetaBefore => $composableBuilder(
    column: $table.thetaBefore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get thetaAfter => $composableBuilder(
    column: $table.thetaAfter,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$LocalAttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAttemptsTable,
          LocalAttempt,
          $$LocalAttemptsTableFilterComposer,
          $$LocalAttemptsTableOrderingComposer,
          $$LocalAttemptsTableAnnotationComposer,
          $$LocalAttemptsTableCreateCompanionBuilder,
          $$LocalAttemptsTableUpdateCompanionBuilder,
          (
            LocalAttempt,
            BaseReferences<_$AppDatabase, $LocalAttemptsTable, LocalAttempt>,
          ),
          LocalAttempt,
          PrefetchHooks Function()
        > {
  $$LocalAttemptsTableTableManager(_$AppDatabase db, $LocalAttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> exerciseItemId = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String> responseJson = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<double> partialScore = const Value.absent(),
                Value<int> responseTimeMs = const Value.absent(),
                Value<int> hintCount = const Value.absent(),
                Value<double> thetaBefore = const Value.absent(),
                Value<double> thetaAfter = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAttemptsCompanion(
                id: id,
                sessionId: sessionId,
                exerciseItemId: exerciseItemId,
                domain: domain,
                responseJson: responseJson,
                isCorrect: isCorrect,
                partialScore: partialScore,
                responseTimeMs: responseTimeMs,
                hintCount: hintCount,
                thetaBefore: thetaBefore,
                thetaAfter: thetaAfter,
                createdAt: createdAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String exerciseItemId,
                required String domain,
                required String responseJson,
                required bool isCorrect,
                required double partialScore,
                required int responseTimeMs,
                required int hintCount,
                required double thetaBefore,
                required double thetaAfter,
                required DateTime createdAt,
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAttemptsCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseItemId: exerciseItemId,
                domain: domain,
                responseJson: responseJson,
                isCorrect: isCorrect,
                partialScore: partialScore,
                responseTimeMs: responseTimeMs,
                hintCount: hintCount,
                thetaBefore: thetaBefore,
                thetaAfter: thetaAfter,
                createdAt: createdAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAttemptsTable,
      LocalAttempt,
      $$LocalAttemptsTableFilterComposer,
      $$LocalAttemptsTableOrderingComposer,
      $$LocalAttemptsTableAnnotationComposer,
      $$LocalAttemptsTableCreateCompanionBuilder,
      $$LocalAttemptsTableUpdateCompanionBuilder,
      (
        LocalAttempt,
        BaseReferences<_$AppDatabase, $LocalAttemptsTable, LocalAttempt>,
      ),
      LocalAttempt,
      PrefetchHooks Function()
    >;
typedef $$LocalAbilityEstimatesTableCreateCompanionBuilder =
    LocalAbilityEstimatesCompanion Function({
      required String domain,
      required double theta,
      Value<double> standardError,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalAbilityEstimatesTableUpdateCompanionBuilder =
    LocalAbilityEstimatesCompanion Function({
      Value<String> domain,
      Value<double> theta,
      Value<double> standardError,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalAbilityEstimatesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAbilityEstimatesTable> {
  $$LocalAbilityEstimatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get theta => $composableBuilder(
    column: $table.theta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get standardError => $composableBuilder(
    column: $table.standardError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAbilityEstimatesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAbilityEstimatesTable> {
  $$LocalAbilityEstimatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get theta => $composableBuilder(
    column: $table.theta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get standardError => $composableBuilder(
    column: $table.standardError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAbilityEstimatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAbilityEstimatesTable> {
  $$LocalAbilityEstimatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<double> get theta =>
      $composableBuilder(column: $table.theta, builder: (column) => column);

  GeneratedColumn<double> get standardError => $composableBuilder(
    column: $table.standardError,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalAbilityEstimatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAbilityEstimatesTable,
          LocalAbilityEstimate,
          $$LocalAbilityEstimatesTableFilterComposer,
          $$LocalAbilityEstimatesTableOrderingComposer,
          $$LocalAbilityEstimatesTableAnnotationComposer,
          $$LocalAbilityEstimatesTableCreateCompanionBuilder,
          $$LocalAbilityEstimatesTableUpdateCompanionBuilder,
          (
            LocalAbilityEstimate,
            BaseReferences<
              _$AppDatabase,
              $LocalAbilityEstimatesTable,
              LocalAbilityEstimate
            >,
          ),
          LocalAbilityEstimate,
          PrefetchHooks Function()
        > {
  $$LocalAbilityEstimatesTableTableManager(
    _$AppDatabase db,
    $LocalAbilityEstimatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAbilityEstimatesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalAbilityEstimatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalAbilityEstimatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> domain = const Value.absent(),
                Value<double> theta = const Value.absent(),
                Value<double> standardError = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAbilityEstimatesCompanion(
                domain: domain,
                theta: theta,
                standardError: standardError,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String domain,
                required double theta,
                Value<double> standardError = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalAbilityEstimatesCompanion.insert(
                domain: domain,
                theta: theta,
                standardError: standardError,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAbilityEstimatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAbilityEstimatesTable,
      LocalAbilityEstimate,
      $$LocalAbilityEstimatesTableFilterComposer,
      $$LocalAbilityEstimatesTableOrderingComposer,
      $$LocalAbilityEstimatesTableAnnotationComposer,
      $$LocalAbilityEstimatesTableCreateCompanionBuilder,
      $$LocalAbilityEstimatesTableUpdateCompanionBuilder,
      (
        LocalAbilityEstimate,
        BaseReferences<
          _$AppDatabase,
          $LocalAbilityEstimatesTable,
          LocalAbilityEstimate
        >,
      ),
      LocalAbilityEstimate,
      PrefetchHooks Function()
    >;
typedef $$LocalSessionsTableCreateCompanionBuilder =
    LocalSessionsCompanion Function({
      required String id,
      required String patientId,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      required String targetDomainsJson,
      required int targetItemCount,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$LocalSessionsTableUpdateCompanionBuilder =
    LocalSessionsCompanion Function({
      Value<String> id,
      Value<String> patientId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<String> targetDomainsJson,
      Value<int> targetItemCount,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$LocalSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSessionsTable> {
  $$LocalSessionsTableFilterComposer({
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

  ColumnFilters<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetDomainsJson => $composableBuilder(
    column: $table.targetDomainsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetItemCount => $composableBuilder(
    column: $table.targetItemCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSessionsTable> {
  $$LocalSessionsTableOrderingComposer({
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

  ColumnOrderings<String> get patientId => $composableBuilder(
    column: $table.patientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetDomainsJson => $composableBuilder(
    column: $table.targetDomainsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetItemCount => $composableBuilder(
    column: $table.targetItemCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSessionsTable> {
  $$LocalSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get targetDomainsJson => $composableBuilder(
    column: $table.targetDomainsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetItemCount => $composableBuilder(
    column: $table.targetItemCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$LocalSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSessionsTable,
          LocalSession,
          $$LocalSessionsTableFilterComposer,
          $$LocalSessionsTableOrderingComposer,
          $$LocalSessionsTableAnnotationComposer,
          $$LocalSessionsTableCreateCompanionBuilder,
          $$LocalSessionsTableUpdateCompanionBuilder,
          (
            LocalSession,
            BaseReferences<_$AppDatabase, $LocalSessionsTable, LocalSession>,
          ),
          LocalSession,
          PrefetchHooks Function()
        > {
  $$LocalSessionsTableTableManager(_$AppDatabase db, $LocalSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> patientId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> targetDomainsJson = const Value.absent(),
                Value<int> targetItemCount = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSessionsCompanion(
                id: id,
                patientId: patientId,
                startedAt: startedAt,
                endedAt: endedAt,
                targetDomainsJson: targetDomainsJson,
                targetItemCount: targetItemCount,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String patientId,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required String targetDomainsJson,
                required int targetItemCount,
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSessionsCompanion.insert(
                id: id,
                patientId: patientId,
                startedAt: startedAt,
                endedAt: endedAt,
                targetDomainsJson: targetDomainsJson,
                targetItemCount: targetItemCount,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSessionsTable,
      LocalSession,
      $$LocalSessionsTableFilterComposer,
      $$LocalSessionsTableOrderingComposer,
      $$LocalSessionsTableAnnotationComposer,
      $$LocalSessionsTableCreateCompanionBuilder,
      $$LocalSessionsTableUpdateCompanionBuilder,
      (
        LocalSession,
        BaseReferences<_$AppDatabase, $LocalSessionsTable, LocalSession>,
      ),
      LocalSession,
      PrefetchHooks Function()
    >;
typedef $$LocalAchievementsTableCreateCompanionBuilder =
    LocalAchievementsCompanion Function({
      required String id,
      required String name,
      required String description,
      required int iconCodePoint,
      required String category,
      Value<bool> isUnlocked,
      Value<DateTime?> unlockedAt,
      Value<int> rowid,
    });
typedef $$LocalAchievementsTableUpdateCompanionBuilder =
    LocalAchievementsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<int> iconCodePoint,
      Value<String> category,
      Value<bool> isUnlocked,
      Value<DateTime?> unlockedAt,
      Value<int> rowid,
    });

class $$LocalAchievementsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAchievementsTable> {
  $$LocalAchievementsTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAchievementsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAchievementsTable> {
  $$LocalAchievementsTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAchievementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAchievementsTable> {
  $$LocalAchievementsTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get iconCodePoint => $composableBuilder(
    column: $table.iconCodePoint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isUnlocked => $composableBuilder(
    column: $table.isUnlocked,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$LocalAchievementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAchievementsTable,
          LocalAchievement,
          $$LocalAchievementsTableFilterComposer,
          $$LocalAchievementsTableOrderingComposer,
          $$LocalAchievementsTableAnnotationComposer,
          $$LocalAchievementsTableCreateCompanionBuilder,
          $$LocalAchievementsTableUpdateCompanionBuilder,
          (
            LocalAchievement,
            BaseReferences<
              _$AppDatabase,
              $LocalAchievementsTable,
              LocalAchievement
            >,
          ),
          LocalAchievement,
          PrefetchHooks Function()
        > {
  $$LocalAchievementsTableTableManager(
    _$AppDatabase db,
    $LocalAchievementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAchievementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAchievementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAchievementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<int> iconCodePoint = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> isUnlocked = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAchievementsCompanion(
                id: id,
                name: name,
                description: description,
                iconCodePoint: iconCodePoint,
                category: category,
                isUnlocked: isUnlocked,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String description,
                required int iconCodePoint,
                required String category,
                Value<bool> isUnlocked = const Value.absent(),
                Value<DateTime?> unlockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAchievementsCompanion.insert(
                id: id,
                name: name,
                description: description,
                iconCodePoint: iconCodePoint,
                category: category,
                isUnlocked: isUnlocked,
                unlockedAt: unlockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAchievementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAchievementsTable,
      LocalAchievement,
      $$LocalAchievementsTableFilterComposer,
      $$LocalAchievementsTableOrderingComposer,
      $$LocalAchievementsTableAnnotationComposer,
      $$LocalAchievementsTableCreateCompanionBuilder,
      $$LocalAchievementsTableUpdateCompanionBuilder,
      (
        LocalAchievement,
        BaseReferences<
          _$AppDatabase,
          $LocalAchievementsTable,
          LocalAchievement
        >,
      ),
      LocalAchievement,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalExerciseItemsTableTableManager get localExerciseItems =>
      $$LocalExerciseItemsTableTableManager(_db, _db.localExerciseItems);
  $$LocalAttemptsTableTableManager get localAttempts =>
      $$LocalAttemptsTableTableManager(_db, _db.localAttempts);
  $$LocalAbilityEstimatesTableTableManager get localAbilityEstimates =>
      $$LocalAbilityEstimatesTableTableManager(_db, _db.localAbilityEstimates);
  $$LocalSessionsTableTableManager get localSessions =>
      $$LocalSessionsTableTableManager(_db, _db.localSessions);
  $$LocalAchievementsTableTableManager get localAchievements =>
      $$LocalAchievementsTableTableManager(_db, _db.localAchievements);
}
