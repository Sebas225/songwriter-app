// GENERATED CODE - MANUAL IMPLEMENTATION DUE TO LIMITED TOOLING.
// coverage:ignore-file
part of 'app_database.dart';

class Song extends DataClass implements Insertable<Song> {
  final String id;
  final String title;
  final String? artist;
  final String? originalKey;
  final String? currentKey;
  final int? tempoBpm;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Song({
    required this.id,
    required this.title,
    this.artist,
    this.originalKey,
    this.currentKey,
    this.tempoBpm,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  Map<String, Expression<Object?>> toColumns(bool nullToAbsent) {
    final map = <String, Expression<Object?>>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String?>(artist);
    }
    if (!nullToAbsent || originalKey != null) {
      map['original_key'] = Variable<String?>(originalKey);
    }
    if (!nullToAbsent || currentKey != null) {
      map['current_key'] = Variable<String?>(currentKey);
    }
    if (!nullToAbsent || tempoBpm != null) {
      map['tempo_bpm'] = Variable<int?>(tempoBpm);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: Value(id),
      title: Value(title),
      artist: artist == null && nullToAbsent ? const Value.absent() : Value(artist),
      originalKey: originalKey == null && nullToAbsent
          ? const Value.absent()
          : Value(originalKey),
      currentKey:
          currentKey == null && nullToAbsent ? const Value.absent() : Value(currentKey),
      tempoBpm: tempoBpm == null && nullToAbsent
          ? const Value.absent()
          : Value(tempoBpm),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Song.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Song(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      originalKey: serializer.fromJson<String?>(json['originalKey']),
      currentKey: serializer.fromJson<String?>(json['currentKey']),
      tempoBpm: serializer.fromJson<int?>(json['tempoBpm']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String?>(artist),
      'originalKey': serializer.toJson<String?>(originalKey),
      'currentKey': serializer.toJson<String?>(currentKey),
      'tempoBpm': serializer.toJson<int?>(tempoBpm),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Song copyWith({
    String? id,
    String? title,
    Value<String?> artist = const Value.absent(),
    Value<String?> originalKey = const Value.absent(),
    Value<String?> currentKey = const Value.absent(),
    Value<int?> tempoBpm = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist.present ? artist.value : this.artist,
      originalKey: originalKey.present ? originalKey.value : this.originalKey,
      currentKey: currentKey.present ? currentKey.value : this.currentKey,
      tempoBpm: tempoBpm.present ? tempoBpm.value : this.tempoBpm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Song(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('originalKey: $originalKey, ')
          ..write('currentKey: $currentKey, ')
          ..write('tempoBpm: $tempoBpm, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, artist, originalKey, currentKey, tempoBpm,
      createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Song &&
          other.id == id &&
          other.title == title &&
          other.artist == artist &&
          other.originalKey == originalKey &&
          other.currentKey == currentKey &&
          other.tempoBpm == tempoBpm &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt);
}

class SongsCompanion extends UpdateCompanion<Song> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> artist;
  final Value<String?> originalKey;
  final Value<String?> currentKey;
  final Value<int?> tempoBpm;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.originalKey = const Value.absent(),
    this.currentKey = const Value.absent(),
    this.tempoBpm = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SongsCompanion.insert({
    required String id,
    required String title,
    this.artist = const Value.absent(),
    this.originalKey = const Value.absent(),
    this.currentKey = const Value.absent(),
    this.tempoBpm = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : id = Value(id),
        title = Value(title);

  static Insertable<Song> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? originalKey,
    Expression<String>? currentKey,
    Expression<int>? tempoBpm,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (originalKey != null) 'original_key': originalKey,
      if (currentKey != null) 'current_key': currentKey,
      if (tempoBpm != null) 'tempo_bpm': tempoBpm,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SongsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? artist,
    Value<String?>? originalKey,
    Value<String?>? currentKey,
    Value<int?>? tempoBpm,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return SongsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      originalKey: originalKey ?? this.originalKey,
      currentKey: currentKey ?? this.currentKey,
      tempoBpm: tempoBpm ?? this.tempoBpm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression<Object?>> toColumns(bool nullToAbsent) {
    final map = <String, Expression<Object?>>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String?>(artist.value);
    }
    if (originalKey.present) {
      map['original_key'] = Variable<String?>(originalKey.value);
    }
    if (currentKey.present) {
      map['current_key'] = Variable<String?>(currentKey.value);
    }
    if (tempoBpm.present) {
      map['tempo_bpm'] = Variable<int?>(tempoBpm.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('originalKey: $originalKey, ')
          ..write('currentKey: $currentKey, ')
          ..write('tempoBpm: $tempoBpm, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SongsTable extends Songs with TableInfo<$SongsTable, Song> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SongsTable(this.attachedDatabase, [this._alias]);

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
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalKeyMeta = const VerificationMeta('originalKey');
  @override
  late final GeneratedColumn<String> originalKey = GeneratedColumn<String>(
    'original_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentKeyMeta = const VerificationMeta('currentKey');
  @override
  late final GeneratedColumn<String> currentKey = GeneratedColumn<String>(
    'current_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tempoBpmMeta = const VerificationMeta('tempoBpm');
  @override
  late final GeneratedColumn<int> tempoBpm = GeneratedColumn<int>(
    'tempo_bpm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );

  @override
  List<GeneratedColumn> get $columns =>
      [id, title, artist, originalKey, currentKey, tempoBpm, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => 'songs';
  @override
  VerificationContext validateIntegrity(Insertable<Song> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(_artistMeta, artist.isAcceptableOrUnknown(data['artist']!, _artistMeta));
    }
    if (data.containsKey('original_key')) {
      context.handle(_originalKeyMeta,
          originalKey.isAcceptableOrUnknown(data['original_key']!, _originalKeyMeta));
    }
    if (data.containsKey('current_key')) {
      context.handle(_currentKeyMeta,
          currentKey.isAcceptableOrUnknown(data['current_key']!, _currentKeyMeta));
    }
    if (data.containsKey('tempo_bpm')) {
      context.handle(_tempoBpmMeta,
          tempoBpm.isAcceptableOrUnknown(data['tempo_bpm']!, _tempoBpmMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Song map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Song(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      artist: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}artist']),
      originalKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_key']),
      currentKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}current_key']),
      tempoBpm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tempo_bpm']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(attachedDatabase, alias);
  }
}

class Section extends DataClass implements Insertable<Section> {
  final String id;
  final String songId;
  final String name;
  final int order;
  const Section({
    required this.id,
    required this.songId,
    required this.name,
    required this.order,
  });

  @override
  Map<String, Expression<Object?>> toColumns(bool nullToAbsent) {
    final map = <String, Expression<Object?>>{};
    map['id'] = Variable<String>(id);
    map['song_id'] = Variable<String>(songId);
    map['name'] = Variable<String>(name);
    map['order'] = Variable<int>(order);
    return map;
  }

  SectionsCompanion toCompanion(bool nullToAbsent) {
    return SectionsCompanion(
      id: Value(id),
      songId: Value(songId),
      name: Value(name),
      order: Value(order),
    );
  }

  factory Section.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Section(
      id: serializer.fromJson<String>(json['id']),
      songId: serializer.fromJson<String>(json['songId']),
      name: serializer.fromJson<String>(json['name']),
      order: serializer.fromJson<int>(json['order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'songId': serializer.toJson<String>(songId),
      'name': serializer.toJson<String>(name),
      'order': serializer.toJson<int>(order),
    };
  }

  Section copyWith({String? id, String? songId, String? name, int? order}) {
    return Section(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      name: name ?? this.name,
      order: order ?? this.order,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Section(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('name: $name, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, songId, name, order);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Section &&
          other.id == id &&
          other.songId == songId &&
          other.name == name &&
          other.order == order);
}

class SectionsCompanion extends UpdateCompanion<Section> {
  final Value<String> id;
  final Value<String> songId;
  final Value<String> name;
  final Value<int> order;
  const SectionsCompanion({
    this.id = const Value.absent(),
    this.songId = const Value.absent(),
    this.name = const Value.absent(),
    this.order = const Value.absent(),
  });
  SectionsCompanion.insert({
    required String id,
    required String songId,
    required String name,
    required int order,
  })  : id = Value(id),
        songId = Value(songId),
        name = Value(name),
        order = Value(order);

  static Insertable<Section> custom({
    Expression<String>? id,
    Expression<String>? songId,
    Expression<String>? name,
    Expression<int>? order,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (songId != null) 'song_id': songId,
      if (name != null) 'name': name,
      if (order != null) 'order': order,
    });
  }

  SectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? songId,
    Value<String>? name,
    Value<int>? order,
  }) {
    return SectionsCompanion(
      id: id ?? this.id,
      songId: songId ?? this.songId,
      name: name ?? this.name,
      order: order ?? this.order,
    );
  }

  @override
  Map<String, Expression<Object?>> toColumns(bool nullToAbsent) {
    final map = <String, Expression<Object?>>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<String>(songId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionsCompanion(')
          ..write('id: $id, ')
          ..write('songId: $songId, ')
          ..write('name: $name, ')
          ..write('order: $order')
          ..write(')'))
        .toString();
  }
}

class $SectionsTable extends Sections with TableInfo<$SectionsTable, Section> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectionsTable(this.attachedDatabase, [this._alias]);

  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _songIdMeta = const VerificationMeta('songId');
  @override
  late final GeneratedColumn<String> songId = GeneratedColumn<String>(
    'song_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints:
        GeneratedColumn.constraintIsAlways('REFERENCES songs (id) ON DELETE CASCADE'),
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
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );

  @override
  List<GeneratedColumn> get $columns => [id, songId, name, order];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => 'sections';
  @override
  VerificationContext validateIntegrity(Insertable<Section> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(
          _songIdMeta, songId.isAcceptableOrUnknown(data['song_id']!, _songIdMeta));
    } else if (isInserting) {
      context.missing(_songIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('order')) {
      context.handle(_orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Section map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Section(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      songId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}song_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
    );
  }

  @override
  $SectionsTable createAlias(String alias) {
    return $SectionsTable(attachedDatabase, alias);
  }
}

class Line extends DataClass implements Insertable<Line> {
  final String id;
  final String sectionId;
  final int order;
  final String rawText;
  const Line({
    required this.id,
    required this.sectionId,
    required this.order,
    required this.rawText,
  });

  @override
  Map<String, Expression<Object?>> toColumns(bool nullToAbsent) {
    final map = <String, Expression<Object?>>{};
    map['id'] = Variable<String>(id);
    map['section_id'] = Variable<String>(sectionId);
    map['order'] = Variable<int>(order);
    map['raw_text'] = Variable<String>(rawText);
    return map;
  }

  LinesCompanion toCompanion(bool nullToAbsent) {
    return LinesCompanion(
      id: Value(id),
      sectionId: Value(sectionId),
      order: Value(order),
      rawText: Value(rawText),
    );
  }

  factory Line.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Line(
      id: serializer.fromJson<String>(json['id']),
      sectionId: serializer.fromJson<String>(json['sectionId']),
      order: serializer.fromJson<int>(json['order']),
      rawText: serializer.fromJson<String>(json['rawText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sectionId': serializer.toJson<String>(sectionId),
      'order': serializer.toJson<int>(order),
      'rawText': serializer.toJson<String>(rawText),
    };
  }

  Line copyWith({String? id, String? sectionId, int? order, String? rawText}) {
    return Line(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      order: order ?? this.order,
      rawText: rawText ?? this.rawText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Line(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('order: $order, ')
          ..write('rawText: $rawText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sectionId, order, rawText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Line &&
          other.id == id &&
          other.sectionId == sectionId &&
          other.order == order &&
          other.rawText == rawText);
}

class LinesCompanion extends UpdateCompanion<Line> {
  final Value<String> id;
  final Value<String> sectionId;
  final Value<int> order;
  final Value<String> rawText;
  const LinesCompanion({
    this.id = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.order = const Value.absent(),
    this.rawText = const Value.absent(),
  });
  LinesCompanion.insert({
    required String id,
    required String sectionId,
    required int order,
    required String rawText,
  })  : id = Value(id),
        sectionId = Value(sectionId),
        order = Value(order),
        rawText = Value(rawText);

  static Insertable<Line> custom({
    Expression<String>? id,
    Expression<String>? sectionId,
    Expression<int>? order,
    Expression<String>? rawText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sectionId != null) 'section_id': sectionId,
      if (order != null) 'order': order,
      if (rawText != null) 'raw_text': rawText,
    });
  }

  LinesCompanion copyWith({
    Value<String>? id,
    Value<String>? sectionId,
    Value<int>? order,
    Value<String>? rawText,
  }) {
    return LinesCompanion(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      order: order ?? this.order,
      rawText: rawText ?? this.rawText,
    );
  }

  @override
  Map<String, Expression<Object?>> toColumns(bool nullToAbsent) {
    final map = <String, Expression<Object?>>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<String>(sectionId.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LinesCompanion(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('order: $order, ')
          ..write('rawText: $rawText')
          ..write(')'))
        .toString();
  }
}

class $LinesTable extends Lines with TableInfo<$LinesTable, Line> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LinesTable(this.attachedDatabase, [this._alias]);

  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta('sectionId');
  @override
  late final GeneratedColumn<String> sectionId = GeneratedColumn<String>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
        'REFERENCES sections (id) ON DELETE CASCADE'),
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawTextMeta = const VerificationMeta('rawText');
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
    'raw_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );

  @override
  List<GeneratedColumn> get $columns => [id, sectionId, order, rawText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => 'lines';
  @override
  VerificationContext validateIntegrity(Insertable<Line> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(_sectionIdMeta,
          sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta));
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('order')) {
      context.handle(_orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(_rawTextMeta,
          rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta));
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Line map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Line(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      sectionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}section_id'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      rawText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_text'])!,
    );
  }

  @override
  $LinesTable createAlias(String alias) {
    return $LinesTable(attachedDatabase, alias);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $SongsTable songs = $SongsTable(this);
  late final $SectionsTable sections = $SectionsTable(this);
  late final $LinesTable lines = $LinesTable(this);
  late final SongDao songDao = SongDao(this as AppDatabase);
  late final SectionDao sectionDao = SectionDao(this as AppDatabase);
  late final LineDao lineDao = LineDao(this as AppDatabase);

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => [songs, sections, lines];

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [songs, sections, lines];
}

mixin _$SongDaoMixin on DatabaseAccessor<AppDatabase> {
  $SongsTable get songs => attachedDatabase.songs;
}

mixin _$SectionDaoMixin on DatabaseAccessor<AppDatabase> {
  $SectionsTable get sections => attachedDatabase.sections;
}

mixin _$LineDaoMixin on DatabaseAccessor<AppDatabase> {
  $LinesTable get lines => attachedDatabase.lines;
}
