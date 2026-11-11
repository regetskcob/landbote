/// Nextcloud News API v1-3.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../feeds/fetcher.dart' show userAgent;
import 'sync_backend.dart';

/// A Nextcloud News client with basic auth (an app password is best).
class NextcloudBackend implements SyncBackend {
  /// Creates a client for the Nextcloud at [server].
  NextcloudBackend(this.client, {required String server, required this.user, required this.password}) : base = _base(server);

  /// The HTTP client.
  final http.Client client;

  /// The API base.
  final Uri base;

  /// The login name.
  final String user;

  /// The (app) password.
  final String password;

  static Uri _base(String server) {
    var s = server.trim();
    if (!s.contains('://')) s = 'https://$s';
    s = s.replaceAll(RegExp(r'/+$'), '');
    if (!s.contains('/apps/news/api')) s = '$s/index.php/apps/news/api/v1-3';
    return Uri.parse(s);
  }

  Map<String, String> get _headers => {
        'User-Agent': userAgent,
        'Authorization': 'Basic ${base64Encode(utf8.encode('$user:$password'))}',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Object?> _send(String method, String path, {Map<String, String>? query, Object? body}) async {
    final req = http.Request(method, base.replace(path: '${base.path}/$path', queryParameters: query))..headers.addAll(_headers);
    if (body != null) req.body = jsonEncode(body);
    final r = await http.Response.fromStream(await client.send(req));
    if (r.statusCode == 401 || r.statusCode == 403) throw const SyncException('unauthorized', unauthorized: true);
    if (r.statusCode >= 300) throw SyncException('$method $path HTTP ${r.statusCode}');
    if (r.body.isEmpty) return null;
    return jsonDecode(utf8.decode(r.bodyBytes));
  }

  @override
  Future<void> login() async => _send('GET', 'version');

  @override
  Future<List<RemoteFeed>> feeds() async {
    final folders = {
      for (final f in ((await _send('GET', 'folders') as Map<String, Object?>)['folders'] as List<Object?>).cast<Map<String, Object?>>())
        f['id']: f['name'] as String?,
    };
    final feeds = ((await _send('GET', 'feeds') as Map<String, Object?>)['feeds'] as List<Object?>).cast<Map<String, Object?>>();
    return [
      for (final f in feeds)
        RemoteFeed(
          id: '${f['id']}',
          url: f['url']! as String,
          title: (f['title'] as String?) ?? '',
          siteUrl: f['link'] as String?,
          folder: folders[f['folderId']],
        ),
    ];
  }

  RemoteItem _item(Map<String, Object?> i) => RemoteItem(
        id: '${i['id']}',
        feedId: '${i['feedId']}',
        title: (i['title'] as String?) ?? '',
        url: i['url'] as String?,
        author: i['author'] as String?,
        html: i['body'] as String?,
        published: i['pubDate'] is num ? DateTime.fromMillisecondsSinceEpoch((i['pubDate']! as num).toInt() * 1000, isUtc: true) : null,
        read: i['unread'] == false,
        starred: i['starred'] == true,
        imageUrl: '${i['enclosureMime']}'.startsWith('image/') ? i['enclosureLink'] as String? : null,
      );

  @override
  Future<List<RemoteItem>> items({DateTime? since}) async {
    final after = since ?? DateTime.now().toUtc().subtract(const Duration(days: 14));
    final json = await _send('GET', 'items/updated', query: {
      'lastModified': '${after.millisecondsSinceEpoch ~/ 1000}',
      'type': '3',
      'id': '0',
    }) as Map<String, Object?>;
    return [for (final i in (json['items'] as List<Object?>).cast<Map<String, Object?>>()) _item(i)];
  }

  Future<List<Map<String, Object?>>> _all({required bool getRead, int type = 3}) async {
    final json = await _send('GET', 'items', query: {'batchSize': '-1', 'type': '$type', 'id': '0', 'getRead': '$getRead'}) as Map<String, Object?>;
    return (json['items'] as List<Object?>).cast<Map<String, Object?>>();
  }

  @override
  Future<Set<String>> unreadIds() async => {for (final i in await _all(getRead: false)) '${i['id']}'};

  @override
  Future<Set<String>> starredIds() async => {for (final i in await _all(getRead: true, type: 2)) '${i['id']}'};

  @override
  Future<void> setRead(List<String> ids, {required bool read}) async {
    if (ids.isEmpty) return;
    await _send('POST', 'items/${read ? 'read' : 'unread'}/multiple', body: {'itemIds': ids.map(int.parse).toList()});
  }

  @override
  Future<void> setStarred(List<String> ids, {required bool starred}) async {
    if (ids.isEmpty) return;
    await _send('POST', 'items/${starred ? 'star' : 'unstar'}/multiple', body: {'itemIds': ids.map(int.parse).toList()});
  }

  @override
  Future<String?> subscribe(String url) async {
    final json = await _send('POST', 'feeds', body: {'url': url, 'folderId': 0}) as Map<String, Object?>;
    final feeds = (json['feeds'] as List<Object?>?)?.cast<Map<String, Object?>>();
    return feeds == null || feeds.isEmpty ? null : '${feeds.first['id']}';
  }

  @override
  Future<void> unsubscribe(String id) async => _send('DELETE', 'feeds/$id');
}
