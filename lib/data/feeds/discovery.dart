/// Finds the feeds behind any URL a person pastes: the feed itself, a page
/// that links its feeds, or a site with a feed at a common path.
library;

import 'package:html/parser.dart' as html;

import 'feed_parser.dart';
import 'fetcher.dart';
import 'parsed_feed.dart';

/// A feed found by discovery.
class DiscoveredFeed {
  /// Creates a found feed.
  const DiscoveredFeed({required this.url, required this.feed});

  /// The feed's own URL, after redirects.
  final Uri url;

  /// The parsed feed, so adding it needs no second request.
  final ParsedFeed feed;
}

const _feedTypes = {
  'application/rss+xml',
  'application/atom+xml',
  'application/feed+json',
  'application/json',
  'application/rdf+xml',
  'application/xml',
  'text/xml',
};

const _commonPaths = ['/feed', '/rss', '/index.xml', '/feed.xml', '/atom.xml', '/rss.xml', '/feed.json'];

/// Normalizes what a person typed: adds `https://` to a bare host.
Uri? normalizeInput(String input) {
  var s = input.trim();
  if (s.isEmpty) return null;
  if (!s.contains('://')) s = 'https://$s';
  final uri = Uri.tryParse(s);
  if (uri == null || uri.host.isEmpty || !uri.host.contains('.')) return null;
  return uri;
}

/// Discovers the feeds of [input] with [fetcher]. Returns an empty list when
/// none was found; never throws.
Future<List<DiscoveredFeed>> discoverFeeds(String input, Fetcher fetcher) async {
  final uri = normalizeInput(input);
  if (uri == null) return const [];
  final first = await fetcher.get(uri);
  if (first is! Fetched) return const [];

  final direct = _tryParse(first);
  if (direct != null) return [direct];

  final candidates = <Uri>[];
  final doc = html.parse(first.body);
  for (final link in doc.querySelectorAll('link').where((l) => _isAlternate(l.attributes['rel']))) {
    final type = (link.attributes['type'] ?? '').toLowerCase();
    final href = link.attributes['href'];
    if (href == null) continue;
    if (type.isEmpty || _feedTypes.contains(type)) {
      // Comment feeds are rarely what a person means.
      final title = (link.attributes['title'] ?? '').toLowerCase();
      if (title.contains('kommentar') || title.contains('comment')) continue;
      candidates.add(first.finalUrl.resolve(href));
    }
  }
  if (candidates.isEmpty) {
    for (final p in _commonPaths) {
      candidates.add(first.finalUrl.replace(path: p, query: null, fragment: null));
    }
  }

  final found = <DiscoveredFeed>[];
  final tried = <String>{};
  final seen = <String>{};
  for (final c in candidates.take(8)) {
    if (!tried.add(c.toString())) continue;
    final r = await fetcher.get(c);
    if (r is! Fetched) continue;
    final f = _tryParse(r);
    if (f != null && seen.add(f.url.toString())) found.add(f);
    // From common paths, the first hit is enough.
    if (found.isNotEmpty && !doc.querySelectorAll('link').any((l) => _isAlternate(l.attributes['rel']))) break;
  }
  return found;
}

DiscoveredFeed? _tryParse(Fetched r) {
  if (!looksLikeFeed(r.body)) return null;
  try {
    return DiscoveredFeed(url: r.finalUrl, feed: parseFeed(r.body, source: r.finalUrl));
  } on FeedFormatException {
    return null;
  }
}

bool _isAlternate(String? rel) {
  final parts = (rel ?? '').toLowerCase().split(RegExp(r'\s+'));
  return parts.contains('alternate') || parts.contains('feed');
}
