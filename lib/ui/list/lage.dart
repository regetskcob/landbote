/// The head of a list below its title: one line that says how current the
/// list is, built on Horizont's [HorizontLage]. Never a spinner alone;
/// without reception the list stays usable and says from when it is.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../../app/providers.dart';
import '../../app/settings.dart';
import '../../l10n/strings.dart';
import '../format.dart';

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
    final pointer = HorizontTheme.of(context).density == HorizontDensity.pointer;
    final lage = lageOf(ref.watch(refreshProvider));
    final unreadOnly = ref.watch(settingsProvider.select((s) => s.unreadOnly));
    final toggle = filter && !pointer
        ? TextButton(
            onPressed: () => ref.read(settingsProvider.notifier).update((s) => s.copyWith(unreadOnly: !s.unreadOnly)),
            child: Text(unreadOnly ? S.showAll : S.showUnreadOnly),
          )
        : null;
    if (lage != null) return HorizontLage(lage.text, status: lage.status, icon: lage.icon, trailing: toggle);
    // Never refreshed yet: nothing to say, the filter keeps its place.
    if (toggle == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: HzSpace.s4),
      child: Align(alignment: AlignmentDirectional.centerEnd, child: toggle),
    );
  }
}
