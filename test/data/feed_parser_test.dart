import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:landbote/data/feeds/dates.dart';
import 'package:landbote/data/feeds/feed_parser.dart';
import 'package:landbote/data/feeds/readability.dart';
import 'package:landbote/data/feeds/tracking.dart';

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

void main() {
  group('RSS 2.0', () {
    test('regetskcob.de with full content, tags and cover', () {
      final f = parseFeed(fixture('regetskcob_full.xml'), source: Uri.parse('https://www.regetskcob.de/index.xml'));
      expect(f.title, 'regetskcob');
      expect(f.siteUrl, 'https://www.regetskcob.de/');
      expect(f.items, hasLength(6));
      final first = f.items.first;
      expect(first.url, startsWith('https://www.regetskcob.de/blog/'));
      expect(first.author, 'Daniel Bocksteger');
      expect(first.categories, isNotEmpty);
      expect(first.contentHtml, contains('<p>'));
      expect(first.imageUrl, startsWith('https://www.regetskcob.de/'));
      expect(first.published, isNotNull);
      expect(looksComplete(first.contentHtml), isTrue);
    });

    test('regetskcob.de as live today (summaries only)', () {
      final f = parseFeed(fixture('regetskcob.xml'), source: Uri.parse('https://www.regetskcob.de/index.xml'));
      expect(f.items.length, greaterThan(100));
      expect(f.items.every((i) => i.guid.isNotEmpty), isTrue);
    });

    test('smnvdl.de (WordPress, excerpts)', () {
      final f = parseFeed(fixture('smnvdl.xml'), source: Uri.parse('https://smnvdl.de/feed/'));
      expect(f.title, 'Simons Seite');
      expect(f.iconUrl, contains('Logo_klein.png'));
      expect(f.items, isNotEmpty);
      final i = f.items.first;
      expect(i.title, 'Kamera-Experimente in der Toskana');
      expect(i.author, 'Simon');
      expect(looksComplete(i.contentHtml ?? i.summaryHtml), isFalse);
    });
  });

  test('Atom with xhtml content and relative links', () {
    const atom = '''<?xml version="1.0"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title type="text">Beispiel</title>
  <link href="https://example.org/"/>
  <link rel="self" href="https://example.org/atom.xml"/>
  <author><name>Ada</name></author>
  <entry>
    <title>Erster &amp; bester</title>
    <id>tag:example.org,2026:1</id>
    <link href="/posts/1?utm_source=rss&amp;id=7"/>
    <updated>2026-11-10T08:00:00+01:00</updated>
    <content type="xhtml"><div xmlns="http://www.w3.org/1999/xhtml"><p>Hallo <a href="/x">Welt</a></p><img src="img/a.jpg" width="800"/></div></content>
  </entry>
</feed>''';
    final f = parseFeed(atom, source: Uri.parse('https://example.org/atom.xml'));
    final e = f.items.single;
    expect(e.title, 'Erster & bester');
    expect(e.url, 'https://example.org/posts/1?id=7');
    expect(e.author, 'Ada');
    expect(e.published, DateTime.utc(2026, 11, 10, 7));
    expect(e.contentHtml, contains('href="https://example.org/x"'));
    expect(e.imageUrl, 'https://example.org/posts/img/a.jpg');
  });

  test('JSON Feed', () {
    const json = '{"version":"https://jsonfeed.org/version/1.1","title":"J","home_page_url":"https://j.example/",'
        '"items":[{"id":"1","url":"https://j.example/1","title":"Eins","content_text":"A\\n\\nB","date_published":"2026-01-02T03:04:05Z","tags":["x"]}]}';
    final f = parseFeed(json, source: Uri.parse('https://j.example/feed.json'));
    expect(f.items.single.contentHtml, '<p>A</p><p>B</p>');
    expect(f.items.single.categories, ['x']);
  });

  test('RSS 1.0 (RDF)', () {
    const rdf = '''<?xml version="1.0"?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://purl.org/rss/1.0/" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <channel rdf:about="https://r.example/"><title>R</title><link>https://r.example/</link></channel>
  <item rdf:about="https://r.example/1"><title>Eins</title><link>https://r.example/1</link><dc:date>2026-03-01T10:00:00Z</dc:date></item>
</rdf:RDF>''';
    final f = parseFeed(rdf, source: Uri.parse('https://r.example/rss'));
    expect(f.items.single.url, 'https://r.example/1');
    expect(f.items.single.published, DateTime.utc(2026, 3, 1, 10));
  });

  test('broken XML with bare ampersand still parses', () {
    const rss = '<rss><channel><title>A & B</title><item><title>X & Y</title><link>https://a.example/1</link></item></channel></rss>';
    final f = parseFeed(rss, source: Uri.parse('https://a.example/rss'));
    expect(f.title, 'A & B');
    expect(f.items.single.title, 'X & Y');
  });

  test('HTML is no feed', () {
    expect(looksLikeFeed('<!doctype html><html></html>'), isFalse);
    expect(() => parseFeed('<html><body/></html>', source: Uri.parse('https://a.example')), throwsA(isA<FeedFormatException>()));
  });

  group('dates', () {
    test('RFC 822 variants', () {
      expect(parseFeedDate('Tue, 10 Nov 2026 20:12:13 +0000'), DateTime.utc(2026, 11, 10, 20, 12, 13));
      expect(parseFeedDate('10 Nov 2026 21:12 +0100'), DateTime.utc(2026, 11, 10, 20, 12));
      expect(parseFeedDate('Tue, 10 Nov 26 20:12:13 GMT'), DateTime.utc(2026, 11, 10, 20, 12, 13));
      expect(parseFeedDate('Mon, 02 Mar 2026 12:00:00 PST'), DateTime.utc(2026, 3, 2, 20));
      expect(parseFeedDate('kein Datum'), isNull);
    });
  });

  test('tracking parameters are removed', () {
    expect(stripTracking('https://a.example/p?utm_source=x&utm_medium=y'), 'https://a.example/p');
    expect(stripTracking('https://a.example/p?id=1&fbclid=abc#top'), 'https://a.example/p?id=1#top');
    expect(stripTracking('https://a.example/p?id=1'), 'https://a.example/p?id=1');
  });

  test('readability extracts the WordPress post of smnvdl.de', () {
    final a = extractArticle(fixture('smnvdl_post.html'), Uri.parse('https://smnvdl.de/2026/11/kamera-experimente-in-der-toskana/'));
    expect(a, isNotNull);
    expect(a!.html.length, greaterThan(1000));
    expect(a.html, isNot(contains('<script')));
    expect(a.html, isNot(contains('comment-form')));
    expect(a.title, contains('Toskana'));
  });
}
