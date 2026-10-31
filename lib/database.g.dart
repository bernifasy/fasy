// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $EntriesTable extends Entries with TableInfo<$EntriesTable, EntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wohlbefindenMeta = const VerificationMeta(
    'wohlbefinden',
  );
  @override
  late final GeneratedColumn<int> wohlbefinden = GeneratedColumn<int>(
    'wohlbefinden',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schlafStundenMeta = const VerificationMeta(
    'schlafStunden',
  );
  @override
  late final GeneratedColumn<double> schlafStunden = GeneratedColumn<double>(
    'schlaf_stunden',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elvanseMgMeta = const VerificationMeta(
    'elvanseMg',
  );
  @override
  late final GeneratedColumn<int> elvanseMg = GeneratedColumn<int>(
    'elvanse_mg',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _elvanseZeitMeta = const VerificationMeta(
    'elvanseZeit',
  );
  @override
  late final GeneratedColumn<String> elvanseZeit = GeneratedColumn<String>(
    'elvanse_zeit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _innereUnruheMeta = const VerificationMeta(
    'innereUnruhe',
  );
  @override
  late final GeneratedColumn<double> innereUnruhe = GeneratedColumn<double>(
    'innere_unruhe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _medikinetMgMeta = const VerificationMeta(
    'medikinetMg',
  );
  @override
  late final GeneratedColumn<int> medikinetMg = GeneratedColumn<int>(
    'medikinet_mg',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _medikinetZeitMeta = const VerificationMeta(
    'medikinetZeit',
  );
  @override
  late final GeneratedColumn<String> medikinetZeit = GeneratedColumn<String>(
    'medikinet_zeit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _medikinetMagenMeta = const VerificationMeta(
    'medikinetMagen',
  );
  @override
  late final GeneratedColumn<String> medikinetMagen = GeneratedColumn<String>(
    'medikinet_magen',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _medikinetEssenAbstandMeta =
      const VerificationMeta('medikinetEssenAbstand');
  @override
  late final GeneratedColumn<String> medikinetEssenAbstand =
      GeneratedColumn<String>(
        'medikinet_essen_abstand',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _migraeneIntensitaetMeta =
      const VerificationMeta('migraeneIntensitaet');
  @override
  late final GeneratedColumn<int> migraeneIntensitaet = GeneratedColumn<int>(
    'migraene_intensitaet',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _migraeneStartMeta = const VerificationMeta(
    'migraeneStart',
  );
  @override
  late final GeneratedColumn<String> migraeneStart = GeneratedColumn<String>(
    'migraene_start',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _migraeneEndeMeta = const VerificationMeta(
    'migraeneEnde',
  );
  @override
  late final GeneratedColumn<String> migraeneEnde = GeneratedColumn<String>(
    'migraene_ende',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ausloeserMeta = const VerificationMeta(
    'ausloeser',
  );
  @override
  late final GeneratedColumn<String> ausloeser = GeneratedColumn<String>(
    'ausloeser',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _begleitsymptomeMeta = const VerificationMeta(
    'begleitsymptome',
  );
  @override
  late final GeneratedColumn<String> begleitsymptome = GeneratedColumn<String>(
    'begleitsymptome',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notizenMeta = const VerificationMeta(
    'notizen',
  );
  @override
  late final GeneratedColumn<String> notizen = GeneratedColumn<String>(
    'notizen',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _migraeneTagMeta = const VerificationMeta(
    'migraeneTag',
  );
  @override
  late final GeneratedColumn<String> migraeneTag = GeneratedColumn<String>(
    'migraene_tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('nein'),
  );
  static const VerificationMeta _customValuesMeta = const VerificationMeta(
    'customValues',
  );
  @override
  late final GeneratedColumn<String> customValues = GeneratedColumn<String>(
    'custom_values',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    wohlbefinden,
    schlafStunden,
    elvanseMg,
    elvanseZeit,
    innereUnruhe,
    medikinetMg,
    medikinetZeit,
    medikinetMagen,
    medikinetEssenAbstand,
    migraeneIntensitaet,
    migraeneStart,
    migraeneEnde,
    ausloeser,
    begleitsymptome,
    notizen,
    migraeneTag,
    customValues,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('wohlbefinden')) {
      context.handle(
        _wohlbefindenMeta,
        wohlbefinden.isAcceptableOrUnknown(
          data['wohlbefinden']!,
          _wohlbefindenMeta,
        ),
      );
    }
    if (data.containsKey('schlaf_stunden')) {
      context.handle(
        _schlafStundenMeta,
        schlafStunden.isAcceptableOrUnknown(
          data['schlaf_stunden']!,
          _schlafStundenMeta,
        ),
      );
    }
    if (data.containsKey('elvanse_mg')) {
      context.handle(
        _elvanseMgMeta,
        elvanseMg.isAcceptableOrUnknown(data['elvanse_mg']!, _elvanseMgMeta),
      );
    }
    if (data.containsKey('elvanse_zeit')) {
      context.handle(
        _elvanseZeitMeta,
        elvanseZeit.isAcceptableOrUnknown(
          data['elvanse_zeit']!,
          _elvanseZeitMeta,
        ),
      );
    }
    if (data.containsKey('innere_unruhe')) {
      context.handle(
        _innereUnruheMeta,
        innereUnruhe.isAcceptableOrUnknown(
          data['innere_unruhe']!,
          _innereUnruheMeta,
        ),
      );
    }
    if (data.containsKey('medikinet_mg')) {
      context.handle(
        _medikinetMgMeta,
        medikinetMg.isAcceptableOrUnknown(
          data['medikinet_mg']!,
          _medikinetMgMeta,
        ),
      );
    }
    if (data.containsKey('medikinet_zeit')) {
      context.handle(
        _medikinetZeitMeta,
        medikinetZeit.isAcceptableOrUnknown(
          data['medikinet_zeit']!,
          _medikinetZeitMeta,
        ),
      );
    }
    if (data.containsKey('medikinet_magen')) {
      context.handle(
        _medikinetMagenMeta,
        medikinetMagen.isAcceptableOrUnknown(
          data['medikinet_magen']!,
          _medikinetMagenMeta,
        ),
      );
    }
    if (data.containsKey('medikinet_essen_abstand')) {
      context.handle(
        _medikinetEssenAbstandMeta,
        medikinetEssenAbstand.isAcceptableOrUnknown(
          data['medikinet_essen_abstand']!,
          _medikinetEssenAbstandMeta,
        ),
      );
    }
    if (data.containsKey('migraene_intensitaet')) {
      context.handle(
        _migraeneIntensitaetMeta,
        migraeneIntensitaet.isAcceptableOrUnknown(
          data['migraene_intensitaet']!,
          _migraeneIntensitaetMeta,
        ),
      );
    }
    if (data.containsKey('migraene_start')) {
      context.handle(
        _migraeneStartMeta,
        migraeneStart.isAcceptableOrUnknown(
          data['migraene_start']!,
          _migraeneStartMeta,
        ),
      );
    }
    if (data.containsKey('migraene_ende')) {
      context.handle(
        _migraeneEndeMeta,
        migraeneEnde.isAcceptableOrUnknown(
          data['migraene_ende']!,
          _migraeneEndeMeta,
        ),
      );
    }
    if (data.containsKey('ausloeser')) {
      context.handle(
        _ausloeserMeta,
        ausloeser.isAcceptableOrUnknown(data['ausloeser']!, _ausloeserMeta),
      );
    }
    if (data.containsKey('begleitsymptome')) {
      context.handle(
        _begleitsymptomeMeta,
        begleitsymptome.isAcceptableOrUnknown(
          data['begleitsymptome']!,
          _begleitsymptomeMeta,
        ),
      );
    }
    if (data.containsKey('notizen')) {
      context.handle(
        _notizenMeta,
        notizen.isAcceptableOrUnknown(data['notizen']!, _notizenMeta),
      );
    }
    if (data.containsKey('migraene_tag')) {
      context.handle(
        _migraeneTagMeta,
        migraeneTag.isAcceptableOrUnknown(
          data['migraene_tag']!,
          _migraeneTagMeta,
        ),
      );
    }
    if (data.containsKey('custom_values')) {
      context.handle(
        _customValuesMeta,
        customValues.isAcceptableOrUnknown(
          data['custom_values']!,
          _customValuesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      wohlbefinden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wohlbefinden'],
      ),
      schlafStunden: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}schlaf_stunden'],
      ),
      elvanseMg: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elvanse_mg'],
      ),
      elvanseZeit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}elvanse_zeit'],
      ),
      innereUnruhe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}innere_unruhe'],
      ),
      medikinetMg: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medikinet_mg'],
      ),
      medikinetZeit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medikinet_zeit'],
      ),
      medikinetMagen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medikinet_magen'],
      ),
      medikinetEssenAbstand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medikinet_essen_abstand'],
      ),
      migraeneIntensitaet: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}migraene_intensitaet'],
      ),
      migraeneStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}migraene_start'],
      ),
      migraeneEnde: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}migraene_ende'],
      ),
      ausloeser: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ausloeser'],
      ),
      begleitsymptome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}begleitsymptome'],
      ),
      notizen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notizen'],
      ),
      migraeneTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}migraene_tag'],
      )!,
      customValues: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_values'],
      ),
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class EntryRow extends DataClass implements Insertable<EntryRow> {
  final int id;
  final String createdAt;
  final int? wohlbefinden;
  final double? schlafStunden;
  final int? elvanseMg;
  final String? elvanseZeit;
  final double? innereUnruhe;
  final int? medikinetMg;
  final String? medikinetZeit;
  final String? medikinetMagen;
  final String? medikinetEssenAbstand;
  final int? migraeneIntensitaet;
  final String? migraeneStart;
  final String? migraeneEnde;
  final String? ausloeser;
  final String? begleitsymptome;
  final String? notizen;
  final String migraeneTag;
  final String? customValues;
  const EntryRow({
    required this.id,
    required this.createdAt,
    this.wohlbefinden,
    this.schlafStunden,
    this.elvanseMg,
    this.elvanseZeit,
    this.innereUnruhe,
    this.medikinetMg,
    this.medikinetZeit,
    this.medikinetMagen,
    this.medikinetEssenAbstand,
    this.migraeneIntensitaet,
    this.migraeneStart,
    this.migraeneEnde,
    this.ausloeser,
    this.begleitsymptome,
    this.notizen,
    required this.migraeneTag,
    this.customValues,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || wohlbefinden != null) {
      map['wohlbefinden'] = Variable<int>(wohlbefinden);
    }
    if (!nullToAbsent || schlafStunden != null) {
      map['schlaf_stunden'] = Variable<double>(schlafStunden);
    }
    if (!nullToAbsent || elvanseMg != null) {
      map['elvanse_mg'] = Variable<int>(elvanseMg);
    }
    if (!nullToAbsent || elvanseZeit != null) {
      map['elvanse_zeit'] = Variable<String>(elvanseZeit);
    }
    if (!nullToAbsent || innereUnruhe != null) {
      map['innere_unruhe'] = Variable<double>(innereUnruhe);
    }
    if (!nullToAbsent || medikinetMg != null) {
      map['medikinet_mg'] = Variable<int>(medikinetMg);
    }
    if (!nullToAbsent || medikinetZeit != null) {
      map['medikinet_zeit'] = Variable<String>(medikinetZeit);
    }
    if (!nullToAbsent || medikinetMagen != null) {
      map['medikinet_magen'] = Variable<String>(medikinetMagen);
    }
    if (!nullToAbsent || medikinetEssenAbstand != null) {
      map['medikinet_essen_abstand'] = Variable<String>(medikinetEssenAbstand);
    }
    if (!nullToAbsent || migraeneIntensitaet != null) {
      map['migraene_intensitaet'] = Variable<int>(migraeneIntensitaet);
    }
    if (!nullToAbsent || migraeneStart != null) {
      map['migraene_start'] = Variable<String>(migraeneStart);
    }
    if (!nullToAbsent || migraeneEnde != null) {
      map['migraene_ende'] = Variable<String>(migraeneEnde);
    }
    if (!nullToAbsent || ausloeser != null) {
      map['ausloeser'] = Variable<String>(ausloeser);
    }
    if (!nullToAbsent || begleitsymptome != null) {
      map['begleitsymptome'] = Variable<String>(begleitsymptome);
    }
    if (!nullToAbsent || notizen != null) {
      map['notizen'] = Variable<String>(notizen);
    }
    map['migraene_tag'] = Variable<String>(migraeneTag);
    if (!nullToAbsent || customValues != null) {
      map['custom_values'] = Variable<String>(customValues);
    }
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      wohlbefinden: wohlbefinden == null && nullToAbsent
          ? const Value.absent()
          : Value(wohlbefinden),
      schlafStunden: schlafStunden == null && nullToAbsent
          ? const Value.absent()
          : Value(schlafStunden),
      elvanseMg: elvanseMg == null && nullToAbsent
          ? const Value.absent()
          : Value(elvanseMg),
      elvanseZeit: elvanseZeit == null && nullToAbsent
          ? const Value.absent()
          : Value(elvanseZeit),
      innereUnruhe: innereUnruhe == null && nullToAbsent
          ? const Value.absent()
          : Value(innereUnruhe),
      medikinetMg: medikinetMg == null && nullToAbsent
          ? const Value.absent()
          : Value(medikinetMg),
      medikinetZeit: medikinetZeit == null && nullToAbsent
          ? const Value.absent()
          : Value(medikinetZeit),
      medikinetMagen: medikinetMagen == null && nullToAbsent
          ? const Value.absent()
          : Value(medikinetMagen),
      medikinetEssenAbstand: medikinetEssenAbstand == null && nullToAbsent
          ? const Value.absent()
          : Value(medikinetEssenAbstand),
      migraeneIntensitaet: migraeneIntensitaet == null && nullToAbsent
          ? const Value.absent()
          : Value(migraeneIntensitaet),
      migraeneStart: migraeneStart == null && nullToAbsent
          ? const Value.absent()
          : Value(migraeneStart),
      migraeneEnde: migraeneEnde == null && nullToAbsent
          ? const Value.absent()
          : Value(migraeneEnde),
      ausloeser: ausloeser == null && nullToAbsent
          ? const Value.absent()
          : Value(ausloeser),
      begleitsymptome: begleitsymptome == null && nullToAbsent
          ? const Value.absent()
          : Value(begleitsymptome),
      notizen: notizen == null && nullToAbsent
          ? const Value.absent()
          : Value(notizen),
      migraeneTag: Value(migraeneTag),
      customValues: customValues == null && nullToAbsent
          ? const Value.absent()
          : Value(customValues),
    );
  }

  factory EntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      wohlbefinden: serializer.fromJson<int?>(json['wohlbefinden']),
      schlafStunden: serializer.fromJson<double?>(json['schlafStunden']),
      elvanseMg: serializer.fromJson<int?>(json['elvanseMg']),
      elvanseZeit: serializer.fromJson<String?>(json['elvanseZeit']),
      innereUnruhe: serializer.fromJson<double?>(json['innereUnruhe']),
      medikinetMg: serializer.fromJson<int?>(json['medikinetMg']),
      medikinetZeit: serializer.fromJson<String?>(json['medikinetZeit']),
      medikinetMagen: serializer.fromJson<String?>(json['medikinetMagen']),
      medikinetEssenAbstand: serializer.fromJson<String?>(
        json['medikinetEssenAbstand'],
      ),
      migraeneIntensitaet: serializer.fromJson<int?>(
        json['migraeneIntensitaet'],
      ),
      migraeneStart: serializer.fromJson<String?>(json['migraeneStart']),
      migraeneEnde: serializer.fromJson<String?>(json['migraeneEnde']),
      ausloeser: serializer.fromJson<String?>(json['ausloeser']),
      begleitsymptome: serializer.fromJson<String?>(json['begleitsymptome']),
      notizen: serializer.fromJson<String?>(json['notizen']),
      migraeneTag: serializer.fromJson<String>(json['migraeneTag']),
      customValues: serializer.fromJson<String?>(json['customValues']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'wohlbefinden': serializer.toJson<int?>(wohlbefinden),
      'schlafStunden': serializer.toJson<double?>(schlafStunden),
      'elvanseMg': serializer.toJson<int?>(elvanseMg),
      'elvanseZeit': serializer.toJson<String?>(elvanseZeit),
      'innereUnruhe': serializer.toJson<double?>(innereUnruhe),
      'medikinetMg': serializer.toJson<int?>(medikinetMg),
      'medikinetZeit': serializer.toJson<String?>(medikinetZeit),
      'medikinetMagen': serializer.toJson<String?>(medikinetMagen),
      'medikinetEssenAbstand': serializer.toJson<String?>(
        medikinetEssenAbstand,
      ),
      'migraeneIntensitaet': serializer.toJson<int?>(migraeneIntensitaet),
      'migraeneStart': serializer.toJson<String?>(migraeneStart),
      'migraeneEnde': serializer.toJson<String?>(migraeneEnde),
      'ausloeser': serializer.toJson<String?>(ausloeser),
      'begleitsymptome': serializer.toJson<String?>(begleitsymptome),
      'notizen': serializer.toJson<String?>(notizen),
      'migraeneTag': serializer.toJson<String>(migraeneTag),
      'customValues': serializer.toJson<String?>(customValues),
    };
  }

  EntryRow copyWith({
    int? id,
    String? createdAt,
    Value<int?> wohlbefinden = const Value.absent(),
    Value<double?> schlafStunden = const Value.absent(),
    Value<int?> elvanseMg = const Value.absent(),
    Value<String?> elvanseZeit = const Value.absent(),
    Value<double?> innereUnruhe = const Value.absent(),
    Value<int?> medikinetMg = const Value.absent(),
    Value<String?> medikinetZeit = const Value.absent(),
    Value<String?> medikinetMagen = const Value.absent(),
    Value<String?> medikinetEssenAbstand = const Value.absent(),
    Value<int?> migraeneIntensitaet = const Value.absent(),
    Value<String?> migraeneStart = const Value.absent(),
    Value<String?> migraeneEnde = const Value.absent(),
    Value<String?> ausloeser = const Value.absent(),
    Value<String?> begleitsymptome = const Value.absent(),
    Value<String?> notizen = const Value.absent(),
    String? migraeneTag,
    Value<String?> customValues = const Value.absent(),
  }) => EntryRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    wohlbefinden: wohlbefinden.present ? wohlbefinden.value : this.wohlbefinden,
    schlafStunden: schlafStunden.present
        ? schlafStunden.value
        : this.schlafStunden,
    elvanseMg: elvanseMg.present ? elvanseMg.value : this.elvanseMg,
    elvanseZeit: elvanseZeit.present ? elvanseZeit.value : this.elvanseZeit,
    innereUnruhe: innereUnruhe.present ? innereUnruhe.value : this.innereUnruhe,
    medikinetMg: medikinetMg.present ? medikinetMg.value : this.medikinetMg,
    medikinetZeit: medikinetZeit.present
        ? medikinetZeit.value
        : this.medikinetZeit,
    medikinetMagen: medikinetMagen.present
        ? medikinetMagen.value
        : this.medikinetMagen,
    medikinetEssenAbstand: medikinetEssenAbstand.present
        ? medikinetEssenAbstand.value
        : this.medikinetEssenAbstand,
    migraeneIntensitaet: migraeneIntensitaet.present
        ? migraeneIntensitaet.value
        : this.migraeneIntensitaet,
    migraeneStart: migraeneStart.present
        ? migraeneStart.value
        : this.migraeneStart,
    migraeneEnde: migraeneEnde.present ? migraeneEnde.value : this.migraeneEnde,
    ausloeser: ausloeser.present ? ausloeser.value : this.ausloeser,
    begleitsymptome: begleitsymptome.present
        ? begleitsymptome.value
        : this.begleitsymptome,
    notizen: notizen.present ? notizen.value : this.notizen,
    migraeneTag: migraeneTag ?? this.migraeneTag,
    customValues: customValues.present ? customValues.value : this.customValues,
  );
  EntryRow copyWithCompanion(EntriesCompanion data) {
    return EntryRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      wohlbefinden: data.wohlbefinden.present
          ? data.wohlbefinden.value
          : this.wohlbefinden,
      schlafStunden: data.schlafStunden.present
          ? data.schlafStunden.value
          : this.schlafStunden,
      elvanseMg: data.elvanseMg.present ? data.elvanseMg.value : this.elvanseMg,
      elvanseZeit: data.elvanseZeit.present
          ? data.elvanseZeit.value
          : this.elvanseZeit,
      innereUnruhe: data.innereUnruhe.present
          ? data.innereUnruhe.value
          : this.innereUnruhe,
      medikinetMg: data.medikinetMg.present
          ? data.medikinetMg.value
          : this.medikinetMg,
      medikinetZeit: data.medikinetZeit.present
          ? data.medikinetZeit.value
          : this.medikinetZeit,
      medikinetMagen: data.medikinetMagen.present
          ? data.medikinetMagen.value
          : this.medikinetMagen,
      medikinetEssenAbstand: data.medikinetEssenAbstand.present
          ? data.medikinetEssenAbstand.value
          : this.medikinetEssenAbstand,
      migraeneIntensitaet: data.migraeneIntensitaet.present
          ? data.migraeneIntensitaet.value
          : this.migraeneIntensitaet,
      migraeneStart: data.migraeneStart.present
          ? data.migraeneStart.value
          : this.migraeneStart,
      migraeneEnde: data.migraeneEnde.present
          ? data.migraeneEnde.value
          : this.migraeneEnde,
      ausloeser: data.ausloeser.present ? data.ausloeser.value : this.ausloeser,
      begleitsymptome: data.begleitsymptome.present
          ? data.begleitsymptome.value
          : this.begleitsymptome,
      notizen: data.notizen.present ? data.notizen.value : this.notizen,
      migraeneTag: data.migraeneTag.present
          ? data.migraeneTag.value
          : this.migraeneTag,
      customValues: data.customValues.present
          ? data.customValues.value
          : this.customValues,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('wohlbefinden: $wohlbefinden, ')
          ..write('schlafStunden: $schlafStunden, ')
          ..write('elvanseMg: $elvanseMg, ')
          ..write('elvanseZeit: $elvanseZeit, ')
          ..write('innereUnruhe: $innereUnruhe, ')
          ..write('medikinetMg: $medikinetMg, ')
          ..write('medikinetZeit: $medikinetZeit, ')
          ..write('medikinetMagen: $medikinetMagen, ')
          ..write('medikinetEssenAbstand: $medikinetEssenAbstand, ')
          ..write('migraeneIntensitaet: $migraeneIntensitaet, ')
          ..write('migraeneStart: $migraeneStart, ')
          ..write('migraeneEnde: $migraeneEnde, ')
          ..write('ausloeser: $ausloeser, ')
          ..write('begleitsymptome: $begleitsymptome, ')
          ..write('notizen: $notizen, ')
          ..write('migraeneTag: $migraeneTag, ')
          ..write('customValues: $customValues')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    wohlbefinden,
    schlafStunden,
    elvanseMg,
    elvanseZeit,
    innereUnruhe,
    medikinetMg,
    medikinetZeit,
    medikinetMagen,
    medikinetEssenAbstand,
    migraeneIntensitaet,
    migraeneStart,
    migraeneEnde,
    ausloeser,
    begleitsymptome,
    notizen,
    migraeneTag,
    customValues,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.wohlbefinden == this.wohlbefinden &&
          other.schlafStunden == this.schlafStunden &&
          other.elvanseMg == this.elvanseMg &&
          other.elvanseZeit == this.elvanseZeit &&
          other.innereUnruhe == this.innereUnruhe &&
          other.medikinetMg == this.medikinetMg &&
          other.medikinetZeit == this.medikinetZeit &&
          other.medikinetMagen == this.medikinetMagen &&
          other.medikinetEssenAbstand == this.medikinetEssenAbstand &&
          other.migraeneIntensitaet == this.migraeneIntensitaet &&
          other.migraeneStart == this.migraeneStart &&
          other.migraeneEnde == this.migraeneEnde &&
          other.ausloeser == this.ausloeser &&
          other.begleitsymptome == this.begleitsymptome &&
          other.notizen == this.notizen &&
          other.migraeneTag == this.migraeneTag &&
          other.customValues == this.customValues);
}

class EntriesCompanion extends UpdateCompanion<EntryRow> {
  final Value<int> id;
  final Value<String> createdAt;
  final Value<int?> wohlbefinden;
  final Value<double?> schlafStunden;
  final Value<int?> elvanseMg;
  final Value<String?> elvanseZeit;
  final Value<double?> innereUnruhe;
  final Value<int?> medikinetMg;
  final Value<String?> medikinetZeit;
  final Value<String?> medikinetMagen;
  final Value<String?> medikinetEssenAbstand;
  final Value<int?> migraeneIntensitaet;
  final Value<String?> migraeneStart;
  final Value<String?> migraeneEnde;
  final Value<String?> ausloeser;
  final Value<String?> begleitsymptome;
  final Value<String?> notizen;
  final Value<String> migraeneTag;
  final Value<String?> customValues;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.wohlbefinden = const Value.absent(),
    this.schlafStunden = const Value.absent(),
    this.elvanseMg = const Value.absent(),
    this.elvanseZeit = const Value.absent(),
    this.innereUnruhe = const Value.absent(),
    this.medikinetMg = const Value.absent(),
    this.medikinetZeit = const Value.absent(),
    this.medikinetMagen = const Value.absent(),
    this.medikinetEssenAbstand = const Value.absent(),
    this.migraeneIntensitaet = const Value.absent(),
    this.migraeneStart = const Value.absent(),
    this.migraeneEnde = const Value.absent(),
    this.ausloeser = const Value.absent(),
    this.begleitsymptome = const Value.absent(),
    this.notizen = const Value.absent(),
    this.migraeneTag = const Value.absent(),
    this.customValues = const Value.absent(),
  });
  EntriesCompanion.insert({
    this.id = const Value.absent(),
    required String createdAt,
    this.wohlbefinden = const Value.absent(),
    this.schlafStunden = const Value.absent(),
    this.elvanseMg = const Value.absent(),
    this.elvanseZeit = const Value.absent(),
    this.innereUnruhe = const Value.absent(),
    this.medikinetMg = const Value.absent(),
    this.medikinetZeit = const Value.absent(),
    this.medikinetMagen = const Value.absent(),
    this.medikinetEssenAbstand = const Value.absent(),
    this.migraeneIntensitaet = const Value.absent(),
    this.migraeneStart = const Value.absent(),
    this.migraeneEnde = const Value.absent(),
    this.ausloeser = const Value.absent(),
    this.begleitsymptome = const Value.absent(),
    this.notizen = const Value.absent(),
    this.migraeneTag = const Value.absent(),
    this.customValues = const Value.absent(),
  }) : createdAt = Value(createdAt);
  static Insertable<EntryRow> custom({
    Expression<int>? id,
    Expression<String>? createdAt,
    Expression<int>? wohlbefinden,
    Expression<double>? schlafStunden,
    Expression<int>? elvanseMg,
    Expression<String>? elvanseZeit,
    Expression<double>? innereUnruhe,
    Expression<int>? medikinetMg,
    Expression<String>? medikinetZeit,
    Expression<String>? medikinetMagen,
    Expression<String>? medikinetEssenAbstand,
    Expression<int>? migraeneIntensitaet,
    Expression<String>? migraeneStart,
    Expression<String>? migraeneEnde,
    Expression<String>? ausloeser,
    Expression<String>? begleitsymptome,
    Expression<String>? notizen,
    Expression<String>? migraeneTag,
    Expression<String>? customValues,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (wohlbefinden != null) 'wohlbefinden': wohlbefinden,
      if (schlafStunden != null) 'schlaf_stunden': schlafStunden,
      if (elvanseMg != null) 'elvanse_mg': elvanseMg,
      if (elvanseZeit != null) 'elvanse_zeit': elvanseZeit,
      if (innereUnruhe != null) 'innere_unruhe': innereUnruhe,
      if (medikinetMg != null) 'medikinet_mg': medikinetMg,
      if (medikinetZeit != null) 'medikinet_zeit': medikinetZeit,
      if (medikinetMagen != null) 'medikinet_magen': medikinetMagen,
      if (medikinetEssenAbstand != null)
        'medikinet_essen_abstand': medikinetEssenAbstand,
      if (migraeneIntensitaet != null)
        'migraene_intensitaet': migraeneIntensitaet,
      if (migraeneStart != null) 'migraene_start': migraeneStart,
      if (migraeneEnde != null) 'migraene_ende': migraeneEnde,
      if (ausloeser != null) 'ausloeser': ausloeser,
      if (begleitsymptome != null) 'begleitsymptome': begleitsymptome,
      if (notizen != null) 'notizen': notizen,
      if (migraeneTag != null) 'migraene_tag': migraeneTag,
      if (customValues != null) 'custom_values': customValues,
    });
  }

  EntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? createdAt,
    Value<int?>? wohlbefinden,
    Value<double?>? schlafStunden,
    Value<int?>? elvanseMg,
    Value<String?>? elvanseZeit,
    Value<double?>? innereUnruhe,
    Value<int?>? medikinetMg,
    Value<String?>? medikinetZeit,
    Value<String?>? medikinetMagen,
    Value<String?>? medikinetEssenAbstand,
    Value<int?>? migraeneIntensitaet,
    Value<String?>? migraeneStart,
    Value<String?>? migraeneEnde,
    Value<String?>? ausloeser,
    Value<String?>? begleitsymptome,
    Value<String?>? notizen,
    Value<String>? migraeneTag,
    Value<String?>? customValues,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      wohlbefinden: wohlbefinden ?? this.wohlbefinden,
      schlafStunden: schlafStunden ?? this.schlafStunden,
      elvanseMg: elvanseMg ?? this.elvanseMg,
      elvanseZeit: elvanseZeit ?? this.elvanseZeit,
      innereUnruhe: innereUnruhe ?? this.innereUnruhe,
      medikinetMg: medikinetMg ?? this.medikinetMg,
      medikinetZeit: medikinetZeit ?? this.medikinetZeit,
      medikinetMagen: medikinetMagen ?? this.medikinetMagen,
      medikinetEssenAbstand:
          medikinetEssenAbstand ?? this.medikinetEssenAbstand,
      migraeneIntensitaet: migraeneIntensitaet ?? this.migraeneIntensitaet,
      migraeneStart: migraeneStart ?? this.migraeneStart,
      migraeneEnde: migraeneEnde ?? this.migraeneEnde,
      ausloeser: ausloeser ?? this.ausloeser,
      begleitsymptome: begleitsymptome ?? this.begleitsymptome,
      notizen: notizen ?? this.notizen,
      migraeneTag: migraeneTag ?? this.migraeneTag,
      customValues: customValues ?? this.customValues,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (wohlbefinden.present) {
      map['wohlbefinden'] = Variable<int>(wohlbefinden.value);
    }
    if (schlafStunden.present) {
      map['schlaf_stunden'] = Variable<double>(schlafStunden.value);
    }
    if (elvanseMg.present) {
      map['elvanse_mg'] = Variable<int>(elvanseMg.value);
    }
    if (elvanseZeit.present) {
      map['elvanse_zeit'] = Variable<String>(elvanseZeit.value);
    }
    if (innereUnruhe.present) {
      map['innere_unruhe'] = Variable<double>(innereUnruhe.value);
    }
    if (medikinetMg.present) {
      map['medikinet_mg'] = Variable<int>(medikinetMg.value);
    }
    if (medikinetZeit.present) {
      map['medikinet_zeit'] = Variable<String>(medikinetZeit.value);
    }
    if (medikinetMagen.present) {
      map['medikinet_magen'] = Variable<String>(medikinetMagen.value);
    }
    if (medikinetEssenAbstand.present) {
      map['medikinet_essen_abstand'] = Variable<String>(
        medikinetEssenAbstand.value,
      );
    }
    if (migraeneIntensitaet.present) {
      map['migraene_intensitaet'] = Variable<int>(migraeneIntensitaet.value);
    }
    if (migraeneStart.present) {
      map['migraene_start'] = Variable<String>(migraeneStart.value);
    }
    if (migraeneEnde.present) {
      map['migraene_ende'] = Variable<String>(migraeneEnde.value);
    }
    if (ausloeser.present) {
      map['ausloeser'] = Variable<String>(ausloeser.value);
    }
    if (begleitsymptome.present) {
      map['begleitsymptome'] = Variable<String>(begleitsymptome.value);
    }
    if (notizen.present) {
      map['notizen'] = Variable<String>(notizen.value);
    }
    if (migraeneTag.present) {
      map['migraene_tag'] = Variable<String>(migraeneTag.value);
    }
    if (customValues.present) {
      map['custom_values'] = Variable<String>(customValues.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('wohlbefinden: $wohlbefinden, ')
          ..write('schlafStunden: $schlafStunden, ')
          ..write('elvanseMg: $elvanseMg, ')
          ..write('elvanseZeit: $elvanseZeit, ')
          ..write('innereUnruhe: $innereUnruhe, ')
          ..write('medikinetMg: $medikinetMg, ')
          ..write('medikinetZeit: $medikinetZeit, ')
          ..write('medikinetMagen: $medikinetMagen, ')
          ..write('medikinetEssenAbstand: $medikinetEssenAbstand, ')
          ..write('migraeneIntensitaet: $migraeneIntensitaet, ')
          ..write('migraeneStart: $migraeneStart, ')
          ..write('migraeneEnde: $migraeneEnde, ')
          ..write('ausloeser: $ausloeser, ')
          ..write('begleitsymptome: $begleitsymptome, ')
          ..write('notizen: $notizen, ')
          ..write('migraeneTag: $migraeneTag, ')
          ..write('customValues: $customValues')
          ..write(')'))
        .toString();
  }
}

class $FieldDefsTable extends FieldDefs
    with TableInfo<$FieldDefsTable, FieldDefRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FieldDefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grpMeta = const VerificationMeta('grp');
  @override
  late final GeneratedColumn<int> grp = GeneratedColumn<int>(
    'grp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configMeta = const VerificationMeta('config');
  @override
  late final GeneratedColumn<String> config = GeneratedColumn<String>(
    'config',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    grp,
    label,
    type,
    config,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'field_defs';
  @override
  VerificationContext validateIntegrity(
    Insertable<FieldDefRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('grp')) {
      context.handle(
        _grpMeta,
        grp.isAcceptableOrUnknown(data['grp']!, _grpMeta),
      );
    } else if (isInserting) {
      context.missing(_grpMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('config')) {
      context.handle(
        _configMeta,
        config.isAcceptableOrUnknown(data['config']!, _configMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FieldDefRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FieldDefRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      grp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grp'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      config: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      ),
    );
  }

  @override
  $FieldDefsTable createAlias(String alias) {
    return $FieldDefsTable(attachedDatabase, alias);
  }
}

class FieldDefRow extends DataClass implements Insertable<FieldDefRow> {
  final String id;
  final int grp;
  final String label;
  final String type;
  final String? config;
  final int? position;
  const FieldDefRow({
    required this.id,
    required this.grp,
    required this.label,
    required this.type,
    this.config,
    this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['grp'] = Variable<int>(grp);
    map['label'] = Variable<String>(label);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || config != null) {
      map['config'] = Variable<String>(config);
    }
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<int>(position);
    }
    return map;
  }

  FieldDefsCompanion toCompanion(bool nullToAbsent) {
    return FieldDefsCompanion(
      id: Value(id),
      grp: Value(grp),
      label: Value(label),
      type: Value(type),
      config: config == null && nullToAbsent
          ? const Value.absent()
          : Value(config),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
    );
  }

  factory FieldDefRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FieldDefRow(
      id: serializer.fromJson<String>(json['id']),
      grp: serializer.fromJson<int>(json['grp']),
      label: serializer.fromJson<String>(json['label']),
      type: serializer.fromJson<String>(json['type']),
      config: serializer.fromJson<String?>(json['config']),
      position: serializer.fromJson<int?>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'grp': serializer.toJson<int>(grp),
      'label': serializer.toJson<String>(label),
      'type': serializer.toJson<String>(type),
      'config': serializer.toJson<String?>(config),
      'position': serializer.toJson<int?>(position),
    };
  }

  FieldDefRow copyWith({
    String? id,
    int? grp,
    String? label,
    String? type,
    Value<String?> config = const Value.absent(),
    Value<int?> position = const Value.absent(),
  }) => FieldDefRow(
    id: id ?? this.id,
    grp: grp ?? this.grp,
    label: label ?? this.label,
    type: type ?? this.type,
    config: config.present ? config.value : this.config,
    position: position.present ? position.value : this.position,
  );
  FieldDefRow copyWithCompanion(FieldDefsCompanion data) {
    return FieldDefRow(
      id: data.id.present ? data.id.value : this.id,
      grp: data.grp.present ? data.grp.value : this.grp,
      label: data.label.present ? data.label.value : this.label,
      type: data.type.present ? data.type.value : this.type,
      config: data.config.present ? data.config.value : this.config,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FieldDefRow(')
          ..write('id: $id, ')
          ..write('grp: $grp, ')
          ..write('label: $label, ')
          ..write('type: $type, ')
          ..write('config: $config, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, grp, label, type, config, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FieldDefRow &&
          other.id == this.id &&
          other.grp == this.grp &&
          other.label == this.label &&
          other.type == this.type &&
          other.config == this.config &&
          other.position == this.position);
}

class FieldDefsCompanion extends UpdateCompanion<FieldDefRow> {
  final Value<String> id;
  final Value<int> grp;
  final Value<String> label;
  final Value<String> type;
  final Value<String?> config;
  final Value<int?> position;
  final Value<int> rowid;
  const FieldDefsCompanion({
    this.id = const Value.absent(),
    this.grp = const Value.absent(),
    this.label = const Value.absent(),
    this.type = const Value.absent(),
    this.config = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FieldDefsCompanion.insert({
    required String id,
    required int grp,
    required String label,
    required String type,
    this.config = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       grp = Value(grp),
       label = Value(label),
       type = Value(type);
  static Insertable<FieldDefRow> custom({
    Expression<String>? id,
    Expression<int>? grp,
    Expression<String>? label,
    Expression<String>? type,
    Expression<String>? config,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (grp != null) 'grp': grp,
      if (label != null) 'label': label,
      if (type != null) 'type': type,
      if (config != null) 'config': config,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FieldDefsCompanion copyWith({
    Value<String>? id,
    Value<int>? grp,
    Value<String>? label,
    Value<String>? type,
    Value<String?>? config,
    Value<int?>? position,
    Value<int>? rowid,
  }) {
    return FieldDefsCompanion(
      id: id ?? this.id,
      grp: grp ?? this.grp,
      label: label ?? this.label,
      type: type ?? this.type,
      config: config ?? this.config,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (grp.present) {
      map['grp'] = Variable<int>(grp.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (config.present) {
      map['config'] = Variable<String>(config.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FieldDefsCompanion(')
          ..write('id: $id, ')
          ..write('grp: $grp, ')
          ..write('label: $label, ')
          ..write('type: $type, ')
          ..write('config: $config, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MetaTable extends Meta with TableInfo<$MetaTable, MetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<MetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $MetaTable createAlias(String alias) {
    return $MetaTable(attachedDatabase, alias);
  }
}

class MetaRow extends DataClass implements Insertable<MetaRow> {
  final String key;
  final String? value;
  const MetaRow({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  MetaCompanion toCompanion(bool nullToAbsent) {
    return MetaCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory MetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  MetaRow copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => MetaRow(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  MetaRow copyWithCompanion(MetaCompanion data) {
    return MetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MetaRow && other.key == this.key && other.value == this.value);
}

class MetaCompanion extends UpdateCompanion<MetaRow> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const MetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MetaCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<MetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MetaCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return MetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GraphDefsTable extends GraphDefs
    with TableInfo<$GraphDefsTable, GraphDefRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GraphDefsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cfgMeta = const VerificationMeta('cfg');
  @override
  late final GeneratedColumn<String> cfg = GeneratedColumn<String>(
    'cfg',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, title, cfg, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'graph_defs';
  @override
  VerificationContext validateIntegrity(
    Insertable<GraphDefRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('cfg')) {
      context.handle(
        _cfgMeta,
        cfg.isAcceptableOrUnknown(data['cfg']!, _cfgMeta),
      );
    } else if (isInserting) {
      context.missing(_cfgMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GraphDefRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GraphDefRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      cfg: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cfg'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      ),
    );
  }

  @override
  $GraphDefsTable createAlias(String alias) {
    return $GraphDefsTable(attachedDatabase, alias);
  }
}

class GraphDefRow extends DataClass implements Insertable<GraphDefRow> {
  final String id;
  final String title;
  final String cfg;
  final int? position;
  const GraphDefRow({
    required this.id,
    required this.title,
    required this.cfg,
    this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['cfg'] = Variable<String>(cfg);
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<int>(position);
    }
    return map;
  }

  GraphDefsCompanion toCompanion(bool nullToAbsent) {
    return GraphDefsCompanion(
      id: Value(id),
      title: Value(title),
      cfg: Value(cfg),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
    );
  }

  factory GraphDefRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GraphDefRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      cfg: serializer.fromJson<String>(json['cfg']),
      position: serializer.fromJson<int?>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'cfg': serializer.toJson<String>(cfg),
      'position': serializer.toJson<int?>(position),
    };
  }

  GraphDefRow copyWith({
    String? id,
    String? title,
    String? cfg,
    Value<int?> position = const Value.absent(),
  }) => GraphDefRow(
    id: id ?? this.id,
    title: title ?? this.title,
    cfg: cfg ?? this.cfg,
    position: position.present ? position.value : this.position,
  );
  GraphDefRow copyWithCompanion(GraphDefsCompanion data) {
    return GraphDefRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      cfg: data.cfg.present ? data.cfg.value : this.cfg,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GraphDefRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('cfg: $cfg, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, cfg, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GraphDefRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.cfg == this.cfg &&
          other.position == this.position);
}

class GraphDefsCompanion extends UpdateCompanion<GraphDefRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> cfg;
  final Value<int?> position;
  final Value<int> rowid;
  const GraphDefsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.cfg = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GraphDefsCompanion.insert({
    required String id,
    required String title,
    required String cfg,
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       cfg = Value(cfg);
  static Insertable<GraphDefRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? cfg,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (cfg != null) 'cfg': cfg,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GraphDefsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? cfg,
    Value<int?>? position,
    Value<int>? rowid,
  }) {
    return GraphDefsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      cfg: cfg ?? this.cfg,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (cfg.present) {
      map['cfg'] = Variable<String>(cfg.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GraphDefsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('cfg: $cfg, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuickValuesTable extends QuickValues
    with TableInfo<$QuickValuesTable, QuickValueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuickValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _defKeyMeta = const VerificationMeta('defKey');
  @override
  late final GeneratedColumn<String> defKey = GeneratedColumn<String>(
    'def_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, defKey, label, value, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quick_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuickValueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('def_key')) {
      context.handle(
        _defKeyMeta,
        defKey.isAcceptableOrUnknown(data['def_key']!, _defKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_defKeyMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuickValueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuickValueRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      defKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}def_key'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $QuickValuesTable createAlias(String alias) {
    return $QuickValuesTable(attachedDatabase, alias);
  }
}

class QuickValueRow extends DataClass implements Insertable<QuickValueRow> {
  final int id;
  final String defKey;
  final String label;
  final double value;
  final String createdAt;
  const QuickValueRow({
    required this.id,
    required this.defKey,
    required this.label,
    required this.value,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['def_key'] = Variable<String>(defKey);
    map['label'] = Variable<String>(label);
    map['value'] = Variable<double>(value);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  QuickValuesCompanion toCompanion(bool nullToAbsent) {
    return QuickValuesCompanion(
      id: Value(id),
      defKey: Value(defKey),
      label: Value(label),
      value: Value(value),
      createdAt: Value(createdAt),
    );
  }

  factory QuickValueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuickValueRow(
      id: serializer.fromJson<int>(json['id']),
      defKey: serializer.fromJson<String>(json['defKey']),
      label: serializer.fromJson<String>(json['label']),
      value: serializer.fromJson<double>(json['value']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'defKey': serializer.toJson<String>(defKey),
      'label': serializer.toJson<String>(label),
      'value': serializer.toJson<double>(value),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  QuickValueRow copyWith({
    int? id,
    String? defKey,
    String? label,
    double? value,
    String? createdAt,
  }) => QuickValueRow(
    id: id ?? this.id,
    defKey: defKey ?? this.defKey,
    label: label ?? this.label,
    value: value ?? this.value,
    createdAt: createdAt ?? this.createdAt,
  );
  QuickValueRow copyWithCompanion(QuickValuesCompanion data) {
    return QuickValueRow(
      id: data.id.present ? data.id.value : this.id,
      defKey: data.defKey.present ? data.defKey.value : this.defKey,
      label: data.label.present ? data.label.value : this.label,
      value: data.value.present ? data.value.value : this.value,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuickValueRow(')
          ..write('id: $id, ')
          ..write('defKey: $defKey, ')
          ..write('label: $label, ')
          ..write('value: $value, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, defKey, label, value, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuickValueRow &&
          other.id == this.id &&
          other.defKey == this.defKey &&
          other.label == this.label &&
          other.value == this.value &&
          other.createdAt == this.createdAt);
}

class QuickValuesCompanion extends UpdateCompanion<QuickValueRow> {
  final Value<int> id;
  final Value<String> defKey;
  final Value<String> label;
  final Value<double> value;
  final Value<String> createdAt;
  const QuickValuesCompanion({
    this.id = const Value.absent(),
    this.defKey = const Value.absent(),
    this.label = const Value.absent(),
    this.value = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  QuickValuesCompanion.insert({
    this.id = const Value.absent(),
    required String defKey,
    required String label,
    required double value,
    required String createdAt,
  }) : defKey = Value(defKey),
       label = Value(label),
       value = Value(value),
       createdAt = Value(createdAt);
  static Insertable<QuickValueRow> custom({
    Expression<int>? id,
    Expression<String>? defKey,
    Expression<String>? label,
    Expression<double>? value,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (defKey != null) 'def_key': defKey,
      if (label != null) 'label': label,
      if (value != null) 'value': value,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  QuickValuesCompanion copyWith({
    Value<int>? id,
    Value<String>? defKey,
    Value<String>? label,
    Value<double>? value,
    Value<String>? createdAt,
  }) {
    return QuickValuesCompanion(
      id: id ?? this.id,
      defKey: defKey ?? this.defKey,
      label: label ?? this.label,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (defKey.present) {
      map['def_key'] = Variable<String>(defKey.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuickValuesCompanion(')
          ..write('id: $id, ')
          ..write('defKey: $defKey, ')
          ..write('label: $label, ')
          ..write('value: $value, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$FasyDatabase extends GeneratedDatabase {
  _$FasyDatabase(QueryExecutor e) : super(e);
  $FasyDatabaseManager get managers => $FasyDatabaseManager(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $FieldDefsTable fieldDefs = $FieldDefsTable(this);
  late final $MetaTable meta = $MetaTable(this);
  late final $GraphDefsTable graphDefs = $GraphDefsTable(this);
  late final $QuickValuesTable quickValues = $QuickValuesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    entries,
    fieldDefs,
    meta,
    graphDefs,
    quickValues,
  ];
}

typedef $$EntriesTableCreateCompanionBuilder = EntriesCompanion Function({
  Value<int> id,
  required String createdAt,
  Value<int?> wohlbefinden,
  Value<double?> schlafStunden,
  Value<int?> elvanseMg,
  Value<String?> elvanseZeit,
  Value<double?> innereUnruhe,
  Value<int?> medikinetMg,
  Value<String?> medikinetZeit,
  Value<String?> medikinetMagen,
  Value<String?> medikinetEssenAbstand,
  Value<int?> migraeneIntensitaet,
  Value<String?> migraeneStart,
  Value<String?> migraeneEnde,
  Value<String?> ausloeser,
  Value<String?> begleitsymptome,
  Value<String?> notizen,
  Value<String> migraeneTag,
  Value<String?> customValues,
});
typedef $$EntriesTableUpdateCompanionBuilder = EntriesCompanion Function({
  Value<int> id,
  Value<String> createdAt,
  Value<int?> wohlbefinden,
  Value<double?> schlafStunden,
  Value<int?> elvanseMg,
  Value<String?> elvanseZeit,
  Value<double?> innereUnruhe,
  Value<int?> medikinetMg,
  Value<String?> medikinetZeit,
  Value<String?> medikinetMagen,
  Value<String?> medikinetEssenAbstand,
  Value<int?> migraeneIntensitaet,
  Value<String?> migraeneStart,
  Value<String?> migraeneEnde,
  Value<String?> ausloeser,
  Value<String?> begleitsymptome,
  Value<String?> notizen,
  Value<String> migraeneTag,
  Value<String?> customValues,
});

class $$EntriesTableFilterComposer
    extends Composer<_$FasyDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wohlbefinden => $composableBuilder(
    column: $table.wohlbefinden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get schlafStunden => $composableBuilder(
    column: $table.schlafStunden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elvanseMg => $composableBuilder(
    column: $table.elvanseMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get elvanseZeit => $composableBuilder(
    column: $table.elvanseZeit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get innereUnruhe => $composableBuilder(
    column: $table.innereUnruhe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get medikinetMg => $composableBuilder(
    column: $table.medikinetMg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medikinetZeit => $composableBuilder(
    column: $table.medikinetZeit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medikinetMagen => $composableBuilder(
    column: $table.medikinetMagen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medikinetEssenAbstand => $composableBuilder(
    column: $table.medikinetEssenAbstand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get migraeneIntensitaet => $composableBuilder(
    column: $table.migraeneIntensitaet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get migraeneStart => $composableBuilder(
    column: $table.migraeneStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get migraeneEnde => $composableBuilder(
    column: $table.migraeneEnde,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ausloeser => $composableBuilder(
    column: $table.ausloeser,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get begleitsymptome => $composableBuilder(
    column: $table.begleitsymptome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notizen => $composableBuilder(
    column: $table.notizen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get migraeneTag => $composableBuilder(
    column: $table.migraeneTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customValues => $composableBuilder(
    column: $table.customValues,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntriesTableOrderingComposer
    extends Composer<_$FasyDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wohlbefinden => $composableBuilder(
    column: $table.wohlbefinden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get schlafStunden => $composableBuilder(
    column: $table.schlafStunden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elvanseMg => $composableBuilder(
    column: $table.elvanseMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get elvanseZeit => $composableBuilder(
    column: $table.elvanseZeit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get innereUnruhe => $composableBuilder(
    column: $table.innereUnruhe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get medikinetMg => $composableBuilder(
    column: $table.medikinetMg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medikinetZeit => $composableBuilder(
    column: $table.medikinetZeit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medikinetMagen => $composableBuilder(
    column: $table.medikinetMagen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medikinetEssenAbstand => $composableBuilder(
    column: $table.medikinetEssenAbstand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get migraeneIntensitaet => $composableBuilder(
    column: $table.migraeneIntensitaet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get migraeneStart => $composableBuilder(
    column: $table.migraeneStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get migraeneEnde => $composableBuilder(
    column: $table.migraeneEnde,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ausloeser => $composableBuilder(
    column: $table.ausloeser,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get begleitsymptome => $composableBuilder(
    column: $table.begleitsymptome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notizen => $composableBuilder(
    column: $table.notizen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get migraeneTag => $composableBuilder(
    column: $table.migraeneTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customValues => $composableBuilder(
    column: $table.customValues,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$FasyDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get wohlbefinden => $composableBuilder(
    column: $table.wohlbefinden,
    builder: (column) => column,
  );

  GeneratedColumn<double> get schlafStunden => $composableBuilder(
    column: $table.schlafStunden,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elvanseMg =>
      $composableBuilder(column: $table.elvanseMg, builder: (column) => column);

  GeneratedColumn<String> get elvanseZeit => $composableBuilder(
    column: $table.elvanseZeit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get innereUnruhe => $composableBuilder(
    column: $table.innereUnruhe,
    builder: (column) => column,
  );

  GeneratedColumn<int> get medikinetMg => $composableBuilder(
    column: $table.medikinetMg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medikinetZeit => $composableBuilder(
    column: $table.medikinetZeit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medikinetMagen => $composableBuilder(
    column: $table.medikinetMagen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medikinetEssenAbstand => $composableBuilder(
    column: $table.medikinetEssenAbstand,
    builder: (column) => column,
  );

  GeneratedColumn<int> get migraeneIntensitaet => $composableBuilder(
    column: $table.migraeneIntensitaet,
    builder: (column) => column,
  );

  GeneratedColumn<String> get migraeneStart => $composableBuilder(
    column: $table.migraeneStart,
    builder: (column) => column,
  );

  GeneratedColumn<String> get migraeneEnde => $composableBuilder(
    column: $table.migraeneEnde,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ausloeser =>
      $composableBuilder(column: $table.ausloeser, builder: (column) => column);

  GeneratedColumn<String> get begleitsymptome => $composableBuilder(
    column: $table.begleitsymptome,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notizen =>
      $composableBuilder(column: $table.notizen, builder: (column) => column);

  GeneratedColumn<String> get migraeneTag => $composableBuilder(
    column: $table.migraeneTag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customValues => $composableBuilder(
    column: $table.customValues,
    builder: (column) => column,
  );
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$FasyDatabase,
          $EntriesTable,
          EntryRow,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (EntryRow, BaseReferences<_$FasyDatabase, $EntriesTable, EntryRow>),
          EntryRow,
          PrefetchHooks Function()
        > {
  $$EntriesTableTableManager(_$FasyDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<int?> wohlbefinden = const Value.absent(),
                Value<double?> schlafStunden = const Value.absent(),
                Value<int?> elvanseMg = const Value.absent(),
                Value<String?> elvanseZeit = const Value.absent(),
                Value<double?> innereUnruhe = const Value.absent(),
                Value<int?> medikinetMg = const Value.absent(),
                Value<String?> medikinetZeit = const Value.absent(),
                Value<String?> medikinetMagen = const Value.absent(),
                Value<String?> medikinetEssenAbstand = const Value.absent(),
                Value<int?> migraeneIntensitaet = const Value.absent(),
                Value<String?> migraeneStart = const Value.absent(),
                Value<String?> migraeneEnde = const Value.absent(),
                Value<String?> ausloeser = const Value.absent(),
                Value<String?> begleitsymptome = const Value.absent(),
                Value<String?> notizen = const Value.absent(),
                Value<String> migraeneTag = const Value.absent(),
                Value<String?> customValues = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                createdAt: createdAt,
                wohlbefinden: wohlbefinden,
                schlafStunden: schlafStunden,
                elvanseMg: elvanseMg,
                elvanseZeit: elvanseZeit,
                innereUnruhe: innereUnruhe,
                medikinetMg: medikinetMg,
                medikinetZeit: medikinetZeit,
                medikinetMagen: medikinetMagen,
                medikinetEssenAbstand: medikinetEssenAbstand,
                migraeneIntensitaet: migraeneIntensitaet,
                migraeneStart: migraeneStart,
                migraeneEnde: migraeneEnde,
                ausloeser: ausloeser,
                begleitsymptome: begleitsymptome,
                notizen: notizen,
                migraeneTag: migraeneTag,
                customValues: customValues,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String createdAt,
                Value<int?> wohlbefinden = const Value.absent(),
                Value<double?> schlafStunden = const Value.absent(),
                Value<int?> elvanseMg = const Value.absent(),
                Value<String?> elvanseZeit = const Value.absent(),
                Value<double?> innereUnruhe = const Value.absent(),
                Value<int?> medikinetMg = const Value.absent(),
                Value<String?> medikinetZeit = const Value.absent(),
                Value<String?> medikinetMagen = const Value.absent(),
                Value<String?> medikinetEssenAbstand = const Value.absent(),
                Value<int?> migraeneIntensitaet = const Value.absent(),
                Value<String?> migraeneStart = const Value.absent(),
                Value<String?> migraeneEnde = const Value.absent(),
                Value<String?> ausloeser = const Value.absent(),
                Value<String?> begleitsymptome = const Value.absent(),
                Value<String?> notizen = const Value.absent(),
                Value<String> migraeneTag = const Value.absent(),
                Value<String?> customValues = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                wohlbefinden: wohlbefinden,
                schlafStunden: schlafStunden,
                elvanseMg: elvanseMg,
                elvanseZeit: elvanseZeit,
                innereUnruhe: innereUnruhe,
                medikinetMg: medikinetMg,
                medikinetZeit: medikinetZeit,
                medikinetMagen: medikinetMagen,
                medikinetEssenAbstand: medikinetEssenAbstand,
                migraeneIntensitaet: migraeneIntensitaet,
                migraeneStart: migraeneStart,
                migraeneEnde: migraeneEnde,
                ausloeser: ausloeser,
                begleitsymptome: begleitsymptome,
                notizen: notizen,
                migraeneTag: migraeneTag,
                customValues: customValues,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntriesTable, EntryRow>(table),
                  BaseReferences<_$FasyDatabase, $EntriesTable, EntryRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$FasyDatabase,
      $EntriesTable,
      EntryRow,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (EntryRow, BaseReferences<_$FasyDatabase, $EntriesTable, EntryRow>),
      EntryRow,
      PrefetchHooks Function()
    >;
typedef $$FieldDefsTableCreateCompanionBuilder = FieldDefsCompanion Function({
  required String id,
  required int grp,
  required String label,
  required String type,
  Value<String?> config,
  Value<int?> position,
  Value<int> rowid,
});
typedef $$FieldDefsTableUpdateCompanionBuilder = FieldDefsCompanion Function({
  Value<String> id,
  Value<int> grp,
  Value<String> label,
  Value<String> type,
  Value<String?> config,
  Value<int?> position,
  Value<int> rowid,
});

class $$FieldDefsTableFilterComposer
    extends Composer<_$FasyDatabase, $FieldDefsTable> {
  $$FieldDefsTableFilterComposer({
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

  ColumnFilters<int> get grp => $composableBuilder(
    column: $table.grp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get config => $composableBuilder(
    column: $table.config,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FieldDefsTableOrderingComposer
    extends Composer<_$FasyDatabase, $FieldDefsTable> {
  $$FieldDefsTableOrderingComposer({
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

  ColumnOrderings<int> get grp => $composableBuilder(
    column: $table.grp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get config => $composableBuilder(
    column: $table.config,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FieldDefsTableAnnotationComposer
    extends Composer<_$FasyDatabase, $FieldDefsTable> {
  $$FieldDefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get grp =>
      $composableBuilder(column: $table.grp, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get config =>
      $composableBuilder(column: $table.config, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$FieldDefsTableTableManager
    extends
        RootTableManager<
          _$FasyDatabase,
          $FieldDefsTable,
          FieldDefRow,
          $$FieldDefsTableFilterComposer,
          $$FieldDefsTableOrderingComposer,
          $$FieldDefsTableAnnotationComposer,
          $$FieldDefsTableCreateCompanionBuilder,
          $$FieldDefsTableUpdateCompanionBuilder,
          (
            FieldDefRow,
            BaseReferences<_$FasyDatabase, $FieldDefsTable, FieldDefRow>,
          ),
          FieldDefRow,
          PrefetchHooks Function()
        > {
  $$FieldDefsTableTableManager(_$FasyDatabase db, $FieldDefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FieldDefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FieldDefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FieldDefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> grp = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> config = const Value.absent(),
                Value<int?> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FieldDefsCompanion(
                id: id,
                grp: grp,
                label: label,
                type: type,
                config: config,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int grp,
                required String label,
                required String type,
                Value<String?> config = const Value.absent(),
                Value<int?> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FieldDefsCompanion.insert(
                id: id,
                grp: grp,
                label: label,
                type: type,
                config: config,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FieldDefsTable, FieldDefRow>(table),
                  BaseReferences<_$FasyDatabase, $FieldDefsTable, FieldDefRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FieldDefsTableProcessedTableManager =
    ProcessedTableManager<
      _$FasyDatabase,
      $FieldDefsTable,
      FieldDefRow,
      $$FieldDefsTableFilterComposer,
      $$FieldDefsTableOrderingComposer,
      $$FieldDefsTableAnnotationComposer,
      $$FieldDefsTableCreateCompanionBuilder,
      $$FieldDefsTableUpdateCompanionBuilder,
      (
        FieldDefRow,
        BaseReferences<_$FasyDatabase, $FieldDefsTable, FieldDefRow>,
      ),
      FieldDefRow,
      PrefetchHooks Function()
    >;
typedef $$MetaTableCreateCompanionBuilder = MetaCompanion Function({
  required String key,
  Value<String?> value,
  Value<int> rowid,
});
typedef $$MetaTableUpdateCompanionBuilder = MetaCompanion Function({
  Value<String> key,
  Value<String?> value,
  Value<int> rowid,
});

class $$MetaTableFilterComposer extends Composer<_$FasyDatabase, $MetaTable> {
  $$MetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MetaTableOrderingComposer extends Composer<_$FasyDatabase, $MetaTable> {
  $$MetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MetaTableAnnotationComposer
    extends Composer<_$FasyDatabase, $MetaTable> {
  $$MetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MetaTableTableManager
    extends
        RootTableManager<
          _$FasyDatabase,
          $MetaTable,
          MetaRow,
          $$MetaTableFilterComposer,
          $$MetaTableOrderingComposer,
          $$MetaTableAnnotationComposer,
          $$MetaTableCreateCompanionBuilder,
          $$MetaTableUpdateCompanionBuilder,
          (MetaRow, BaseReferences<_$FasyDatabase, $MetaTable, MetaRow>),
          MetaRow,
          PrefetchHooks Function()
        > {
  $$MetaTableTableManager(_$FasyDatabase db, $MetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => MetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MetaTable, MetaRow>(table),
                  BaseReferences<_$FasyDatabase, $MetaTable, MetaRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MetaTableProcessedTableManager =
    ProcessedTableManager<
      _$FasyDatabase,
      $MetaTable,
      MetaRow,
      $$MetaTableFilterComposer,
      $$MetaTableOrderingComposer,
      $$MetaTableAnnotationComposer,
      $$MetaTableCreateCompanionBuilder,
      $$MetaTableUpdateCompanionBuilder,
      (MetaRow, BaseReferences<_$FasyDatabase, $MetaTable, MetaRow>),
      MetaRow,
      PrefetchHooks Function()
    >;
typedef $$GraphDefsTableCreateCompanionBuilder = GraphDefsCompanion Function({
  required String id,
  required String title,
  required String cfg,
  Value<int?> position,
  Value<int> rowid,
});
typedef $$GraphDefsTableUpdateCompanionBuilder = GraphDefsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> cfg,
  Value<int?> position,
  Value<int> rowid,
});

class $$GraphDefsTableFilterComposer
    extends Composer<_$FasyDatabase, $GraphDefsTable> {
  $$GraphDefsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cfg => $composableBuilder(
    column: $table.cfg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GraphDefsTableOrderingComposer
    extends Composer<_$FasyDatabase, $GraphDefsTable> {
  $$GraphDefsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cfg => $composableBuilder(
    column: $table.cfg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GraphDefsTableAnnotationComposer
    extends Composer<_$FasyDatabase, $GraphDefsTable> {
  $$GraphDefsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get cfg =>
      $composableBuilder(column: $table.cfg, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$GraphDefsTableTableManager
    extends
        RootTableManager<
          _$FasyDatabase,
          $GraphDefsTable,
          GraphDefRow,
          $$GraphDefsTableFilterComposer,
          $$GraphDefsTableOrderingComposer,
          $$GraphDefsTableAnnotationComposer,
          $$GraphDefsTableCreateCompanionBuilder,
          $$GraphDefsTableUpdateCompanionBuilder,
          (
            GraphDefRow,
            BaseReferences<_$FasyDatabase, $GraphDefsTable, GraphDefRow>,
          ),
          GraphDefRow,
          PrefetchHooks Function()
        > {
  $$GraphDefsTableTableManager(_$FasyDatabase db, $GraphDefsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GraphDefsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GraphDefsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GraphDefsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> cfg = const Value.absent(),
                Value<int?> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GraphDefsCompanion(
                id: id,
                title: title,
                cfg: cfg,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String cfg,
                Value<int?> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GraphDefsCompanion.insert(
                id: id,
                title: title,
                cfg: cfg,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GraphDefsTable, GraphDefRow>(table),
                  BaseReferences<_$FasyDatabase, $GraphDefsTable, GraphDefRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GraphDefsTableProcessedTableManager =
    ProcessedTableManager<
      _$FasyDatabase,
      $GraphDefsTable,
      GraphDefRow,
      $$GraphDefsTableFilterComposer,
      $$GraphDefsTableOrderingComposer,
      $$GraphDefsTableAnnotationComposer,
      $$GraphDefsTableCreateCompanionBuilder,
      $$GraphDefsTableUpdateCompanionBuilder,
      (
        GraphDefRow,
        BaseReferences<_$FasyDatabase, $GraphDefsTable, GraphDefRow>,
      ),
      GraphDefRow,
      PrefetchHooks Function()
    >;
typedef $$QuickValuesTableCreateCompanionBuilder =
    QuickValuesCompanion Function({
      Value<int> id,
      required String defKey,
      required String label,
      required double value,
      required String createdAt,
    });
typedef $$QuickValuesTableUpdateCompanionBuilder =
    QuickValuesCompanion Function({
      Value<int> id,
      Value<String> defKey,
      Value<String> label,
      Value<double> value,
      Value<String> createdAt,
    });

class $$QuickValuesTableFilterComposer
    extends Composer<_$FasyDatabase, $QuickValuesTable> {
  $$QuickValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defKey => $composableBuilder(
    column: $table.defKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuickValuesTableOrderingComposer
    extends Composer<_$FasyDatabase, $QuickValuesTable> {
  $$QuickValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defKey => $composableBuilder(
    column: $table.defKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuickValuesTableAnnotationComposer
    extends Composer<_$FasyDatabase, $QuickValuesTable> {
  $$QuickValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get defKey =>
      $composableBuilder(column: $table.defKey, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$QuickValuesTableTableManager
    extends
        RootTableManager<
          _$FasyDatabase,
          $QuickValuesTable,
          QuickValueRow,
          $$QuickValuesTableFilterComposer,
          $$QuickValuesTableOrderingComposer,
          $$QuickValuesTableAnnotationComposer,
          $$QuickValuesTableCreateCompanionBuilder,
          $$QuickValuesTableUpdateCompanionBuilder,
          (
            QuickValueRow,
            BaseReferences<_$FasyDatabase, $QuickValuesTable, QuickValueRow>,
          ),
          QuickValueRow,
          PrefetchHooks Function()
        > {
  $$QuickValuesTableTableManager(_$FasyDatabase db, $QuickValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuickValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuickValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuickValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> defKey = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
              }) => QuickValuesCompanion(
                id: id,
                defKey: defKey,
                label: label,
                value: value,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String defKey,
                required String label,
                required double value,
                required String createdAt,
              }) => QuickValuesCompanion.insert(
                id: id,
                defKey: defKey,
                label: label,
                value: value,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuickValuesTable, QuickValueRow>(table),
                  BaseReferences<
                    _$FasyDatabase,
                    $QuickValuesTable,
                    QuickValueRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuickValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$FasyDatabase,
      $QuickValuesTable,
      QuickValueRow,
      $$QuickValuesTableFilterComposer,
      $$QuickValuesTableOrderingComposer,
      $$QuickValuesTableAnnotationComposer,
      $$QuickValuesTableCreateCompanionBuilder,
      $$QuickValuesTableUpdateCompanionBuilder,
      (
        QuickValueRow,
        BaseReferences<_$FasyDatabase, $QuickValuesTable, QuickValueRow>,
      ),
      QuickValueRow,
      PrefetchHooks Function()
    >;

class $FasyDatabaseManager {
  final _$FasyDatabase _db;
  $FasyDatabaseManager(this._db);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$FieldDefsTableTableManager get fieldDefs =>
      $$FieldDefsTableTableManager(_db, _db.fieldDefs);
  $$MetaTableTableManager get meta => $$MetaTableTableManager(_db, _db.meta);
  $$GraphDefsTableTableManager get graphDefs =>
      $$GraphDefsTableTableManager(_db, _db.graphDefs);
  $$QuickValuesTableTableManager get quickValues =>
      $$QuickValuesTableTableManager(_db, _db.quickValues);
}
