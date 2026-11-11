/// Brings the local store and a sync server together: pending changes go
/// up, subscriptions and articles come down, read and starred states meet.
library;

import 'package:drift/drift.dart';

import '../db/database.dart';
import '../feeds/html_text.dart';
import '../feeds/tracking.dart';
import '../repository.dart';
import 'sync_backend.dart';

/// The result of a sync run.
class SyncReport {
  /// Creates the report.
  const SyncReport({required this.feeds, required this.newArticles, required this.pushed});

  /// Subscriptions on the server.
  final int feeds;

  /// Articles that were new here.
  final int newArticles;

  /// Local changes sent to the server.
  final int pushed;
}

/// Runs a sync against one [SyncBackend].
class SyncEngine {
  /// Creates the engine.
  SyncEngine(this.repo, this.backend, {DateTime Function()? clock}) : _now = clock ?? DateTime.now;

  /// The local store.
  final FeedRepository repo;

  /// The server.
  final SyncBackend backend;

  final DateTime Function() _now;

  LandboteDatabase get _db => repo.db;

  /// Syncs once. [since] is the previous successful sync; null on the first
  /// run, which also uploads local-only feeds. Throws [SyncException].
  Future<SyncReport> sync({DateTime? since}) async {
    await backend.login();
    final pushed = await _push();

    // Feeds: first sync uploads what was here before the account.
    if (since == null) {
      final local = await (_db.select(_db.feeds)..where((f) => f.remoteId.isNull())).get();
      for (final f in local) {
        try {
          final id = await backend.subscribe(f.url);
          if (id != null) await repo.addFeedUrl(f.url, title: f.title, remoteId: id);
        } on SyncException {
          // A feed the server refuses stays local.
        }
      }
    }
    final remote = await backend.feeds();
    final byRemoteId = <String, int>{};
    for (final r in remote) {
      final folder = r.folder == null || r.folder!.isEmpty ? null : await repo.folderNamed(r.folder!);
      byRemoteId[r.id] = await repo.addFeedUrl(r.url, title: r.title.isEmpty ? r.url : r.title, siteUrl: r.siteUrl, folderId: folder, remoteId: r.id);
    }
    // Unsubscribed elsewhere: remove here too.
    final gone = await (_db.select(_db.feeds)..where((f) => f.remoteId.isNotNull() & f.remoteId.isNotIn(byRemoteId.keys))).get();
    for (final f in gone) {
      await repo.deleteFeed(f.id);
    }

    // Articles.
    final items = await backend.items(since: since?.subtract(const Duration(minutes: 5)));
    var fresh = 0;
    final now = _now().toUtc();
    await _db.transaction(() async {
      for (final i in items) {
        final feedId = byRemoteId[i.feedId];
        if (feedId == null) continue;
        final guid = 'remote:${i.id}';
        final existing = await (_db.select(_db.articles)..where((a) => a.feedId.equals(feedId) & a.guid.equals(guid))).getSingleOrNull();
        if (existing != null) continue;
        final text = plainText(i.html);
        await _db.into(_db.articles).insert(ArticlesCompanion.insert(
              feedId: feedId,
              guid: guid,
              remoteId: Value(i.id),
              url: Value(i.url == null ? null : stripTracking(i.url!)),
              title: i.title,
              author: Value(i.author),
              summary: Value(text.length > 320 ? '${text.substring(0, 320).trimRight()}…' : text),
              contentHtml: Value(i.html),
              imageUrl: Value(i.imageUrl ?? firstImage(i.html, base: i.url == null ? null : Uri.tryParse(i.url!))),
              publishedAt: i.published ?? now,
              fetchedAt: now,
              readAt: Value(i.read ? now : null),
              savedAt: Value(i.starred ? now : null),
              readingMinutes: Value(readingMinutes(text)),
            ));
        if (!i.read) fresh++;
      }
    });

    // States: the server is the truth for everything not pending here.
    final unread = await backend.unreadIds();
    final starred = await backend.starredIds();
    final local = await (_db.select(_db.articles)..where((a) => a.remoteId.isNotNull())).get();
    await _db.transaction(() async {
      for (final a in local) {
        final isUnread = unread.contains(a.remoteId);
        final isStarred = starred.contains(a.remoteId);
        final readChanged = isUnread == (a.readAt != null);
        final starChanged = isStarred != (a.savedAt != null);
        if (!readChanged && !starChanged) continue;
        await (_db.update(_db.articles)..where((x) => x.id.equals(a.id))).write(ArticlesCompanion(
          readAt: readChanged ? Value(isUnread ? null : now) : const Value.absent(),
          savedAt: starChanged ? Value(isStarred ? now : null) : const Value.absent(),
        ));
      }
    });
    await repo.applyRules();
    return SyncReport(feeds: remote.length, newArticles: fresh, pushed: pushed);
  }

  Future<int> _push() async {
    final ops = await (_db.select(_db.syncOps)..orderBy([(o) => OrderingTerm(expression: o.id)])).get();
    if (ops.isEmpty) return 0;
    // The last change per article wins.
    final last = <String, String>{};
    for (final o in ops) {
      final group = o.kind.contains('star') ? 's' : 'r';
      last['$group:${o.remoteId}'] = o.kind;
    }
    List<String> idsOf(String kind) => [
          for (final e in last.entries)
            if (e.value == kind) e.key.substring(2),
        ];
    await backend.setRead(idsOf('read'), read: true);
    await backend.setRead(idsOf('unread'), read: false);
    await backend.setStarred(idsOf('star'), starred: true);
    await backend.setStarred(idsOf('unstar'), starred: false);
    await (_db.delete(_db.syncOps)..where((o) => o.id.isSmallerOrEqualValue(ops.last.id))).go();
    return last.length;
  }
}
