/// The reader: one article in reading type, the Lese-Horizont, full text on
/// demand. Used as a pushed page on the phone and as the right pane from 840.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../../app/providers.dart';
import '../../app/settings.dart';
import '../../app/supporter.dart';
import '../../data/feeds/readability.dart';
import '../../data/repository.dart';
import '../../l10n/strings.dart';
import '../actions.dart';
import '../format.dart';
import '../nav_state.dart';
import 'article_html.dart';
import 'image_viewer.dart';
import 'lese_horizont.dart';

/// Pushes the reader for [id] on the phone.
Future<void> pushReader(BuildContext context, int id) => Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(builder: (_) => ReaderPage(articleId: id)),
    );

/// The reader as a page, with its own app bar and back.
class ReaderPage extends ConsumerStatefulWidget {
  /// Creates the page for [articleId].
  const ReaderPage({required this.articleId, super.key});

  /// The article.
  final int articleId;

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  late int _id = widget.articleId;

  @override
  Widget build(BuildContext context) => ReaderView(
        articleId: _id,
        embedded: false,
        onNavigate: (id) => setState(() => _id = id),
      );
}

/// The reader for [articleId].
class ReaderView extends ConsumerStatefulWidget {
  /// Creates the reader.
  const ReaderView({required this.articleId, required this.embedded, this.onNavigate, super.key});

  /// The article.
  final int articleId;

  /// In a pane (no back button) or as a page.
  final bool embedded;

  /// Called to show another article (next/previous).
  final ValueChanged<int>? onNavigate;

  @override
  ConsumerState<ReaderView> createState() => _ReaderViewState();
}

enum _FullText { idle, loading, failed }

class _ReaderViewState extends ConsumerState<ReaderView> {
  final _scroll = ScrollController();
  double _progress = 0;
  List<ArticleHeading> _headings = const [];
  List<HorizonTick> _ticks = const [];
  bool _feedVersion = false;
  _FullText _full = _FullText.idle;
  int? _markedFor;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(ReaderView old) {
    super.didUpdateWidget(old);
    if (old.articleId != widget.articleId) {
      _progress = 0;
      _headings = const [];
      _ticks = const [];
      _feedVersion = false;
      _full = _FullText.idle;
      if (_scroll.hasClients) _scroll.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    final p = max <= 0 ? 1.0 : (_scroll.offset / max).clamp(0.0, 1.0);
    if ((p - _progress).abs() > 0.001) setState(() => _progress = p);
  }

  void _measure() {
    if (!_scroll.hasClients || !mounted) return;
    final max = _scroll.position.maxScrollExtent;
    if (max <= 0) {
      if (_ticks.isNotEmpty) setState(() => _ticks = const []);
      return;
    }
    final ticks = <HorizonTick>[];
    for (final h in _headings) {
      final ro = h.key.currentContext?.findRenderObject();
      if (ro == null) continue;
      final viewport = RenderAbstractViewport.maybeOf(ro);
      if (viewport == null) continue;
      final at = viewport.getOffsetToReveal(ro, 0).offset;
      ticks.add(HorizonTick(h.title, (at / max).clamp(0.0, 1.0)));
    }
    setState(() => _ticks = ticks);
    _onScroll();
  }

  void _seek(double p) {
    if (!_scroll.hasClients) return;
    final target = p * _scroll.position.maxScrollExtent;
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.jumpTo(target);
    } else {
      _scroll.animateTo(target, duration: HzMotion.slow, curve: HzMotion.standard);
    }
  }

  void _markRead(ArticleRow row) {
    if (_markedFor == row.article.id) return;
    _markedFor = row.article.id;
    if (!row.isRead) unawaited(ref.read(repositoryProvider).setRead(row.article.id, true));
  }

  Future<void> _loadFull(int id) async {
    setState(() => _full = _FullText.loading);
    final html = await ref.read(repositoryProvider).fetchFullText(id);
    if (!mounted) return;
    setState(() => _full = html == null ? _FullText.failed : _FullText.idle);
  }

  void _go(int? id) {
    if (id == null) return;
    if (widget.embedded) {
      ref.read(navProvider.notifier).select(id);
    } else {
      widget.onNavigate?.call(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(articleProvider(widget.articleId));
    final row = async.value;
    final h = HorizontTheme.of(context);
    final c = h.colors;
    if (row == null) {
      return Scaffold(appBar: widget.embedded ? null : AppBar(), body: async.isLoading ? const SizedBox.shrink() : const HorizontEmptyHint(text: S.noContent, icon: HorizontSymbols.article));
    }
    _markRead(row);
    final a = row.article;
    final complete = looksComplete(a.contentHtml);
    final needsFull = a.url != null && a.fullHtml == null && !complete;
    if (needsFull && _full == _FullText.idle && !_feedVersion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _full == _FullText.idle) unawaited(_loadFull(a.id));
      });
    }
    final source = (!_feedVersion && a.fullHtml != null) ? a.fullHtml! : (a.contentHtml ?? '');
    final settings = ref.watch(settingsProvider);
    final supporter = ref.watch(isSupporterProvider);
    final style = ReaderStyle.of(context, settings, supporter: supporter);
    final pointer = h.density == HorizontDensity.pointer;
    final order = ref.read(visibleOrderProvider.notifier);
    final next = order.after(a.id);
    final previous = order.before(a.id);

    final horizon = LeseHorizont(progress: _progress, ticks: _ticks, onSeek: _seek);
    final bar = AppBar(
      automaticallyImplyLeading: !widget.embedded,
      title: pointer ? null : Kennung(row.feedTitle, oneLine: true),
      actions: [
        IconButton(
          tooltip: row.isSaved ? S.unsave : S.save,
          isSelected: row.isSaved,
          color: row.isSaved ? c.accentText : null,
          icon: Icon(row.isSaved ? HorizontSymbols.bookmarkFill : HorizontSymbols.bookmark),
          onPressed: () => ref.read(repositoryProvider).setSaved(a.id, !row.isSaved),
        ),
        if (a.url != null)
          Builder(
            builder: (context) => IconButton(
              tooltip: S.share,
              icon: Icon(horizontShareSymbol(Theme.of(context).platform)),
              onPressed: () => shareLink(context, a.url!, a.title),
            ),
          ),
        if (a.url != null)
          IconButton(tooltip: S.openInBrowser, icon: const Icon(HorizontSymbols.openInBrowser), onPressed: () => openLink(ref, a.url!, forceBrowser: true)),
        PopupMenuButton<String>(
          tooltip: S.menu,
          icon: Icon(horizontMoreSymbol(Theme.of(context).platform)),
          onSelected: (v) async {
            final repo = ref.read(repositoryProvider);
            switch (v) {
              case 'full':
                setState(() => _feedVersion = false);
                if (a.fullHtml == null) await _loadFull(a.id);
              case 'feed':
                setState(() => _feedVersion = true);
              case 'unread':
                await repo.setRead(a.id, false);
                _markedFor = a.id;
              case 'copy':
                if (context.mounted) await copyLink(context, a.url!);
            }
          },
          itemBuilder: (_) => [
            if (a.url != null && (a.fullHtml == null || _feedVersion)) const PopupMenuItem(value: 'full', child: Text(S.fullText)),
            if (a.fullHtml != null && !_feedVersion) const PopupMenuItem(value: 'feed', child: Text(S.feedVersion)),
            const PopupMenuItem(value: 'unread', child: Text(S.markUnread)),
            if (a.url != null) const PopupMenuItem(value: 'copy', child: Text(S.copyLink)),
          ],
        ),
      ],
      bottom: pointer ? PreferredSize(preferredSize: const Size.fromHeight(LeseHorizont.height), child: horizon) : null,
    );

    final width = MediaQuery.sizeOf(context).width;
    final side = width >= HzBreakpoint.medium ? HzSpace.s24 : HzSpace.s16;
    final meta = [
      row.feedTitle,
      longDate(a.publishedAt),
      if (a.readingMinutes > 0) S.minutes(a.readingMinutes),
    ].join(horizontMetaSeparator);
    final contentHasImage = source.contains('<img');

    return Scaffold(
      appBar: bar,
      bottomNavigationBar: pointer ? null : DecoratedBox(
        decoration: BoxDecoration(color: c.bg, border: Border(top: BorderSide(color: c.line, width: HzLine.hairline))),
        child: SafeArea(top: false, child: horizon),
      ),
      body: NotificationListener<ScrollMetricsNotification>(
        onNotification: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
          return false;
        },
        child: SelectionArea(
          child: SingleChildScrollView(
            controller: _scroll,
            padding: EdgeInsets.fromLTRB(side, HzSpace.s16, side, HzSpace.s48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: HzSize.textColumn),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Kennung(meta),
                  const SizedBox(height: HzSpace.s8),
                  Semantics(header: true, child: Text(a.title.isEmpty ? row.feedTitle : a.title, style: Theme.of(context).textTheme.headlineMedium)),
                  if (a.author != null && a.author!.isNotEmpty) ...[
                    const SizedBox(height: HzSpace.s8),
                    Text(a.author!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textMuted)),
                  ],
                  const SizedBox(height: HzSpace.s24),
                  if (a.imageUrl != null && !contentHasImage && settings.images == ImageLoading.always)
                    Padding(
                      padding: const EdgeInsets.only(bottom: HzSpace.s24),
                      child: GestureDetector(
                        onTap: () => showImage(context, a.imageUrl!),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(HzRadius.r6),
                          child: Image.network(a.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
                        ),
                      ),
                    ),
                  if (_full == _FullText.loading)
                    Padding(
                      padding: const EdgeInsets.only(bottom: HzSpace.s16),
                      child: Row(children: [
                        const SizedBox.square(dimension: HzIconSize.inline, child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
                        const SizedBox(width: HzSpace.s8),
                        Text(S.fullTextLoading, style: Theme.of(context).textTheme.bodySmall),
                      ]),
                    ),
                  if (_full == _FullText.failed)
                    const Padding(
                      padding: EdgeInsets.only(bottom: HzSpace.s16),
                      child: HorizontNotice(HorizontStatus.info, child: Text(S.fullTextFailed)),
                    ),
                  if (source.trim().isEmpty)
                    Text(S.noContent, style: style.body.copyWith(color: c.textMuted))
                  else
                    ArticleHtml(
                      key: ValueKey('${a.id}-${_feedVersion || a.fullHtml == null}'),
                      source: source,
                      style: style,
                      loadImages: settings.images == ImageLoading.always,
                      onLink: (href) => openLink(ref, href),
                      onImage: (url, alt) => showImage(context, url, alt: alt),
                      onHeadings: (h) {
                        _headings = h;
                        _measure();
                      },
                    ),
                  const SizedBox(height: HzSpace.s32),
                  Divider(height: HzLine.hairline, color: c.line),
                  const SizedBox(height: HzSpace.s16),
                  Wrap(spacing: HzSpace.s8, runSpacing: HzSpace.s8, children: [
                    if (a.url != null)
                      OutlinedButton.icon(
                        onPressed: () => openLink(ref, a.url!),
                        icon: const Icon(HorizontSymbols.openInNew, size: HzIconSize.inline),
                        label: const Text(S.openInBrowser),
                      ),
                    if (previous != null) OutlinedButton(onPressed: () => _go(previous), child: const Text(S.previous)),
                    if (next != null) FilledButton(onPressed: () => _go(next), child: const Text(S.next)),
                  ]),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
