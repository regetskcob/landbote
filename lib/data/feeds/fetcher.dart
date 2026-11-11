/// HTTP access for feeds and pages: conditional GET, charset detection,
/// one honest user agent, nothing else sent.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// The user agent Landbote sends. No device, no user, no tracking id.
const userAgent = 'Landbote/1.0 (RSS-Reader; +https://github.com/regetskcob/landbote)';

/// The outcome of a fetch.
sealed class FetchResult {
  const FetchResult();
}

/// The resource changed (or was fetched unconditionally).
final class Fetched extends FetchResult {
  /// Creates a fetched result.
  const Fetched({required this.body, required this.finalUrl, this.etag, this.lastModified, this.contentType});

  /// The decoded body.
  final String body;

  /// The URL after redirects.
  final Uri finalUrl;

  /// The validators for the next conditional request.
  final String? etag;

  /// See [etag].
  final String? lastModified;

  /// The `Content-Type` header, lower case.
  final String? contentType;
}

/// The server answered 304: nothing new since the last fetch.
final class NotModified extends FetchResult {
  /// Creates the result.
  const NotModified();
}

/// The fetch failed; [message] is technical, the UI shows its own sentence.
final class FetchFailed extends FetchResult {
  /// Creates a failure.
  const FetchFailed(this.message, {this.statusCode});

  /// What went wrong.
  final String message;

  /// The HTTP status, if there was a response.
  final int? statusCode;
}

/// Fetches URLs with conditional GET.
class Fetcher {
  /// Creates a fetcher on [client].
  Fetcher(this.client, {this.timeout = const Duration(seconds: 20)});

  /// The HTTP client, injected for tests.
  final http.Client client;

  /// The time a single request may take.
  final Duration timeout;

  /// GETs [url]. With [etag] or [lastModified] the request is conditional.
  Future<FetchResult> get(Uri url, {String? etag, String? lastModified, String? accept}) async {
    final request = http.Request('GET', url)
      ..followRedirects = true
      ..maxRedirects = 8
      ..headers['User-Agent'] = userAgent
      ..headers['Accept'] = accept ??
          'application/rss+xml, application/atom+xml, application/feed+json, application/xml;q=0.9, text/html;q=0.8, */*;q=0.5';
    if (etag != null) request.headers['If-None-Match'] = etag;
    if (lastModified != null) request.headers['If-Modified-Since'] = lastModified;
    try {
      final streamed = await client.send(request).timeout(timeout);
      final response = await http.Response.fromStream(streamed).timeout(timeout);
      if (response.statusCode == 304) return const NotModified();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return FetchFailed('HTTP ${response.statusCode}', statusCode: response.statusCode);
      }
      final type = response.headers['content-type']?.toLowerCase();
      return Fetched(
        body: decodeBody(response.bodyBytes, type),
        finalUrl: response.request?.url ?? url,
        etag: response.headers['etag'],
        lastModified: response.headers['last-modified'],
        contentType: type,
      );
    } on TimeoutException {
      return const FetchFailed('timeout');
    } on http.ClientException catch (e) {
      return FetchFailed(e.message);
    } on Exception catch (e) {
      return FetchFailed('$e');
    }
  }
}

final _xmlEncoding = RegExp(r'''<\?xml[^>]*encoding=["']([^"']+)["']''', caseSensitive: false);
final _metaCharset = RegExp(r'''<meta[^>]+charset=["']?([\w-]+)''', caseSensitive: false);

/// Decodes [bytes] by the charset of [contentType], the XML declaration or a
/// meta tag, in that order; UTF-8 by default, Latin-1 when UTF-8 fails.
String decodeBody(List<int> bytes, String? contentType) {
  String? charset = RegExp(r'charset=([\w-]+)').firstMatch(contentType ?? '')?.group(1);
  if (charset == null) {
    final head = latin1.decode(bytes.take(1024).toList());
    charset = _xmlEncoding.firstMatch(head)?.group(1) ?? _metaCharset.firstMatch(head)?.group(1);
  }
  final cs = charset?.toLowerCase();
  if (cs == 'iso-8859-1' || cs == 'latin1' || cs == 'windows-1252' || cs == 'iso-8859-15') {
    return latin1.decode(bytes, allowInvalid: true);
  }
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return latin1.decode(bytes, allowInvalid: true);
  }
}
