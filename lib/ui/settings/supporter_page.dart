/// The Förderpaket: what it gives, one button, restore.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../../app/supporter.dart';
import '../../l10n/strings.dart';
import '../format.dart';

/// The page.
class SupporterPage extends ConsumerWidget {
  /// Creates the page.
  const SupporterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(supporterProvider);
    final c = HorizontTheme.of(context).colors;
    final t = Theme.of(context).textTheme;
    final message = switch (s.message) {
      'thanks' => (HorizontStatus.positive, S.thanks),
      'pending' => (HorizontStatus.info, S.purchasePending),
      'failed' => (HorizontStatus.critical, S.purchaseFailed),
      'unavailable' => (HorizontStatus.warning, S.storeUnavailable),
      _ => null,
    };
    Widget feature(IconData icon, String title, String text) => Padding(
          padding: const EdgeInsets.only(bottom: HzSpace.s16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, size: HzIconSize.bar, color: c.accentText),
            const SizedBox(width: HzSpace.s16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: t.titleSmall),
                const SizedBox(height: HzSpace.s2),
                Text(text, style: t.bodyMedium?.copyWith(color: c.textMuted)),
              ]),
            ),
          ]),
        );
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: HorizontTitle.toolbarHeight(context),
        title: HorizontTitle(kennung: s.unlocked && s.since != null ? S.supporterSince(numericDate(s.since!)) : S.supporterKennung, title: S.supporterTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HzSpace.s16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: HzSize.form),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(S.supporterIntro, style: HorizontTheme.of(context).reading),
              const SizedBox(height: HzSpace.s32),
              feature(HorizontSymbols.formatSize, S.supporterStyle, S.supporterStyleText),
              feature(HorizontSymbols.gridView, S.supporterHarvest, S.supporterHarvestText),
              feature(HorizontSymbols.notifications, S.supporterMorning, S.supporterMorningText),
              feature(HorizontSymbols.flag, S.supporterFlag, S.supporterFlagText),
              const SizedBox(height: HzSpace.s16),
              if (message != null) ...[
                HorizontNotice(message.$1, child: Text(message.$2)),
                const SizedBox(height: HzSpace.s16),
              ],
              if (!s.unlocked) ...[
                FilledButton(
                  onPressed: s.busy ? null : () => ref.read(supporterProvider.notifier).buy(),
                  child: Text(S.buy(s.price ?? S.buyFallbackPrice)),
                ),
                const SizedBox(height: HzSpace.s8),
                TextButton(onPressed: s.busy ? null : () => ref.read(supporterProvider.notifier).restore(), child: const Text(S.restore)),
              ] else
                const HorizontStatusLine(HorizontStatus.positive, S.thanks),
            ]),
          ),
        ),
      ),
    );
  }
}
