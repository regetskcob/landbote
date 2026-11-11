/// The Lese-Horizont: Horizont's web navigation as a reading bar. One line;
/// the mark stands on it where the reader is, the line left of it is drawn
/// in the accent. Headings are ticks at their real place, the current one
/// dark and whole; where ticks are close, only the number shows. Tapping a
/// tick jumps there; dragging along the line scrubs.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horizont/horizont.dart';

import '../../l10n/strings.dart';

/// A chapter on the line: its title and position from 0 to 1.
@immutable
class HorizonTick {
  /// Creates a tick.
  const HorizonTick(this.title, this.position);

  /// The heading.
  final String title;

  /// Where it starts, as a fraction of the scroll extent.
  final double position;
}

/// The reading bar.
class LeseHorizont extends StatelessWidget {
  /// Creates the bar.
  const LeseHorizont({required this.progress, required this.ticks, required this.onSeek, super.key});

  /// How far the reader is, 0 to 1.
  final double progress;

  /// The chapters.
  final List<HorizonTick> ticks;

  /// Jump to a fraction.
  final ValueChanged<double> onSeek;

  /// The bar's height: a touch target.
  static const double height = HzSize.touch;

  int get _current {
    var i = -1;
    for (var t = 0; t < ticks.length; t++) {
      if (ticks[t].position <= progress + 0.002) i = t;
    }
    return i;
  }

  @override
  Widget build(BuildContext context) {
    final h = HorizontTheme.of(context);
    final c = h.colors;
    final percent = (progress * 100).round();
    final current = _current;
    return Semantics(
      label: S.progress,
      value: '$percent %${current >= 0 ? ', ${ticks[current].title}' : ''}',
      increasedValue: '${(percent + 10).clamp(0, 100)} %',
      decreasedValue: '${(percent - 10).clamp(0, 100)} %',
      onIncrease: () => onSeek((progress + 0.1).clamp(0, 1)),
      onDecrease: () => onSeek((progress - 0.1).clamp(0, 1)),
      child: ExcludeSemantics(
        child: SizedBox(
          height: height,
          child: LayoutBuilder(builder: (context, box) {
            const inset = HzSpace.s16;
            final width = box.maxWidth - 2 * inset;
            double xOf(double p) => inset + width * p.clamp(0, 1);
            void seekAt(double dx) => onSeek(((dx - inset) / width).clamp(0, 1));
            final labels = _labels(context, width);
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) {
                // Snap to a tick under the finger.
                final p = (d.localPosition.dx - inset) / width;
                for (final t in ticks) {
                  if ((t.position - p).abs() * width < HzSpace.s12) {
                    HapticFeedback.selectionClick();
                    onSeek(t.position);
                    return;
                  }
                }
                seekAt(d.localPosition.dx);
              },
              onHorizontalDragUpdate: (d) => seekAt(d.localPosition.dx),
              child: Stack(clipBehavior: Clip.none, children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _LinePainter(
                      progress: progress,
                      ticks: [for (final t in ticks) t.position],
                      current: current,
                      line: c.lineStrong,
                      drawn: c.accent,
                      tick: c.textMuted,
                      tickCurrent: c.text,
                      inset: inset,
                    ),
                  ),
                ),
                // The mark stands on the line at the reader's place.
                Positioned(
                  left: xOf(progress) - 9,
                  top: _lineY - 18 * 2 / 3,
                  child: HorizontMark(h.product, size: 18, color: c.accentText),
                ),
                for (final l in labels)
                  Positioned(
                    left: (xOf(ticks[l.index].position) - 2).clamp(0, box.maxWidth - 24),
                    top: _lineY + HzSpace.s4,
                    child: Text(
                      l.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: h.kennung.copyWith(color: l.index == current ? c.text : c.textMuted),
                    ),
                  ),
              ]),
            );
          }),
        ),
      ),
    );
  }

  // The line sits at two thirds of the bar, like the horizon in the mark.
  static const double _lineY = height * 0.45;

  List<({int index, String text})> _labels(BuildContext context, double width) {
    if (ticks.isEmpty) return const [];
    final style = HorizontTheme.of(context).kennung;
    final painter = TextPainter(textDirection: TextDirection.ltr, maxLines: 1, textScaler: MediaQuery.textScalerOf(context));
    double measure(String s) {
      painter.text = TextSpan(text: s, style: style);
      painter.layout();
      return painter.width;
    }

    // Labels never overlap: the current chapter is placed first and whole
    // (it may run past its own stretch); every other one gets its title if
    // it fits before the next tick and the space is free, else its number,
    // else nothing.
    const gap = HzSpace.s8;
    final taken = <(double, double)>[];
    bool free(double from, double to) => taken.every((t) => to + gap <= t.$1 || from >= t.$2 + gap);
    final out = <({int index, String text})>[];
    final current = _current;
    if (current >= 0) {
      final title = ticks[current].title.toUpperCase();
      final x = width * ticks[current].position;
      final w = measure(title).clamp(0.0, width - x);
      taken.add((x, x + w));
      out.add((index: current, text: title));
    }
    for (var i = 0; i < ticks.length; i++) {
      if (i == current) continue;
      final x = width * ticks[i].position;
      final next = i + 1 < ticks.length ? width * ticks[i + 1].position : width;
      final title = ticks[i].title.toUpperCase();
      final tw = measure(title);
      if (x + tw <= next - gap && free(x, x + tw)) {
        taken.add((x, x + tw));
        out.add((index: i, text: title));
        continue;
      }
      final number = '${i + 1}';
      final nw = measure(number);
      if (free(x, x + nw)) {
        taken.add((x, x + nw));
        out.add((index: i, text: number));
      }
    }
    painter.dispose();
    return out;
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.progress,
    required this.ticks,
    required this.current,
    required this.line,
    required this.drawn,
    required this.tick,
    required this.tickCurrent,
    required this.inset,
  });

  final double progress;
  final List<double> ticks;
  final int current;
  final Color line;
  final Color drawn;
  final Color tick;
  final Color tickCurrent;
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final y = LeseHorizont._lineY;
    final w = size.width - 2 * inset;
    final x = inset + w * progress.clamp(0, 1);
    final base = Paint()
      ..color = line
      ..strokeWidth = HzLine.hairline;
    canvas.drawLine(Offset(inset, y), Offset(size.width - inset, y), base);
    canvas.drawLine(
      Offset(inset, y),
      Offset(x, y),
      Paint()
        ..color = drawn
        ..strokeWidth = HzLine.selection,
    );
    for (var i = 0; i < ticks.length; i++) {
      final tx = inset + w * ticks[i];
      final p = Paint()
        ..color = i == current ? tickCurrent : tick
        ..strokeWidth = i == current ? HzLine.selection : HzLine.hairline;
      canvas.drawLine(Offset(tx, y - 5), Offset(tx, y + 3), p);
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) =>
      old.progress != progress || old.current != current || old.ticks.length != ticks.length || old.line != line || old.drawn != drawn;
}
