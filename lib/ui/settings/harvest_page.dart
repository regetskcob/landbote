/// Jahresernte (Förderpaket): a year of reading as a field seen from above.
/// Weeks are columns, days rows, each day's tone from the data ramp; the
/// count is always also in the semantics and the totals.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../../app/providers.dart';
import '../../data/db/database.dart';
import '../../l10n/strings.dart';
import '../format.dart';

/// The data of a year.
class HarvestData {
  /// Creates the data.
  const HarvestData({required this.year, required this.perDay, required this.events, required this.feedTitles});

  /// The year.
  final int year;

  /// Reads per local day.
  final Map<DateTime, int> perDay;

  /// All read events.
  final List<ReadEvent> events;

  /// Feed titles by id.
  final Map<int, String> feedTitles;
}

/// The data of the current year.
final harvestProvider = FutureProvider.autoDispose<HarvestData>((ref) async {
  final repo = ref.watch(repositoryProvider);
  final year = DateTime.now().year;
  final since = DateTime(year);
  final feeds = await repo.feeds();
  return HarvestData(
    year: year,
    perDay: await repo.readsPerDay(since),
    events: await repo.readEvents(since),
    feedTitles: {for (final f in feeds) f.id: f.customTitle ?? f.title},
  );
});

/// The ramp step for [n] reads on a day.
int harvestStep(int n) => n == 0 ? -1 : (n <= 1 ? 0 : (n <= 3 ? 1 : (n <= 6 ? 2 : (n <= 10 ? 3 : 4))));

/// The page.
class HarvestPage extends ConsumerWidget {
  /// Creates the page.
  const HarvestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(harvestProvider).value;
    final h = HorizontTheme.of(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: HorizontTitle.toolbarHeight(context),
        title: HorizontTitle(kennung: S.harvestKennung(data?.year ?? DateTime.now().year), title: S.yearHarvest),
      ),
      body: data == null
          ? const SizedBox.shrink()
          : data.events.isEmpty
              ? const HorizontEmptyHint(text: S.harvestEmpty, icon: HorizontSymbols.gridView)
              : ListView(padding: const EdgeInsets.all(HzSpace.s16), children: [
                  HorizontMetricRow(children: [
                    HorizontMetric(label: S.harvestRead, value: '${data.events.length}'),
                    HorizontMetric(label: S.harvestMinutes, value: '${(data.events.fold<int>(0, (a, e) => a + e.minutes) / 60).toStringAsFixed(1)} h'),
                    HorizontMetric(label: S.harvestDays, value: '${data.perDay.length}'),
                  ]),
                  const SizedBox(height: HzSpace.s24),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    child: _YearGrid(data: data),
                  ),
                  const SizedBox(height: HzSpace.s8),
                  Row(children: [
                    Text('0', style: h.kennung),
                    const SizedBox(width: HzSpace.s8),
                    for (final c in h.colors.dataRamp) Container(width: 12, height: 12, color: c, margin: const EdgeInsets.only(right: HzSpace.s2)),
                    const SizedBox(width: HzSpace.s8),
                    Text('10+', style: h.kennung),
                  ]),
                  const SizedBox(height: HzSpace.s32),
                  const Kennung(S.harvestTop),
                  const SizedBox(height: HzSpace.s8),
                  for (final e in _top(data))
                    HorizontFact(term: '${e.value}', value: e.key, measured: false),
                ]),
    );
  }

  List<MapEntry<String, int>> _top(HarvestData d) {
    final counts = <String, int>{};
    for (final e in d.events) {
      final t = e.feedId == null ? '–' : (d.feedTitles[e.feedId] ?? '–');
      counts[t] = (counts[t] ?? 0) + 1;
    }
    return (counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).take(5).toList();
  }
}

class _YearGrid extends StatelessWidget {
  const _YearGrid({required this.data});

  final HarvestData data;

  static const double cell = 12;
  static const double gap = HzSpace.s2;

  @override
  Widget build(BuildContext context) {
    final h = HorizontTheme.of(context);
    final c = h.colors;
    final first = DateTime(data.year);
    final start = first.subtract(Duration(days: first.weekday - 1));
    final today = DateTime.now();
    final weeks = (today.difference(start).inDays ~/ 7) + 1;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        for (var w = 0; w < weeks; w++)
          SizedBox(
            width: cell + gap,
            child: () {
              final d = start.add(Duration(days: w * 7));
              return d.day <= 7 && d.year == data.year ? Text(monthShort(d.month).toUpperCase(), style: h.kennung, softWrap: false, overflow: TextOverflow.visible) : const SizedBox.shrink();
            }(),
          ),
      ]),
      const SizedBox(height: HzSpace.s4),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var w = 0; w < weeks; w++)
          Column(children: [
            for (var d = 0; d < 7; d++)
              () {
                final day = start.add(Duration(days: w * 7 + d));
                if (day.year != data.year || day.isAfter(today)) return const SizedBox(width: cell + gap, height: cell + gap);
                final n = data.perDay[DateTime(day.year, day.month, day.day)] ?? 0;
                final step = harvestStep(n);
                return Semantics(
                  label: S.harvestDaySemantics(numericDate(day), n),
                  child: Container(
                    width: cell,
                    height: cell,
                    margin: const EdgeInsets.only(right: gap, bottom: gap),
                    color: step < 0 ? c.sunken : c.dataRamp[step],
                  ),
                );
              }(),
          ]),
      ]),
    ]);
  }
}
