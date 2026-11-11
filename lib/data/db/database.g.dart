// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
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
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final int id;
  final String name;
  final int position;
  const Folder({required this.id, required this.name, required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['position'] = Variable<int>(position);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      name: Value(name),
      position: Value(position),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<int>(position),
    };
  }

  Folder copyWith({int? id, String? name, int? position}) => Folder(
    id: id ?? this.id,
    name: name ?? this.name,
    position: position ?? this.position,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.name == this.name &&
          other.position == this.position);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> position;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
  });
  FoldersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.position = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Folder> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
    });
  }

  FoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? position,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $FeedsTable extends Feeds with TableInfo<$FeedsTable, Feed> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeedsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
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
  static const VerificationMeta _customTitleMeta = const VerificationMeta(
    'customTitle',
  );
  @override
  late final GeneratedColumn<String> customTitle = GeneratedColumn<String>(
    'custom_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _siteUrlMeta = const VerificationMeta(
    'siteUrl',
  );
  @override
  late final GeneratedColumn<String> siteUrl = GeneratedColumn<String>(
    'site_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconUrlMeta = const VerificationMeta(
    'iconUrl',
  );
  @override
  late final GeneratedColumn<String> iconUrl = GeneratedColumn<String>(
    'icon_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
    'folder_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<String> lastModified = GeneratedColumn<String>(
    'last_modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastFetchedAtMeta = const VerificationMeta(
    'lastFetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastFetchedAt =
      GeneratedColumn<DateTime>(
        'last_fetched_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorCountMeta = const VerificationMeta(
    'errorCount',
  );
  @override
  late final GeneratedColumn<int> errorCount = GeneratedColumn<int>(
    'error_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fullTextMeta = const VerificationMeta(
    'fullText',
  );
  @override
  late final GeneratedColumn<bool> fullText = GeneratedColumn<bool>(
    'full_text',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("full_text" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _neverBundleMeta = const VerificationMeta(
    'neverBundle',
  );
  @override
  late final GeneratedColumn<bool> neverBundle = GeneratedColumn<bool>(
    'never_bundle',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("never_bundle" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    url,
    title,
    customTitle,
    siteUrl,
    iconUrl,
    description,
    folderId,
    etag,
    lastModified,
    lastFetchedAt,
    lastError,
    errorCount,
    fullText,
    neverBundle,
    remoteId,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feeds';
  @override
  VerificationContext validateIntegrity(
    Insertable<Feed> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('custom_title')) {
      context.handle(
        _customTitleMeta,
        customTitle.isAcceptableOrUnknown(
          data['custom_title']!,
          _customTitleMeta,
        ),
      );
    }
    if (data.containsKey('site_url')) {
      context.handle(
        _siteUrlMeta,
        siteUrl.isAcceptableOrUnknown(data['site_url']!, _siteUrlMeta),
      );
    }
    if (data.containsKey('icon_url')) {
      context.handle(
        _iconUrlMeta,
        iconUrl.isAcceptableOrUnknown(data['icon_url']!, _iconUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    }
    if (data.containsKey('last_fetched_at')) {
      context.handle(
        _lastFetchedAtMeta,
        lastFetchedAt.isAcceptableOrUnknown(
          data['last_fetched_at']!,
          _lastFetchedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('error_count')) {
      context.handle(
        _errorCountMeta,
        errorCount.isAcceptableOrUnknown(data['error_count']!, _errorCountMeta),
      );
    }
    if (data.containsKey('full_text')) {
      context.handle(
        _fullTextMeta,
        fullText.isAcceptableOrUnknown(data['full_text']!, _fullTextMeta),
      );
    }
    if (data.containsKey('never_bundle')) {
      context.handle(
        _neverBundleMeta,
        neverBundle.isAcceptableOrUnknown(
          data['never_bundle']!,
          _neverBundleMeta,
        ),
      );
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Feed map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Feed(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      customTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_title'],
      ),
      siteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_url'],
      ),
      iconUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_url'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folder_id'],
      ),
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified'],
      ),
      lastFetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_fetched_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      errorCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}error_count'],
      )!,
      fullText: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}full_text'],
      )!,
      neverBundle: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}never_bundle'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $FeedsTable createAlias(String alias) {
    return $FeedsTable(attachedDatabase, alias);
  }
}

class Feed extends DataClass implements Insertable<Feed> {
  final int id;
  final String url;
  final String title;
  final String? customTitle;
  final String? siteUrl;
  final String? iconUrl;
  final String? description;
  final int? folderId;
  final String? etag;
  final String? lastModified;
  final DateTime? lastFetchedAt;
  final String? lastError;
  final int errorCount;

  /// Always fetch the full text from the page, even if the feed has content.
  final bool fullText;

  /// Never bundle this feed into one line, however loud it is.
  final bool neverBundle;

  /// The id on the sync server, if an account is connected.
  final String? remoteId;
  final DateTime addedAt;
  const Feed({
    required this.id,
    required this.url,
    required this.title,
    this.customTitle,
    this.siteUrl,
    this.iconUrl,
    this.description,
    this.folderId,
    this.etag,
    this.lastModified,
    this.lastFetchedAt,
    this.lastError,
    required this.errorCount,
    required this.fullText,
    required this.neverBundle,
    this.remoteId,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['url'] = Variable<String>(url);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || customTitle != null) {
      map['custom_title'] = Variable<String>(customTitle);
    }
    if (!nullToAbsent || siteUrl != null) {
      map['site_url'] = Variable<String>(siteUrl);
    }
    if (!nullToAbsent || iconUrl != null) {
      map['icon_url'] = Variable<String>(iconUrl);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || folderId != null) {
      map['folder_id'] = Variable<int>(folderId);
    }
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<String>(lastModified);
    }
    if (!nullToAbsent || lastFetchedAt != null) {
      map['last_fetched_at'] = Variable<DateTime>(lastFetchedAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['error_count'] = Variable<int>(errorCount);
    map['full_text'] = Variable<bool>(fullText);
    map['never_bundle'] = Variable<bool>(neverBundle);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  FeedsCompanion toCompanion(bool nullToAbsent) {
    return FeedsCompanion(
      id: Value(id),
      url: Value(url),
      title: Value(title),
      customTitle: customTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(customTitle),
      siteUrl: siteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(siteUrl),
      iconUrl: iconUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(iconUrl),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      folderId: folderId == null && nullToAbsent
          ? const Value.absent()
          : Value(folderId),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      lastFetchedAt: lastFetchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastFetchedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      errorCount: Value(errorCount),
      fullText: Value(fullText),
      neverBundle: Value(neverBundle),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      addedAt: Value(addedAt),
    );
  }

  factory Feed.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Feed(
      id: serializer.fromJson<int>(json['id']),
      url: serializer.fromJson<String>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      customTitle: serializer.fromJson<String?>(json['customTitle']),
      siteUrl: serializer.fromJson<String?>(json['siteUrl']),
      iconUrl: serializer.fromJson<String?>(json['iconUrl']),
      description: serializer.fromJson<String?>(json['description']),
      folderId: serializer.fromJson<int?>(json['folderId']),
      etag: serializer.fromJson<String?>(json['etag']),
      lastModified: serializer.fromJson<String?>(json['lastModified']),
      lastFetchedAt: serializer.fromJson<DateTime?>(json['lastFetchedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      errorCount: serializer.fromJson<int>(json['errorCount']),
      fullText: serializer.fromJson<bool>(json['fullText']),
      neverBundle: serializer.fromJson<bool>(json['neverBundle']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'url': serializer.toJson<String>(url),
      'title': serializer.toJson<String>(title),
      'customTitle': serializer.toJson<String?>(customTitle),
      'siteUrl': serializer.toJson<String?>(siteUrl),
      'iconUrl': serializer.toJson<String?>(iconUrl),
      'description': serializer.toJson<String?>(description),
      'folderId': serializer.toJson<int?>(folderId),
      'etag': serializer.toJson<String?>(etag),
      'lastModified': serializer.toJson<String?>(lastModified),
      'lastFetchedAt': serializer.toJson<DateTime?>(lastFetchedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'errorCount': serializer.toJson<int>(errorCount),
      'fullText': serializer.toJson<bool>(fullText),
      'neverBundle': serializer.toJson<bool>(neverBundle),
      'remoteId': serializer.toJson<String?>(remoteId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  Feed copyWith({
    int? id,
    String? url,
    String? title,
    Value<String?> customTitle = const Value.absent(),
    Value<String?> siteUrl = const Value.absent(),
    Value<String?> iconUrl = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<int?> folderId = const Value.absent(),
    Value<String?> etag = const Value.absent(),
    Value<String?> lastModified = const Value.absent(),
    Value<DateTime?> lastFetchedAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    int? errorCount,
    bool? fullText,
    bool? neverBundle,
    Value<String?> remoteId = const Value.absent(),
    DateTime? addedAt,
  }) => Feed(
    id: id ?? this.id,
    url: url ?? this.url,
    title: title ?? this.title,
    customTitle: customTitle.present ? customTitle.value : this.customTitle,
    siteUrl: siteUrl.present ? siteUrl.value : this.siteUrl,
    iconUrl: iconUrl.present ? iconUrl.value : this.iconUrl,
    description: description.present ? description.value : this.description,
    folderId: folderId.present ? folderId.value : this.folderId,
    etag: etag.present ? etag.value : this.etag,
    lastModified: lastModified.present ? lastModified.value : this.lastModified,
    lastFetchedAt: lastFetchedAt.present
        ? lastFetchedAt.value
        : this.lastFetchedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    errorCount: errorCount ?? this.errorCount,
    fullText: fullText ?? this.fullText,
    neverBundle: neverBundle ?? this.neverBundle,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    addedAt: addedAt ?? this.addedAt,
  );
  Feed copyWithCompanion(FeedsCompanion data) {
    return Feed(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      customTitle: data.customTitle.present
          ? data.customTitle.value
          : this.customTitle,
      siteUrl: data.siteUrl.present ? data.siteUrl.value : this.siteUrl,
      iconUrl: data.iconUrl.present ? data.iconUrl.value : this.iconUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      etag: data.etag.present ? data.etag.value : this.etag,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      lastFetchedAt: data.lastFetchedAt.present
          ? data.lastFetchedAt.value
          : this.lastFetchedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      errorCount: data.errorCount.present
          ? data.errorCount.value
          : this.errorCount,
      fullText: data.fullText.present ? data.fullText.value : this.fullText,
      neverBundle: data.neverBundle.present
          ? data.neverBundle.value
          : this.neverBundle,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Feed(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('customTitle: $customTitle, ')
          ..write('siteUrl: $siteUrl, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('description: $description, ')
          ..write('folderId: $folderId, ')
          ..write('etag: $etag, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastFetchedAt: $lastFetchedAt, ')
          ..write('lastError: $lastError, ')
          ..write('errorCount: $errorCount, ')
          ..write('fullText: $fullText, ')
          ..write('neverBundle: $neverBundle, ')
          ..write('remoteId: $remoteId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    url,
    title,
    customTitle,
    siteUrl,
    iconUrl,
    description,
    folderId,
    etag,
    lastModified,
    lastFetchedAt,
    lastError,
    errorCount,
    fullText,
    neverBundle,
    remoteId,
    addedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Feed &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.customTitle == this.customTitle &&
          other.siteUrl == this.siteUrl &&
          other.iconUrl == this.iconUrl &&
          other.description == this.description &&
          other.folderId == this.folderId &&
          other.etag == this.etag &&
          other.lastModified == this.lastModified &&
          other.lastFetchedAt == this.lastFetchedAt &&
          other.lastError == this.lastError &&
          other.errorCount == this.errorCount &&
          other.fullText == this.fullText &&
          other.neverBundle == this.neverBundle &&
          other.remoteId == this.remoteId &&
          other.addedAt == this.addedAt);
}

class FeedsCompanion extends UpdateCompanion<Feed> {
  final Value<int> id;
  final Value<String> url;
  final Value<String> title;
  final Value<String?> customTitle;
  final Value<String?> siteUrl;
  final Value<String?> iconUrl;
  final Value<String?> description;
  final Value<int?> folderId;
  final Value<String?> etag;
  final Value<String?> lastModified;
  final Value<DateTime?> lastFetchedAt;
  final Value<String?> lastError;
  final Value<int> errorCount;
  final Value<bool> fullText;
  final Value<bool> neverBundle;
  final Value<String?> remoteId;
  final Value<DateTime> addedAt;
  const FeedsCompanion({
    this.id = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.customTitle = const Value.absent(),
    this.siteUrl = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.folderId = const Value.absent(),
    this.etag = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.lastFetchedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.errorCount = const Value.absent(),
    this.fullText = const Value.absent(),
    this.neverBundle = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  FeedsCompanion.insert({
    this.id = const Value.absent(),
    required String url,
    required String title,
    this.customTitle = const Value.absent(),
    this.siteUrl = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.folderId = const Value.absent(),
    this.etag = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.lastFetchedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.errorCount = const Value.absent(),
    this.fullText = const Value.absent(),
    this.neverBundle = const Value.absent(),
    this.remoteId = const Value.absent(),
    required DateTime addedAt,
  }) : url = Value(url),
       title = Value(title),
       addedAt = Value(addedAt);
  static Insertable<Feed> custom({
    Expression<int>? id,
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? customTitle,
    Expression<String>? siteUrl,
    Expression<String>? iconUrl,
    Expression<String>? description,
    Expression<int>? folderId,
    Expression<String>? etag,
    Expression<String>? lastModified,
    Expression<DateTime>? lastFetchedAt,
    Expression<String>? lastError,
    Expression<int>? errorCount,
    Expression<bool>? fullText,
    Expression<bool>? neverBundle,
    Expression<String>? remoteId,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (customTitle != null) 'custom_title': customTitle,
      if (siteUrl != null) 'site_url': siteUrl,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (description != null) 'description': description,
      if (folderId != null) 'folder_id': folderId,
      if (etag != null) 'etag': etag,
      if (lastModified != null) 'last_modified': lastModified,
      if (lastFetchedAt != null) 'last_fetched_at': lastFetchedAt,
      if (lastError != null) 'last_error': lastError,
      if (errorCount != null) 'error_count': errorCount,
      if (fullText != null) 'full_text': fullText,
      if (neverBundle != null) 'never_bundle': neverBundle,
      if (remoteId != null) 'remote_id': remoteId,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  FeedsCompanion copyWith({
    Value<int>? id,
    Value<String>? url,
    Value<String>? title,
    Value<String?>? customTitle,
    Value<String?>? siteUrl,
    Value<String?>? iconUrl,
    Value<String?>? description,
    Value<int?>? folderId,
    Value<String?>? etag,
    Value<String?>? lastModified,
    Value<DateTime?>? lastFetchedAt,
    Value<String?>? lastError,
    Value<int>? errorCount,
    Value<bool>? fullText,
    Value<bool>? neverBundle,
    Value<String?>? remoteId,
    Value<DateTime>? addedAt,
  }) {
    return FeedsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      customTitle: customTitle ?? this.customTitle,
      siteUrl: siteUrl ?? this.siteUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      description: description ?? this.description,
      folderId: folderId ?? this.folderId,
      etag: etag ?? this.etag,
      lastModified: lastModified ?? this.lastModified,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      lastError: lastError ?? this.lastError,
      errorCount: errorCount ?? this.errorCount,
      fullText: fullText ?? this.fullText,
      neverBundle: neverBundle ?? this.neverBundle,
      remoteId: remoteId ?? this.remoteId,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (customTitle.present) {
      map['custom_title'] = Variable<String>(customTitle.value);
    }
    if (siteUrl.present) {
      map['site_url'] = Variable<String>(siteUrl.value);
    }
    if (iconUrl.present) {
      map['icon_url'] = Variable<String>(iconUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<String>(lastModified.value);
    }
    if (lastFetchedAt.present) {
      map['last_fetched_at'] = Variable<DateTime>(lastFetchedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (errorCount.present) {
      map['error_count'] = Variable<int>(errorCount.value);
    }
    if (fullText.present) {
      map['full_text'] = Variable<bool>(fullText.value);
    }
    if (neverBundle.present) {
      map['never_bundle'] = Variable<bool>(neverBundle.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('customTitle: $customTitle, ')
          ..write('siteUrl: $siteUrl, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('description: $description, ')
          ..write('folderId: $folderId, ')
          ..write('etag: $etag, ')
          ..write('lastModified: $lastModified, ')
          ..write('lastFetchedAt: $lastFetchedAt, ')
          ..write('lastError: $lastError, ')
          ..write('errorCount: $errorCount, ')
          ..write('fullText: $fullText, ')
          ..write('neverBundle: $neverBundle, ')
          ..write('remoteId: $remoteId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $ArticlesTable extends Articles with TableInfo<$ArticlesTable, Article> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArticlesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<int> feedId = GeneratedColumn<int>(
    'feed_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES feeds (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _guidMeta = const VerificationMeta('guid');
  @override
  late final GeneratedColumn<String> guid = GeneratedColumn<String>(
    'guid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contentHtmlMeta = const VerificationMeta(
    'contentHtml',
  );
  @override
  late final GeneratedColumn<String> contentHtml = GeneratedColumn<String>(
    'content_html',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fullHtmlMeta = const VerificationMeta(
    'fullHtml',
  );
  @override
  late final GeneratedColumn<String> fullHtml = GeneratedColumn<String>(
    'full_html',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hiddenMeta = const VerificationMeta('hidden');
  @override
  late final GeneratedColumn<bool> hidden = GeneratedColumn<bool>(
    'hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _readingMinutesMeta = const VerificationMeta(
    'readingMinutes',
  );
  @override
  late final GeneratedColumn<int> readingMinutes = GeneratedColumn<int>(
    'reading_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _categoriesMeta = const VerificationMeta(
    'categories',
  );
  @override
  late final GeneratedColumn<String> categories = GeneratedColumn<String>(
    'categories',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    feedId,
    guid,
    url,
    title,
    author,
    summary,
    contentHtml,
    fullHtml,
    imageUrl,
    publishedAt,
    fetchedAt,
    readAt,
    savedAt,
    archivedAt,
    hidden,
    readingMinutes,
    categories,
    remoteId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'articles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Article> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('feed_id')) {
      context.handle(
        _feedIdMeta,
        feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta),
      );
    } else if (isInserting) {
      context.missing(_feedIdMeta);
    }
    if (data.containsKey('guid')) {
      context.handle(
        _guidMeta,
        guid.isAcceptableOrUnknown(data['guid']!, _guidMeta),
      );
    } else if (isInserting) {
      context.missing(_guidMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('content_html')) {
      context.handle(
        _contentHtmlMeta,
        contentHtml.isAcceptableOrUnknown(
          data['content_html']!,
          _contentHtmlMeta,
        ),
      );
    }
    if (data.containsKey('full_html')) {
      context.handle(
        _fullHtmlMeta,
        fullHtml.isAcceptableOrUnknown(data['full_html']!, _fullHtmlMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publishedAtMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('hidden')) {
      context.handle(
        _hiddenMeta,
        hidden.isAcceptableOrUnknown(data['hidden']!, _hiddenMeta),
      );
    }
    if (data.containsKey('reading_minutes')) {
      context.handle(
        _readingMinutesMeta,
        readingMinutes.isAcceptableOrUnknown(
          data['reading_minutes']!,
          _readingMinutesMeta,
        ),
      );
    }
    if (data.containsKey('categories')) {
      context.handle(
        _categoriesMeta,
        categories.isAcceptableOrUnknown(data['categories']!, _categoriesMeta),
      );
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {feedId, guid},
  ];
  @override
  Article map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Article(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      feedId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feed_id'],
      )!,
      guid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guid'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      contentHtml: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_html'],
      ),
      fullHtml: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_html'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      ),
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      hidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}hidden'],
      )!,
      readingMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reading_minutes'],
      )!,
      categories: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categories'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
    );
  }

  @override
  $ArticlesTable createAlias(String alias) {
    return $ArticlesTable(attachedDatabase, alias);
  }
}

class Article extends DataClass implements Insertable<Article> {
  final int id;
  final int feedId;
  final String guid;
  final String? url;
  final String title;
  final String? author;

  /// Plain-text teaser for the list, at most a few hundred characters.
  final String summary;
  final String? contentHtml;

  /// The extracted full text, filled on demand or by [Feeds.fullText].
  final String? fullHtml;
  final String? imageUrl;
  final DateTime publishedAt;
  final DateTime fetchedAt;
  final DateTime? readAt;
  final DateTime? savedAt;

  /// Set when an unread article drifted out of Heute (the "Ernte").
  final DateTime? archivedAt;

  /// Hidden by a filter rule ("Graben").
  final bool hidden;
  final int readingMinutes;

  /// Categories joined by U+001F.
  final String categories;
  final String? remoteId;
  const Article({
    required this.id,
    required this.feedId,
    required this.guid,
    this.url,
    required this.title,
    this.author,
    required this.summary,
    this.contentHtml,
    this.fullHtml,
    this.imageUrl,
    required this.publishedAt,
    required this.fetchedAt,
    this.readAt,
    this.savedAt,
    this.archivedAt,
    required this.hidden,
    required this.readingMinutes,
    required this.categories,
    this.remoteId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['feed_id'] = Variable<int>(feedId);
    map['guid'] = Variable<String>(guid);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    map['summary'] = Variable<String>(summary);
    if (!nullToAbsent || contentHtml != null) {
      map['content_html'] = Variable<String>(contentHtml);
    }
    if (!nullToAbsent || fullHtml != null) {
      map['full_html'] = Variable<String>(fullHtml);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['published_at'] = Variable<DateTime>(publishedAt);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    if (!nullToAbsent || savedAt != null) {
      map['saved_at'] = Variable<DateTime>(savedAt);
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['hidden'] = Variable<bool>(hidden);
    map['reading_minutes'] = Variable<int>(readingMinutes);
    map['categories'] = Variable<String>(categories);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    return map;
  }

  ArticlesCompanion toCompanion(bool nullToAbsent) {
    return ArticlesCompanion(
      id: Value(id),
      feedId: Value(feedId),
      guid: Value(guid),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      title: Value(title),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      summary: Value(summary),
      contentHtml: contentHtml == null && nullToAbsent
          ? const Value.absent()
          : Value(contentHtml),
      fullHtml: fullHtml == null && nullToAbsent
          ? const Value.absent()
          : Value(fullHtml),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      publishedAt: Value(publishedAt),
      fetchedAt: Value(fetchedAt),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      savedAt: savedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(savedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      hidden: Value(hidden),
      readingMinutes: Value(readingMinutes),
      categories: Value(categories),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
    );
  }

  factory Article.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Article(
      id: serializer.fromJson<int>(json['id']),
      feedId: serializer.fromJson<int>(json['feedId']),
      guid: serializer.fromJson<String>(json['guid']),
      url: serializer.fromJson<String?>(json['url']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String?>(json['author']),
      summary: serializer.fromJson<String>(json['summary']),
      contentHtml: serializer.fromJson<String?>(json['contentHtml']),
      fullHtml: serializer.fromJson<String?>(json['fullHtml']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      publishedAt: serializer.fromJson<DateTime>(json['publishedAt']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      savedAt: serializer.fromJson<DateTime?>(json['savedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      hidden: serializer.fromJson<bool>(json['hidden']),
      readingMinutes: serializer.fromJson<int>(json['readingMinutes']),
      categories: serializer.fromJson<String>(json['categories']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'feedId': serializer.toJson<int>(feedId),
      'guid': serializer.toJson<String>(guid),
      'url': serializer.toJson<String?>(url),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String?>(author),
      'summary': serializer.toJson<String>(summary),
      'contentHtml': serializer.toJson<String?>(contentHtml),
      'fullHtml': serializer.toJson<String?>(fullHtml),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'publishedAt': serializer.toJson<DateTime>(publishedAt),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'savedAt': serializer.toJson<DateTime?>(savedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'hidden': serializer.toJson<bool>(hidden),
      'readingMinutes': serializer.toJson<int>(readingMinutes),
      'categories': serializer.toJson<String>(categories),
      'remoteId': serializer.toJson<String?>(remoteId),
    };
  }

  Article copyWith({
    int? id,
    int? feedId,
    String? guid,
    Value<String?> url = const Value.absent(),
    String? title,
    Value<String?> author = const Value.absent(),
    String? summary,
    Value<String?> contentHtml = const Value.absent(),
    Value<String?> fullHtml = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    DateTime? publishedAt,
    DateTime? fetchedAt,
    Value<DateTime?> readAt = const Value.absent(),
    Value<DateTime?> savedAt = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
    bool? hidden,
    int? readingMinutes,
    String? categories,
    Value<String?> remoteId = const Value.absent(),
  }) => Article(
    id: id ?? this.id,
    feedId: feedId ?? this.feedId,
    guid: guid ?? this.guid,
    url: url.present ? url.value : this.url,
    title: title ?? this.title,
    author: author.present ? author.value : this.author,
    summary: summary ?? this.summary,
    contentHtml: contentHtml.present ? contentHtml.value : this.contentHtml,
    fullHtml: fullHtml.present ? fullHtml.value : this.fullHtml,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    publishedAt: publishedAt ?? this.publishedAt,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    readAt: readAt.present ? readAt.value : this.readAt,
    savedAt: savedAt.present ? savedAt.value : this.savedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    hidden: hidden ?? this.hidden,
    readingMinutes: readingMinutes ?? this.readingMinutes,
    categories: categories ?? this.categories,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
  );
  Article copyWithCompanion(ArticlesCompanion data) {
    return Article(
      id: data.id.present ? data.id.value : this.id,
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      guid: data.guid.present ? data.guid.value : this.guid,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      summary: data.summary.present ? data.summary.value : this.summary,
      contentHtml: data.contentHtml.present
          ? data.contentHtml.value
          : this.contentHtml,
      fullHtml: data.fullHtml.present ? data.fullHtml.value : this.fullHtml,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      hidden: data.hidden.present ? data.hidden.value : this.hidden,
      readingMinutes: data.readingMinutes.present
          ? data.readingMinutes.value
          : this.readingMinutes,
      categories: data.categories.present
          ? data.categories.value
          : this.categories,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Article(')
          ..write('id: $id, ')
          ..write('feedId: $feedId, ')
          ..write('guid: $guid, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('summary: $summary, ')
          ..write('contentHtml: $contentHtml, ')
          ..write('fullHtml: $fullHtml, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('readAt: $readAt, ')
          ..write('savedAt: $savedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('hidden: $hidden, ')
          ..write('readingMinutes: $readingMinutes, ')
          ..write('categories: $categories, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    feedId,
    guid,
    url,
    title,
    author,
    summary,
    contentHtml,
    fullHtml,
    imageUrl,
    publishedAt,
    fetchedAt,
    readAt,
    savedAt,
    archivedAt,
    hidden,
    readingMinutes,
    categories,
    remoteId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Article &&
          other.id == this.id &&
          other.feedId == this.feedId &&
          other.guid == this.guid &&
          other.url == this.url &&
          other.title == this.title &&
          other.author == this.author &&
          other.summary == this.summary &&
          other.contentHtml == this.contentHtml &&
          other.fullHtml == this.fullHtml &&
          other.imageUrl == this.imageUrl &&
          other.publishedAt == this.publishedAt &&
          other.fetchedAt == this.fetchedAt &&
          other.readAt == this.readAt &&
          other.savedAt == this.savedAt &&
          other.archivedAt == this.archivedAt &&
          other.hidden == this.hidden &&
          other.readingMinutes == this.readingMinutes &&
          other.categories == this.categories &&
          other.remoteId == this.remoteId);
}

class ArticlesCompanion extends UpdateCompanion<Article> {
  final Value<int> id;
  final Value<int> feedId;
  final Value<String> guid;
  final Value<String?> url;
  final Value<String> title;
  final Value<String?> author;
  final Value<String> summary;
  final Value<String?> contentHtml;
  final Value<String?> fullHtml;
  final Value<String?> imageUrl;
  final Value<DateTime> publishedAt;
  final Value<DateTime> fetchedAt;
  final Value<DateTime?> readAt;
  final Value<DateTime?> savedAt;
  final Value<DateTime?> archivedAt;
  final Value<bool> hidden;
  final Value<int> readingMinutes;
  final Value<String> categories;
  final Value<String?> remoteId;
  const ArticlesCompanion({
    this.id = const Value.absent(),
    this.feedId = const Value.absent(),
    this.guid = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.summary = const Value.absent(),
    this.contentHtml = const Value.absent(),
    this.fullHtml = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.hidden = const Value.absent(),
    this.readingMinutes = const Value.absent(),
    this.categories = const Value.absent(),
    this.remoteId = const Value.absent(),
  });
  ArticlesCompanion.insert({
    this.id = const Value.absent(),
    required int feedId,
    required String guid,
    this.url = const Value.absent(),
    required String title,
    this.author = const Value.absent(),
    this.summary = const Value.absent(),
    this.contentHtml = const Value.absent(),
    this.fullHtml = const Value.absent(),
    this.imageUrl = const Value.absent(),
    required DateTime publishedAt,
    required DateTime fetchedAt,
    this.readAt = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.hidden = const Value.absent(),
    this.readingMinutes = const Value.absent(),
    this.categories = const Value.absent(),
    this.remoteId = const Value.absent(),
  }) : feedId = Value(feedId),
       guid = Value(guid),
       title = Value(title),
       publishedAt = Value(publishedAt),
       fetchedAt = Value(fetchedAt);
  static Insertable<Article> custom({
    Expression<int>? id,
    Expression<int>? feedId,
    Expression<String>? guid,
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? summary,
    Expression<String>? contentHtml,
    Expression<String>? fullHtml,
    Expression<String>? imageUrl,
    Expression<DateTime>? publishedAt,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? readAt,
    Expression<DateTime>? savedAt,
    Expression<DateTime>? archivedAt,
    Expression<bool>? hidden,
    Expression<int>? readingMinutes,
    Expression<String>? categories,
    Expression<String>? remoteId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feedId != null) 'feed_id': feedId,
      if (guid != null) 'guid': guid,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (summary != null) 'summary': summary,
      if (contentHtml != null) 'content_html': contentHtml,
      if (fullHtml != null) 'full_html': fullHtml,
      if (imageUrl != null) 'image_url': imageUrl,
      if (publishedAt != null) 'published_at': publishedAt,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (readAt != null) 'read_at': readAt,
      if (savedAt != null) 'saved_at': savedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (hidden != null) 'hidden': hidden,
      if (readingMinutes != null) 'reading_minutes': readingMinutes,
      if (categories != null) 'categories': categories,
      if (remoteId != null) 'remote_id': remoteId,
    });
  }

  ArticlesCompanion copyWith({
    Value<int>? id,
    Value<int>? feedId,
    Value<String>? guid,
    Value<String?>? url,
    Value<String>? title,
    Value<String?>? author,
    Value<String>? summary,
    Value<String?>? contentHtml,
    Value<String?>? fullHtml,
    Value<String?>? imageUrl,
    Value<DateTime>? publishedAt,
    Value<DateTime>? fetchedAt,
    Value<DateTime?>? readAt,
    Value<DateTime?>? savedAt,
    Value<DateTime?>? archivedAt,
    Value<bool>? hidden,
    Value<int>? readingMinutes,
    Value<String>? categories,
    Value<String?>? remoteId,
  }) {
    return ArticlesCompanion(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      guid: guid ?? this.guid,
      url: url ?? this.url,
      title: title ?? this.title,
      author: author ?? this.author,
      summary: summary ?? this.summary,
      contentHtml: contentHtml ?? this.contentHtml,
      fullHtml: fullHtml ?? this.fullHtml,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      readAt: readAt ?? this.readAt,
      savedAt: savedAt ?? this.savedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      hidden: hidden ?? this.hidden,
      readingMinutes: readingMinutes ?? this.readingMinutes,
      categories: categories ?? this.categories,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (feedId.present) {
      map['feed_id'] = Variable<int>(feedId.value);
    }
    if (guid.present) {
      map['guid'] = Variable<String>(guid.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (contentHtml.present) {
      map['content_html'] = Variable<String>(contentHtml.value);
    }
    if (fullHtml.present) {
      map['full_html'] = Variable<String>(fullHtml.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (hidden.present) {
      map['hidden'] = Variable<bool>(hidden.value);
    }
    if (readingMinutes.present) {
      map['reading_minutes'] = Variable<int>(readingMinutes.value);
    }
    if (categories.present) {
      map['categories'] = Variable<String>(categories.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticlesCompanion(')
          ..write('id: $id, ')
          ..write('feedId: $feedId, ')
          ..write('guid: $guid, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('summary: $summary, ')
          ..write('contentHtml: $contentHtml, ')
          ..write('fullHtml: $fullHtml, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('readAt: $readAt, ')
          ..write('savedAt: $savedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('hidden: $hidden, ')
          ..write('readingMinutes: $readingMinutes, ')
          ..write('categories: $categories, ')
          ..write('remoteId: $remoteId')
          ..write(')'))
        .toString();
  }
}

class $RulesTable extends Rules with TableInfo<$RulesTable, Rule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _patternMeta = const VerificationMeta(
    'pattern',
  );
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
    'pattern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<int> field = GeneratedColumn<int>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<int> feedId = GeneratedColumn<int>(
    'feed_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES feeds (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<int> action = GeneratedColumn<int>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pattern,
    field,
    feedId,
    action,
    enabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<Rule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pattern')) {
      context.handle(
        _patternMeta,
        pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta),
      );
    } else if (isInserting) {
      context.missing(_patternMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    }
    if (data.containsKey('feed_id')) {
      context.handle(
        _feedIdMeta,
        feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Rule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Rule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}field'],
      )!,
      feedId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feed_id'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}action'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $RulesTable createAlias(String alias) {
    return $RulesTable(attachedDatabase, alias);
  }
}

class Rule extends DataClass implements Insertable<Rule> {
  final int id;
  final String pattern;

  /// 0 title or text, 1 title only, 2 author.
  final int field;

  /// Limits the rule to one feed; null for all.
  final int? feedId;

  /// 0 hide, 1 mark read.
  final int action;
  final bool enabled;
  const Rule({
    required this.id,
    required this.pattern,
    required this.field,
    this.feedId,
    required this.action,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pattern'] = Variable<String>(pattern);
    map['field'] = Variable<int>(field);
    if (!nullToAbsent || feedId != null) {
      map['feed_id'] = Variable<int>(feedId);
    }
    map['action'] = Variable<int>(action);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  RulesCompanion toCompanion(bool nullToAbsent) {
    return RulesCompanion(
      id: Value(id),
      pattern: Value(pattern),
      field: Value(field),
      feedId: feedId == null && nullToAbsent
          ? const Value.absent()
          : Value(feedId),
      action: Value(action),
      enabled: Value(enabled),
    );
  }

  factory Rule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Rule(
      id: serializer.fromJson<int>(json['id']),
      pattern: serializer.fromJson<String>(json['pattern']),
      field: serializer.fromJson<int>(json['field']),
      feedId: serializer.fromJson<int?>(json['feedId']),
      action: serializer.fromJson<int>(json['action']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pattern': serializer.toJson<String>(pattern),
      'field': serializer.toJson<int>(field),
      'feedId': serializer.toJson<int?>(feedId),
      'action': serializer.toJson<int>(action),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  Rule copyWith({
    int? id,
    String? pattern,
    int? field,
    Value<int?> feedId = const Value.absent(),
    int? action,
    bool? enabled,
  }) => Rule(
    id: id ?? this.id,
    pattern: pattern ?? this.pattern,
    field: field ?? this.field,
    feedId: feedId.present ? feedId.value : this.feedId,
    action: action ?? this.action,
    enabled: enabled ?? this.enabled,
  );
  Rule copyWithCompanion(RulesCompanion data) {
    return Rule(
      id: data.id.present ? data.id.value : this.id,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      field: data.field.present ? data.field.value : this.field,
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      action: data.action.present ? data.action.value : this.action,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Rule(')
          ..write('id: $id, ')
          ..write('pattern: $pattern, ')
          ..write('field: $field, ')
          ..write('feedId: $feedId, ')
          ..write('action: $action, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pattern, field, feedId, action, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Rule &&
          other.id == this.id &&
          other.pattern == this.pattern &&
          other.field == this.field &&
          other.feedId == this.feedId &&
          other.action == this.action &&
          other.enabled == this.enabled);
}

class RulesCompanion extends UpdateCompanion<Rule> {
  final Value<int> id;
  final Value<String> pattern;
  final Value<int> field;
  final Value<int?> feedId;
  final Value<int> action;
  final Value<bool> enabled;
  const RulesCompanion({
    this.id = const Value.absent(),
    this.pattern = const Value.absent(),
    this.field = const Value.absent(),
    this.feedId = const Value.absent(),
    this.action = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  RulesCompanion.insert({
    this.id = const Value.absent(),
    required String pattern,
    this.field = const Value.absent(),
    this.feedId = const Value.absent(),
    this.action = const Value.absent(),
    this.enabled = const Value.absent(),
  }) : pattern = Value(pattern);
  static Insertable<Rule> custom({
    Expression<int>? id,
    Expression<String>? pattern,
    Expression<int>? field,
    Expression<int>? feedId,
    Expression<int>? action,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pattern != null) 'pattern': pattern,
      if (field != null) 'field': field,
      if (feedId != null) 'feed_id': feedId,
      if (action != null) 'action': action,
      if (enabled != null) 'enabled': enabled,
    });
  }

  RulesCompanion copyWith({
    Value<int>? id,
    Value<String>? pattern,
    Value<int>? field,
    Value<int?>? feedId,
    Value<int>? action,
    Value<bool>? enabled,
  }) {
    return RulesCompanion(
      id: id ?? this.id,
      pattern: pattern ?? this.pattern,
      field: field ?? this.field,
      feedId: feedId ?? this.feedId,
      action: action ?? this.action,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (field.present) {
      map['field'] = Variable<int>(field.value);
    }
    if (feedId.present) {
      map['feed_id'] = Variable<int>(feedId.value);
    }
    if (action.present) {
      map['action'] = Variable<int>(action.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RulesCompanion(')
          ..write('id: $id, ')
          ..write('pattern: $pattern, ')
          ..write('field: $field, ')
          ..write('feedId: $feedId, ')
          ..write('action: $action, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

class $ReadEventsTable extends ReadEvents
    with TableInfo<$ReadEventsTable, ReadEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadEventsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _feedIdMeta = const VerificationMeta('feedId');
  @override
  late final GeneratedColumn<int> feedId = GeneratedColumn<int>(
    'feed_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES feeds (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
    'minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, feedId, at, minutes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'read_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('feed_id')) {
      context.handle(
        _feedIdMeta,
        feedId.isAcceptableOrUnknown(data['feed_id']!, _feedIdMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      feedId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}feed_id'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes'],
      )!,
    );
  }

  @override
  $ReadEventsTable createAlias(String alias) {
    return $ReadEventsTable(attachedDatabase, alias);
  }
}

class ReadEvent extends DataClass implements Insertable<ReadEvent> {
  final int id;
  final int? feedId;
  final DateTime at;
  final int minutes;
  const ReadEvent({
    required this.id,
    this.feedId,
    required this.at,
    required this.minutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || feedId != null) {
      map['feed_id'] = Variable<int>(feedId);
    }
    map['at'] = Variable<DateTime>(at);
    map['minutes'] = Variable<int>(minutes);
    return map;
  }

  ReadEventsCompanion toCompanion(bool nullToAbsent) {
    return ReadEventsCompanion(
      id: Value(id),
      feedId: feedId == null && nullToAbsent
          ? const Value.absent()
          : Value(feedId),
      at: Value(at),
      minutes: Value(minutes),
    );
  }

  factory ReadEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadEvent(
      id: serializer.fromJson<int>(json['id']),
      feedId: serializer.fromJson<int?>(json['feedId']),
      at: serializer.fromJson<DateTime>(json['at']),
      minutes: serializer.fromJson<int>(json['minutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'feedId': serializer.toJson<int?>(feedId),
      'at': serializer.toJson<DateTime>(at),
      'minutes': serializer.toJson<int>(minutes),
    };
  }

  ReadEvent copyWith({
    int? id,
    Value<int?> feedId = const Value.absent(),
    DateTime? at,
    int? minutes,
  }) => ReadEvent(
    id: id ?? this.id,
    feedId: feedId.present ? feedId.value : this.feedId,
    at: at ?? this.at,
    minutes: minutes ?? this.minutes,
  );
  ReadEvent copyWithCompanion(ReadEventsCompanion data) {
    return ReadEvent(
      id: data.id.present ? data.id.value : this.id,
      feedId: data.feedId.present ? data.feedId.value : this.feedId,
      at: data.at.present ? data.at.value : this.at,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadEvent(')
          ..write('id: $id, ')
          ..write('feedId: $feedId, ')
          ..write('at: $at, ')
          ..write('minutes: $minutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, feedId, at, minutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadEvent &&
          other.id == this.id &&
          other.feedId == this.feedId &&
          other.at == this.at &&
          other.minutes == this.minutes);
}

class ReadEventsCompanion extends UpdateCompanion<ReadEvent> {
  final Value<int> id;
  final Value<int?> feedId;
  final Value<DateTime> at;
  final Value<int> minutes;
  const ReadEventsCompanion({
    this.id = const Value.absent(),
    this.feedId = const Value.absent(),
    this.at = const Value.absent(),
    this.minutes = const Value.absent(),
  });
  ReadEventsCompanion.insert({
    this.id = const Value.absent(),
    this.feedId = const Value.absent(),
    required DateTime at,
    this.minutes = const Value.absent(),
  }) : at = Value(at);
  static Insertable<ReadEvent> custom({
    Expression<int>? id,
    Expression<int>? feedId,
    Expression<DateTime>? at,
    Expression<int>? minutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feedId != null) 'feed_id': feedId,
      if (at != null) 'at': at,
      if (minutes != null) 'minutes': minutes,
    });
  }

  ReadEventsCompanion copyWith({
    Value<int>? id,
    Value<int?>? feedId,
    Value<DateTime>? at,
    Value<int>? minutes,
  }) {
    return ReadEventsCompanion(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      at: at ?? this.at,
      minutes: minutes ?? this.minutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (feedId.present) {
      map['feed_id'] = Variable<int>(feedId.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadEventsCompanion(')
          ..write('id: $id, ')
          ..write('feedId: $feedId, ')
          ..write('at: $at, ')
          ..write('minutes: $minutes')
          ..write(')'))
        .toString();
  }
}

class $SyncOpsTable extends SyncOps with TableInfo<$SyncOpsTable, SyncOp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOpsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
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
  @override
  List<GeneratedColumn> get $columns => [id, remoteId, kind, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_ops';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_remoteIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
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
  SyncOp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOp(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncOpsTable createAlias(String alias) {
    return $SyncOpsTable(attachedDatabase, alias);
  }
}

class SyncOp extends DataClass implements Insertable<SyncOp> {
  final int id;
  final String remoteId;

  /// `read`, `unread`, `star` or `unstar`.
  final String kind;
  final DateTime createdAt;
  const SyncOp({
    required this.id,
    required this.remoteId,
    required this.kind,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['remote_id'] = Variable<String>(remoteId);
    map['kind'] = Variable<String>(kind);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncOpsCompanion toCompanion(bool nullToAbsent) {
    return SyncOpsCompanion(
      id: Value(id),
      remoteId: Value(remoteId),
      kind: Value(kind),
      createdAt: Value(createdAt),
    );
  }

  factory SyncOp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOp(
      id: serializer.fromJson<int>(json['id']),
      remoteId: serializer.fromJson<String>(json['remoteId']),
      kind: serializer.fromJson<String>(json['kind']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'remoteId': serializer.toJson<String>(remoteId),
      'kind': serializer.toJson<String>(kind),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncOp copyWith({
    int? id,
    String? remoteId,
    String? kind,
    DateTime? createdAt,
  }) => SyncOp(
    id: id ?? this.id,
    remoteId: remoteId ?? this.remoteId,
    kind: kind ?? this.kind,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncOp copyWithCompanion(SyncOpsCompanion data) {
    return SyncOp(
      id: data.id.present ? data.id.value : this.id,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      kind: data.kind.present ? data.kind.value : this.kind,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOp(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, remoteId, kind, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOp &&
          other.id == this.id &&
          other.remoteId == this.remoteId &&
          other.kind == this.kind &&
          other.createdAt == this.createdAt);
}

class SyncOpsCompanion extends UpdateCompanion<SyncOp> {
  final Value<int> id;
  final Value<String> remoteId;
  final Value<String> kind;
  final Value<DateTime> createdAt;
  const SyncOpsCompanion({
    this.id = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.kind = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncOpsCompanion.insert({
    this.id = const Value.absent(),
    required String remoteId,
    required String kind,
    required DateTime createdAt,
  }) : remoteId = Value(remoteId),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<SyncOp> custom({
    Expression<int>? id,
    Expression<String>? remoteId,
    Expression<String>? kind,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (remoteId != null) 'remote_id': remoteId,
      if (kind != null) 'kind': kind,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncOpsCompanion copyWith({
    Value<int>? id,
    Value<String>? remoteId,
    Value<String>? kind,
    Value<DateTime>? createdAt,
  }) {
    return SyncOpsCompanion(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOpsCompanion(')
          ..write('id: $id, ')
          ..write('remoteId: $remoteId, ')
          ..write('kind: $kind, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$LandboteDatabase extends GeneratedDatabase {
  _$LandboteDatabase(QueryExecutor e) : super(e);
  $LandboteDatabaseManager get managers => $LandboteDatabaseManager(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $FeedsTable feeds = $FeedsTable(this);
  late final $ArticlesTable articles = $ArticlesTable(this);
  late final $RulesTable rules = $RulesTable(this);
  late final $ReadEventsTable readEvents = $ReadEventsTable(this);
  late final $SyncOpsTable syncOps = $SyncOpsTable(this);
  late final Index articlesPublished = Index(
    'articles_published',
    'CREATE INDEX articles_published ON articles (published_at)',
  );
  late final Index articlesFeed = Index(
    'articles_feed',
    'CREATE INDEX articles_feed ON articles (feed_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    folders,
    feeds,
    articles,
    rules,
    readEvents,
    syncOps,
    articlesPublished,
    articlesFeed,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'folders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('feeds', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'feeds',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('articles', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'feeds',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rules', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'feeds',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('read_events', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$FoldersTableCreateCompanionBuilder = FoldersCompanion Function({
  Value<int> id,
  required String name,
  Value<int> position,
});
typedef $$FoldersTableUpdateCompanionBuilder = FoldersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> position,
});

final class $$FoldersTableReferences
    extends BaseReferences<_$LandboteDatabase, $FoldersTable, Folder> {
  $$FoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FeedsTable, List<Feed>> _feedsRefsTable(
    _$LandboteDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.feeds,
    aliasName: 'folders__id__feeds__folder_id',
  );

  $$FeedsTableProcessedTableManager get feedsRefs {
    final manager = $$FeedsTableTableManager(
      $_db,
      $_db.feeds,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_feedsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoldersTableFilterComposer
    extends Composer<_$LandboteDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> feedsRefs(
    Expression<bool> Function($$FeedsTableFilterComposer f) f,
  ) {
    final $$FeedsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feeds,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedsTableFilterComposer(
            $db: $db,
            $table: $db.feeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableOrderingComposer
    extends Composer<_$LandboteDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$LandboteDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  Expression<T> feedsRefs<T extends Object>(
    Expression<T> Function($$FeedsTableAnnotationComposer a) f,
  ) {
    final $$FeedsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.feeds,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedsTableAnnotationComposer(
            $db: $db,
            $table: $db.feeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$LandboteDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, $$FoldersTableReferences),
          Folder,
          PrefetchHooks Function({bool feedsRefs})
        > {
  $$FoldersTableTableManager(_$LandboteDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> position = const Value.absent(),
          }) => FoldersCompanion(id: id, name: name, position: position),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int> position = const Value.absent(),
          }) => FoldersCompanion.insert(id: id, name: name, position: position),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoldersTable, Folder>(table),
                  $$FoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({feedsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (feedsRefs) db.feeds],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (feedsRefs)
                    await $_getPrefetchedDataByColumns<
                      Folder,
                      $FoldersTable,
                      Feed,
                      $FeedsTable
                    >(
                      currentTable: table,
                      referencedTable: $$FoldersTableReferences._feedsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$FoldersTableReferences(db, table, p0).feedsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'folder_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$LandboteDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, $$FoldersTableReferences),
      Folder,
      PrefetchHooks Function({bool feedsRefs})
    >;
typedef $$FeedsTableCreateCompanionBuilder = FeedsCompanion Function({
  Value<int> id,
  required String url,
  required String title,
  Value<String?> customTitle,
  Value<String?> siteUrl,
  Value<String?> iconUrl,
  Value<String?> description,
  Value<int?> folderId,
  Value<String?> etag,
  Value<String?> lastModified,
  Value<DateTime?> lastFetchedAt,
  Value<String?> lastError,
  Value<int> errorCount,
  Value<bool> fullText,
  Value<bool> neverBundle,
  Value<String?> remoteId,
  required DateTime addedAt,
});
typedef $$FeedsTableUpdateCompanionBuilder = FeedsCompanion Function({
  Value<int> id,
  Value<String> url,
  Value<String> title,
  Value<String?> customTitle,
  Value<String?> siteUrl,
  Value<String?> iconUrl,
  Value<String?> description,
  Value<int?> folderId,
  Value<String?> etag,
  Value<String?> lastModified,
  Value<DateTime?> lastFetchedAt,
  Value<String?> lastError,
  Value<int> errorCount,
  Value<bool> fullText,
  Value<bool> neverBundle,
  Value<String?> remoteId,
  Value<DateTime> addedAt,
});

final class $$FeedsTableReferences
    extends BaseReferences<_$LandboteDatabase, $FeedsTable, Feed> {
  $$FeedsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$LandboteDatabase db) =>
      db.folders.createAlias('feeds__folder_id__folders__id');

  $$FoldersTableProcessedTableManager? get folderId {
    final $_column = $_itemColumn<int>('folder_id');
    if ($_column == null) return null;
    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ArticlesTable, List<Article>> _articlesRefsTable(
    _$LandboteDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.articles,
    aliasName: 'feeds__id__articles__feed_id',
  );

  $$ArticlesTableProcessedTableManager get articlesRefs {
    final manager = $$ArticlesTableTableManager(
      $_db,
      $_db.articles,
    ).filter((f) => f.feedId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_articlesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RulesTable, List<Rule>> _rulesRefsTable(
    _$LandboteDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.rules,
    aliasName: 'feeds__id__rules__feed_id',
  );

  $$RulesTableProcessedTableManager get rulesRefs {
    final manager = $$RulesTableTableManager(
      $_db,
      $_db.rules,
    ).filter((f) => f.feedId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_rulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadEventsTable, List<ReadEvent>>
  _readEventsRefsTable(_$LandboteDatabase db) => MultiTypedResultKey.fromTable(
    db.readEvents,
    aliasName: 'feeds__id__read_events__feed_id',
  );

  $$ReadEventsTableProcessedTableManager get readEventsRefs {
    final manager = $$ReadEventsTableTableManager(
      $_db,
      $_db.readEvents,
    ).filter((f) => f.feedId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FeedsTableFilterComposer
    extends Composer<_$LandboteDatabase, $FeedsTable> {
  $$FeedsTableFilterComposer({
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

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customTitle => $composableBuilder(
    column: $table.customTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteUrl => $composableBuilder(
    column: $table.siteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconUrl => $composableBuilder(
    column: $table.iconUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fullText => $composableBuilder(
    column: $table.fullText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get neverBundle => $composableBuilder(
    column: $table.neverBundle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> articlesRefs(
    Expression<bool> Function($$ArticlesTableFilterComposer f) f,
  ) {
    final $$ArticlesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.feedId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableFilterComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rulesRefs(
    Expression<bool> Function($$RulesTableFilterComposer f) f,
  ) {
    final $$RulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.feedId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableFilterComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readEventsRefs(
    Expression<bool> Function($$ReadEventsTableFilterComposer f) f,
  ) {
    final $$ReadEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readEvents,
      getReferencedColumn: (t) => t.feedId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadEventsTableFilterComposer(
            $db: $db,
            $table: $db.readEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FeedsTableOrderingComposer
    extends Composer<_$LandboteDatabase, $FeedsTable> {
  $$FeedsTableOrderingComposer({
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

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customTitle => $composableBuilder(
    column: $table.customTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteUrl => $composableBuilder(
    column: $table.siteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconUrl => $composableBuilder(
    column: $table.iconUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fullText => $composableBuilder(
    column: $table.fullText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get neverBundle => $composableBuilder(
    column: $table.neverBundle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FeedsTableAnnotationComposer
    extends Composer<_$LandboteDatabase, $FeedsTable> {
  $$FeedsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get customTitle => $composableBuilder(
    column: $table.customTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get siteUrl =>
      $composableBuilder(column: $table.siteUrl, builder: (column) => column);

  GeneratedColumn<String> get iconUrl =>
      $composableBuilder(column: $table.iconUrl, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get errorCount => $composableBuilder(
    column: $table.errorCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get fullText =>
      $composableBuilder(column: $table.fullText, builder: (column) => column);

  GeneratedColumn<bool> get neverBundle => $composableBuilder(
    column: $table.neverBundle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$FoldersTableAnnotationComposer get folderId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> articlesRefs<T extends Object>(
    Expression<T> Function($$ArticlesTableAnnotationComposer a) f,
  ) {
    final $$ArticlesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.articles,
      getReferencedColumn: (t) => t.feedId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArticlesTableAnnotationComposer(
            $db: $db,
            $table: $db.articles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rulesRefs<T extends Object>(
    Expression<T> Function($$RulesTableAnnotationComposer a) f,
  ) {
    final $$RulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rules,
      getReferencedColumn: (t) => t.feedId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RulesTableAnnotationComposer(
            $db: $db,
            $table: $db.rules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readEventsRefs<T extends Object>(
    Expression<T> Function($$ReadEventsTableAnnotationComposer a) f,
  ) {
    final $$ReadEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readEvents,
      getReferencedColumn: (t) => t.feedId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.readEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FeedsTableTableManager
    extends
        RootTableManager<
          _$LandboteDatabase,
          $FeedsTable,
          Feed,
          $$FeedsTableFilterComposer,
          $$FeedsTableOrderingComposer,
          $$FeedsTableAnnotationComposer,
          $$FeedsTableCreateCompanionBuilder,
          $$FeedsTableUpdateCompanionBuilder,
          (Feed, $$FeedsTableReferences),
          Feed,
          PrefetchHooks Function({
            bool folderId,
            bool articlesRefs,
            bool rulesRefs,
            bool readEventsRefs,
          })
        > {
  $$FeedsTableTableManager(_$LandboteDatabase db, $FeedsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeedsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeedsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeedsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> customTitle = const Value.absent(),
                Value<String?> siteUrl = const Value.absent(),
                Value<String?> iconUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> folderId = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<String?> lastModified = const Value.absent(),
                Value<DateTime?> lastFetchedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> errorCount = const Value.absent(),
                Value<bool> fullText = const Value.absent(),
                Value<bool> neverBundle = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => FeedsCompanion(
                id: id,
                url: url,
                title: title,
                customTitle: customTitle,
                siteUrl: siteUrl,
                iconUrl: iconUrl,
                description: description,
                folderId: folderId,
                etag: etag,
                lastModified: lastModified,
                lastFetchedAt: lastFetchedAt,
                lastError: lastError,
                errorCount: errorCount,
                fullText: fullText,
                neverBundle: neverBundle,
                remoteId: remoteId,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String url,
                required String title,
                Value<String?> customTitle = const Value.absent(),
                Value<String?> siteUrl = const Value.absent(),
                Value<String?> iconUrl = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> folderId = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<String?> lastModified = const Value.absent(),
                Value<DateTime?> lastFetchedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> errorCount = const Value.absent(),
                Value<bool> fullText = const Value.absent(),
                Value<bool> neverBundle = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                required DateTime addedAt,
              }) => FeedsCompanion.insert(
                id: id,
                url: url,
                title: title,
                customTitle: customTitle,
                siteUrl: siteUrl,
                iconUrl: iconUrl,
                description: description,
                folderId: folderId,
                etag: etag,
                lastModified: lastModified,
                lastFetchedAt: lastFetchedAt,
                lastError: lastError,
                errorCount: errorCount,
                fullText: fullText,
                neverBundle: neverBundle,
                remoteId: remoteId,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FeedsTable, Feed>(table),
                  $$FeedsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                folderId = false,
                articlesRefs = false,
                rulesRefs = false,
                readEventsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (articlesRefs) db.articles,
                    if (rulesRefs) db.rules,
                    if (readEventsRefs) db.readEvents,
                  ],
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
                        if (folderId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.folderId,
                            referencedTable: $$FeedsTableReferences
                                ._folderIdTable(db),
                            referencedColumn: $$FeedsTableReferences
                                ._folderIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (articlesRefs)
                        await $_getPrefetchedDataByColumns<
                          Feed,
                          $FeedsTable,
                          Article,
                          $ArticlesTable
                        >(
                          currentTable: table,
                          referencedTable: $$FeedsTableReferences
                              ._articlesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FeedsTableReferences(
                                db,
                                table,
                                p0,
                              ).articlesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'feed_id',
                          typedResults: items,
                        ),
                      if (rulesRefs)
                        await $_getPrefetchedDataByColumns<
                          Feed,
                          $FeedsTable,
                          Rule,
                          $RulesTable
                        >(
                          currentTable: table,
                          referencedTable: $$FeedsTableReferences
                              ._rulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FeedsTableReferences(db, table, p0).rulesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'feed_id',
                          typedResults: items,
                        ),
                      if (readEventsRefs)
                        await $_getPrefetchedDataByColumns<
                          Feed,
                          $FeedsTable,
                          ReadEvent,
                          $ReadEventsTable
                        >(
                          currentTable: table,
                          referencedTable: $$FeedsTableReferences
                              ._readEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FeedsTableReferences(
                                db,
                                table,
                                p0,
                              ).readEventsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'feed_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FeedsTableProcessedTableManager =
    ProcessedTableManager<
      _$LandboteDatabase,
      $FeedsTable,
      Feed,
      $$FeedsTableFilterComposer,
      $$FeedsTableOrderingComposer,
      $$FeedsTableAnnotationComposer,
      $$FeedsTableCreateCompanionBuilder,
      $$FeedsTableUpdateCompanionBuilder,
      (Feed, $$FeedsTableReferences),
      Feed,
      PrefetchHooks Function({
        bool folderId,
        bool articlesRefs,
        bool rulesRefs,
        bool readEventsRefs,
      })
    >;
typedef $$ArticlesTableCreateCompanionBuilder = ArticlesCompanion Function({
  Value<int> id,
  required int feedId,
  required String guid,
  Value<String?> url,
  required String title,
  Value<String?> author,
  Value<String> summary,
  Value<String?> contentHtml,
  Value<String?> fullHtml,
  Value<String?> imageUrl,
  required DateTime publishedAt,
  required DateTime fetchedAt,
  Value<DateTime?> readAt,
  Value<DateTime?> savedAt,
  Value<DateTime?> archivedAt,
  Value<bool> hidden,
  Value<int> readingMinutes,
  Value<String> categories,
  Value<String?> remoteId,
});
typedef $$ArticlesTableUpdateCompanionBuilder = ArticlesCompanion Function({
  Value<int> id,
  Value<int> feedId,
  Value<String> guid,
  Value<String?> url,
  Value<String> title,
  Value<String?> author,
  Value<String> summary,
  Value<String?> contentHtml,
  Value<String?> fullHtml,
  Value<String?> imageUrl,
  Value<DateTime> publishedAt,
  Value<DateTime> fetchedAt,
  Value<DateTime?> readAt,
  Value<DateTime?> savedAt,
  Value<DateTime?> archivedAt,
  Value<bool> hidden,
  Value<int> readingMinutes,
  Value<String> categories,
  Value<String?> remoteId,
});

final class $$ArticlesTableReferences
    extends BaseReferences<_$LandboteDatabase, $ArticlesTable, Article> {
  $$ArticlesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FeedsTable _feedIdTable(_$LandboteDatabase db) =>
      db.feeds.createAlias('articles__feed_id__feeds__id');

  $$FeedsTableProcessedTableManager get feedId {
    final $_column = $_itemColumn<int>('feed_id')!;

    final manager = $$FeedsTableTableManager(
      $_db,
      $_db.feeds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_feedIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ArticlesTableFilterComposer
    extends Composer<_$LandboteDatabase, $ArticlesTable> {
  $$ArticlesTableFilterComposer({
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

  ColumnFilters<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullHtml => $composableBuilder(
    column: $table.fullHtml,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get readingMinutes => $composableBuilder(
    column: $table.readingMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categories => $composableBuilder(
    column: $table.categories,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  $$FeedsTableFilterComposer get feedId {
    final $$FeedsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: $db.feeds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedsTableFilterComposer(
            $db: $db,
            $table: $db.feeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticlesTableOrderingComposer
    extends Composer<_$LandboteDatabase, $ArticlesTable> {
  $$ArticlesTableOrderingComposer({
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

  ColumnOrderings<String> get guid => $composableBuilder(
    column: $table.guid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullHtml => $composableBuilder(
    column: $table.fullHtml,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hidden => $composableBuilder(
    column: $table.hidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get readingMinutes => $composableBuilder(
    column: $table.readingMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categories => $composableBuilder(
    column: $table.categories,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  $$FeedsTableOrderingComposer get feedId {
    final $$FeedsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: $db.feeds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedsTableOrderingComposer(
            $db: $db,
            $table: $db.feeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticlesTableAnnotationComposer
    extends Composer<_$LandboteDatabase, $ArticlesTable> {
  $$ArticlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get guid =>
      $composableBuilder(column: $table.guid, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get contentHtml => $composableBuilder(
    column: $table.contentHtml,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullHtml =>
      $composableBuilder(column: $table.fullHtml, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hidden =>
      $composableBuilder(column: $table.hidden, builder: (column) => column);

  GeneratedColumn<int> get readingMinutes => $composableBuilder(
    column: $table.readingMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categories => $composableBuilder(
    column: $table.categories,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  $$FeedsTableAnnotationComposer get feedId {
    final $$FeedsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: $db.feeds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedsTableAnnotationComposer(
            $db: $db,
            $table: $db.feeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArticlesTableTableManager
    extends
        RootTableManager<
          _$LandboteDatabase,
          $ArticlesTable,
          Article,
          $$ArticlesTableFilterComposer,
          $$ArticlesTableOrderingComposer,
          $$ArticlesTableAnnotationComposer,
          $$ArticlesTableCreateCompanionBuilder,
          $$ArticlesTableUpdateCompanionBuilder,
          (Article, $$ArticlesTableReferences),
          Article,
          PrefetchHooks Function({bool feedId})
        > {
  $$ArticlesTableTableManager(_$LandboteDatabase db, $ArticlesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArticlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArticlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArticlesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> feedId = const Value.absent(),
                Value<String> guid = const Value.absent(),
                Value<String?> url = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String?> contentHtml = const Value.absent(),
                Value<String?> fullHtml = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<DateTime> publishedAt = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime?> savedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int> readingMinutes = const Value.absent(),
                Value<String> categories = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
              }) => ArticlesCompanion(
                id: id,
                feedId: feedId,
                guid: guid,
                url: url,
                title: title,
                author: author,
                summary: summary,
                contentHtml: contentHtml,
                fullHtml: fullHtml,
                imageUrl: imageUrl,
                publishedAt: publishedAt,
                fetchedAt: fetchedAt,
                readAt: readAt,
                savedAt: savedAt,
                archivedAt: archivedAt,
                hidden: hidden,
                readingMinutes: readingMinutes,
                categories: categories,
                remoteId: remoteId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int feedId,
                required String guid,
                Value<String?> url = const Value.absent(),
                required String title,
                Value<String?> author = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String?> contentHtml = const Value.absent(),
                Value<String?> fullHtml = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                required DateTime publishedAt,
                required DateTime fetchedAt,
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime?> savedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<bool> hidden = const Value.absent(),
                Value<int> readingMinutes = const Value.absent(),
                Value<String> categories = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
              }) => ArticlesCompanion.insert(
                id: id,
                feedId: feedId,
                guid: guid,
                url: url,
                title: title,
                author: author,
                summary: summary,
                contentHtml: contentHtml,
                fullHtml: fullHtml,
                imageUrl: imageUrl,
                publishedAt: publishedAt,
                fetchedAt: fetchedAt,
                readAt: readAt,
                savedAt: savedAt,
                archivedAt: archivedAt,
                hidden: hidden,
                readingMinutes: readingMinutes,
                categories: categories,
                remoteId: remoteId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ArticlesTable, Article>(table),
                  $$ArticlesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({feedId = false}) {
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
                    if (feedId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.feedId,
                        referencedTable: $$ArticlesTableReferences._feedIdTable(
                          db,
                        ),
                        referencedColumn: $$ArticlesTableReferences
                            ._feedIdTable(db)
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

typedef $$ArticlesTableProcessedTableManager =
    ProcessedTableManager<
      _$LandboteDatabase,
      $ArticlesTable,
      Article,
      $$ArticlesTableFilterComposer,
      $$ArticlesTableOrderingComposer,
      $$ArticlesTableAnnotationComposer,
      $$ArticlesTableCreateCompanionBuilder,
      $$ArticlesTableUpdateCompanionBuilder,
      (Article, $$ArticlesTableReferences),
      Article,
      PrefetchHooks Function({bool feedId})
    >;
typedef $$RulesTableCreateCompanionBuilder = RulesCompanion Function({
  Value<int> id,
  required String pattern,
  Value<int> field,
  Value<int?> feedId,
  Value<int> action,
  Value<bool> enabled,
});
typedef $$RulesTableUpdateCompanionBuilder = RulesCompanion Function({
  Value<int> id,
  Value<String> pattern,
  Value<int> field,
  Value<int?> feedId,
  Value<int> action,
  Value<bool> enabled,
});

final class $$RulesTableReferences
    extends BaseReferences<_$LandboteDatabase, $RulesTable, Rule> {
  $$RulesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FeedsTable _feedIdTable(_$LandboteDatabase db) =>
      db.feeds.createAlias('rules__feed_id__feeds__id');

  $$FeedsTableProcessedTableManager? get feedId {
    final $_column = $_itemColumn<int>('feed_id');
    if ($_column == null) return null;
    final manager = $$FeedsTableTableManager(
      $_db,
      $_db.feeds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_feedIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RulesTableFilterComposer
    extends Composer<_$LandboteDatabase, $RulesTable> {
  $$RulesTableFilterComposer({
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

  ColumnFilters<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  $$FeedsTableFilterComposer get feedId {
    final $$FeedsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: $db.feeds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedsTableFilterComposer(
            $db: $db,
            $table: $db.feeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RulesTableOrderingComposer
    extends Composer<_$LandboteDatabase, $RulesTable> {
  $$RulesTableOrderingComposer({
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

  ColumnOrderings<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  $$FeedsTableOrderingComposer get feedId {
    final $$FeedsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: $db.feeds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedsTableOrderingComposer(
            $db: $db,
            $table: $db.feeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RulesTableAnnotationComposer
    extends Composer<_$LandboteDatabase, $RulesTable> {
  $$RulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<int> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<int> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  $$FeedsTableAnnotationComposer get feedId {
    final $$FeedsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: $db.feeds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedsTableAnnotationComposer(
            $db: $db,
            $table: $db.feeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RulesTableTableManager
    extends
        RootTableManager<
          _$LandboteDatabase,
          $RulesTable,
          Rule,
          $$RulesTableFilterComposer,
          $$RulesTableOrderingComposer,
          $$RulesTableAnnotationComposer,
          $$RulesTableCreateCompanionBuilder,
          $$RulesTableUpdateCompanionBuilder,
          (Rule, $$RulesTableReferences),
          Rule,
          PrefetchHooks Function({bool feedId})
        > {
  $$RulesTableTableManager(_$LandboteDatabase db, $RulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> pattern = const Value.absent(),
                Value<int> field = const Value.absent(),
                Value<int?> feedId = const Value.absent(),
                Value<int> action = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => RulesCompanion(
                id: id,
                pattern: pattern,
                field: field,
                feedId: feedId,
                action: action,
                enabled: enabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String pattern,
                Value<int> field = const Value.absent(),
                Value<int?> feedId = const Value.absent(),
                Value<int> action = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => RulesCompanion.insert(
                id: id,
                pattern: pattern,
                field: field,
                feedId: feedId,
                action: action,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RulesTable, Rule>(table),
                  $$RulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({feedId = false}) {
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
                    if (feedId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.feedId,
                        referencedTable: $$RulesTableReferences._feedIdTable(
                          db,
                        ),
                        referencedColumn: $$RulesTableReferences
                            ._feedIdTable(db)
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

typedef $$RulesTableProcessedTableManager =
    ProcessedTableManager<
      _$LandboteDatabase,
      $RulesTable,
      Rule,
      $$RulesTableFilterComposer,
      $$RulesTableOrderingComposer,
      $$RulesTableAnnotationComposer,
      $$RulesTableCreateCompanionBuilder,
      $$RulesTableUpdateCompanionBuilder,
      (Rule, $$RulesTableReferences),
      Rule,
      PrefetchHooks Function({bool feedId})
    >;
typedef $$ReadEventsTableCreateCompanionBuilder = ReadEventsCompanion Function({
  Value<int> id,
  Value<int?> feedId,
  required DateTime at,
  Value<int> minutes,
});
typedef $$ReadEventsTableUpdateCompanionBuilder = ReadEventsCompanion Function({
  Value<int> id,
  Value<int?> feedId,
  Value<DateTime> at,
  Value<int> minutes,
});

final class $$ReadEventsTableReferences
    extends BaseReferences<_$LandboteDatabase, $ReadEventsTable, ReadEvent> {
  $$ReadEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FeedsTable _feedIdTable(_$LandboteDatabase db) =>
      db.feeds.createAlias('read_events__feed_id__feeds__id');

  $$FeedsTableProcessedTableManager? get feedId {
    final $_column = $_itemColumn<int>('feed_id');
    if ($_column == null) return null;
    final manager = $$FeedsTableTableManager(
      $_db,
      $_db.feeds,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_feedIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadEventsTableFilterComposer
    extends Composer<_$LandboteDatabase, $ReadEventsTable> {
  $$ReadEventsTableFilterComposer({
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

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnFilters(column),
  );

  $$FeedsTableFilterComposer get feedId {
    final $$FeedsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: $db.feeds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedsTableFilterComposer(
            $db: $db,
            $table: $db.feeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadEventsTableOrderingComposer
    extends Composer<_$LandboteDatabase, $ReadEventsTable> {
  $$ReadEventsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$FeedsTableOrderingComposer get feedId {
    final $$FeedsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: $db.feeds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedsTableOrderingComposer(
            $db: $db,
            $table: $db.feeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadEventsTableAnnotationComposer
    extends Composer<_$LandboteDatabase, $ReadEventsTable> {
  $$ReadEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  $$FeedsTableAnnotationComposer get feedId {
    final $$FeedsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: $db.feeds,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FeedsTableAnnotationComposer(
            $db: $db,
            $table: $db.feeds,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadEventsTableTableManager
    extends
        RootTableManager<
          _$LandboteDatabase,
          $ReadEventsTable,
          ReadEvent,
          $$ReadEventsTableFilterComposer,
          $$ReadEventsTableOrderingComposer,
          $$ReadEventsTableAnnotationComposer,
          $$ReadEventsTableCreateCompanionBuilder,
          $$ReadEventsTableUpdateCompanionBuilder,
          (ReadEvent, $$ReadEventsTableReferences),
          ReadEvent,
          PrefetchHooks Function({bool feedId})
        > {
  $$ReadEventsTableTableManager(_$LandboteDatabase db, $ReadEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> feedId = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> minutes = const Value.absent(),
              }) => ReadEventsCompanion(
                id: id,
                feedId: feedId,
                at: at,
                minutes: minutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> feedId = const Value.absent(),
                required DateTime at,
                Value<int> minutes = const Value.absent(),
              }) => ReadEventsCompanion.insert(
                id: id,
                feedId: feedId,
                at: at,
                minutes: minutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadEventsTable, ReadEvent>(table),
                  $$ReadEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({feedId = false}) {
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
                    if (feedId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.feedId,
                        referencedTable: $$ReadEventsTableReferences
                            ._feedIdTable(db),
                        referencedColumn: $$ReadEventsTableReferences
                            ._feedIdTable(db)
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

typedef $$ReadEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$LandboteDatabase,
      $ReadEventsTable,
      ReadEvent,
      $$ReadEventsTableFilterComposer,
      $$ReadEventsTableOrderingComposer,
      $$ReadEventsTableAnnotationComposer,
      $$ReadEventsTableCreateCompanionBuilder,
      $$ReadEventsTableUpdateCompanionBuilder,
      (ReadEvent, $$ReadEventsTableReferences),
      ReadEvent,
      PrefetchHooks Function({bool feedId})
    >;
typedef $$SyncOpsTableCreateCompanionBuilder = SyncOpsCompanion Function({
  Value<int> id,
  required String remoteId,
  required String kind,
  required DateTime createdAt,
});
typedef $$SyncOpsTableUpdateCompanionBuilder = SyncOpsCompanion Function({
  Value<int> id,
  Value<String> remoteId,
  Value<String> kind,
  Value<DateTime> createdAt,
});

class $$SyncOpsTableFilterComposer
    extends Composer<_$LandboteDatabase, $SyncOpsTable> {
  $$SyncOpsTableFilterComposer({
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

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOpsTableOrderingComposer
    extends Composer<_$LandboteDatabase, $SyncOpsTable> {
  $$SyncOpsTableOrderingComposer({
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

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOpsTableAnnotationComposer
    extends Composer<_$LandboteDatabase, $SyncOpsTable> {
  $$SyncOpsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncOpsTableTableManager
    extends
        RootTableManager<
          _$LandboteDatabase,
          $SyncOpsTable,
          SyncOp,
          $$SyncOpsTableFilterComposer,
          $$SyncOpsTableOrderingComposer,
          $$SyncOpsTableAnnotationComposer,
          $$SyncOpsTableCreateCompanionBuilder,
          $$SyncOpsTableUpdateCompanionBuilder,
          (SyncOp, BaseReferences<_$LandboteDatabase, $SyncOpsTable, SyncOp>),
          SyncOp,
          PrefetchHooks Function()
        > {
  $$SyncOpsTableTableManager(_$LandboteDatabase db, $SyncOpsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOpsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOpsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOpsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> remoteId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncOpsCompanion(
                id: id,
                remoteId: remoteId,
                kind: kind,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String remoteId,
                required String kind,
                required DateTime createdAt,
              }) => SyncOpsCompanion.insert(
                id: id,
                remoteId: remoteId,
                kind: kind,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncOpsTable, SyncOp>(table),
                  BaseReferences<_$LandboteDatabase, $SyncOpsTable, SyncOp>(
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

typedef $$SyncOpsTableProcessedTableManager =
    ProcessedTableManager<
      _$LandboteDatabase,
      $SyncOpsTable,
      SyncOp,
      $$SyncOpsTableFilterComposer,
      $$SyncOpsTableOrderingComposer,
      $$SyncOpsTableAnnotationComposer,
      $$SyncOpsTableCreateCompanionBuilder,
      $$SyncOpsTableUpdateCompanionBuilder,
      (SyncOp, BaseReferences<_$LandboteDatabase, $SyncOpsTable, SyncOp>),
      SyncOp,
      PrefetchHooks Function()
    >;

class $LandboteDatabaseManager {
  final _$LandboteDatabase _db;
  $LandboteDatabaseManager(this._db);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$FeedsTableTableManager get feeds =>
      $$FeedsTableTableManager(_db, _db.feeds);
  $$ArticlesTableTableManager get articles =>
      $$ArticlesTableTableManager(_db, _db.articles);
  $$RulesTableTableManager get rules =>
      $$RulesTableTableManager(_db, _db.rules);
  $$ReadEventsTableTableManager get readEvents =>
      $$ReadEventsTableTableManager(_db, _db.readEvents);
  $$SyncOpsTableTableManager get syncOps =>
      $$SyncOpsTableTableManager(_db, _db.syncOps);
}
