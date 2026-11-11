/// Renders article HTML as Flutter widgets in Horizont's reading type, not in
/// a WebView: every post looks like it belongs here, text is selectable, and
/// the headings are known to the Lese-Horizont.
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:horizont/horizont.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html;

import '../../app/settings.dart';
import '../../l10n/strings.dart';

/// A heading of the article, for the Lese-Horizont.
class ArticleHeading {
  /// Creates a heading.
  ArticleHeading(this.title, this.key);

  /// The heading text.
  final String title;

  /// The key of the rendered heading, to find its position.
  final GlobalKey key;
}

/// The reader's typographic settings.
@immutable
class ReaderStyle {
  /// Creates the style.
  const ReaderStyle({required this.body, required this.justify, required this.heading});

  /// The paragraph style.
  final TextStyle body;

  /// The heading style.
  final TextStyle heading;

  /// Justified paragraphs.
  final bool justify;

  /// Builds the style from the theme and [settings]; [supporter] gates the
  /// personal settings.
  factory ReaderStyle.of(BuildContext context, Settings settings, {required bool supporter}) {
    final h = HorizontTheme.of(context);
    var body = h.reading;
    if (supporter) {
      if (settings.readerFont == ReaderFont.mona) body = body.copyWith(fontFamily: HzFont.sans, package: HzFont.package, fontWeight: FontWeight.w400);
      body = body.copyWith(fontSize: (body.fontSize ?? HzType.reading.size) * settings.readerScale, height: settings.readerSpacing.height);
    }
    final heading = body.copyWith(fontSize: (body.fontSize ?? HzType.reading.size) * 1.22, fontWeight: FontWeight.w600, height: 1.3);
    return ReaderStyle(body: body, heading: heading, justify: supporter && settings.justify);
  }
}

/// The rendered article.
class ArticleHtml extends StatefulWidget {
  /// Creates the view for [source].
  const ArticleHtml({
    required this.source,
    required this.style,
    required this.loadImages,
    required this.onLink,
    required this.onImage,
    this.onHeadings,
    super.key,
  });

  /// The HTML.
  final String source;

  /// The typography.
  final ReaderStyle style;

  /// Whether images load without a tap.
  final bool loadImages;

  /// Called for a tapped link.
  final ValueChanged<String> onLink;

  /// Called for a tapped image with its URL and alt text.
  final void Function(String url, String? alt) onImage;

  /// Called with the headings after each parse.
  final ValueChanged<List<ArticleHeading>>? onHeadings;

  @override
  State<ArticleHtml> createState() => _ArticleHtmlState();
}

class _ArticleHtmlState extends State<ArticleHtml> {
  late dom.DocumentFragment _doc;
  final _recognizers = <GestureRecognizer>[];
  final _headings = <ArticleHeading>[];
  final _revealed = <String>{};

  @override
  void initState() {
    super.initState();
    _parse();
  }

  @override
  void didUpdateWidget(ArticleHtml old) {
    super.didUpdateWidget(old);
    if (old.source != widget.source) _parse();
  }

  void _parse() {
    _doc = html.parseFragment(widget.source);
    _doc.querySelectorAll('script, style, noscript, form, button').forEach((e) => e.remove());
  }

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    _headings.clear();
    final blocks = _blocks(context, _doc.nodes);
    final headings = List<ArticleHeading>.of(_headings);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onHeadings?.call(headings);
    });
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: blocks);
  }

  // ------------------------------------------------------------- blocks

  static const _blockNames = {
    'p', 'div', 'section', 'article', 'main', 'header', 'footer', 'figure', 'blockquote', 'pre',
    'ul', 'ol', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'hr', 'table', 'img', 'picture', 'iframe', 'video', 'dl', 'details', 'aside',
  };

  bool _isBlock(dom.Node n) => n is dom.Element && _blockNames.contains(n.localName);

  List<Widget> _blocks(BuildContext context, List<dom.Node> nodes) {
    final out = <Widget>[];
    var inline = <dom.Node>[];
    void flush() {
      if (inline.isEmpty) return;
      final p = _paragraph(context, inline);
      if (p != null) out.add(p);
      inline = [];
    }

    for (final n in nodes) {
      if (_isBlock(n)) {
        flush();
        out.addAll(_block(context, n as dom.Element));
      } else {
        inline.add(n);
      }
    }
    flush();
    return out;
  }

  List<Widget> _block(BuildContext context, dom.Element e) {
    final c = HorizontTheme.of(context).colors;
    final s = widget.style;
    switch (e.localName) {
      case 'p':
        final hasBlock = e.nodes.any(_isBlock);
        if (hasBlock) return _blocks(context, e.nodes);
        final p = _paragraph(context, e.nodes);
        return p == null ? const [] : [p];
      case 'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6':
        final text = e.text.trim();
        if (text.isEmpty) return const [];
        final key = GlobalKey();
        if (e.localName == 'h2' || e.localName == 'h3' || e.localName == 'h1') _headings.add(ArticleHeading(text, key));
        final level = int.parse(e.localName!.substring(1));
        final style = level <= 2 ? s.heading : s.heading.copyWith(fontSize: (s.heading.fontSize ?? 20) * 0.88);
        return [
          Padding(
            key: key,
            padding: const EdgeInsets.only(top: HzSpace.s24, bottom: HzSpace.s8),
            child: Semantics(header: true, child: Text.rich(TextSpan(children: _inline(context, e.nodes, style)), style: style)),
          ),
        ];
      case 'blockquote':
        return [
          Container(
            margin: const EdgeInsets.only(bottom: HzSpace.s16),
            padding: const EdgeInsetsDirectional.only(start: HzSpace.s16),
            decoration: BoxDecoration(border: BorderDirectional(start: BorderSide(color: c.lineStrong, width: HzLine.selection))),
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontStyle: FontStyle.italic),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _blocks(context, e.nodes)),
            ),
          ),
        ];
      case 'pre':
        return [
          Container(
            margin: const EdgeInsets.only(bottom: HzSpace.s16),
            decoration: BoxDecoration(color: c.sunken, borderRadius: BorderRadius.circular(HzRadius.r6)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(HzSpace.s12),
              child: Text(e.text.replaceAll(RegExp(r'\n$'), ''), style: HorizontTheme.of(context).data),
            ),
          ),
        ];
      case 'ul' || 'ol':
        final ordered = e.localName == 'ol';
        final items = e.children.where((x) => x.localName == 'li').toList();
        return [
          Padding(
            padding: const EdgeInsets.only(bottom: HzSpace.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: HzSpace.s4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: HzSpace.s24,
                          child: Text(ordered ? '${i + 1}.' : '–', style: ordered ? s.body.copyWith(fontFeatures: const [FontFeature.tabularFigures()]) : s.body.copyWith(color: c.textMuted)),
                        ),
                        Expanded(child: _listItem(context, items[i])),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ];
      case 'hr':
        return [
          Padding(padding: const EdgeInsets.symmetric(vertical: HzSpace.s16), child: Divider(height: HzLine.hairline, color: c.line)),
        ];
      case 'img':
        final img = _image(context, e, null);
        return img == null ? const [] : [img];
      case 'picture':
        final i = e.querySelector('img');
        final img = i == null ? null : _image(context, i, null);
        return img == null ? const [] : [img];
      case 'figure':
        final i = e.querySelector('img');
        final caption = e.querySelector('figcaption')?.text.trim();
        if (i == null) return _blocks(context, e.nodes.where((n) => !(n is dom.Element && n.localName == 'figcaption')).toList());
        final img = _image(context, i, caption);
        return img == null ? const [] : [img];
      case 'iframe' || 'video':
        final src = e.attributes['src'] ?? e.querySelector('source')?.attributes['src'];
        if (src == null) return const [];
        return [
          Padding(
            padding: const EdgeInsets.only(bottom: HzSpace.s16),
            child: HorizontNotice(
              HorizontStatus.info,
              icon: HorizontSymbols.openInNew,
              onTap: () => widget.onLink(src),
              child: Text(Uri.tryParse(src)?.host ?? src),
            ),
          ),
        ];
      case 'table':
        return [_table(context, e)];
      default:
        return _blocks(context, e.nodes);
    }
  }

  Widget _listItem(BuildContext context, dom.Element li) {
    final children = _blocks(context, li.nodes);
    if (children.isEmpty) return const SizedBox.shrink();
    // A list item's last paragraph has no gap below; the list sets it.
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  Widget? _paragraph(BuildContext context, List<dom.Node> nodes) {
    final spans = _inline(context, nodes, widget.style.body);
    final hasText = spans.any((s) => s is! TextSpan || (s.toPlainText().trim().isNotEmpty));
    if (spans.isEmpty || !hasText) return null;
    return Padding(
      padding: const EdgeInsets.only(bottom: HzSpace.s16),
      child: Text.rich(
        TextSpan(children: _trim(spans)),
        style: widget.style.body,
        textAlign: widget.style.justify ? TextAlign.justify : TextAlign.start,
      ),
    );
  }

  List<InlineSpan> _trim(List<InlineSpan> spans) {
    if (spans.isEmpty) return spans;
    final first = spans.first;
    if (first is TextSpan && first.text != null && first.children == null) {
      spans[0] = TextSpan(text: first.text!.trimLeft(), style: first.style, recognizer: first.recognizer);
    }
    return spans;
  }

  List<InlineSpan> _inline(BuildContext context, List<dom.Node> nodes, TextStyle base, {String? link}) {
    final c = HorizontTheme.of(context).colors;
    final out = <InlineSpan>[];
    for (final n in nodes) {
      if (n is dom.Text) {
        final t = n.text.replaceAll(RegExp(r'\s+'), ' ');
        if (t.isEmpty) continue;
        out.add(TextSpan(text: t, recognizer: link == null ? null : _tap(link)));
      } else if (n is dom.Element) {
        switch (n.localName) {
          case 'br':
            out.add(const TextSpan(text: '\n'));
          case 'strong' || 'b':
            out.add(TextSpan(style: const TextStyle(fontWeight: FontWeight.w600), children: _inline(context, n.nodes, base, link: link)));
          case 'em' || 'i' || 'cite':
            out.add(TextSpan(style: const TextStyle(fontStyle: FontStyle.italic), children: _inline(context, n.nodes, base, link: link)));
          case 'code' || 'kbd' || 'samp':
            out.add(TextSpan(
              text: n.text,
              style: HorizontTheme.of(context).data.copyWith(fontSize: (base.fontSize ?? 18) * 0.85, backgroundColor: c.sunken),
            ));
          case 'a':
            final href = n.attributes['href'];
            out.add(TextSpan(
              style: TextStyle(color: c.accentText, decoration: TextDecoration.underline, decorationColor: c.accentText.withValues(alpha: 0.5)),
              children: _inline(context, n.nodes, base, link: href ?? link),
            ));
          case 'sup':
            out.add(TextSpan(style: TextStyle(fontSize: (base.fontSize ?? 18) * 0.7), children: _inline(context, n.nodes, base, link: link)));
          case 'del' || 's':
            out.add(TextSpan(style: const TextStyle(decoration: TextDecoration.lineThrough), children: _inline(context, n.nodes, base, link: link)));
          case 'mark':
            out.add(TextSpan(style: TextStyle(backgroundColor: c.warningTint), children: _inline(context, n.nodes, base, link: link)));
          case 'img':
            // Small inline images (emoji, icons) stay in the line.
            final w = double.tryParse(n.attributes['width'] ?? '');
            final src = n.attributes['src'];
            if (src != null && w != null && w <= 32) {
              out.add(WidgetSpan(alignment: PlaceholderAlignment.middle, child: Image.network(src, width: w, height: w, errorBuilder: (_, _, _) => const SizedBox.shrink())));
            } else if (n.attributes['alt']?.isNotEmpty ?? false) {
              out.add(TextSpan(text: n.attributes['alt']));
            }
          default:
            out.addAll(_inline(context, n.nodes, base, link: link));
        }
      }
    }
    return out;
  }

  TapGestureRecognizer _tap(String href) {
    final r = TapGestureRecognizer()..onTap = () => widget.onLink(href);
    _recognizers.add(r);
    return r;
  }

  Widget? _image(BuildContext context, dom.Element img, String? caption) {
    final src = img.attributes['src'];
    if (src == null || src.isEmpty || src.startsWith('data:')) return null;
    final c = HorizontTheme.of(context).colors;
    final alt = img.attributes['alt'];
    final w = double.tryParse(img.attributes['width'] ?? '');
    final h = double.tryParse(img.attributes['height'] ?? '');
    if (w != null && w < 48 && h != null && h < 48) return null; // tracking pixels
    final ratio = (w != null && h != null && w > 0 && h > 0) ? w / h : null;
    final show = widget.loadImages || _revealed.contains(src);
    Widget picture;
    if (!show) {
      picture = AspectRatio(
        aspectRatio: ratio ?? 3 / 2,
        child: Material(
          color: c.sunken,
          borderRadius: BorderRadius.circular(HzRadius.r6),
          child: InkWell(
            borderRadius: BorderRadius.circular(HzRadius.r6),
            onTap: () => setState(() => _revealed.add(src)),
            child: Center(
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(HorizontSymbols.image, size: HzIconSize.inline, color: c.textMuted),
                const SizedBox(width: HzSpace.s8),
                Text(S.loadImage, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textMuted)),
              ]),
            ),
          ),
        ),
      );
    } else {
      picture = GestureDetector(
        onTap: () => widget.onImage(src, alt),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(HzRadius.r6),
          child: Image.network(
            src,
            fit: BoxFit.contain,
            semanticLabel: alt,
            frameBuilder: (context, child, frame, sync) => frame == null && !sync
                ? AspectRatio(aspectRatio: ratio ?? 3 / 2, child: ColoredBox(color: c.sunken))
                : child,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: HzSpace.s8, bottom: HzSpace.s16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        picture,
        if (caption != null && caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: HzSpace.s8),
            child: Text(caption, style: Theme.of(context).textTheme.bodySmall),
          ),
      ]),
    );
  }

  Widget _table(BuildContext context, dom.Element table) {
    final c = HorizontTheme.of(context).colors;
    final rows = table.querySelectorAll('tr');
    if (rows.isEmpty) return const SizedBox.shrink();
    final cols = rows.map((r) => r.children.where((x) => x.localName == 'td' || x.localName == 'th').length).fold<int>(0, (a, b) => a > b ? a : b);
    final style = Theme.of(context).textTheme.bodyMedium!;
    return Padding(
      padding: const EdgeInsets.only(bottom: HzSpace.s16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder(horizontalInside: BorderSide(color: c.line, width: HzLine.hairline), bottom: BorderSide(color: c.line, width: HzLine.hairline)),
          children: [
            for (final r in rows)
              TableRow(children: [
                for (var i = 0; i < cols; i++)
                  () {
                    final cells = r.children.where((x) => x.localName == 'td' || x.localName == 'th').toList();
                    final cell = i < cells.length ? cells[i] : null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: HzSpace.s8, vertical: HzSpace.s8),
                      child: Text(cell?.text.trim() ?? '', style: cell?.localName == 'th' ? style.copyWith(fontWeight: FontWeight.w600) : style),
                    );
                  }(),
              ]),
          ],
        ),
      ),
    );
  }
}
