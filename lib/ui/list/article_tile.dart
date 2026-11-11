/// One article in a list: Kennung with source and time, the headline,
/// two lines of teaser, a thumbnail. No card; a hairline below.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../../app/providers.dart';
import '../../app/settings.dart';
import '../../data/repository.dart';
import '../../l10n/strings.dart';
import '../actions.dart';
import '../format.dart';
import '../timeline.dart';

/// An article row.
class ArticleTile extends ConsumerWidget {
  /// Creates the row.
  const ArticleTile({required this.row, required this.selected, required this.onOpen, this.indent = false, this.showSource = true, super.key});

  /// The article.
  final ArticleRow row;

  /// Whether it is open in the reader pane.
  final bool selected;

  /// Opens it.
  final VoidCallback onOpen;

  /// Indented under an opened bundle.
  final bool indent;

  /// Whether the source name shows (not in a feed's own list).
  final bool showSource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = HorizontTheme.of(context);
    final c = h.colors;
    final t = Theme.of(context).textTheme;
    final a = row.article;
    final read = row.isRead;
    final pointer = h.density == HorizontDensity.pointer;
    final images = ref.watch(settingsProvider.select((s) => s.images)) == ImageLoading.always;
    final meta = [
      if (showSource) row.feedTitle,
      shortTime(a.publishedAt),
      if (a.readingMinutes > 0) S.minutes(a.readingMinutes),
    ].join(horizontMetaSeparator);
    final title = Text(
      a.title.isEmpty ? a.summary : a.title,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: t.titleSmall?.copyWith(
        color: read ? c.textMuted : c.text,
        fontWeight: read ? FontWeight.w500 : FontWeight.w600,
      ),
    );
    final thumb = a.imageUrl != null && images
        ? Padding(
            padding: const EdgeInsetsDirectional.only(start: HzSpace.s12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(HzRadius.r6),
              child: Opacity(
                opacity: read ? 0.6 : 1,
                child: Image.network(
                  a.imageUrl!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  cacheWidth: (64 * MediaQuery.devicePixelRatioOf(context)).round(),
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          )
        : null;
    final semantics = [
      if (!read) S.unread,
      if (row.isSaved) S.saved,
      a.title,
      if (showSource) row.feedTitle,
      shortTime(a.publishedAt),
    ].join(', ');

    Widget tile = HorizontSelectable(
      selected: selected,
      onTap: onOpen,
      semanticsLabel: semantics,
      minHeight: HzSize.row,
      padding: EdgeInsetsDirectional.fromSTEB(indent ? HzSpace.s32 : HzSpace.s16, HzSpace.s12, HzSpace.s16, HzSpace.s12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Kennung(meta, oneLine: true)),
              if (row.isSaved) ...[
                const SizedBox(width: HzSpace.s4),
                Icon(HorizontSymbols.bookmarkFill, size: HzIconSize.badge, color: c.accentText),
              ],
            ]),
            const SizedBox(height: HzSpace.s4),
            title,
            if (a.summary.isNotEmpty && a.title.isNotEmpty) ...[
              const SizedBox(height: HzSpace.s4),
              Text(a.summary, maxLines: pointer ? 1 : 2, overflow: TextOverflow.ellipsis, style: t.bodySmall),
            ],
          ]),
        ),
        ?thumb,
      ]),
    );

    tile = _Swipe(row: row, child: tile);
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line, width: HzLine.hairline))),
      child: _ContextMenu(row: row, child: tile),
    );
  }
}

class _Swipe extends ConsumerWidget {
  const _Swipe({required this.row, required this.child});

  final ArticleRow row;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = HorizontTheme.of(context).colors;
    final t = Theme.of(context).textTheme.labelLarge;
    Widget side(IconData icon, String label, AlignmentGeometry align) => ColoredBox(
          color: c.sunken,
          child: Align(
            alignment: align,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: HzSpace.s24),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: HzIconSize.bar, color: c.text),
                const SizedBox(width: HzSpace.s8),
                Text(label, style: t),
              ]),
            ),
          ),
        );
    return Dismissible(
      key: ValueKey('swipe-${row.article.id}'),
      background: side(row.isSaved ? HorizontSymbols.bookmark : HorizontSymbols.bookmarkFill, row.isSaved ? S.unsave : S.save, AlignmentDirectional.centerStart),
      secondaryBackground: side(row.isRead ? HorizontSymbols.markEmailUnread : HorizontSymbols.doneAll, row.isRead ? S.unread : S.read, AlignmentDirectional.centerEnd),
      dismissThresholds: const {DismissDirection.startToEnd: 0.25, DismissDirection.endToStart: 0.25},
      confirmDismiss: (direction) async {
        final repo = ref.read(repositoryProvider);
        if (direction == DismissDirection.startToEnd) {
          await repo.setSaved(row.article.id, !row.isSaved);
        } else {
          await repo.setRead(row.article.id, !row.isRead);
        }
        return false;
      },
      child: child,
    );
  }
}

class _ContextMenu extends ConsumerWidget {
  const _ContextMenu({required this.row, required this.child});

  final ArticleRow row;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = MenuController();
    final repo = ref.read(repositoryProvider);
    final a = row.article;
    return MenuAnchor(
      controller: controller,
      menuChildren: [
        MenuItemButton(onPressed: () => repo.setRead(a.id, !row.isRead), child: Text(row.isRead ? S.markUnread : S.markRead)),
        MenuItemButton(onPressed: () => repo.setSaved(a.id, !row.isSaved), child: Text(row.isSaved ? S.unsave : S.save)),
        if (a.url != null) ...[
          MenuItemButton(onPressed: () => openLink(ref, a.url!, forceBrowser: true), child: const Text(S.openInBrowser)),
          MenuItemButton(onPressed: () => copyLink(context, a.url!), child: const Text(S.copyLink)),
          MenuItemButton(onPressed: () => shareLink(context, a.url!, a.title), child: const Text(S.share)),
        ],
      ],
      child: GestureDetector(
        onSecondaryTapUp: (d) => controller.open(position: d.localPosition),
        onLongPressStart: (d) => controller.open(position: d.localPosition),
        child: child,
      ),
    );
  }
}

/// The line of a bundled loud feed.
class BundleTile extends StatelessWidget {
  /// Creates the line.
  const BundleTile({required this.entry, required this.onToggle, super.key});

  /// The bundle.
  final BundleEntry entry;

  /// Opens or closes it.
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = HorizontTheme.of(context).colors;
    final t = Theme.of(context).textTheme;
    final newest = entry.rows.first.article;
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line, width: HzLine.hairline))),
      child: HorizontSelectable(
        selected: false,
        onTap: onToggle,
        semanticsLabel: '${entry.feedTitle}, ${S.bundle(entry.rows.length)}, ${entry.expanded ? S.bundleClose : S.bundleOpen}',
        padding: const EdgeInsetsDirectional.fromSTEB(HzSpace.s16, HzSpace.s12, HzSpace.s16, HzSpace.s12),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Kennung(entry.feedTitle, count: entry.rows.length, oneLine: true),
              const SizedBox(height: HzSpace.s4),
              Text(newest.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.titleSmall),
              Text(
                entry.rows.skip(1).take(3).map((r) => r.article.title).join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.bodySmall,
              ),
            ]),
          ),
          Icon(entry.expanded ? HorizontSymbols.unfoldLess : HorizontSymbols.unfoldMore, size: HzIconSize.row, color: c.textMuted),
        ]),
      ),
    );
  }
}

/// A day header in Kennung type.
class DayHeaderTile extends StatelessWidget {
  /// Creates the header.
  const DayHeaderTile({required this.header, super.key});

  /// The header.
  final DayHeader header;

  @override
  Widget build(BuildContext context) => Semantics(
        header: true,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(HzSpace.s16, HzSpace.s24, HzSpace.s16, HzSpace.s8),
          child: Kennung(dayLabel(header.day), count: header.count),
        ),
      );
}
