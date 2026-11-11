/// Small HTML helpers shared by the parser, the list and the reader.
library;

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;

final _space = RegExp(r'\s+');

/// The visible text of an HTML fragment, whitespace collapsed.
String plainText(String? fragment) {
  if (fragment == null || fragment.isEmpty) return '';
  if (!fragment.contains('<') && !fragment.contains('&')) {
    return fragment.replaceAll(_space, ' ').trim();
  }
  final doc = html.parseFragment(fragment);
  doc.querySelectorAll('script, style, noscript').forEach((e) => e.remove());
  return (doc.text ?? '').replaceAll(_space, ' ').trim();
}

/// The first useful image of an HTML fragment, resolved against [base].
/// Tracking pixels and emoji images (1×1, `wp-smiley`) are skipped.
String? firstImage(String? fragment, {Uri? base}) {
  if (fragment == null || !fragment.contains('<img')) return null;
  final doc = html.parseFragment(fragment);
  for (final img in doc.querySelectorAll('img')) {
    final src = img.attributes['src'] ?? img.attributes['data-src'];
    if (src == null || src.isEmpty || src.startsWith('data:')) continue;
    final w = int.tryParse(img.attributes['width'] ?? '');
    final h = int.tryParse(img.attributes['height'] ?? '');
    if ((w != null && w < 48) || (h != null && h < 48)) continue;
    final cls = img.attributes['class'] ?? '';
    if (cls.contains('smiley') || cls.contains('emoji')) continue;
    return resolveUrl(src, base);
  }
  return null;
}

/// [href] made absolute against [base]; null for unusable input.
String? resolveUrl(String? href, Uri? base) {
  final h = href?.trim();
  if (h == null || h.isEmpty) return null;
  final uri = Uri.tryParse(h);
  if (uri == null) return null;
  if (uri.hasScheme) return uri.toString();
  if (base == null) return h;
  return base.resolveUri(uri).toString();
}

/// Rewrites relative `src` and `href` attributes of [fragment] against [base].
String absolutize(String fragment, Uri? base) {
  if (base == null) return fragment;
  final doc = html.parseFragment(fragment);
  for (final e in doc.querySelectorAll('[src], [href]')) {
    for (final attr in const ['src', 'href']) {
      final v = e.attributes[attr];
      if (v != null && !v.startsWith('#')) {
        e.attributes[attr] = resolveUrl(v, base) ?? v;
      }
    }
  }
  return _outer(doc);
}

String _outer(dom.DocumentFragment doc) =>
    doc.nodes.map((n) => n is dom.Element ? n.outerHtml : (n is dom.Text ? _escape(n.text) : '')).join();

String _escape(String s) =>
    s.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

/// Estimated reading time in whole minutes, at least 1, for German prose at
/// about 220 words per minute.
int readingMinutes(String text) {
  if (text.isEmpty) return 0;
  final words = text.split(_space).length;
  return (words / 220).ceil().clamp(1, 999);
}
