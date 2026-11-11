/// Full-text extraction: finds the article in a web page and returns it as
/// clean HTML, the way Mozilla's Readability does, much smaller.
///
/// Runs locally; nothing is sent anywhere but the page request itself.
library;

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;

import 'html_text.dart';

/// The extracted article.
class ExtractedArticle {
  /// Creates the result.
  const ExtractedArticle({required this.html, this.title, this.leadImage});

  /// The article body as clean HTML with absolute links.
  final String html;

  /// The page's headline, if found.
  final String? title;

  /// The `og:image`, if the page names one.
  final String? leadImage;
}

const _remove = 'script, style, noscript, iframe, form, nav, aside, footer, '
    'button, input, select, textarea, svg, canvas, template, [hidden], [aria-hidden="true"], '
    '.comments, #comments, .comment-respond, .sharedaddy, .share, .social, .related, .newsletter, .advertisement, .ad';

final _positive = RegExp(r'article|body|content|entry|hentry|main|page|post|text|blog|story|prose', caseSensitive: false);
final _negative = RegExp(
  r'comment|meta|footer|footnote|sidebar|widget|share|social|related|nav|menu|breadcrumb|promo|sponsor|ad-|banner|cookie|popup|subscribe|newsletter|author-box',
  caseSensitive: false,
);

const _blockTags = {'p', 'pre', 'blockquote', 'h2', 'h3', 'h4', 'ul', 'ol', 'figure', 'table'};

/// Extracts the main article of [page], fetched from [url]. Returns null when
/// no block of text worth reading was found.
ExtractedArticle? extractArticle(String page, Uri url) {
  final doc = html.parse(page);
  final title = doc.querySelector('meta[property="og:title"]')?.attributes['content'] ??
      doc.querySelector('h1')?.text.trim() ??
      doc.querySelector('title')?.text.trim();
  final lead = resolveUrl(doc.querySelector('meta[property="og:image"]')?.attributes['content'], url);

  // Semantic containers first: most blogs mark their article.
  dom.Element? best;
  for (final selector in const [
    '[itemprop="articleBody"]',
    'article .entry-content',
    'article .post-content',
    '.entry-content',
    '.post-content',
    'article',
    'main',
    '[role="main"]',
  ]) {
    final candidates = doc.querySelectorAll(selector);
    if (candidates.isEmpty) continue;
    candidates.sort((a, b) => _textLength(b).compareTo(_textLength(a)));
    if (_textLength(candidates.first) > 400) {
      best = candidates.first;
      break;
    }
  }
  doc.querySelectorAll(_remove).forEach((e) => e.remove());
  if (best != null && best.parent == null) best = null; // removed with the noise
  best ??= _byScore(doc);
  if (best == null || _textLength(best) < 200) return null;

  _clean(best, url);
  final out = best.innerHtml.trim();
  return out.isEmpty ? null : ExtractedArticle(html: out, title: title, leadImage: lead);
}

int _textLength(dom.Element e) => (e.text).replaceAll(RegExp(r'\s+'), ' ').trim().length;

double _classWeight(dom.Element e) {
  final s = '${e.className} ${e.id}';
  var w = 0.0;
  if (_positive.hasMatch(s)) w += 25;
  if (_negative.hasMatch(s)) w -= 25;
  return w;
}

dom.Element? _byScore(dom.Document doc) {
  final scores = <dom.Element, double>{};
  for (final p in doc.querySelectorAll('p, pre, td, blockquote')) {
    final text = p.text.trim();
    if (text.length < 25) continue;
    var score = 1.0 + ','.allMatches(text).length + (text.length / 100).clamp(0, 3);
    final parent = p.parent;
    if (parent == null) continue;
    scores[parent] = (scores[parent] ?? _classWeight(parent)) + score;
    final grand = parent.parent;
    if (grand != null) scores[grand] = (scores[grand] ?? _classWeight(grand)) + score / 2;
  }
  if (scores.isEmpty) return null;
  dom.Element? top;
  var topScore = double.negativeInfinity;
  scores.forEach((e, s) {
    final adjusted = s * (1 - _linkDensity(e));
    if (adjusted > topScore) {
      top = e;
      topScore = adjusted;
    }
  });
  return top;
}

double _linkDensity(dom.Element e) {
  final total = _textLength(e);
  if (total == 0) return 0;
  final links = e.querySelectorAll('a').fold<int>(0, (n, a) => n + a.text.trim().length);
  return links / total;
}

void _clean(dom.Element root, Uri base) {
  // Drop link farms and empty blocks the extractor dragged in.
  for (final e in root.querySelectorAll('div, section, ul, ol, table').toList()) {
    if (_linkDensity(e) > 0.5 && _textLength(e) < 400) e.remove();
  }
  for (final h in root.querySelectorAll('h1').toList()) {
    h.remove(); // the reader shows the title itself
  }
  for (final e in root.querySelectorAll('*')) {
    final keep = <String, String>{};
    for (final attr in const ['href', 'src', 'alt', 'title', 'width', 'height', 'colspan', 'rowspan']) {
      final v = e.attributes[attr];
      if (v != null) keep[attr] = v;
    }
    // Lazy-loaded images carry the real source in a data attribute.
    final lazy = e.attributes['data-src'] ?? e.attributes['data-lazy-src'] ?? e.attributes['data-original'];
    if (e.localName == 'img' && lazy != null) keep['src'] = lazy;
    if (e.localName == 'img' && (keep['src'] == null || keep['src']!.startsWith('data:'))) {
      final srcset = e.attributes['srcset'] ?? e.attributes['data-srcset'];
      final firstSrc = srcset?.split(',').last.trim().split(' ').first;
      if (firstSrc != null && firstSrc.isNotEmpty) keep['src'] = firstSrc;
    }
    for (final attr in const ['href', 'src']) {
      final v = keep[attr];
      if (v != null && !v.startsWith('#')) keep[attr] = resolveUrl(v, base) ?? v;
    }
    e.attributes
      ..clear()
      ..addAll(keep);
  }
  for (final e in root.querySelectorAll('p, div, span, section').toList().reversed) {
    if (e.text.trim().isEmpty && e.querySelector('img, picture, video') == null) e.remove();
  }
}

/// Whether [contentHtml] from the feed already is the whole post, so no page
/// fetch is needed: long enough and not cut off with "weiterlesen".
bool looksComplete(String? contentHtml) {
  if (contentHtml == null) return false;
  final text = plainText(contentHtml);
  if (text.length < 600) return false;
  final tail = text.length > 160 ? text.substring(text.length - 160).toLowerCase() : text.toLowerCase();
  if (tail.contains('weiterlesen') || tail.contains('read more') || tail.contains('continue reading') || tail.endsWith('…') || tail.endsWith('[…]')) {
    return false;
  }
  final doc = html.parseFragment(contentHtml);
  return doc.querySelectorAll(_blockTags.join(',')).length >= 2;
}
