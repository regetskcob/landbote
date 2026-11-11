/// One source: its facts and the person's settings for it.
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../../app/providers.dart';
import '../../data/repository.dart';
import '../../l10n/strings.dart';
import '../actions.dart';
import '../format.dart';

/// Shows the sheet for [row].
Future<void> showFeedSheet(BuildContext context, FeedRow row) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => FeedSheet(feedId: row.feed.id),
    );

/// Asks for a name; returns it, or null when cancelled.
Future<String?> askName(BuildContext context, {required String title, String? initial}) {
  final controller = TextEditingController(text: initial);
  return showAdaptiveDialog<String>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(title),
      content: Material(
        type: MaterialType.transparency,
        child: Padding(
          padding: const EdgeInsets.only(top: HzSpace.s8),
          child: TextField(controller: controller, autofocus: true, onSubmitted: (v) => Navigator.pop(context, v.trim())),
        ),
      ),
      actions: [
        horizontDialogAction(context, label: S.cancel, onPressed: () => Navigator.pop(context)),
        horizontDialogAction(context, label: S.ok, primary: true, onPressed: () => Navigator.pop(context, controller.text.trim())),
      ],
    ),
  ).whenComplete(controller.dispose);
}

/// Asks to confirm a destructive [message]; true when confirmed.
Future<bool> confirmDestructive(BuildContext context, {required String message, required String action}) async =>
    await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        content: Text(message),
        actions: [
          horizontDialogAction(context, label: S.cancel, onPressed: () => Navigator.pop(context, false)),
          horizontDialogAction(context, label: action, destructive: true, primary: true, onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    ) ??
    false;

/// The sheet.
class FeedSheet extends ConsumerWidget {
  /// Creates the sheet for feed [feedId].
  const FeedSheet({required this.feedId, super.key});

  /// The feed.
  final int feedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(feedsProvider).value ?? const <FeedRow>[];
    final row = rows.where((r) => r.feed.id == feedId).firstOrNull;
    if (row == null) return const SizedBox.shrink();
    final f = row.feed;
    final repo = ref.read(repositoryProvider);
    final folders = ref.watch(foldersProvider).value ?? const [];
    final c = HorizontTheme.of(context).colors;
    return Padding(
      padding: horizontSheetPadding(context),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          HorizontTitle(kennung: S.feedSettings, title: row.title),
          const SizedBox(height: HzSpace.s16),
          HorizontFact(term: S.unreadTerm, value: '${row.unread}', measured: true),
          HorizontFact(term: S.perMonth, value: '${row.recent}', measured: true),
          if (f.lastFetchedAt != null) HorizontFact(term: S.lastFetched, value: longDate(f.lastFetchedAt!), measured: true),
          HorizontFact(term: S.address, value: f.url, measured: true, selectable: true),
          if (f.siteUrl != null) HorizontFact(term: S.site, value: f.siteUrl, onTap: () => openLink(ref, f.siteUrl!), external: true),
          if (f.lastError != null) HorizontFact(term: S.error, child: HorizontStatusLine(HorizontStatus.critical, f.lastError!)),
          const SizedBox(height: HzSpace.s16),
          Divider(height: HzLine.hairline, color: c.line),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(S.alwaysFullText),
            subtitle: Text(S.alwaysFullTextHelp, style: Theme.of(context).textTheme.bodySmall),
            value: f.fullText,
            onChanged: (v) => repo.updateFeed(f.id, fullText: v),
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text(S.neverBundle),
            subtitle: Text(S.neverBundleHelp, style: Theme.of(context).textTheme.bodySmall),
            value: f.neverBundle,
            onChanged: (v) => repo.updateFeed(f.id, neverBundle: v),
          ),
          const SizedBox(height: HzSpace.s8),
          HorizontField(
            label: S.folder,
            child: HorizontFieldDropdown<int?>(
              value: f.folderId,
              items: [(null, S.noFolder), for (final x in folders) (x.id, x.name), (-1, '${S.newFolder} …')],
              onChanged: (v) async {
                if (v == -1) {
                  final name = await askName(context, title: S.newFolder);
                  if (name == null || name.isEmpty) return;
                  final id = await repo.folderNamed(name);
                  await repo.updateFeed(f.id, folderId: Value(id));
                } else {
                  await repo.updateFeed(f.id, folderId: Value(v));
                }
              },
            ),
          ),
          const SizedBox(height: HzSpace.s24),
          Wrap(spacing: HzSpace.s8, runSpacing: HzSpace.s8, children: [
            OutlinedButton(
              onPressed: () async {
                final name = await askName(context, title: S.rename, initial: row.title);
                if (name == null) return;
                await repo.updateFeed(f.id, customTitle: Value(name.isEmpty || name == f.title ? null : name));
              },
              child: const Text(S.rename),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: c.critical),
              onPressed: () async {
                final navigator = Navigator.of(context);
                if (!await confirmDestructive(context, message: S.deleteFeedConfirm(row.title), action: S.delete)) return;
                await repo.deleteFeed(f.id);
                navigator.pop();
              },
              child: const Text(S.deleteFeed),
            ),
          ]),
        ]),
      ),
    );
  }
}
