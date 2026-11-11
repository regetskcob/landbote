/// The local store: feeds, folders, articles, filter rules, the reading log
/// and pending sync operations. One SQLite file, offline first.
library;

import 'package:drift/drift.dart';

part 'database.g.dart';

/// Folders group feeds in the sidebar and the Flurkarte.
class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// A subscribed feed.
class Feeds extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get url => text().unique()();
  TextColumn get title => text()();
  TextColumn get customTitle => text().nullable()();
  TextColumn get siteUrl => text().nullable()();
  TextColumn get iconUrl => text().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get folderId => integer().nullable().references(Folders, #id, onDelete: KeyAction.setNull)();
  TextColumn get etag => text().nullable()();
  TextColumn get lastModified => text().nullable()();
  DateTimeColumn get lastFetchedAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  IntColumn get errorCount => integer().withDefault(const Constant(0))();

  /// Always fetch the full text from the page, even if the feed has content.
  BoolColumn get fullText => boolean().withDefault(const Constant(false))();

  /// Never bundle this feed into one line, however loud it is.
  BoolColumn get neverBundle => boolean().withDefault(const Constant(false))();

  /// The id on the sync server, if an account is connected.
  TextColumn get remoteId => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();
}

/// One post.
@TableIndex(name: 'articles_published', columns: {#publishedAt})
@TableIndex(name: 'articles_feed', columns: {#feedId})
class Articles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get feedId => integer().references(Feeds, #id, onDelete: KeyAction.cascade)();
  TextColumn get guid => text()();
  TextColumn get url => text().nullable()();
  TextColumn get title => text()();
  TextColumn get author => text().nullable()();

  /// Plain-text teaser for the list, at most a few hundred characters.
  TextColumn get summary => text().withDefault(const Constant(''))();
  TextColumn get contentHtml => text().nullable()();

  /// The extracted full text, filled on demand or by [Feeds.fullText].
  TextColumn get fullHtml => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  DateTimeColumn get publishedAt => dateTime()();
  DateTimeColumn get fetchedAt => dateTime()();
  DateTimeColumn get readAt => dateTime().nullable()();
  DateTimeColumn get savedAt => dateTime().nullable()();

  /// Set when an unread article drifted out of Heute (the "Ernte").
  DateTimeColumn get archivedAt => dateTime().nullable()();

  /// Hidden by a filter rule ("Graben").
  BoolColumn get hidden => boolean().withDefault(const Constant(false))();
  IntColumn get readingMinutes => integer().withDefault(const Constant(0))();

  /// Categories joined by U+001F.
  TextColumn get categories => text().withDefault(const Constant(''))();
  TextColumn get remoteId => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {feedId, guid},
      ];
}

/// A filter rule: articles matching [pattern] are hidden or marked read.
class Rules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pattern => text()();

  /// 0 title or text, 1 title only, 2 author.
  IntColumn get field => integer().withDefault(const Constant(0))();

  /// Limits the rule to one feed; null for all.
  IntColumn get feedId => integer().nullable().references(Feeds, #id, onDelete: KeyAction.cascade)();

  /// 0 hide, 1 mark read.
  IntColumn get action => integer().withDefault(const Constant(0))();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
}

/// One finished read, for the Jahresernte. Survives article pruning.
class ReadEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get feedId => integer().nullable().references(Feeds, #id, onDelete: KeyAction.setNull)();
  DateTimeColumn get at => dateTime()();
  IntColumn get minutes => integer().withDefault(const Constant(0))();
}

/// A state change waiting to be sent to the sync server.
class SyncOps extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text()();

  /// `read`, `unread`, `star` or `unstar`.
  TextColumn get kind => text()();
  DateTimeColumn get createdAt => dateTime()();
}

/// The database.
@DriftDatabase(tables: [Folders, Feeds, Articles, Rules, ReadEvents, SyncOps])
class LandboteDatabase extends _$LandboteDatabase {
  /// Opens the database on [executor].
  LandboteDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
