/// An article list with its head: Heute, Gemerkt, Archiv, a feed or folder,
/// or search results. Pull to refresh on touch, toolbar buttons with pointer.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../../app/providers.dart';
import '../../app/settings.dart';
import '../../data/repository.dart';
import '../../l10n/strings.dart';
import '../nav_state.dart';
import '../reader/reader_view.dart';
import '../timeline.dart';
import '../sources/sources_pane.dart';
import 'article_tile.dart';
import 'lage.dart';

/// Runs a refresh and says what came of it.
Future<void> refreshWithMessage(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final colors = HorizontTheme.of(context).colors;
  final r = await ref.read(refreshProvider.notifier).refresh();
  if (messenger == null) return;
  messenger.hideCurrentSnackBar();
  if (r.lastFailed > 0 || r.lastError != null) {
    messenger.showSnackBar(horizontMessageSnackBar(colors, '${S.refreshed(r.lastNew ?? 0)} ${S.refreshFailed(r.lastFailed + (r.lastError != null ? 1 : 0))}', status: HorizontStatus.warning));
  } else {
    messenger.showSnackBar(horizontMessageSnackBar(colors, S.refreshed(r.lastNew ?? 0), status: HorizontStatus.positive));
  }
}

/// The list pane.
class ArticleListPane extends ConsumerStatefulWidget {
  /// Creates the pane for [scope].
  const ArticleListPane({
    required this.scope,
    required this.title,
    required this.kennung,
    this.readerBeside = false,
    this.leading,
    this.automaticallyImplyLeading = true,
    super.key,
  });

  /// What the list shows.
  final ArticleScope scope;

  /// The title under the Kennung.
  final String title;

  /// The Kennung over the title; gets the count.
  final String Function(int count) kennung;

  /// Whether the reader is a pane beside the list (from 840).
  final bool readerBeside;

  /// A leading widget (the sidebar toggle).
  final Widget? leading;

  /// Whether the back button shows when pushed.
  final bool automaticallyImplyLeading;

  @override
  ConsumerState<ArticleListPane> createState() => _ArticleListPaneState();
}

class _ArticleListPaneState extends ConsumerState<ArticleListPane> {
  final _search = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searching = false;

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  ArticleScope get _scope {
    final q = _search.text.trim();
    return _searching && q.length >= 2 ? SearchScope(q) : widget.scope;
  }

  void _open(int id) {
    if (widget.readerBeside) {
      ref.read(navProvider.notifier).select(id);
    } else {
      unawaited(pushReader(context, id));
    }
  }

  /// Marks the unread articles of one day as read. No dialog in the way:
  /// the message offers to take it back.
  Future<void> _markDay(List<int> ids) async {
    if (ids.isEmpty) return;
    final messenger = ScaffoldMessenger.of(context);
    final colors = HorizontTheme.of(context).colors;
    final repo = ref.read(repositoryProvider);
    await repo.markAllRead(ids);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(horizontMessageSnackBar(
      colors,
      S.dayReadDone(ids.length),
      status: HorizontStatus.positive,
      action: SnackBarAction(
        label: S.undo,
        onPressed: () async {
          for (final id in ids) {
            await repo.setRead(id, false);
          }
        },
      ),
    ));
  }

  Future<void> _markAll(List<ArticleRow> rows) async {
    final ids = [for (final r in rows) if (!r.isRead) r.article.id];
    if (ids.isEmpty) return;
    final ok = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        content: const Text(S.markAllReadConfirm),
        actions: [
          horizontDialogAction(context, label: S.cancel, onPressed: () => Navigator.pop(context, false)),
          horizontDialogAction(context, label: S.markAllRead, primary: true, onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );
    if (ok ?? false) await ref.read(repositoryProvider).markAllRead(ids);
  }

  @override
  Widget build(BuildContext context) {
    final h = HorizontTheme.of(context);
    final c = h.colors;
    final pointer = h.density == HorizontDensity.pointer;
    final width = MediaQuery.sizeOf(context).width;
    final settings = ref.watch(settingsProvider);
    final nav = ref.watch(navProvider);
    final scope = _scope;
    final async = ref.watch(articlesProvider(scope));
    final rows = async.value ?? const <ArticleRow>[];
    final unread = rows.where((r) => !r.isRead).length;
    final refreshing = ref.watch(refreshProvider.select((s) => s.running));

    final entries = buildTimeline(
      rows,
      bundleThreshold: scope is TodayScope ? settings.bundleThreshold : 0,
      expanded: nav.expanded,
      dayHeaders: scope is! SavedScope,
    );
    final order = readingOrder(entries);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(visibleOrderProvider.notifier).set(order);
    });

    final count = scope is SavedScope ? rows.length : unread;
    final searchField = SizedBox(
      width: width >= HzBreakpoint.medium ? HzSize.search : null,
      child: TextField(
        controller: _search,
        focusNode: _searchFocus,
        autofocus: true,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: S.search,
          prefixIcon: const Icon(HorizontSymbols.search, size: HzIconSize.row),
          suffixIcon: IconButton(
            tooltip: S.cancel,
            icon: const Icon(HorizontSymbols.close, size: HzIconSize.row),
            onPressed: () => setState(() {
              _searching = false;
              _search.clear();
            }),
          ),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
    final compactSearch = _searching && width < HzBreakpoint.medium;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: widget.automaticallyImplyLeading,
        leading: widget.leading,
        toolbarHeight: HorizontTitle.toolbarHeight(context),
        titleSpacing: widget.leading == null && !Navigator.canPop(context) ? HzSpace.s16 : null,
        title: compactSearch ? searchField : HorizontTitle(kennung: widget.kennung(count), title: widget.title),
        actions: [
          if (_searching && !compactSearch) Padding(padding: const EdgeInsets.only(right: HzSpace.s8), child: searchField),
          if (!_searching)
            IconButton(
              tooltip: S.search,
              icon: const Icon(HorizontSymbols.search),
              onPressed: () => setState(() => _searching = true),
            ),
          // With a pointer the filter and "all read" are toolbar buttons with a
          // tooltip. On touch they carry their word: the filter in the line
          // under the head, "Alle gelesen" at each day.
          if (pointer && scope is! SavedScope && !compactSearch)
            IconButton(
              tooltip: S.showUnreadOnly,
              isSelected: settings.unreadOnly,
              color: settings.unreadOnly ? c.accentText : null,
              icon: const Icon(HorizontSymbols.filterAlt),
              onPressed: () => ref.read(settingsProvider.notifier).update((s) => s.copyWith(unreadOnly: !s.unreadOnly)),
            ),
          if (pointer && !compactSearch && unread > 0)
            IconButton(tooltip: S.markAllRead, icon: const Icon(HorizontSymbols.doneAll), onPressed: () => _markAll(rows)),
          if (pointer)
            IconButton(
              tooltip: S.refresh,
              // No spinner: the line under the head says that it runs.
              icon: const Icon(HorizontSymbols.refresh),
              onPressed: refreshing ? null : () => refreshWithMessage(context, ref),
            ),
          const SizedBox(width: HzSpace.s4),
        ],
        // The horizon instead of a hairline: its accent part is the share of
        // this list that is read.
        bottom: ListHorizont(fraction: rows.isEmpty ? 0 : (rows.length - unread) / rows.length),
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (!_searching) LageLine(filter: scope is! SavedScope),
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: () => refreshWithMessage(context, ref),
            child: _body(context, entries, async, nav, rows),
          ),
        ),
      ]),
    );
  }

  Widget _body(BuildContext context, List<TimelineEntry> entries, AsyncValue<List<ArticleRow>> async, NavState nav, List<ArticleRow> rows) {
    if (async.isLoading && !async.hasValue) return const SizedBox.shrink();
    // Without any source "all read" would be wrong: say what Landbote is
    // and offer the first step right here.
    final noSources = ref.watch(feedsProvider).value?.isEmpty ?? false;
    if (noSources && _scope is! SearchScope) return const Welcome();
    if (entries.isEmpty) {
      final (text, detail, icon) = switch (_scope) {
        SearchScope() => (S.emptySearch, null, HorizontSymbols.search),
        TodayScope() => (S.emptyToday, S.emptyTodayDetail, HorizontSymbols.wbTwilight),
        SavedScope() => (S.emptySaved, S.emptySavedDetail, HorizontSymbols.bookmark),
        _ => (S.emptyFeed, null, HorizontSymbols.rssFeed),
      };
      // Scrollable, so pull to refresh works on an empty list.
      return LayoutBuilder(
        builder: (context, box) => ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
          SizedBox(height: box.maxHeight * 0.6, child: HorizontEmptyHint(text: text, detail: detail, icon: icon)),
        ]),
      );
    }
    final showSource = _scope is! FeedScope;
    final allUnread = [for (final r in rows) if (!r.isRead) r.article.id];
    List<int> unreadOf(DateTime day) => [
          for (final r in rows)
            if (!r.isRead && DateUtils.isSameDay(r.article.publishedAt.toLocal(), day)) r.article.id,
        ];
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: widget.readerBeside ? double.infinity : HzSize.page),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: HzSpace.s48),
          itemCount: entries.length + 1,
          itemBuilder: (context, i) => i == entries.length
              ? _EndOfList(unread: allUnread, onMarkRead: () => _markDay(allUnread))
              : switch (entries[i]) {
            final DayHeader e => () {
                final ids = unreadOf(e.day);
                // One unread article needs no button of its own: reading or
                // swiping it does the same.
                return DayHeaderTile(header: e, onMarkRead: ids.length < 2 ? null : () => _markDay(ids));
              }(),
            final BundleEntry e => BundleTile(entry: e, onToggle: () => ref.read(navProvider.notifier).toggleBundle(e.feedId)),
            final ArticleEntry e => ArticleTile(
                key: ValueKey(e.row.article.id),
                row: e.row,
                indent: e.inBundle,
                showSource: showSource,
                showDate: _scope is SavedScope,
                selected: widget.readerBeside && nav.articleId == e.row.article.id,
                onOpen: () => _open(e.row.article.id),
              ),
          },
        ),
      ),
    );
  }
}

/// The end of a list on touch: what is left unread can be put aside in one
/// step, with its word and a way back. With a pointer the toolbar has it.
class _EndOfList extends StatelessWidget {
  const _EndOfList({required this.unread, required this.onMarkRead});

  final List<int> unread;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final pointer = HorizontTheme.of(context).density == HorizontDensity.pointer;
    if (pointer || unread.length < 2) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(HzSpace.s16, HzSpace.s24, HzSpace.s16, 0),
      child: OutlinedButton.icon(
        onPressed: onMarkRead,
        icon: const Icon(HorizontSymbols.doneAll, size: HzIconSize.row),
        label: Text(S.markRest(unread.length)),
      ),
    );
  }
}
