/// Quellen: the feeds by folder as a list, or as the Flurkarte.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../../app/providers.dart';
import '../../app/settings.dart';
import '../../data/repository.dart';
import '../../l10n/strings.dart';
import '../format.dart';
import '../list/article_list.dart';
import '../settings/settings_page.dart';
import 'add_feed_sheet.dart';
import 'feed_sheet.dart';
import 'flurkarte.dart';

/// Opens the list of [scope] the way the layout wants it.
typedef OpenScope = void Function(ArticleScope scope, String title);

/// The pane.
class SourcesPane extends ConsumerStatefulWidget {
  /// Creates the pane; [onOpen] shows a feed's or folder's list.
  const SourcesPane({required this.onOpen, this.leading, super.key});

  /// Shows a list.
  final OpenScope onOpen;

  /// The sidebar toggle, if any.
  final Widget? leading;

  @override
  ConsumerState<SourcesPane> createState() => _SourcesPaneState();
}

class _SourcesPaneState extends ConsumerState<SourcesPane> {
  final _collapsed = <int?>{};

  @override
  Widget build(BuildContext context) {
    final feeds = ref.watch(feedsProvider).value ?? const <FeedRow>[];
    final folders = ref.watch(foldersProvider).value ?? const [];
    final asMap = ref.watch(settingsProvider.select((s) => s.sourcesAsMap));
    final add = HorizontPrimaryAction(icon: HorizontSymbols.addLink, label: S.addSource, onPressed: () => showAddFeed(context));
    final c = HorizontTheme.of(context).colors;

    Widget body;
    if (feeds.isEmpty) {
      body = const _Welcome();
    } else if (asMap) {
      body = Padding(
        padding: EdgeInsets.fromLTRB(HzSpace.s16, HzSpace.s8, HzSpace.s16, add.fab(context) == null ? HzSpace.s16 : 88),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Kennung(S.flurkarteKennung),
          const SizedBox(height: HzSpace.s8),
          Expanded(
            child: Flurkarte(feeds: feeds, onOpen: (r) => widget.onOpen(FeedScope(r.feed.id), r.title)),
          ),
          const SizedBox(height: HzSpace.s8),
          const FlurkarteLegend(),
        ]),
      );
    } else {
      final groups = <int?, List<FeedRow>>{};
      for (final f in feeds) {
        (groups[f.feed.folderId] ??= []).add(f);
      }
      final ordered = [
        for (final folder in folders)
          if (groups.containsKey(folder.id)) (folder.id, folder.name),
        if (groups.containsKey(null)) (null, S.folderless),
      ];
      body = RefreshIndicator.adaptive(
        onRefresh: () => refreshWithMessage(context, ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            for (final (id, name) in ordered) ...[
              HorizontSectionHeader(
                name,
                count: groups[id]!.length,
                collapsed: _collapsed.contains(id),
                onToggle: () => setState(() => _collapsed.contains(id) ? _collapsed.remove(id) : _collapsed.add(id)),
                trailing: id == null
                    ? null
                    : IconButton(
                        tooltip: S.rename,
                        icon: Icon(horizontMoreSymbol(Theme.of(context).platform), size: HzIconSize.row),
                        onPressed: () => _folderMenu(id, name),
                      ),
              ),
              if (!_collapsed.contains(id)) ...[
                if (id != null)
                  _FeedLine.folder(
                    name: name,
                    unread: groups[id]!.fold(0, (a, r) => a + r.unread),
                    onTap: () => widget.onOpen(FolderScope(id), name),
                  ),
                for (final r in groups[id]!) _FeedLine(row: r, onTap: () => widget.onOpen(FeedScope(r.feed.id), r.title)),
              ],
            ],
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: widget.leading,
        toolbarHeight: HorizontTitle.toolbarHeight(context),
        titleSpacing: widget.leading == null ? HzSpace.s16 : null,
        title: HorizontTitle(kennung: S.sourcesKennung(feeds.length), title: S.sources),
        actions: [
          if (feeds.isNotEmpty)
            IconButton(
              tooltip: asMap ? S.listView : S.mapView,
              icon: Icon(asMap ? HorizontSymbols.viewAgenda : HorizontSymbols.map),
              onPressed: () => ref.read(settingsProvider.notifier).update((s) => s.copyWith(sourcesAsMap: !s.sourcesAsMap)),
            ),
          IconButton(tooltip: S.settings, icon: const Icon(HorizontSymbols.settings), onPressed: () => pushSettings(context)),
          ...add.toolbar(context),
          const SizedBox(width: HzSpace.s4),
        ],
      ),
      floatingActionButton: add.fab(context),
      body: DecoratedBox(decoration: BoxDecoration(color: c.bg), child: body),
    );
  }

  Future<void> _folderMenu(int id, String name) async {
    final repo = ref.read(repositoryProvider);
    final choice = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(title: const Text(S.rename), onTap: () => Navigator.pop(context, 'rename')),
          ListTile(
            title: Text(S.deleteFolder, style: TextStyle(color: HorizontTheme.of(context).colors.critical)),
            onTap: () => Navigator.pop(context, 'delete'),
          ),
        ]),
      ),
    );
    if (!mounted) return;
    if (choice == 'rename') {
      final n = await askName(context, title: S.rename, initial: name);
      if (n != null && n.isNotEmpty) await repo.renameFolder(id, n);
    } else if (choice == 'delete') {
      if (await confirmDestructive(context, message: S.deleteFolderConfirm(name), action: S.delete)) await repo.deleteFolder(id);
    }
  }
}

class _FeedLine extends StatelessWidget {
  const _FeedLine({required FeedRow this.row, required this.onTap}) : name = null, unread = 0;

  const _FeedLine.folder({required String this.name, required this.unread, required this.onTap}) : row = null;

  final FeedRow? row;
  final String? name;
  final int unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final h = HorizontTheme.of(context);
    final c = h.colors;
    final t = Theme.of(context).textTheme;
    final r = row;
    final count = r?.unread ?? unread;
    final title = r?.title ?? name!;
    final failing = r != null && r.feed.errorCount >= 2;
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line, width: HzLine.hairline))),
      child: HorizontSelectable(
        selected: false,
        onTap: onTap,
        onLongPress: r == null ? null : () => showFeedSheet(context, r),
        padding: const EdgeInsetsDirectional.fromSTEB(HzSpace.s16, HzSpace.s8, HzSpace.s4, HzSpace.s8),
        child: Row(children: [
          Icon(r == null ? HorizontSymbols.folder : HorizontSymbols.rssFeed, size: HzIconSize.row, color: c.textMuted),
          const SizedBox(width: HzSpace.s12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r == null ? '$title · alle' : title, style: t.bodyLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
              if (failing)
                HorizontStatusLine(HorizontStatus.warning, r.feed.lastError ?? S.error)
              else if (r?.lastPublished != null)
                Kennung(shortTime(r!.lastPublished!), oneLine: true),
            ]),
          ),
          if (count > 0) Text('$count', style: h.data.copyWith(color: c.textMuted)),
          if (r != null)
            IconButton(
              tooltip: S.feedSettings,
              icon: const Icon(HorizontSymbols.info, size: HzIconSize.row),
              onPressed: () => showFeedSheet(context, r),
            )
          else
            const SizedBox(width: HzSpace.s12),
        ]),
      ),
    );
  }
}

class _Welcome extends ConsumerStatefulWidget {
  const _Welcome();

  @override
  ConsumerState<_Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends ConsumerState<_Welcome> {
  bool _busy = false;

  Future<void> _start() async {
    setState(() => _busy = true);
    final repo = ref.read(repositoryProvider);
    final found = await repo.discover('https://www.regetskcob.de/');
    if (found.isNotEmpty) await repo.addFeed(found.first);
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(HzSpace.s24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: HzSize.form),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            HorizontMark(HorizontTheme.of(context).product, size: 48),
            const SizedBox(height: HzSpace.s24),
            const Kennung(S.welcomeKennung),
            const SizedBox(height: HzSpace.s8),
            Text(S.welcomeTitle, style: t.headlineMedium),
            const SizedBox(height: HzSpace.s16),
            Text(S.welcomeText, style: HorizontTheme.of(context).reading),
            const SizedBox(height: HzSpace.s32),
            FilledButton(onPressed: () => showAddFeed(context), child: const Text(S.welcomeOwn)),
            const SizedBox(height: HzSpace.s8),
            OutlinedButton(onPressed: _busy ? null : () => unawaited(_start()), child: const Text(S.welcomeStart)),
            const SizedBox(height: HzSpace.s8),
            TextButton(onPressed: () => pushSettings(context, opml: true), child: const Text(S.importOpml)),
          ]),
        ),
      ),
    );
  }
}
