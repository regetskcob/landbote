/// Morgenausgabe (Förderpaket): one notification in the morning.
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../../app/providers.dart';
import '../../app/settings.dart';
import '../../app/supporter.dart';
import '../../l10n/strings.dart';
import '../../services/notifications.dart';
import '../format.dart';
import 'supporter_page.dart';
import 'widgets.dart';

/// The page.
class MorningPage extends ConsumerWidget {
  /// Creates the page.
  const MorningPage({super.key});

  Future<void> _apply(WidgetRef ref) async {
    final s = ref.read(settingsProvider);
    final repo = ref.read(repositoryProvider);
    await MorningEdition.instance.reschedule(enabled: s.morningEnabled, minutes: s.morningMinutes, repo: repo);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isSupporterProvider)) return const SupporterPage();
    final s = ref.watch(settingsProvider);
    final set = ref.read(settingsProvider.notifier).update;
    final apple = Theme.of(context).platform == TargetPlatform.iOS || Theme.of(context).platform == TargetPlatform.macOS;
    return SettingsScaffold(kennung: S.supporterTitle, title: S.morningEdition, children: [
      SwitchRow(
        title: S.morningOn,
        help: S.morningHelp,
        value: s.morningEnabled,
        onChanged: (v) async {
          if (v && !await MorningEdition.instance.requestPermission()) return;
          await set((x) => x.copyWith(morningEnabled: v));
          await _apply(ref);
        },
      ),
      ListTile(
        title: const Text(S.morningTime),
        trailing: Text(clock(s.morningMinutes), style: HorizontTheme.of(context).data),
        enabled: s.morningEnabled,
        onTap: () async {
          int? picked;
          if (apple) {
            var value = s.morningMinutes;
            await showCupertinoModalPopup<void>(
              context: context,
              builder: (context) => Container(
                height: 260,
                color: HorizontTheme.of(context).colors.surface,
                child: SafeArea(
                  top: false,
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: true,
                    initialDateTime: DateTime(2026, 1, 1, value ~/ 60, value % 60),
                    onDateTimeChanged: (d) => value = d.hour * 60 + d.minute,
                  ),
                ),
              ),
            );
            picked = value;
          } else {
            final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: s.morningMinutes ~/ 60, minute: s.morningMinutes % 60));
            if (t != null) picked = t.hour * 60 + t.minute;
          }
          if (picked == null) return;
          await set((x) => x.copyWith(morningMinutes: picked));
          await _apply(ref);
        },
      ),
    ]);
  }
}
