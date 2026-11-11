/// Parses RSS 2.0, RSS 1.0 (RDF), Atom 1.0 and JSON Feed 1.x into
/// [ParsedFeed]. Lenient by design: feeds in the wild are rarely valid.
library;

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';

import 'dates.dart';
import 'html_text.dart';
import 'parsed_feed.dart';
import 'tracking.dart';

const _nsContent = 'http://purl.org/rss/1.0/modules/content/';
const _nsDc = 'http://purl.org/dc/elements/1.1/';
const _nsMedia = 'http://search.yahoo.com/mrss/';
const _nsAtom = 'http://www.w3.org/2005/Atom';

/// Thrown when a document is not a feed in any known format.
class FeedFormatException implements Exception {
  /// Creates the exception with a technical [message].
  const FeedFormatException(this.message);

  /// What went wrong, for the log, not for the UI.
  final String message;

  @override
  String toString() => 'FeedFormatException: $message';
}

/// Whether [body] looks like a feed (as opposed to an HTML page).
bool looksLikeFeed(String body) {
  final head = body.trimLeft();
  if (head.startsWith('{')) return head.contains('jsonfeed.org');
  final start = head.length > 2048 ? head.substring(0, 2048) : head;
  return start.contains('<rss') || start.contains('<feed') || start.contains('<rdf:RDF');
}

/// Parses [body], fetched from [source], into a [ParsedFeed].
///
/// Throws [FeedFormatException] when [body] is neither XML nor JSON Feed.
ParsedFeed parseFeed(String body, {required Uri source}) {
  final trimmed = body.trimLeft();
  if (trimmed.startsWith('{')) return _parseJson(trimmed, source);
  final XmlDocument doc;
  try {
    doc = XmlDocument.parse(_sanitize(trimmed));
  } on XmlException catch (e) {
    throw FeedFormatException('not XML: ${e.message}');
  }
  final root = doc.rootElement;
  switch (root.name.local) {
    case 'rss':
      final channel = _child(root, 'channel');
      if (channel == null) throw const FeedFormatException('rss without channel');
      return _parseRss(channel, channel, source);
    case 'RDF':
      final channel = _child(root, 'channel');
      if (channel == null) throw const FeedFormatException('rdf without channel');
      return _parseRss(channel, root, source);
    case 'feed':
      return _parseAtom(root, source);
    default:
      throw FeedFormatException('unknown root <${root.name.qualified}>');
  }
}

// Strips a byte order mark and characters XML 1.0 forbids, both of which
// real feeds contain and both of which make a strict parser give up.
String _sanitize(String s) {
  var out = s.startsWith('﻿') ? s.substring(1) : s;
  out = out.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
  // Bare ampersands outside entities.
  out = out.replaceAllMapped(
    RegExp(r'&(?!(?:[a-zA-Z][a-zA-Z0-9]*|#[0-9]+|#x[0-9a-fA-F]+);)'),
    (_) => '&amp;',
  );
  return out;
}

XmlElement? _child(XmlElement e, String local, [String? ns]) {
  for (final c in e.childElements) {
    if (c.name.local == local && (ns == null || c.name.namespaceUri == ns)) return c;
  }
  return null;
}

Iterable<XmlElement> _children(XmlElement e, String local, [String? ns]) =>
    e.childElements.where((c) => c.name.local == local && (ns == null || c.name.namespaceUri == ns));

String? _text(XmlElement? e) {
  final t = e?.innerText.trim();
  return (t == null || t.isEmpty) ? null : t;
}

// Elements without a namespace prefix: RSS 2.0 has none, RDF uses the RSS 1.0
// namespace. Either way the local name is what matters.
String? _plainChild(XmlElement e, String local) {
  for (final c in e.childElements) {
    if (c.name.local == local && (c.name.prefix == null || c.name.prefix!.isEmpty)) {
      return _text(c);
    }
  }
  return null;
}

ParsedFeed _parseRss(XmlElement channel, XmlElement itemParent, Uri source) {
  final site = _plainChild(channel, 'link');
  final siteUri = site == null ? source : Uri.tryParse(site) ?? source;
  String? self;
  for (final l in _children(channel, 'link', _nsAtom)) {
    if (l.getAttribute('rel') == 'self') self = l.getAttribute('href');
  }
  final image = _child(channel, 'image');
  final items = <ParsedItem>[];
  for (final item in _children(itemParent, 'item')) {
    final link = _plainChild(item, 'link') ?? item.getAttribute('rdf:about');
    final url = link == null ? null : stripTracking(resolveUrl(link, siteUri) ?? link);
    final base = url == null ? siteUri : Uri.tryParse(url) ?? siteUri;
    final title = plainText(_plainChild(item, 'title'));
    final summary = _plainChild(item, 'description');
    final content = _text(_child(item, 'encoded', _nsContent));
    final guid = _plainChild(item, 'guid') ?? url ?? _hash('$title|$summary');
    final author = _text(_child(item, 'creator', _nsDc)) ?? _plainChild(item, 'author');
    final date = parseFeedDate(_plainChild(item, 'pubDate') ?? _text(_child(item, 'date', _nsDc)));
    items.add(ParsedItem(
      guid: guid,
      title: title,
      url: url,
      author: author,
      summaryHtml: summary == null ? null : absolutize(summary, base),
      contentHtml: content == null ? null : absolutize(content, base),
      imageUrl: _mediaImage(item, base) ?? firstImage(content ?? summary, base: base),
      published: date,
      categories: [
        for (final c in _children(item, 'category')) ?_text(c),
        for (final c in _children(item, 'subject', _nsDc)) ?_text(c),
      ],
    ));
  }
  return ParsedFeed(
    title: plainText(_plainChild(channel, 'title')).ifEmpty(source.host),
    siteUrl: site == null ? null : resolveUrl(site, source),
    iconUrl: image == null ? null : resolveUrl(_plainChild(image, 'url'), siteUri),
    description: plainText(_plainChild(channel, 'description')),
    selfUrl: self,
    items: items,
  );
}

String? _mediaImage(XmlElement item, Uri base) {
  for (final m in [
    ..._children(item, 'content', _nsMedia),
    ..._children(item, 'thumbnail', _nsMedia),
  ]) {
    final type = m.getAttribute('type') ?? '';
    final medium = m.getAttribute('medium') ?? '';
    if (type.startsWith('image/') || medium == 'image' || m.name.local == 'thumbnail' || (type.isEmpty && medium.isEmpty)) {
      final url = resolveUrl(m.getAttribute('url'), base);
      if (url != null) return url;
    }
  }
  for (final group in _children(item, 'group', _nsMedia)) {
    final url = _mediaImage(group, base);
    if (url != null) return url;
  }
  for (final e in _children(item, 'enclosure')) {
    if ((e.getAttribute('type') ?? '').startsWith('image/')) {
      return resolveUrl(e.getAttribute('url'), base);
    }
  }
  return null;
}

ParsedFeed _parseAtom(XmlElement feed, Uri source) {
  String? site;
  String? self;
  for (final l in _children(feed, 'link')) {
    final rel = l.getAttribute('rel') ?? 'alternate';
    if (rel == 'alternate' && site == null) site = l.getAttribute('href');
    if (rel == 'self') self = l.getAttribute('href');
  }
  final siteUri = site == null ? source : source.resolve(site);
  final feedAuthor = _text(_child(_child(feed, 'author') ?? feed, 'name'));
  final items = <ParsedItem>[];
  for (final entry in _children(feed, 'entry')) {
    String? link;
    for (final l in _children(entry, 'link')) {
      final rel = l.getAttribute('rel') ?? 'alternate';
      if (rel == 'alternate') {
        link = l.getAttribute('href');
        break;
      }
    }
    final url = link == null ? null : stripTracking(resolveUrl(link, siteUri) ?? link);
    final base = url == null ? siteUri : Uri.tryParse(url) ?? siteUri;
    final title = plainText(_atomText(_child(entry, 'title')));
    final summary = _atomText(_child(entry, 'summary'));
    final content = _atomText(_child(entry, 'content'));
    final author = _text(_child(_child(entry, 'author') ?? entry, 'name')) ?? feedAuthor;
    items.add(ParsedItem(
      guid: _text(_child(entry, 'id')) ?? url ?? _hash('$title|$summary'),
      title: title,
      url: url,
      author: author,
      summaryHtml: summary == null ? null : absolutize(summary, base),
      contentHtml: content == null ? null : absolutize(content, base),
      imageUrl: _mediaImage(entry, base) ?? firstImage(content ?? summary, base: base),
      published: parseFeedDate(_text(_child(entry, 'published')) ?? _text(_child(entry, 'updated'))),
      categories: [
        for (final c in _children(entry, 'category')) ?(c.getAttribute('label') ?? c.getAttribute('term')),
      ],
    ));
  }
  return ParsedFeed(
    title: plainText(_atomText(_child(feed, 'title'))).ifEmpty(source.host),
    siteUrl: site == null ? null : resolveUrl(site, source),
    iconUrl: resolveUrl(_text(_child(feed, 'icon')) ?? _text(_child(feed, 'logo')), siteUri),
    description: plainText(_atomText(_child(feed, 'subtitle'))),
    selfUrl: self,
    items: items,
  );
}

// Atom text constructs: type="xhtml" carries markup as child nodes, "html"
// and "text" as (escaped) text.
String? _atomText(XmlElement? e) {
  if (e == null) return null;
  if (e.getAttribute('type') == 'xhtml') {
    final div = e.childElements.isEmpty ? null : e.childElements.first;
    final inner = (div ?? e).children.map((n) => n.toXmlString()).join().trim();
    return inner.isEmpty ? null : inner;
  }
  if (e.getAttribute('type') == 'text') {
    final t = _text(e);
    return t == null ? null : _escapeText(t);
  }
  return _text(e);
}

String _escapeText(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

ParsedFeed _parseJson(String body, Uri source) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException catch (e) {
    throw FeedFormatException('not JSON: ${e.message}');
  }
  if (decoded is! Map<String, Object?>) throw const FeedFormatException('JSON Feed is no object');
  final site = decoded['home_page_url'] as String?;
  final siteUri = site == null ? source : source.resolve(site);
  final items = <ParsedItem>[];
  for (final raw in (decoded['items'] as List<Object?>? ?? const [])) {
    if (raw is! Map<String, Object?>) continue;
    final link = (raw['url'] ?? raw['external_url']) as String?;
    final url = link == null ? null : stripTracking(resolveUrl(link, siteUri) ?? link);
    final base = url == null ? siteUri : Uri.tryParse(url) ?? siteUri;
    final html = raw['content_html'] as String?;
    final text = raw['content_text'] as String?;
    final content = html ?? (text == null ? null : '<p>${_escapeText(text).replaceAll('\n\n', '</p><p>')}</p>');
    final authors = raw['authors'] as List<Object?>?;
    final firstAuthor = (authors != null && authors.isNotEmpty) ? authors.first as Map<String, Object?>? : null;
    final author = (raw['author'] as Map<String, Object?>?)?['name'] as String? ?? firstAuthor?['name'] as String?;
    items.add(ParsedItem(
      guid: '${raw['id'] ?? url ?? _hash(content ?? '')}',
      title: plainText(raw['title'] as String?),
      url: url,
      author: author,
      summaryHtml: raw['summary'] as String?,
      contentHtml: content == null ? null : absolutize(content, base),
      imageUrl: resolveUrl((raw['image'] ?? raw['banner_image']) as String?, base) ?? firstImage(content, base: base),
      published: parseFeedDate((raw['date_published'] ?? raw['date_modified']) as String?),
      categories: [for (final t in (raw['tags'] as List<Object?>? ?? const [])) '$t'],
    ));
  }
  return ParsedFeed(
    title: plainText(decoded['title'] as String?).ifEmpty(source.host),
    siteUrl: site,
    iconUrl: resolveUrl((decoded['icon'] ?? decoded['favicon']) as String?, siteUri),
    description: decoded['description'] as String?,
    selfUrl: decoded['feed_url'] as String?,
    items: items,
  );
}

String _hash(String s) => sha1.convert(utf8.encode(s)).toString();

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
