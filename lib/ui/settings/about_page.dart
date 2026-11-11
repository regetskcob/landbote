/// Über Landbote: lockup, version, sender, source, licenses, shortcuts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../../app/supporter.dart';
import '../../l10n/strings.dart';
import '../actions.dart';
import '../format.dart';

/// The app version, kept in step with pubspec.yaml.
const appVersion = '1.0.0';

/// The page.
class AboutPage extends ConsumerWidget {
  /// Creates the page.
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = HorizontTheme.of(context);
    final t = Theme.of(context).textTheme;
    final supporter = ref.watch(supporterProvider);
    return Scaffold(
      appBar: AppBar(),
      body: ListView(padding: const EdgeInsets.all(HzSpace.s24), children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: HzSize.form),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              HorizontLockup(h.product, label: S.appName, style: t.headlineMedium),
              const SizedBox(height: HzSpace.s16),
              if (supporter.unlocked && supporter.since != null) ...[
                Kennung(S.supporterSince(numericDate(supporter.since!)), color: h.colors.accentText),
                const SizedBox(height: HzSpace.s16),
              ],
              const HorizontFact(term: S.version, value: appVersion, measured: true),
              HorizontFact(term: 'HORIZONT', value: horizontTokensVersion, measured: true),
              const SizedBox(height: HzSpace.s24),
              Text(S.sourceCodeHelp, style: t.bodyMedium),
              const SizedBox(height: HzSpace.s8),
              Wrap(spacing: HzSpace.s8, runSpacing: HzSpace.s8, children: [
                OutlinedButton(onPressed: () => openLink(ref, 'https://github.com/regetskcob/landbote'), child: const Text(S.sourceCode)),
                OutlinedButton(
                  onPressed: () => showLicensePage(context: context, applicationName: S.appName, applicationVersion: appVersion),
                  child: const Text(S.licenses),
                ),
              ]),
              const SizedBox(height: HzSpace.s48),
              InkWell(
                onTap: () => openLink(ref, 'https://www.regetskcob.de/'),
                child: HorizontLockup(HorizontProduct.regetskcob, label: S.sender, style: t.bodyMedium?.copyWith(color: h.colors.textMuted)),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

/// The keyboard shortcuts, as a dialog.
Future<void> showKeyboardHelp(BuildContext context) => showAdaptiveDialog<void>(
      context: context,
      builder: (context) {
        const keys = [
          ('J / ↓', 'Nächster Beitrag'),
          ('K / ↑', 'Voriger Beitrag'),
          ('M', 'Gelesen / ungelesen'),
          ('S', 'Merken'),
          ('O / ⌘↩', 'Im Browser öffnen'),
          ('⌘R', 'Aktualisieren'),
          ('⇧⌘A', 'Alles gelesen'),
          ('⌘N', 'Quelle hinzufügen'),
          ('⌘F', 'Suchen'),
          ('⌘1 – ⌘4', 'Heute, Quellen, Gemerkt, Archiv'),
          ('⌘⌥S', 'Seitenleiste'),
          ('⌘,', 'Einstellungen'),
        ];
        return AlertDialog.adaptive(
          title: const Text(S.keyboard),
          content: Material(
            type: MaterialType.transparency,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (final (k, v) in keys) HorizontFact(term: k, value: v, padding: const EdgeInsets.symmetric(vertical: HzSpace.s2)),
            ]),
          ),
          actions: [horizontDialogAction(context, label: S.done, primary: true, onPressed: () => Navigator.pop(context))],
        );
      },
    );
