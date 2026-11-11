/// Turns a list of articles into what the list shows: day headers, single
/// articles and the bundles of loud feeds. Pure, so it is tested alone.
library;

import '../data/repository.dart';

/// One line of the list.
sealed class TimelineEntry {
  const TimelineEntry();
}

/// A day header ("HEUTE", "GESTERN", "MO · 9. NOV").
final class DayHeader extends TimelineEntry {
  /// Creates a header.
  const DayHeader(this.day, this.count);

  /// The local day.
  final DateTime day;

  /// Articles under it.
  final int count;
}

/// A single article.
final class ArticleEntry extends TimelineEntry {
  /// Creates the entry.
  const ArticleEntry(this.row, {this.inBundle = false});

  /// The article.
  final ArticleRow row;

  /// Whether it is shown as part of an opened bundle (indented).
  final bool inBundle;
}

/// The unread articles of one loud feed as one line.
final class BundleEntry extends TimelineEntry {
  /// Creates the entry.
  const BundleEntry({required this.feedId, required this.feedTitle, required this.rows, required this.expanded});

  /// The feed.
  final int feedId;

  /// Its title.
  final String feedTitle;

  /// Its articles in the bundle, newest first.
  final List<ArticleRow> rows;

  /// Whether the bundle is open.
  final bool expanded;
}

/// Builds the timeline of [rows] (newest first).
///
/// With [bundleThreshold] > 0, a feed with at least that many unread rows
/// becomes one [BundleEntry] at the place of its newest article, unless the
/// feed opted out. [expanded] feeds show their rows below the bundle line.
List<TimelineEntry> buildTimeline(
  List<ArticleRow> rows, {
  int bundleThreshold = 0,
  Set<int> expanded = const {},
  bool dayHeaders = true,
}) {
  final unreadPerFeed = <int, int>{};
  for (final r in rows) {
    if (!r.isRead) unreadPerFeed[r.article.feedId] = (unreadPerFeed[r.article.feedId] ?? 0) + 1;
  }
  final loud = <int>{
    if (bundleThreshold > 0)
      for (final e in unreadPerFeed.entries)
        if (e.value >= bundleThreshold) e.key,
  }..removeWhere((id) => rows.any((r) => r.article.feedId == id && r.neverBundle));

  final bundled = <int, List<ArticleRow>>{};
  for (final r in rows) {
    if (loud.contains(r.article.feedId) && !r.isRead) (bundled[r.article.feedId] ??= []).add(r);
  }

  final out = <TimelineEntry>[];
  DateTime? currentDay;
  var headerIndex = -1;
  var headerCount = 0;
  final placed = <int>{};

  void closeHeader() {
    if (headerIndex >= 0 && currentDay != null) out[headerIndex] = DayHeader(currentDay, headerCount);
  }

  for (final r in rows) {
    final feedId = r.article.feedId;
    final inBundle = loud.contains(feedId) && !r.isRead;
    if (inBundle && placed.contains(feedId)) continue;
    final local = r.article.publishedAt.toLocal();
    final day = DateTime(local.year, local.month, local.day);
    if (dayHeaders && day != currentDay) {
      closeHeader();
      currentDay = day;
      headerCount = 0;
      headerIndex = out.length;
      out.add(DayHeader(day, 0));
    }
    if (inBundle) {
      placed.add(feedId);
      final items = bundled[feedId]!;
      final open = expanded.contains(feedId);
      out.add(BundleEntry(feedId: feedId, feedTitle: r.feedTitle, rows: items, expanded: open));
      if (open) out.addAll(items.map((i) => ArticleEntry(i, inBundle: true)));
      headerCount += items.length;
    } else {
      out.add(ArticleEntry(r));
      headerCount++;
    }
  }
  closeHeader();
  return out;
}

/// The article ids in reading order, for next/previous in the reader.
List<int> readingOrder(List<TimelineEntry> entries) => [
      for (final e in entries)
        if (e is ArticleEntry) e.row.article.id,
    ];
