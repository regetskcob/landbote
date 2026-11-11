/// OPML 2.0 import and export: the one format every reader understands.
library;

import 'package:xml/xml.dart';

/// One subscription from or for an OPML file.
class OpmlFeed {
  /// Creates an entry.
  const OpmlFeed({required this.url, required this.title, this.siteUrl, this.folder});

  /// The feed URL (`xmlUrl`).
  final String url;

  /// The title (`title`, else `text`).
  final String title;

  /// The web page (`htmlUrl`).
  final String? siteUrl;

  /// The folder: the title of the enclosing outline, if any.
  final String? folder;
}

/// Parses an OPML document. Nested outlines become folders; deeper nesting
/// keeps the innermost folder. Throws [XmlException] on broken XML.
List<OpmlFeed> parseOpml(String source) {
  final doc = XmlDocument.parse(source.startsWith('﻿') ? source.substring(1) : source);
  final body = doc.findAllElements('body').firstOrNull;
  if (body == null) return const [];
  final out = <OpmlFeed>[];
  void walk(XmlElement e, String? folder) {
    for (final o in e.childElements.where((c) => c.name.local == 'outline')) {
      final url = o.getAttribute('xmlUrl') ?? o.getAttribute('xmlurl');
      final title = o.getAttribute('title') ?? o.getAttribute('text') ?? '';
      if (url != null && url.isNotEmpty) {
        out.add(OpmlFeed(url: url, title: title.isEmpty ? url : title, siteUrl: o.getAttribute('htmlUrl'), folder: folder));
      }
      if (o.childElements.isNotEmpty) walk(o, url == null ? (title.isEmpty ? folder : title) : folder);
    }
  }

  walk(body, null);
  return out;
}

/// Writes [feeds] as OPML 2.0, grouped by folder.
String writeOpml(List<OpmlFeed> feeds, {DateTime? now}) {
  final b = XmlBuilder()..processing('xml', 'version="1.0" encoding="UTF-8"');
  b.element('opml', attributes: {'version': '2.0'}, nest: () {
    b.element('head', nest: () {
      b.element('title', nest: 'Landbote – Abonnements');
      b.element('dateCreated', nest: _rfc822(now ?? DateTime.now().toUtc()));
    });
    b.element('body', nest: () {
      void feed(OpmlFeed f) => b.element('outline', attributes: {
            'type': 'rss',
            'text': f.title,
            'title': f.title,
            'xmlUrl': f.url,
            'htmlUrl': ?f.siteUrl,
          });
      for (final f in feeds.where((f) => f.folder == null)) {
        feed(f);
      }
      final folders = feeds.map((f) => f.folder).nonNulls.toSet().toList()..sort();
      for (final name in folders) {
        b.element('outline', attributes: {'text': name, 'title': name}, nest: () {
          feeds.where((f) => f.folder == name).forEach(feed);
        });
      }
    });
  });
  return b.buildDocument().toXmlString(pretty: true);
}

String _rfc822(DateTime t) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final u = t.toUtc();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${days[u.weekday - 1]}, ${two(u.day)} ${months[u.month - 1]} ${u.year} ${two(u.hour)}:${two(u.minute)}:${two(u.second)} GMT';
}
