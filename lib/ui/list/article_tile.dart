/// One article in a list: a quiet line with source and time, the headline
/// in the reading face, two lines of teaser, a thumbnail. No card and no
/// hairline: rows are set apart by space. Unread carries a dot in the accent
/// and full weight, read turns light and quiet.
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
  const ArticleTile({required this.row, required this.selected, required this.onOpen, this.indent = false, this.showSource = true, this.showDate = true, super.key});

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

  /// Whether the date shows (not under a day header, which already says it;
  /// an article of today keeps its time).
  final bool showDate;

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
      if (showDate || DateUtils.isSameDay(a.publishedAt.toLocal(), DateTime.now())) shortTime(a.publishedAt),
      if (a.readingMinutes > 0) S.minutes(a.readingMinutes),
    ].join(horizontMetaSeparator);
    // What one reads is set in Literata; larger on touch, where the list is
    // read at arm's length and outdoors.
    final title = Text(
      a.title.isEmpty ? a.summary : a.title,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: HzFont.serif,
        package: HzFont.package,
        fontSize: pointer ? 16 : 19,
        height: pointer ? 22 / 16 : 26 / 19,
        color: read ? c.textMuted : c.text,
        // Read stays semibold and turns quiet by colour and the missing dot:
        // the light cut was too thin to read in a list.
        fontWeight: FontWeight.w600,
      ),
    );
    final metaStyle = t.bodySmall?.copyWith(color: c.textMuted);
    const dot = 8.0;
    final metaShown = meta.isNotEmpty || row.isSaved;
    final gutter = pointer ? HzSpace.s24 : HzSpace.s32 - HzSpace.s4;
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
      padding: EdgeInsetsDirectional.fromSTEB(indent ? HzSpace.s16 : 0, HzSpace.s12, HzSpace.s16, HzSpace.s12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // The gutter holds the dot of an unread article, level with the
        // first line of the headline.
        SizedBox(
          width: gutter,
          child: read
              ? null
              : Padding(
                  padding: EdgeInsets.only(top: (metaShown ? (pointer ? 20 : 22) : 0) + (pointer ? 22 : 26) / 2 - dot / 2),
                  child: Center(child: DecoratedBox(decoration: BoxDecoration(color: c.accent, shape: BoxShape.circle), child: const SizedBox.square(dimension: dot))),
                ),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (metaShown) ...[
              Row(children: [
                Flexible(child: Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: metaStyle)),
                if (row.isSaved) ...[
                  const SizedBox(width: HzSpace.s4),
                  Icon(HorizontSymbols.bookmarkFill, size: HzIconSize.badge, color: c.accentText),
                ],
              ]),
              const SizedBox(height: HzSpace.s4),
            ],
            title,
            if (a.summary.isNotEmpty && a.title.isNotEmpty) ...[
              const SizedBox(height: HzSpace.s4),
              Text(a.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: (pointer ? t.bodySmall : t.bodyMedium)?.copyWith(color: c.textMuted)),
            ],
          ]),
        ),
        ?thumb,
      ]),
    );

    tile = _Swipe(row: row, child: tile);
    return _ContextMenu(row: row, child: tile);
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
    final pointer = HorizontTheme.of(context).density == HorizontDensity.pointer;
    return HorizontSelectable(
        selected: false,
        onTap: onToggle,
        semanticsLabel: '${entry.feedTitle}, ${S.bundle(entry.rows.length)}, ${entry.expanded ? S.bundleClose : S.bundleOpen}',
        padding: EdgeInsetsDirectional.fromSTEB(pointer ? HzSpace.s24 : HzSpace.s32 - HzSpace.s4, HzSpace.s12, HzSpace.s16, HzSpace.s12),
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
    );
  }
}

/// A day header in Kennung type.
class DayHeaderTile extends StatelessWidget {
  /// Creates the header.
  const DayHeaderTile({required this.header, this.onMarkRead, super.key});

  /// The header.
  final DayHeader header;

  /// Marks the unread articles of this day as read; null when there are
  /// none. The action carries its word, it is no bare symbol in the bar.
  final VoidCallback? onMarkRead;

  @override
  Widget build(BuildContext context) {
    final pointer = HorizontTheme.of(context).density == HorizontDensity.pointer;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(pointer ? HzSpace.s24 : HzSpace.s32 - HzSpace.s4, HzSpace.s16, HzSpace.s4, 0),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: pointer ? HzSize.rowDense : HzSize.touch),
        child: Row(children: [
          Expanded(child: Semantics(header: true, child: Kennung(dayLabel(header.day), count: header.count))),
          if (onMarkRead != null)
            TextButton.icon(
              onPressed: onMarkRead,
              icon: const Icon(HorizontSymbols.doneAll, size: HzIconSize.row),
              label: const Text(S.dayRead),
            )
          else
            const SizedBox(width: HzSpace.s12),
        ]),
      ),
    );
  }
}
