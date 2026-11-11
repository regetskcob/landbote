import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:landbote/data/db/database.dart';
import 'package:landbote/data/feeds/fetcher.dart';
import 'package:landbote/data/repository.dart';
import 'package:landbote/data/sync/greader.dart';
import 'package:landbote/data/sync/miniflux.dart';
import 'package:landbote/data/sync/nextcloud.dart';
import 'package:landbote/data/sync/sync_backend.dart';
import 'package:landbote/data/sync/sync_engine.dart';

class FakeBackend implements SyncBackend {
  final feedsList = [const RemoteFeed(id: 'f1', url: 'https://smnvdl.de/feed/', title: 'Simons Seite', folder: 'Freunde')];
  final itemsList = [
    RemoteItem(id: '1', feedId: 'f1', title: 'Eins', read: false, starred: false, html: '<p>A</p>', published: DateTime.utc(2026, 11, 10)),
    RemoteItem(id: '2', feedId: 'f1', title: 'Zwei', read: true, starred: true, html: '<p>B</p>', published: DateTime.utc(2026, 11, 9)),
  ];
  Set<String> unread = {'1'};
  Set<String> starred = {'2'};
  final readCalls = <(List<String>, bool)>[];
  final subscribed = <String>[];

  @override
  Future<void> login() async {}
  @override
  Future<List<RemoteFeed>> feeds() async => feedsList;
  @override
  Future<List<RemoteItem>> items({DateTime? since}) async => itemsList;
  @override
  Future<Set<String>> unreadIds() async => unread;
  @override
  Future<Set<String>> starredIds() async => starred;
  @override
  Future<void> setRead(List<String> ids, {required bool read}) async {
    if (ids.isNotEmpty) readCalls.add((ids, read));
  }

  @override
  Future<void> setStarred(List<String> ids, {required bool starred}) async {}
  @override
  Future<String?> subscribe(String url) async {
    subscribed.add(url);
    return 'new';
  }

  @override
  Future<void> unsubscribe(String id) async {}
}

void main() {
  late LandboteDatabase db;
  late FeedRepository repo;

  setUp(() {
    db = LandboteDatabase(NativeDatabase.memory());
    repo = FeedRepository(db, Fetcher(MockClient((_) async => http.Response('', 404))));
  });
  tearDown(() => db.close());

  test('first sync uploads local feeds, pulls feeds, items and states', () async {
    await repo.addFeedUrl('https://local.example/feed', title: 'Lokal');
    final backend = FakeBackend()
      ..feedsList.add(const RemoteFeed(id: 'new', url: 'https://local.example/feed', title: 'Lokal'));
    final report = await SyncEngine(repo, backend).sync();
    expect(backend.subscribed, ['https://local.example/feed']);
    expect(report.feeds, 2);
    expect(report.newArticles, 1);
    final feeds = await repo.watchFeeds().first;
    expect(feeds.firstWhere((f) => f.title == 'Simons Seite').folder?.name, 'Freunde');
    final saved = await repo.watchArticles(const SavedScope()).first;
    expect(saved.single.article.title, 'Zwei');
  });

  test('local read goes up, server state comes down', () async {
    final backend = FakeBackend();
    final engine = SyncEngine(repo, backend);
    await engine.sync(since: DateTime.utc(2026));
    final eins = (await repo.watchArticles(const TodayScope()).first).firstWhere((r) => r.article.title == 'Eins');
    await repo.setRead(eins.article.id, true);
    backend.unread = {};
    await engine.sync(since: DateTime.utc(2026));
    expect(backend.readCalls.single.$1, ['1']);
    expect(backend.readCalls.single.$2, isTrue);
    // Marked unread elsewhere: comes back unread here.
    backend.unread = {'1'};
    await engine.sync(since: DateTime.utc(2026));
    final again = await repo.watchArticle(eins.article.id).first;
    expect(again!.isRead, isFalse);
  });

  test('a feed unsubscribed on the server disappears here', () async {
    final backend = FakeBackend();
    await SyncEngine(repo, backend).sync(since: DateTime.utc(2026));
    backend.feedsList.clear();
    await SyncEngine(repo, backend).sync(since: DateTime.utc(2026));
    expect(await repo.feeds(), isEmpty);
  });

  group('clients', () {
    test('GReader logs in, lists feeds and normalizes ids', () async {
      final client = MockClient((r) async {
        final path = r.url.path;
        if (path.endsWith('/accounts/ClientLogin')) {
          expect(r.body, contains('Email=ada'));
          return http.Response('SID=x\nLSID=y\nAuth=TOKEN\n', 200);
        }
        expect(r.headers['Authorization'], 'GoogleLogin auth=TOKEN');
        if (path.endsWith('/subscription/list')) {
          return http.Response(jsonEncode({
            'subscriptions': [
              {'id': 'feed/1', 'title': 'Simons Seite', 'url': 'https://smnvdl.de/feed/', 'categories': [{'id': 'user/-/label/Freunde', 'label': 'Freunde'}]},
            ],
          }), 200);
        }
        if (path.contains('/stream/items/ids')) {
          return http.Response(jsonEncode({'itemRefs': [{'id': '255'}]}), 200);
        }
        return http.Response('', 404);
      });
      final g = GReaderBackend(client, server: 'rss.example.org', user: 'ada', password: 'pw');
      expect(g.base.toString(), 'https://rss.example.org/api/greader.php');
      final feeds = await g.feeds();
      expect(feeds.single.folder, 'Freunde');
      expect(await g.unreadIds(), {'255'});
      expect(normalizeItemId('tag:google.com,2005:reader/item/00000000000000ff'), '255');
    });

    test('GReader refuses bad credentials', () async {
      final g = GReaderBackend(MockClient((_) async => http.Response('Error=BadAuthentication', 401)), server: 'x.example', user: 'a', password: 'b');
      expect(g.login(), throwsA(isA<SyncException>().having((e) => e.unauthorized, 'unauthorized', isTrue)));
    });

    test('Miniflux sends the token and maps entries', () async {
      final client = MockClient((r) async {
        expect(r.headers['X-Auth-Token'], 'T');
        if (r.url.path == '/v1/entries') {
          return http.Response(jsonEncode({
            'total': 1,
            'entries': [
              {'id': 7, 'feed_id': 3, 'title': 'Eins', 'url': 'https://a.example/1', 'content': '<p>x</p>', 'published_at': '2026-11-10T08:00:00Z', 'status': 'read', 'starred': true},
            ],
          }), 200);
        }
        return http.Response('[]', 200);
      });
      final m = MinifluxBackend(client, server: 'https://flux.example/', token: 'T');
      final items = await m.items();
      expect(items.single.id, '7');
      expect(items.single.read, isTrue);
      expect(items.single.starred, isTrue);
      expect(items.single.published, DateTime.utc(2026, 11, 10, 8));
    });

    test('Nextcloud uses basic auth on the News API path', () async {
      final client = MockClient((r) async {
        expect(r.url.path, startsWith('/index.php/apps/news/api/v1-3/'));
        expect(r.headers['Authorization'], startsWith('Basic '));
        if (r.url.path.endsWith('/folders')) return http.Response(jsonEncode({'folders': [{'id': 1, 'name': 'Freunde'}]}), 200);
        if (r.url.path.endsWith('/feeds')) {
          return http.Response(jsonEncode({'feeds': [{'id': 9, 'url': 'https://smnvdl.de/feed/', 'title': 'Simon', 'folderId': 1}]}), 200);
        }
        return http.Response('{}', 200);
      });
      final n = NextcloudBackend(client, server: 'cloud.example', user: 'ada', password: 'pw');
      final feeds = await n.feeds();
      expect(feeds.single.folder, 'Freunde');
    });
  });
}
