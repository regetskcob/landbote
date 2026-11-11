/// Miniflux REST API v1.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../feeds/dates.dart';
import '../feeds/fetcher.dart' show userAgent;
import 'sync_backend.dart';

/// A Miniflux client authenticated by API token.
class MinifluxBackend implements SyncBackend {
  /// Creates a client for [server] with [token].
  MinifluxBackend(this.client, {required String server, required this.token}) : base = _base(server);

  /// The HTTP client.
  final http.Client client;

  /// The server root.
  final Uri base;

  /// The API token.
  final String token;

  static Uri _base(String server) {
    var s = server.trim();
    if (!s.contains('://')) s = 'https://$s';
    return Uri.parse(s.replaceAll(RegExp(r'/+$'), '').replaceAll(RegExp(r'/v1$'), ''));
  }

  Map<String, String> get _headers => {'User-Agent': userAgent, 'X-Auth-Token': token, 'Content-Type': 'application/json'};

  Uri _u(String path, [Map<String, String>? q]) => base.replace(path: '${base.path}/v1/$path', queryParameters: q);

  Future<Object?> _send(String method, String path, {Map<String, String>? query, Object? body}) async {
    final req = http.Request(method, _u(path, query))..headers.addAll(_headers);
    if (body != null) req.body = jsonEncode(body);
    final r = await http.Response.fromStream(await client.send(req));
    if (r.statusCode == 401 || r.statusCode == 403) throw const SyncException('unauthorized', unauthorized: true);
    if (r.statusCode >= 300) throw SyncException('$method $path HTTP ${r.statusCode}');
    if (r.body.isEmpty) return null;
    return jsonDecode(utf8.decode(r.bodyBytes));
  }

  @override
  Future<void> login() async => _send('GET', 'me');

  @override
  Future<List<RemoteFeed>> feeds() async {
    final list = (await _send('GET', 'feeds') as List<Object?>).cast<Map<String, Object?>>();
    return [
      for (final f in list)
        RemoteFeed(
          id: '${f['id']}',
          url: f['feed_url']! as String,
          title: (f['title'] as String?) ?? '',
          siteUrl: f['site_url'] as String?,
          folder: (f['category'] as Map<String, Object?>?)?['title'] as String?,
        ),
    ];
  }

  RemoteItem _item(Map<String, Object?> e) {
    final enclosures = (e['enclosures'] as List<Object?>?)?.cast<Map<String, Object?>>() ?? const [];
    return RemoteItem(
      id: '${e['id']}',
      feedId: '${e['feed_id']}',
      title: (e['title'] as String?) ?? '',
      url: e['url'] as String?,
      author: e['author'] as String?,
      html: e['content'] as String?,
      published: parseFeedDate(e['published_at'] as String?),
      read: e['status'] == 'read',
      starred: e['starred'] == true,
      imageUrl: enclosures.where((x) => '${x['mime_type']}'.startsWith('image/')).firstOrNull?['url'] as String?,
    );
  }

  @override
  Future<List<RemoteItem>> items({DateTime? since}) async {
    final after = since ?? DateTime.now().toUtc().subtract(const Duration(days: 14));
    final out = <RemoteItem>[];
    var offset = 0;
    while (true) {
      final json = await _send('GET', 'entries', query: {
        'limit': '250',
        'offset': '$offset',
        'order': 'published_at',
        'direction': 'desc',
        'changed_after': '${after.millisecondsSinceEpoch ~/ 1000}',
      }) as Map<String, Object?>;
      final entries = (json['entries'] as List<Object?>? ?? const []).cast<Map<String, Object?>>();
      out.addAll(entries.map(_item));
      offset += entries.length;
      if (entries.isEmpty || offset >= ((json['total'] as num?) ?? 0) || out.length >= 2000) break;
    }
    return out;
  }

  Future<Set<String>> _idsWhere(Map<String, String> q) async {
    final out = <String>{};
    var offset = 0;
    while (true) {
      final json = await _send('GET', 'entries', query: {'limit': '1000', 'offset': '$offset', ...q}) as Map<String, Object?>;
      final entries = (json['entries'] as List<Object?>? ?? const []).cast<Map<String, Object?>>();
      out.addAll(entries.map((e) => '${e['id']}'));
      offset += entries.length;
      if (entries.isEmpty || offset >= ((json['total'] as num?) ?? 0)) break;
    }
    return out;
  }

  @override
  Future<Set<String>> unreadIds() => _idsWhere({'status': 'unread'});

  @override
  Future<Set<String>> starredIds() => _idsWhere({'starred': 'true'});

  @override
  Future<void> setRead(List<String> ids, {required bool read}) async {
    if (ids.isEmpty) return;
    await _send('PUT', 'entries', body: {'entry_ids': ids.map(int.parse).toList(), 'status': read ? 'read' : 'unread'});
  }

  @override
  Future<void> setStarred(List<String> ids, {required bool starred}) async {
    // Miniflux only toggles; check the current state first.
    for (final id in ids) {
      final e = await _send('GET', 'entries/$id') as Map<String, Object?>;
      if ((e['starred'] == true) != starred) await _send('PUT', 'entries/$id/bookmark');
    }
  }

  @override
  Future<String?> subscribe(String url) async {
    final cats = (await _send('GET', 'categories') as List<Object?>).cast<Map<String, Object?>>();
    final json = await _send('POST', 'feeds', body: {'feed_url': url, if (cats.isNotEmpty) 'category_id': cats.first['id']}) as Map<String, Object?>;
    return '${json['feed_id']}';
  }

  @override
  Future<void> unsubscribe(String id) async => _send('DELETE', 'feeds/$id');
}
