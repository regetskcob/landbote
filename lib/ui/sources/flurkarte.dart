/// The Flurkarte of the sources: each feed a field seen from above, its area
/// by what it published in the last 30 days, its tone from the data ramp by
/// how much of it is unread. Fields of a folder lie together, separated by a
/// Feldweg (a wider gap).
library;

import 'package:flutter/material.dart';
import 'package:horizont/horizont.dart';

import '../../data/repository.dart';
import '../../l10n/strings.dart';

/// A placed field.
@immutable
class Field {
  /// Creates a field.
  const Field(this.row, this.rect);

  /// The feed.
  final FeedRow row;

  /// Where it lies, in the map's coordinates.
  final Rect rect;
}

/// Lays out [weights] in [area] as a squarified treemap (Bruls et al.), so
/// fields stay close to square. Returns rects in input order.
List<Rect> squarify(List<double> weights, Rect area) {
  final total = weights.fold<double>(0, (a, b) => a + b);
  if (weights.isEmpty || total <= 0 || area.isEmpty) return [for (final _ in weights) Rect.zero];
  final scale = area.width * area.height / total;
  final order = List<int>.generate(weights.length, (i) => i)..sort((a, b) => weights[b].compareTo(weights[a]));
  final out = List<Rect>.filled(weights.length, Rect.zero);
  var rest = area;
  var i = 0;
  while (i < order.length) {
    final side = rest.shortestSide;
    final row = <int>[order[i]];
    var rowSum = weights[order[i]] * scale;
    double worst(List<int> r, double sum) {
      var w = 0.0;
      for (final k in r) {
        final a = weights[k] * scale;
        final ratio = (side * side * a) / (sum * sum);
        w = w > ratio ? w : ratio;
        final inv = (sum * sum) / (side * side * a);
        w = w > inv ? w : inv;
      }
      return w;
    }

    i++;
    while (i < order.length) {
      final candidate = [...row, order[i]];
      final candSum = rowSum + weights[order[i]] * scale;
      if (worst(candidate, candSum) > worst(row, rowSum)) break;
      row.add(order[i]);
      rowSum = candSum;
      i++;
    }
    final horizontal = rest.width >= rest.height;
    final thickness = rowSum / side;
    var offset = 0.0;
    for (final k in row) {
      final len = weights[k] * scale / thickness;
      out[k] = horizontal
          ? Rect.fromLTWH(rest.left, rest.top + offset, thickness, len)
          : Rect.fromLTWH(rest.left + offset, rest.top, len, thickness);
      offset += len;
    }
    rest = horizontal
        ? Rect.fromLTRB(rest.left + thickness, rest.top, rest.right, rest.bottom)
        : Rect.fromLTRB(rest.left, rest.top + thickness, rest.right, rest.bottom);
  }
  return out;
}

/// The data ramp step (0 to 4) for a feed: how loud its unread pile is.
int loudness(FeedRow row) {
  final u = row.unread;
  if (u == 0) return 0;
  if (u <= 2) return 1;
  if (u <= 6) return 2;
  if (u <= 15) return 3;
  return 4;
}

/// The Flurkarte widget.
class Flurkarte extends StatelessWidget {
  /// Creates the map of [feeds].
  const Flurkarte({required this.feeds, required this.onOpen, super.key});

  /// The feeds.
  final List<FeedRow> feeds;

  /// Opens a feed.
  final ValueChanged<FeedRow> onOpen;

  /// The Feldweg between folders, and the furrow between fields.
  static const double way = HzSpace.s8;

  /// See [way].
  static const double furrow = HzSpace.s2;

  @override
  Widget build(BuildContext context) {
    final h = HorizontTheme.of(context);
    final c = h.colors;
    final ramp = c.dataRamp;
    return LayoutBuilder(builder: (context, box) {
      final area = Offset.zero & box.biggest;
      // Folders first as blocks, then fields within them.
      final groups = <String, List<FeedRow>>{};
      for (final f in feeds) {
        (groups[f.folder?.name ?? S.folderless] ??= []).add(f);
      }
      final names = groups.keys.toList();
      double weight(FeedRow f) => (f.recent + 1).toDouble();
      final groupRects = squarify([for (final n in names) groups[n]!.fold<double>(0, (a, f) => a + weight(f))], area);
      final fields = <Field>[];
      for (var g = 0; g < names.length; g++) {
        final inner = groupRects[g].deflate(way / 2);
        final rows = groups[names[g]]!;
        final rects = squarify([for (final f in rows) weight(f)], inner);
        for (var i = 0; i < rows.length; i++) {
          fields.add(Field(rows[i], rects[i].deflate(furrow / 2)));
        }
      }
      final label = h.kennung;
      return Stack(children: [
        for (final f in fields)
          Positioned.fromRect(
            rect: f.rect,
            child: Semantics(
              button: true,
              label: S.flurkarteSemantics(f.row.title, f.row.recent, f.row.unread),
              excludeSemantics: true,
              onTap: () => onOpen(f.row),
              child: Material(
                color: ramp[loudness(f.row)],
                child: InkWell(
                  onTap: () => onOpen(f.row),
                  child: Padding(
                    padding: const EdgeInsets.all(HzSpace.s8),
                    child: f.rect.width < 56 || f.rect.height < 32
                        ? const SizedBox.shrink()
                        : Align(
                            alignment: AlignmentDirectional.topStart,
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                              Text(
                                f.row.title.toUpperCase(),
                                maxLines: f.rect.height > 72 ? 2 : 1,
                                overflow: TextOverflow.ellipsis,
                                style: label.copyWith(color: _ink(c, ramp[loudness(f.row)])),
                              ),
                              if (f.rect.height > 56)
                                // Area and tone say different things, so the
                                // numbers carry their words: "3 im Monat · 2 neu".
                                Text(
                                  S.flurkarteField(f.row.recent, f.row.unread),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: _ink(c, ramp[loudness(f.row)])),
                                ),
                            ]),
                          ),
                  ),
                ),
              ),
            ),
          ),
      ]);
    });
  }

  // Ink or page ground on a field, whichever contrasts more with its tone.
  static Color _ink(HorizontColors c, Color field) => _contrast(c.text, field) >= _contrast(c.bg, field) ? c.text : c.bg;

  static double _contrast(Color a, Color b) {
    final la = a.computeLuminance() + 0.05;
    final lb = b.computeLuminance() + 0.05;
    return la > lb ? la / lb : lb / la;
  }
}

/// The legend: what the tone means (unread), then the ramp from still to
/// loud, the value also in words.
class FlurkarteLegend extends StatelessWidget {
  /// Creates the legend.
  const FlurkarteLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final h = HorizontTheme.of(context);
    final style = h.kennung;
    // The title wraps above the ramp on a narrow phone; the ramp stays whole.
    return Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: HzSpace.s16, runSpacing: HzSpace.s4, children: [
      Text(S.flurkarteLegendTitle.toUpperCase(), style: style),
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text(S.flurkarteLegendLow.toUpperCase(), style: style),
        const SizedBox(width: HzSpace.s8),
        for (final color in h.colors.dataRamp)
          Container(width: HzSpace.s16, height: HzSpace.s8, color: color, margin: const EdgeInsets.only(right: HzSpace.s2)),
        const SizedBox(width: HzSpace.s8),
        Text(S.flurkarteLegendHigh.toUpperCase(), style: style),
      ]),
    ]);
  }
}
