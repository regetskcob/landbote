/// Einstellungen: Lesen, Ernte, Konto, Daten, Förderpaket, Über.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:xml/xml.dart';

import '../../app/providers.dart';
import '../../app/settings.dart';
import '../../app/supporter.dart';
import '../../l10n/strings.dart';
import '../../services/background.dart';
import '../list/article_list.dart';
import 'about_page.dart';
import 'account_page.dart';
import 'harvest_page.dart';
import 'morning_page.dart';
import 'reading_style_page.dart';
import 'rules_page.dart';
import 'supporter_page.dart';
import 'widgets.dart';

/// Opens the settings; with [opml] the import starts right away.
Future<void> pushSettings(BuildContext context, {bool opml = false}) =>
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(builder: (_) => SettingsPage(importOnOpen: opml)));

/// Pushes [page] on the root navigator.
Future<void> pushPage(BuildContext context, Widget page) =>
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute<void>(builder: (_) => page));

/// The settings page.
class SettingsPage extends ConsumerStatefulWidget {
  /// Creates the page.
  const SettingsPage({this.importOnOpen = false, super.key});

  /// Starts the OPML import when opened.
  final bool importOnOpen;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
    if (widget.importOnOpen) WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_import()));
  }

  Future<void> _import() async {
    final messenger = ScaffoldMessenger.of(context);
    final colors = HorizontTheme.of(context).colors;
    const group = XTypeGroup(
      label: 'OPML',
      extensions: ['opml', 'xml'],
      uniformTypeIdentifiers: ['org.opml.opml', 'public.xml', 'public.data'],
      mimeTypes: ['text/x-opml', 'application/xml', 'text/xml'],
    );
    final file = await openFile(acceptedTypeGroups: [group]);
    if (file == null) return;
    try {
      final text = utf8.decode(await file.readAsBytes(), allowMalformed: true);
      final n = await ref.read(repositoryProvider).importOpml(text);
      messenger.showSnackBar(horizontMessageSnackBar(colors, S.imported(n), status: HorizontStatus.positive));
      unawaited(ref.read(refreshProvider.notifier).refresh());
    } on XmlException {
      messenger.showSnackBar(horizontMessageSnackBar(colors, S.importFailed, status: HorizontStatus.critical));
    }
  }

  Future<void> _export(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final opml = await ref.read(repositoryProvider).exportOpml();
    const name = 'landbote.opml';
    if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
      final location = await getSaveLocation(suggestedName: name);
      if (location == null) return;
      await File(location.path).writeAsString(opml);
      return;
    }
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, name));
    await file.writeAsString(opml);
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'text/x-opml')],
      sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    final set = ref.read(settingsProvider.notifier).update;
    final account = ref.watch(accountProvider);
    final supporter = ref.watch(isSupporterProvider);
    final rules = ref.watch(rulesProvider).value?.length ?? 0;
    final pointer = HorizontTheme.of(context).density == HorizontDensity.pointer;

    return SettingsScaffold(kennung: S.menu, title: S.settings, children: [
      const SectionKennung(S.sectionReading),
      ChoiceRow<ThemeMode>(
        title: S.appearance,
        icon: HorizontSymbols.contrast,
        value: s.themeMode,
        items: const [(ThemeMode.system, S.system), (ThemeMode.light, S.light), (ThemeMode.dark, S.dark)],
        onChanged: (v) => set((x) => x.copyWith(themeMode: v)),
      ),
      ChoiceRow<ImageLoading>(
        title: S.images,
        icon: HorizontSymbols.image,
        value: s.images,
        items: const [(ImageLoading.always, S.imagesAlways), (ImageLoading.onDemand, S.imagesOnDemand)],
        onChanged: (v) => set((x) => x.copyWith(images: v)),
      ),
      ChoiceRow<bool>(
        title: S.openLinks,
        icon: HorizontSymbols.link,
        value: s.openInApp,
        items: const [(true, S.openLinksInApp), (false, S.openLinksBrowser)],
        onChanged: (v) => set((x) => x.copyWith(openInApp: v)),
      ),
      NavRow(title: S.readingStyle, icon: HorizontSymbols.formatSize, locked: !supporter, onTap: () => pushPage(context, const ReadingStylePage())),

      const SectionKennung(S.sectionHarvest),
      ChoiceRow<int>(
        title: S.harvestAfter,
        help: S.harvestHelp,
        icon: HorizontSymbols.archive,
        value: s.harvestDays,
        items: [for (final d in const [3, 7, 14, 30]) (d, S.days(d))],
        onChanged: (v) async {
          await set((x) => x.copyWith(harvestDays: v));
          await ref.read(repositoryProvider).harvest(days: v);
        },
      ),
      ChoiceRow<int>(
        title: S.bundleFrom,
        help: S.bundleHelp,
        icon: HorizontSymbols.unfoldLess,
        value: s.bundleThreshold,
        items: [for (final n in const [4, 6, 10]) (n, S.perDay(n)), (0, S.refreshOff)],
        onChanged: (v) => set((x) => x.copyWith(bundleThreshold: v)),
      ),
      ChoiceRow<int>(
        title: S.refreshEvery,
        icon: HorizontSymbols.schedule,
        value: s.refreshMinutes,
        items: [for (final m in const [15, 30, 60, 180]) (m, S.everyMinutes(m)), (0, S.refreshOff)],
        onChanged: (v) async {
          await set((x) => x.copyWith(refreshMinutes: v));
          await scheduleBackgroundRefresh(v);
        },
      ),
      NavRow(title: S.rules, icon: HorizontSymbols.filterAlt, value: '$rules', onTap: () => pushPage(context, const RulesPage())),

      const SectionKennung(S.sectionAccount),
      NavRow(
        title: S.account,
        icon: HorizontSymbols.cloudSync,
        value: account?.kind.label ?? S.accountLocal,
        onTap: () => pushPage(context, const AccountPage()),
      ),

      const SectionKennung(S.sectionData),
      NavRow(title: S.importOpml, icon: HorizontSymbols.download, onTap: _import),
      Builder(builder: (context) => NavRow(title: S.exportOpml, icon: HorizontSymbols.upload, onTap: () => _export(context))),

      const SectionKennung(S.sectionSupporter),
      NavRow(
        title: S.supporterTitle,
        icon: HorizontSymbols.volunteerActivism,
        value: supporter ? '✓' : null,
        onTap: () => pushPage(context, const SupporterPage()),
      ),
      NavRow(title: S.yearHarvest, icon: HorizontSymbols.gridView, locked: !supporter, onTap: () => pushPage(context, supporter ? const HarvestPage() : const SupporterPage())),
      NavRow(
        title: S.morningEdition,
        icon: HorizontSymbols.notifications,
        locked: !supporter,
        value: s.morningEnabled ? null : S.refreshOff,
        onTap: () => pushPage(context, supporter ? const MorningPage() : const SupporterPage()),
      ),

      const SectionKennung(S.sectionAbout),
      NavRow(title: S.about, icon: HorizontSymbols.info, onTap: () => pushPage(context, const AboutPage())),
      if (pointer) NavRow(title: S.keyboard, icon: HorizontSymbols.keyboard, onTap: () => showKeyboardHelp(context)),
      // A refresh from here is handy after changing the account.
      if (account != null)
        NavRow(title: S.syncNow, icon: HorizontSymbols.sync, onTap: () => refreshWithMessage(context, ref)),
    ]);
  }
}
