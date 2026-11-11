/// The Google Reader API as FreshRSS (and others) implement it.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../feeds/fetcher.dart' show userAgent;
import '../feeds/html_text.dart';
import 'sync_backend.dart';

const _readingList = 'user/-/state/com.google/reading-list';
const _read = 'user/-/state/com.google/read';
const _starred = 'user/-/state/com.google/starred';

/// A Google Reader API client.
class GReaderBackend implements SyncBackend {
  /// Creates a client for [server], e.g. `https://rss.example.org`; the API
  /// path `/api/greader.php` is appended when missing.
  GReaderBackend(this.client, {required String server, required this.user, required this.password})
      : base = _apiBase(server);

  /// The HTTP client.
  final http.Client client;

  /// The API base, ending in `greader.php` or the server's equivalent.
  final Uri base;

  /// The login name.
  final String user;

  /// The API password.
  final String password;

  String? _auth;
  String? _token;

  static Uri _apiBase(String server) {
    var s = server.trim();
    if (!s.contains('://')) s = 'https://$s';
    s = s.replaceAll(RegExp(r'/+$'), '');
    if (!s.contains('greader.php') && !s.contains('/reader/api')) s = '$s/api/greader.php';
    return Uri.parse(s);
  }

  Uri _u(String path, [Map<String, String>? q]) {
    final p = '${base.path}/$path'.replaceAll('//', '/');
    return base.replace(path: p, queryParameters: {'output': 'json', ...?q});
  }

  Map<String, String> get _headers => {
        'User-Agent': userAgent,
        if (_auth != null) 'Authorization': 'GoogleLogin auth=$_auth',
      };

  @override
  Future<void> login() async {
    final r = await client.post(
      base.replace(path: '${base.path}/accounts/ClientLogin'),
      headers: {'User-Agent': userAgent},
      body: {'Email': user, 'Passwd': password},
    );
    if (r.statusCode == 401 || r.statusCode == 403) throw const SyncException('unauthorized', unauthorized: true);
    if (r.statusCode != 200) throw SyncException('login HTTP ${r.statusCode}');
    final line = const LineSplitter().convert(r.body).firstWhere((l) => l.startsWith('Auth='), orElse: () => '');
    if (line.isEmpty) throw const SyncException('no Auth in ClientLogin', unauthorized: true);
    _auth = line.substring(5).trim();
  }

  Future<void> _ensure() async {
    if (_auth == null) await login();
  }

  Future<String> _editToken() async {
    if (_token != null) return _token!;
    await _ensure();
    final r = await client.get(base.replace(path: '${base.path}/reader/api/0/token'), headers: _headers);
    if (r.statusCode != 200) throw SyncException('token HTTP ${r.statusCode}');
    return _token = r.body.trim();
  }

  Future<Object?> _getJson(String path, [Map<String, String>? q]) async {
    await _ensure();
    final r = await client.get(_u('reader/api/0/$path', q), headers: _headers);
    if (r.statusCode == 401) {
      _auth = null;
      throw const SyncException('unauthorized', unauthorized: true);
    }
    if (r.statusCode != 200) throw SyncException('$path HTTP ${r.statusCode}');
    return jsonDecode(utf8.decode(r.bodyBytes));
  }

  Future<void> _post(String path, Map<String, String> body, {List<MapEntry<String, String>> repeated = const []}) async {
    final token = await _editToken();
    final parts = [
      for (final e in {...body, 'T': token}.entries) '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
      for (final e in repeated) '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}',
    ];
    final r = await client.post(
      base.replace(path: '${base.path}/reader/api/0/$path'),
      headers: {..._headers, 'Content-Type': 'application/x-www-form-urlencoded'},
      body: parts.join('&'),
    );
    if (r.statusCode != 200) throw SyncException('$path HTTP ${r.statusCode}');
  }

  @override
  Future<List<RemoteFeed>> feeds() async {
    final json = await _getJson('subscription/list') as Map<String, Object?>;
    return [
      for (final s in (json['subscriptions'] as List<Object?>? ?? const []).cast<Map<String, Object?>>())
        RemoteFeed(
          id: s['id']! as String,
          url: (s['url'] ?? (s['id']! as String).replaceFirst('feed/', '')) as String,
          title: (s['title'] as String?) ?? '',
          siteUrl: s['htmlUrl'] as String?,
          folder: ((s['categories'] as List<Object?>?)?.cast<Map<String, Object?>>().firstOrNull)?['label'] as String?,
        ),
    ];
  }

  @override
  Future<List<RemoteItem>> items({DateTime? since}) async {
    final out = <RemoteItem>[];
    String? continuation;
    final ot = since ?? DateTime.now().toUtc().subtract(const Duration(days: 14));
    do {
      final json = await _getJson('stream/contents/$_readingList', {
        'n': '250',
        'ot': '${ot.millisecondsSinceEpoch ~/ 1000}',
        'c': ?continuation,
      }) as Map<String, Object?>;
      for (final i in (json['items'] as List<Object?>? ?? const []).cast<Map<String, Object?>>()) {
        out.add(_item(i));
      }
      continuation = json['continuation'] as String?;
    } while (continuation != null && out.length < 2000);
    return out;
  }

  RemoteItem _item(Map<String, Object?> i) {
    final cats = (i['categories'] as List<Object?>? ?? const []).cast<String>();
    final links = [...?(i['canonical'] as List<Object?>?), ...?(i['alternate'] as List<Object?>?)].cast<Map<String, Object?>>();
    final content = ((i['content'] ?? i['summary']) as Map<String, Object?>?)?['content'] as String?;
    final enclosure = (i['enclosure'] as List<Object?>?)?.cast<Map<String, Object?>>().where((e) => '${e['type']}'.startsWith('image/')).firstOrNull;
    return RemoteItem(
      id: normalizeItemId(i['id']! as String),
      feedId: ((i['origin'] as Map<String, Object?>?)?['streamId'] as String?) ?? '',
      title: plainText(i['title'] as String?),
      url: links.firstOrNull?['href'] as String?,
      author: i['author'] as String?,
      html: content,
      published: i['published'] is num ? DateTime.fromMillisecondsSinceEpoch((i['published']! as num).toInt() * 1000, isUtc: true) : null,
      read: cats.any((c) => c.endsWith('/state/com.google/read')),
      starred: cats.any((c) => c.endsWith('/state/com.google/starred')),
      imageUrl: enclosure?['href'] as String?,
    );
  }

  Future<Set<String>> _ids(Map<String, String> q) async {
    final json = await _getJson('stream/items/ids', {'n': '10000', ...q}) as Map<String, Object?>;
    return {
      for (final r in (json['itemRefs'] as List<Object?>? ?? const []).cast<Map<String, Object?>>()) normalizeItemId('${r['id']}'),
    };
  }

  @override
  Future<Set<String>> unreadIds() => _ids({'s': _readingList, 'xt': _read});

  @override
  Future<Set<String>> starredIds() => _ids({'s': _starred});

  Future<void> _tag(List<String> ids, String tag, {required bool add}) async {
    for (var i = 0; i < ids.length; i += 100) {
      final chunk = ids.sublist(i, (i + 100).clamp(0, ids.length));
      await _post('edit-tag', {add ? 'a' : 'r': tag}, repeated: [for (final id in chunk) MapEntry('i', id)]);
    }
  }

  @override
  Future<void> setRead(List<String> ids, {required bool read}) => _tag(ids, _read, add: read);

  @override
  Future<void> setStarred(List<String> ids, {required bool starred}) => _tag(ids, _starred, add: starred);

  @override
  Future<String?> subscribe(String url) async {
    final token = await _editToken();
    final r = await client.post(
      base.replace(path: '${base.path}/reader/api/0/subscription/quickadd', queryParameters: {'quickadd': url, 'output': 'json'}),
      headers: {..._headers, 'Content-Type': 'application/x-www-form-urlencoded'},
      body: 'T=${Uri.encodeQueryComponent(token)}',
    );
    if (r.statusCode != 200) throw SyncException('quickadd HTTP ${r.statusCode}');
    final json = jsonDecode(r.body) as Map<String, Object?>;
    return json['streamId'] as String?;
  }

  @override
  Future<void> unsubscribe(String id) => _post('subscription/edit', {'ac': 'unsubscribe', 's': id});
}

/// Item ids come as `tag:google.com,2005:reader/item/<16 hex>` or as a
/// decimal number; both become the decimal string.
String normalizeItemId(String id) {
  const prefix = 'tag:google.com,2005:reader/item/';
  if (id.startsWith(prefix)) {
    final hex = id.substring(prefix.length);
    return BigInt.parse(hex, radix: 16).toSigned(64).toString();
  }
  return id;
}
