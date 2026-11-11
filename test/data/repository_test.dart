import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:landbote/data/db/database.dart';
import 'package:landbote/data/feeds/fetcher.dart';
import 'package:landbote/data/feeds/opml.dart';
import 'package:landbote/data/repository.dart';

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

void main() {
  late LandboteDatabase db;
  late FeedRepository repo;
  var now = DateTime.utc(2026, 11, 11, 7);

  setUp(() {
    db = LandboteDatabase(NativeDatabase.memory());
    final client = MockClient((r) async {
      final url = r.url.toString();
      if (r.headers['If-None-Match'] == '"v1"') return http.Response('', 304);
      if (url.contains('smnvdl.de/feed') || url == 'https://smnvdl.de/rss') {
        return http.Response(fixture('smnvdl.xml'), 200, headers: {'content-type': 'application/rss+xml; charset=UTF-8', 'etag': '"v1"'});
      }
      if (url.contains('smnvdl.de/20')) {
        return http.Response.bytes(File('test/fixtures/smnvdl_post.html').readAsBytesSync(), 200, headers: {'content-type': 'text/html; charset=UTF-8'});
      }
      if (url == 'https://smnvdl.de' || url == 'https://smnvdl.de/') {
        return http.Response('<html><head><link rel="alternate" type="application/rss+xml" title="Simons Seite" href="/feed/"></head></html>', 200,
            headers: {'content-type': 'text/html'});
      }
      if (url.contains('regetskcob')) {
        return http.Response.bytes(File('test/fixtures/regetskcob_full.xml').readAsBytesSync(), 200, headers: {'content-type': 'application/xml'});
      }
      return http.Response('nope', 404);
    });
    repo = FeedRepository(db, Fetcher(client), clock: () => now);
  });

  tearDown(() => db.close());

  test('discovers a feed from the site URL and adds it', () async {
    final found = await repo.discover('smnvdl.de');
    expect(found, hasLength(1));
    expect(found.single.url.toString(), 'https://smnvdl.de/feed/');
    final id = await repo.addFeed(found.single);
    final rows = await repo.watchArticles(const FeedScope(0)).first;
    expect(rows, isEmpty);
    final feedRows = await repo.watchArticles(FeedScope(id)).first;
    expect(feedRows, isNotEmpty);
  });

  test('refresh honours ETag and stores no duplicates', () async {
    final found = await repo.discover('https://smnvdl.de/rss');
    final id = await repo.addFeed(found.single);
    final before = (await repo.watchArticles(FeedScope(id)).first).length;
    // First refresh: no etag stored by addFeed, so a full fetch, no dupes.
    final feed = (await repo.feeds()).single;
    expect(await repo.refreshFeed(feed), 0);
    final after = (await repo.watchArticles(FeedScope(id)).first).length;
    expect(after, before);
  });

  test('full text is extracted for an excerpt feed', () async {
    final id = await repo.addFeed((await repo.discover('https://smnvdl.de/rss')).single);
    final article = (await repo.watchArticles(FeedScope(id)).first).first.article;
    final html = await repo.fetchFullText(article.id);
    expect(html, isNotNull);
    expect(html!.length, greaterThan(1000));
  });

  test('reading logs an event, saving survives the harvest', () async {
    final id = await repo.addFeed((await repo.discover('https://www.regetskcob.de/index.xml')).single);
    final rows = await repo.watchArticles(FeedScope(id)).first;
    await repo.setRead(rows.first.article.id, true);
    await repo.setSaved(rows[1].article.id, true);
    expect((await repo.readEvents(DateTime.utc(2026))).length, 1);
    now = now.add(const Duration(days: 400));
    await repo.harvest();
    final saved = await repo.watchArticles(const SavedScope()).first;
    expect(saved.single.article.id, rows[1].article.id);
    final today = await repo.watchArticles(const TodayScope()).first;
    expect(today.where((r) => r.article.id == rows[1].article.id), hasLength(1));
    expect(today.length, 1);
    now = DateTime.utc(2026, 11, 11, 7);
  });

  test('rules hide matching articles and come back when deleted', () async {
    final id = await repo.addFeed((await repo.discover('https://smnvdl.de/rss')).single);
    final all = await repo.watchArticles(FeedScope(id)).first;
    await repo.addRule(pattern: 'toskana', field: 1);
    final filtered = await repo.watchArticles(FeedScope(id)).first;
    expect(filtered.length, all.length - 1);
    final rule = (await repo.watchRules().first).single;
    await repo.deleteRule(rule.id);
    expect((await repo.watchArticles(FeedScope(id)).first).length, all.length);
  });

  test('OPML round trip keeps folders', () async {
    final folder = await repo.folderNamed('Freunde');
    await repo.addFeedUrl('https://smnvdl.de/feed/', title: 'Simons Seite', folderId: folder);
    await repo.addFeedUrl('https://www.regetskcob.de/index.xml', title: 'regetskcob');
    final opml = await repo.exportOpml();
    final parsed = parseOpml(opml);
    expect(parsed, hasLength(2));
    expect(parsed.firstWhere((f) => f.url.contains('smnvdl')).folder, 'Freunde');

    final db2 = LandboteDatabase(NativeDatabase.memory());
    final repo2 = FeedRepository(db2, Fetcher(MockClient((_) async => http.Response('', 404))));
    expect(await repo2.importOpml(opml), 2);
    await db2.close();
  });

  test('feed rows count unread and recent', () async {
    final id = await repo.addFeed((await repo.discover('https://www.regetskcob.de/index.xml')).single);
    await repo.updateFeed(id, customTitle: const Value('Mein Blog'));
    final rows = await repo.watchFeeds().first;
    expect(rows.single.title, 'Mein Blog');
    expect(rows.single.unread, greaterThan(0));
  });
}
