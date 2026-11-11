import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:landbote/data/db/database.dart';
import 'package:landbote/data/repository.dart';
import 'package:landbote/ui/sources/flurkarte.dart';
import 'package:landbote/ui/timeline.dart';

ArticleRow row(int id, int feed, DateTime at, {bool read = false, bool neverBundle = false}) => ArticleRow(
      feedTitle: 'Feed $feed',
      neverBundle: neverBundle,
      article: Article(
        id: id,
        feedId: feed,
        guid: '$id',
        title: 'A$id',
        summary: '',
        publishedAt: at,
        fetchedAt: at,
        readAt: read ? at : null,
        hidden: false,
        readingMinutes: 1,
        categories: '',
      ),
    );

void main() {
  final d1 = DateTime(2026, 11, 11, 9);
  final d0 = DateTime(2026, 11, 10, 9);

  test('day headers count their articles', () {
    final t = buildTimeline([row(1, 1, d1), row(2, 2, d1), row(3, 1, d0)]);
    expect(t.whereType<DayHeader>().map((h) => h.count), [2, 1]);
  });

  test('a loud feed becomes one bundle at its newest article', () {
    final rows = [
      for (var i = 0; i < 7; i++) row(i, 9, d1.subtract(Duration(minutes: i))),
      row(100, 1, d1.subtract(const Duration(minutes: 3))),
    ]..sort((a, b) => b.article.publishedAt.compareTo(a.article.publishedAt));
    final t = buildTimeline(rows, bundleThreshold: 6);
    expect(t.whereType<BundleEntry>().single.rows, hasLength(7));
    expect(t.whereType<ArticleEntry>().single.row.article.id, 100);
    expect(readingOrder(t), [100]);
    final open = buildTimeline(rows, bundleThreshold: 6, expanded: {9});
    expect(readingOrder(open), hasLength(8));
  });

  test('a feed that opted out is never bundled', () {
    final rows = [for (var i = 0; i < 7; i++) row(i, 9, d1, neverBundle: true)];
    expect(buildTimeline(rows, bundleThreshold: 6).whereType<BundleEntry>(), isEmpty);
  });

  test('squarify fills the area and keeps weights', () {
    const area = Rect.fromLTWH(0, 0, 300, 200);
    final rects = squarify([6, 6, 4, 3, 2, 2, 1], area);
    final total = rects.fold<double>(0, (a, r) => a + r.width * r.height);
    expect(total, closeTo(60000, 1));
    expect(rects[0].width * rects[0].height, closeTo(60000 * 6 / 24, 1));
    for (final r in rects) {
      expect(area.inflate(0.01).contains(r.topLeft) && area.inflate(0.01).contains(r.bottomRight), isTrue);
    }
  });
}
