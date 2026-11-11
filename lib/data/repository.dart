/// The one write path for feeds and articles: adding, refreshing, reading,
/// saving, the Ernte and the filter rules. The UI only reads streams from
/// here and calls these methods.
library;

import 'dart:async';

import 'package:drift/drift.dart';

import 'db/database.dart';
import 'feeds/discovery.dart';
import 'feeds/feed_parser.dart';
import 'feeds/fetcher.dart';
import 'feeds/html_text.dart';
import 'feeds/opml.dart';
import 'feeds/parsed_feed.dart';
import 'feeds/readability.dart';

/// Which articles a list shows.
sealed class ArticleScope {
  const ArticleScope();
}

/// Everything not yet harvested: the "Heute" stream.
final class TodayScope extends ArticleScope {
  /// Creates the scope.
  const TodayScope();
  @override
  bool operator ==(Object other) => other is TodayScope;
  @override
  int get hashCode => 1;
}

/// Saved for later.
final class SavedScope extends ArticleScope {
  /// Creates the scope.
  const SavedScope();
  @override
  bool operator ==(Object other) => other is SavedScope;
  @override
  int get hashCode => 2;
}

/// The archive: harvested and read articles.
final class ArchiveScope extends ArticleScope {
  /// Creates the scope.
  const ArchiveScope();
  @override
  bool operator ==(Object other) => other is ArchiveScope;
  @override
  int get hashCode => 3;
}

/// One feed, all its articles.
final class FeedScope extends ArticleScope {
  /// Creates the scope for feed [feedId].
  const FeedScope(this.feedId);

  /// The feed.
  final int feedId;
  @override
  bool operator ==(Object other) => other is FeedScope && other.feedId == feedId;
  @override
  int get hashCode => Object.hash(4, feedId);
}

/// One folder, all its feeds.
final class FolderScope extends ArticleScope {
  /// Creates the scope for folder [folderId].
  const FolderScope(this.folderId);

  /// The folder.
  final int folderId;
  @override
  bool operator ==(Object other) => other is FolderScope && other.folderId == folderId;
  @override
  int get hashCode => Object.hash(5, folderId);
}

/// Full-text search over title, teaser and author.
final class SearchScope extends ArticleScope {
  /// Creates the scope for [query].
  const SearchScope(this.query);

  /// What the person typed.
  final String query;
  @override
  bool operator ==(Object other) => other is SearchScope && other.query == query;
  @override
  int get hashCode => Object.hash(6, query);
}

/// An article with what the list needs of its feed.
class ArticleRow {
  /// Creates a row.
  const ArticleRow({required this.article, required this.feedTitle, this.feedIcon, this.neverBundle = false});

  /// The article.
  final Article article;

  /// The feed's display title.
  final String feedTitle;

  /// The feed's icon URL.
  final String? feedIcon;

  /// Whether the feed opted out of bundling.
  final bool neverBundle;

  /// Whether the article is read.
  bool get isRead => article.readAt != null;

  /// Whether the article is saved.
  bool get isSaved => article.savedAt != null;
}

/// A feed with its counts, for Quellen and the Flurkarte.
class FeedRow {
  /// Creates a row.
  const FeedRow({required this.feed, required this.unread, required this.recent, this.folder, this.lastPublished});

  /// The feed.
  final Feed feed;

  /// Unread, not harvested, not hidden.
  final int unread;

  /// Articles published in the last 30 days: the feed's "Fläche".
  final int recent;

  /// The folder, if any.
  final Folder? folder;

  /// The newest article's date.
  final DateTime? lastPublished;

  /// The title shown: the person's own name for it, else the feed's.
  String get title => feed.customTitle ?? feed.title;
}

/// The result of a refresh run.
class RefreshReport {
  /// Creates the report.
  const RefreshReport({required this.feeds, required this.newArticles, required this.failed});

  /// Feeds checked.
  final int feeds;

  /// Articles that were new.
  final int newArticles;

  /// Feeds that failed.
  final int failed;
}

/// Feeds and articles.
class FeedRepository {
  /// Creates the repository.
  FeedRepository(this.db, this.fetcher, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  /// The database.
  final LandboteDatabase db;

  /// The HTTP access.
  final Fetcher fetcher;

  final DateTime Function() _now;

  /// Articles older than this are not stored at all.
  static const retention = Duration(days: 90);

  /// How many feeds refresh at the same time.
  static const parallel = 4;

  DateTime get _utc => _now().toUtc();

  // ---------------------------------------------------------------- feeds

  /// Discovers the feeds behind [input].
  Future<List<DiscoveredFeed>> discover(String input) => discoverFeeds(input, fetcher);

  /// Adds [found] in [folderId] and stores its items. Returns the feed id;
  /// an already subscribed URL returns the existing id.
  Future<int> addFeed(DiscoveredFeed found, {int? folderId}) async {
    final url = found.url.toString();
    final existing = await (db.select(db.feeds)..where((f) => f.url.equals(url))).getSingleOrNull();
    if (existing != null) return existing.id;
    final id = await db.into(db.feeds).insert(FeedsCompanion.insert(
          url: url,
          title: found.feed.title,
          siteUrl: Value(found.feed.siteUrl),
          iconUrl: Value(found.feed.iconUrl),
          description: Value(found.feed.description),
          folderId: Value(folderId),
          addedAt: _utc,
          lastFetchedAt: Value(_utc),
        ));
    await _store(id, found.feed.items, initial: true);
    return id;
  }

  /// Adds a feed by URL without discovery, for OPML import and sync.
  Future<int> addFeedUrl(String url, {required String title, String? siteUrl, int? folderId, String? remoteId}) async {
    final existing = await (db.select(db.feeds)..where((f) => f.url.equals(url))).getSingleOrNull();
    if (existing != null) {
      if (remoteId != null && existing.remoteId != remoteId) {
        await (db.update(db.feeds)..where((f) => f.id.equals(existing.id))).write(FeedsCompanion(remoteId: Value(remoteId)));
      }
      return existing.id;
    }
    return db.into(db.feeds).insert(FeedsCompanion.insert(
          url: url,
          title: title,
          siteUrl: Value(siteUrl),
          folderId: Value(folderId),
          remoteId: Value(remoteId),
          addedAt: _utc,
        ));
  }

  /// Removes feed [id] and its articles.
  Future<void> deleteFeed(int id) => (db.delete(db.feeds)..where((f) => f.id.equals(id))).go();

  /// Changes the person's settings for feed [id].
  Future<void> updateFeed(int id, {Value<String?>? customTitle, Value<int?>? folderId, bool? fullText, bool? neverBundle}) =>
      (db.update(db.feeds)..where((f) => f.id.equals(id))).write(FeedsCompanion(
        customTitle: customTitle ?? const Value.absent(),
        folderId: folderId ?? const Value.absent(),
        fullText: fullText == null ? const Value.absent() : Value(fullText),
        neverBundle: neverBundle == null ? const Value.absent() : Value(neverBundle),
      ));

  /// Returns the id of folder [name], creating it.
  Future<int> folderNamed(String name) async {
    final existing = await (db.select(db.folders)..where((f) => f.name.equals(name))).getSingleOrNull();
    if (existing != null) return existing.id;
    return db.into(db.folders).insert(FoldersCompanion.insert(name: name));
  }

  /// Renames folder [id].
  Future<void> renameFolder(int id, String name) =>
      (db.update(db.folders)..where((f) => f.id.equals(id))).write(FoldersCompanion(name: Value(name)));

  /// Deletes folder [id]; its feeds stay, without folder.
  Future<void> deleteFolder(int id) => (db.delete(db.folders)..where((f) => f.id.equals(id))).go();

  /// All folders by position and name.
  Stream<List<Folder>> watchFolders() =>
      (db.select(db.folders)..orderBy([(f) => OrderingTerm(expression: f.position), (f) => OrderingTerm(expression: f.name)])).watch();

  /// All feeds with their counts.
  Stream<List<FeedRow>> watchFeeds() {
    final since = _utc.subtract(const Duration(days: 30));
    final unread = db.articles.id.count(
      filter: db.articles.readAt.isNull() & db.articles.archivedAt.isNull() & db.articles.hidden.equals(false),
    );
    final recent = db.articles.id.count(filter: db.articles.publishedAt.isBiggerOrEqualValue(since));
    final last = db.articles.publishedAt.max();
    final q = db.select(db.feeds).join([
      leftOuterJoin(db.articles, db.articles.feedId.equalsExp(db.feeds.id)),
      leftOuterJoin(db.folders, db.folders.id.equalsExp(db.feeds.folderId)),
    ])
      ..addColumns([unread, recent, last])
      ..groupBy([db.feeds.id]);
    return q.watch().map((rows) {
      final out = [
        for (final r in rows)
          FeedRow(
            feed: r.readTable(db.feeds),
            folder: r.readTableOrNull(db.folders),
            unread: r.read(unread) ?? 0,
            recent: r.read(recent) ?? 0,
            lastPublished: r.read(last),
          ),
      ]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      return out;
    });
  }

  /// All feeds, once.
  Future<List<Feed>> feeds() => db.select(db.feeds).get();

  // ------------------------------------------------------------- refresh

  /// Refreshes every feed that has no sync account behind it. [onProgress]
  /// gets done/total after each feed.
  Future<RefreshReport> refreshAll({void Function(int done, int total)? onProgress}) async {
    final all = await (db.select(db.feeds)..where((f) => f.remoteId.isNull())).get();
    var done = 0;
    var fresh = 0;
    var failed = 0;
    final queue = [...all];
    Future<void> worker() async {
      while (queue.isNotEmpty) {
        final feed = queue.removeLast();
        final n = await refreshFeed(feed);
        if (n < 0) {
          failed++;
        } else {
          fresh += n;
        }
        done++;
        onProgress?.call(done, all.length);
      }
    }

    await Future.wait([for (var i = 0; i < parallel; i++) worker()]);
    await harvest();
    return RefreshReport(feeds: all.length, newArticles: fresh, failed: failed);
  }

  /// Refreshes [feed]. Returns the number of new articles, or -1 on failure.
  Future<int> refreshFeed(Feed feed) async {
    final result = await fetcher.get(Uri.parse(feed.url), etag: feed.etag, lastModified: feed.lastModified);
    final update = db.update(db.feeds)..where((f) => f.id.equals(feed.id));
    switch (result) {
      case NotModified():
        await update.write(FeedsCompanion(lastFetchedAt: Value(_utc), lastError: const Value(null), errorCount: const Value(0)));
        return 0;
      case FetchFailed(:final message):
        await update.write(FeedsCompanion(lastFetchedAt: Value(_utc), lastError: Value(message), errorCount: Value(feed.errorCount + 1)));
        return -1;
      case Fetched():
        final ParsedFeed parsed;
        try {
          parsed = parseFeed(result.body, source: result.finalUrl);
        } on FeedFormatException catch (e) {
          await update.write(FeedsCompanion(lastFetchedAt: Value(_utc), lastError: Value(e.message), errorCount: Value(feed.errorCount + 1)));
          return -1;
        }
        await update.write(FeedsCompanion(
          lastFetchedAt: Value(_utc),
          etag: Value(result.etag),
          lastModified: Value(result.lastModified),
          lastError: const Value(null),
          errorCount: const Value(0),
          iconUrl: parsed.iconUrl == null ? const Value.absent() : Value(parsed.iconUrl),
          siteUrl: parsed.siteUrl == null ? const Value.absent() : Value(parsed.siteUrl),
          title: parsed.title.isEmpty ? const Value.absent() : Value(parsed.title),
        ));
        final ids = await _store(feed.id, parsed.items);
        if (feed.fullText) {
          for (final id in ids.take(10)) {
            await fetchFullText(id);
          }
        }
        return ids.length;
    }
  }

  /// Stores [items] of feed [feedId]; returns the ids of new articles.
  ///
  /// On the [initial] fetch of a new feed only the newest ten stay unread:
  /// a feed with 150 posts should not flood Heute.
  Future<List<int>> _store(int feedId, List<ParsedItem> items, {bool initial = false}) async {
    final now = _utc;
    final cutoff = now.subtract(retention);
    final rules = await (db.select(db.rules)..where((r) => r.enabled.equals(true))).get();
    final sorted = [...items]..sort((a, b) => (b.published ?? now).compareTo(a.published ?? now));
    final fresh = <int>[];
    await db.transaction(() async {
      var index = 0;
      for (final item in sorted) {
        index++;
        final published = item.published ?? now;
        if (published.isBefore(cutoff)) continue;
        final existing = await (db.select(db.articles)
              ..where((a) => a.feedId.equals(feedId) & a.guid.equals(item.guid)))
            .getSingleOrNull();
        final content = item.contentHtml ?? item.summaryHtml;
        final teaser = _teaser(item.summaryHtml ?? item.contentHtml);
        if (existing != null) {
          if (existing.contentHtml != content || existing.title != item.title) {
            await (db.update(db.articles)..where((a) => a.id.equals(existing.id))).write(ArticlesCompanion(
              title: Value(item.title),
              contentHtml: Value(content),
              summary: Value(teaser),
              imageUrl: Value(item.imageUrl),
            ));
          }
          continue;
        }
        final rule = matchRule(rules, feedId: feedId, title: item.title, text: teaser, author: item.author);
        final oldOnStart = initial && index > 10;
        final id = await db.into(db.articles).insert(ArticlesCompanion.insert(
              feedId: feedId,
              guid: item.guid,
              url: Value(item.url),
              title: item.title,
              author: Value(item.author),
              summary: Value(teaser),
              contentHtml: Value(content),
              imageUrl: Value(item.imageUrl),
              publishedAt: published,
              fetchedAt: now,
              readingMinutes: Value(readingMinutes(plainText(content))),
              categories: Value(item.categories.join('\u001f')),
              hidden: Value(rule?.action == 0),
              readAt: Value(rule?.action == 1 ? now : null),
              archivedAt: Value(oldOnStart ? now : null),
            ));
        if (!oldOnStart && rule == null) fresh.add(id);
      }
    });
    return fresh;
  }

  static String _teaser(String? html) {
    final t = plainText(html);
    return t.length > 320 ? '${t.substring(0, 320).trimRight()}…' : t;
  }

  /// Fetches and stores the full text of article [id]. Returns the HTML, or
  /// null when the page could not be read.
  Future<String?> fetchFullText(int id) async {
    final a = await (db.select(db.articles)..where((x) => x.id.equals(id))).getSingleOrNull();
    if (a == null || a.url == null) return null;
    if (a.fullHtml != null) return a.fullHtml;
    final r = await fetcher.get(Uri.parse(a.url!), accept: 'text/html,application/xhtml+xml');
    if (r is! Fetched) return null;
    final extracted = extractArticle(r.body, r.finalUrl);
    if (extracted == null) return null;
    await (db.update(db.articles)..where((x) => x.id.equals(id))).write(ArticlesCompanion(
      fullHtml: Value(extracted.html),
      readingMinutes: Value(readingMinutes(plainText(extracted.html))),
      imageUrl: a.imageUrl == null && extracted.leadImage != null ? Value(extracted.leadImage) : const Value.absent(),
    ));
    return extracted.html;
  }

  /// Moves unread articles older than [days] out of Heute. Saved ones stay.
  Future<int> harvest({int days = 14}) {
    final before = _utc.subtract(Duration(days: days));
    return (db.update(db.articles)
          ..where((a) => a.archivedAt.isNull() & a.savedAt.isNull() & a.publishedAt.isSmallerThanValue(before)))
        .write(ArticlesCompanion(archivedAt: Value(_utc)));
  }

  // ------------------------------------------------------------ articles

  /// The articles of [scope], newest first. Heute shows unread and today's
  /// read ones, so what was just read does not jump away.
  Stream<List<ArticleRow>> watchArticles(ArticleScope scope, {bool unreadOnly = false, int limit = 500}) {
    final a = db.articles;
    final q = db.select(a).join([innerJoin(db.feeds, db.feeds.id.equalsExp(a.feedId))]);
    Expression<bool> where = a.hidden.equals(false);
    final startOfDay = DateTime(_now().year, _now().month, _now().day).toUtc();
    switch (scope) {
      case TodayScope():
        where = where & a.archivedAt.isNull() & (a.readAt.isNull() | a.readAt.isBiggerOrEqualValue(startOfDay));
      case SavedScope():
        where = where & a.savedAt.isNotNull();
      case ArchiveScope():
        where = where & (a.archivedAt.isNotNull() | a.readAt.isNotNull());
      case FeedScope(:final feedId):
        where = where & a.feedId.equals(feedId);
      case FolderScope(:final folderId):
        where = where & db.feeds.folderId.equals(folderId);
      case SearchScope(:final query):
        final like = '%${query.replaceAll('%', r'\%')}%';
        where = a.title.like(like) | a.summary.like(like) | a.author.like(like) | a.contentHtml.like(like);
    }
    if (unreadOnly) where = where & a.readAt.isNull();
    q
      ..where(where)
      ..orderBy([
        if (scope is SavedScope) OrderingTerm.desc(a.savedAt),
        OrderingTerm.desc(a.publishedAt),
      ])
      ..limit(limit);
    return q.watch().map((rows) => [
          for (final r in rows)
            () {
              final f = r.readTable(db.feeds);
              return ArticleRow(article: r.readTable(a), feedTitle: f.customTitle ?? f.title, feedIcon: f.iconUrl, neverBundle: f.neverBundle);
            }(),
        ]);
  }

  /// One article, live.
  Stream<ArticleRow?> watchArticle(int id) {
    final q = db.select(db.articles).join([innerJoin(db.feeds, db.feeds.id.equalsExp(db.articles.feedId))])
      ..where(db.articles.id.equals(id));
    return q.watchSingleOrNull().map((r) {
      if (r == null) return null;
      final f = r.readTable(db.feeds);
      return ArticleRow(article: r.readTable(db.articles), feedTitle: f.customTitle ?? f.title, feedIcon: f.iconUrl);
    });
  }

  /// Unread count of Heute.
  Stream<int> watchUnreadToday() {
    final a = db.articles;
    final c = a.id.count();
    final q = db.selectOnly(a)
      ..addColumns([c])
      ..where(a.hidden.equals(false) & a.archivedAt.isNull() & a.readAt.isNull());
    return q.watchSingle().map((r) => r.read(c) ?? 0);
  }

  /// Marks article [id] read or unread. Reading logs a [ReadEvents] row.
  Future<void> setRead(int id, bool read) async {
    final a = await (db.select(db.articles)..where((x) => x.id.equals(id))).getSingleOrNull();
    if (a == null || (a.readAt != null) == read) return;
    await db.transaction(() async {
      await (db.update(db.articles)..where((x) => x.id.equals(id))).write(ArticlesCompanion(readAt: Value(read ? _utc : null)));
      if (read) {
        await db.into(db.readEvents).insert(ReadEventsCompanion.insert(feedId: Value(a.feedId), at: _utc, minutes: Value(a.readingMinutes)));
      }
      if (a.remoteId != null) await _queue(a.remoteId!, read ? 'read' : 'unread');
    });
  }

  /// Saves or unsaves article [id].
  Future<void> setSaved(int id, bool saved) async {
    final a = await (db.select(db.articles)..where((x) => x.id.equals(id))).getSingleOrNull();
    if (a == null) return;
    await db.transaction(() async {
      await (db.update(db.articles)..where((x) => x.id.equals(id))).write(ArticlesCompanion(
        savedAt: Value(saved ? _utc : null),
        // A saved article comes back from the archive.
        archivedAt: saved ? const Value(null) : const Value.absent(),
      ));
      if (a.remoteId != null) await _queue(a.remoteId!, saved ? 'star' : 'unstar');
    });
  }

  /// Marks the given articles read (the list's "Alles gelesen").
  Future<void> markAllRead(Iterable<int> ids) async {
    for (final id in ids) {
      await setRead(id, true);
    }
  }

  Future<void> _queue(String remoteId, String kind) =>
      db.into(db.syncOps).insert(SyncOpsCompanion.insert(remoteId: remoteId, kind: kind, createdAt: _utc));

  // --------------------------------------------------------------- rules

  /// All rules.
  Stream<List<Rule>> watchRules() => db.select(db.rules).watch();

  /// Adds a rule and applies it to what is in Heute.
  Future<void> addRule({required String pattern, int field = 0, int? feedId, int action = 0}) async {
    await db.into(db.rules).insert(RulesCompanion.insert(pattern: pattern, field: Value(field), feedId: Value(feedId), action: Value(action)));
    await applyRules();
  }

  /// Deletes rule [id] and shows what it hid again.
  Future<void> deleteRule(int id) async {
    await (db.delete(db.rules)..where((r) => r.id.equals(id))).go();
    await (db.update(db.articles)..where((a) => a.hidden.equals(true))).write(const ArticlesCompanion(hidden: Value(false)));
    await applyRules();
  }

  /// Re-applies all enabled rules to articles not yet harvested.
  Future<void> applyRules() async {
    final rules = await (db.select(db.rules)..where((r) => r.enabled.equals(true))).get();
    if (rules.isEmpty) return;
    final open = await (db.select(db.articles)..where((a) => a.archivedAt.isNull() & a.readAt.isNull())).get();
    await db.transaction(() async {
      for (final a in open) {
        final rule = matchRule(rules, feedId: a.feedId, title: a.title, text: a.summary, author: a.author);
        if (rule == null) continue;
        await (db.update(db.articles)..where((x) => x.id.equals(a.id))).write(
          rule.action == 0 ? const ArticlesCompanion(hidden: Value(true)) : ArticlesCompanion(readAt: Value(_utc)),
        );
      }
    });
  }

  // ---------------------------------------------------------------- OPML

  /// Imports [opml]; returns how many feeds were added. Items arrive with
  /// the next refresh.
  Future<int> importOpml(String opml) async {
    final entries = parseOpml(opml);
    var added = 0;
    final before = (await feeds()).length;
    for (final e in entries) {
      final folder = e.folder == null ? null : await folderNamed(e.folder!);
      await addFeedUrl(e.url, title: e.title, siteUrl: e.siteUrl, folderId: folder);
    }
    added = (await feeds()).length - before;
    return added;
  }

  /// Exports all feeds as OPML.
  Future<String> exportOpml() async {
    final rows = await (db.select(db.feeds).join([leftOuterJoin(db.folders, db.folders.id.equalsExp(db.feeds.folderId))])).get();
    return writeOpml([
      for (final r in rows)
        () {
          final f = r.readTable(db.feeds);
          return OpmlFeed(url: f.url, title: f.customTitle ?? f.title, siteUrl: f.siteUrl, folder: r.readTableOrNull(db.folders)?.name);
        }(),
    ]);
  }

  // -------------------------------------------------------------- stats

  /// Reads per local day since [since], for the Jahresernte.
  Future<Map<DateTime, int>> readsPerDay(DateTime since) async {
    final events = await (db.select(db.readEvents)..where((e) => e.at.isBiggerOrEqualValue(since.toUtc()))).get();
    final out = <DateTime, int>{};
    for (final e in events) {
      final l = e.at.toLocal();
      final day = DateTime(l.year, l.month, l.day);
      out[day] = (out[day] ?? 0) + 1;
    }
    return out;
  }

  /// Read events since [since], for totals and the top sources.
  Future<List<ReadEvent>> readEvents(DateTime since) =>
      (db.select(db.readEvents)..where((e) => e.at.isBiggerOrEqualValue(since.toUtc()))).get();
}

/// The first enabled rule matching an article, or null. Patterns match
/// case-insensitively as substrings; a pattern in slashes is a regex.
Rule? matchRule(List<Rule> rules, {required int feedId, required String title, required String text, String? author}) {
  for (final r in rules) {
    if (!r.enabled || (r.feedId != null && r.feedId != feedId)) continue;
    final haystack = switch (r.field) {
      1 => title,
      2 => author ?? '',
      _ => '$title\n$text',
    };
    if (_matches(r.pattern, haystack)) return r;
  }
  return null;
}

bool _matches(String pattern, String haystack) {
  if (pattern.length > 2 && pattern.startsWith('/') && pattern.endsWith('/')) {
    try {
      return RegExp(pattern.substring(1, pattern.length - 1), caseSensitive: false).hasMatch(haystack);
    } on FormatException {
      return false;
    }
  }
  return haystack.toLowerCase().contains(pattern.toLowerCase());
}
