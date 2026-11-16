/// The head of a list below its title: the horizon line with the share
/// already read, and one line that says how current the list is. Never a
/// spinner alone; without reception the list stays usable and says from
/// when it is.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../../app/providers.dart';
import '../../app/settings.dart';
import '../../l10n/strings.dart';
import '../format.dart';

/// The horizon under a list head: a 2 px line, its left part in the accent
/// for [fraction] (0 to 1), here the share of the list that is read.
class ListHorizont extends StatelessWidget implements PreferredSizeWidget {
  /// Creates the line.
  const ListHorizont({required this.fraction, super.key});

  /// The share in the accent.
  final double fraction;

  @override
  Size get preferredSize => const Size.fromHeight(HzLine.selection);

  @override
  Widget build(BuildContext context) {
    final c = HorizontTheme.of(context).colors;
    final still = MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: SizedBox(
        width: double.infinity,
        height: HzLine.selection,
        child: ColoredBox(
          color: c.line,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: fraction.clamp(0.0, 1.0)),
            duration: still ? Duration.zero : HzMotion.calm,
            curve: HzMotion.settle,
            builder: (context, v, _) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(widthFactor: v, heightFactor: 1, child: ColoredBox(color: c.accent)),
            ),
          ),
        ),
      ),
    );
  }
}

/// What the line says, as sign, colour and words.
({IconData icon, HorizontStatus status, String text})? lageOf(RefreshState r) {
  final time = r.lastAt == null ? null : shortTime(r.lastAt!);
  if (r.running) return (icon: HorizontSymbols.sync, status: HorizontStatus.neutral, text: S.lageRunning);
  if (r.offline) return (icon: HorizontSymbols.cloudOff, status: HorizontStatus.warning, text: S.lageOffline(time));
  if (time == null) return null;
  // A failed account sync is no "Aktuell", even with every feed answering.
  if (r.lastError != null) return (icon: HorizontStatus.warning.icon, status: HorizontStatus.warning, text: S.lageSyncFailed(time));
  if (r.lastFailed > 0) return (icon: HorizontStatus.warning.icon, status: HorizontStatus.warning, text: S.lagePartial(r.lastFailed, time));
  return (icon: HorizontStatus.positive.icon, status: HorizontStatus.positive, text: S.lageCurrent(time));
}

/// The line under the horizon: the state of the list on the left, on touch
/// the filter with its word on the right.
class LageLine extends ConsumerWidget {
  /// Creates the line. [filter] shows the "Nur ungelesene" switch.
  const LageLine({this.filter = true, super.key});

  /// Whether the unread filter shows (not in Gemerkt).
  final bool filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = HorizontTheme.of(context);
    final c = h.colors;
    final t = Theme.of(context).textTheme;
    final pointer = h.density == HorizontDensity.pointer;
    final lage = lageOf(ref.watch(refreshProvider));
    final unreadOnly = ref.watch(settingsProvider.select((s) => s.unreadOnly));
    final showFilter = filter && !pointer;
    if (lage == null && !showFilter) return const SizedBox.shrink();
    final warn = lage?.status == HorizontStatus.warning;
    final sign = lage == null ? null : (lage.status == HorizontStatus.neutral ? c.textMuted : lage.status.color(c));
    return ColoredBox(
      color: warn ? c.warningTint : c.bg,
      child: Padding(
        padding: const EdgeInsetsDirectional.only(start: HzSpace.s16, end: HzSpace.s4),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: pointer ? HzSize.rowDense : HzSize.touch),
          child: Row(children: [
            if (lage != null) ...[
              Icon(lage.icon, size: HzIconSize.row, color: sign),
              const SizedBox(width: HzSpace.s8),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: HzSpace.s8),
                    child: Text(lage.text, style: t.bodySmall?.copyWith(color: warn ? c.text : c.textMuted)),
                  ),
                ),
              ),
            ] else
              const Spacer(),
            if (showFilter)
              TextButton(
                onPressed: () => ref.read(settingsProvider.notifier).update((s) => s.copyWith(unreadOnly: !s.unreadOnly)),
                child: Text(unreadOnly ? S.showAll : S.showUnreadOnly),
              ),
            if (!showFilter) const SizedBox(width: HzSpace.s12),
          ]),
        ),
      ),
    );
  }
}
