/// Gräben: filter rules that hide or mark articles.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../../app/providers.dart';
import '../../data/db/database.dart';
import '../../l10n/strings.dart';

/// The rules page.
class RulesPage extends ConsumerWidget {
  /// Creates the page.
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rules = ref.watch(rulesProvider).value ?? const <Rule>[];
    final feeds = ref.watch(feedsProvider).value ?? const [];
    final c = HorizontTheme.of(context).colors;
    final t = Theme.of(context).textTheme;
    final add = HorizontPrimaryAction(icon: HorizontSymbols.add, label: S.addRule, onPressed: () => _add(context, ref));
    String feedName(int? id) => id == null ? S.ruleAllFeeds : (feeds.where((f) => f.feed.id == id).firstOrNull?.title ?? '');
    String field(int f) => switch (f) { 1 => S.ruleFieldTitle, 2 => S.ruleFieldAuthor, _ => S.ruleFieldAny };
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: HorizontTitle.toolbarHeight(context),
        title: HorizontTitle(kennung: S.rulesKennung, count: rules.length, title: S.rules),
        actions: [...add.toolbar(context)],
      ),
      floatingActionButton: add.fab(context),
      body: rules.isEmpty
          ? const HorizontEmptyHint(text: S.noRules, detail: S.rulesHelp, icon: HorizontSymbols.filterAlt)
          : ListView(children: [
              Padding(padding: const EdgeInsets.all(HzSpace.s16), child: Text(S.rulesHelp, style: t.bodySmall)),
              for (final r in rules)
                DecoratedBox(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.line, width: HzLine.hairline))),
                  child: ListTile(
                    title: Text(r.pattern, style: HorizontTheme.of(context).data),
                    subtitle: Kennung([field(r.field), r.action == 0 ? S.ruleHide : S.ruleMarkRead, feedName(r.feedId)].join(horizontMetaSeparator)),
                    trailing: IconButton(
                      tooltip: S.delete,
                      icon: const Icon(HorizontSymbols.delete, size: HzIconSize.row),
                      onPressed: () => ref.read(repositoryProvider).deleteRule(r.id),
                    ),
                  ),
                ),
            ]),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => const _RuleSheet(),
      );
}

class _RuleSheet extends ConsumerStatefulWidget {
  const _RuleSheet();

  @override
  ConsumerState<_RuleSheet> createState() => _RuleSheetState();
}

class _RuleSheetState extends ConsumerState<_RuleSheet> {
  final _pattern = TextEditingController();
  int _field = 0;
  int _action = 0;
  int? _feed;

  @override
  void dispose() {
    _pattern.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feeds = ref.watch(feedsProvider).value ?? const [];
    return Padding(
      padding: horizontSheetPadding(context),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const HorizontTitle(kennung: S.rulesKennung, title: S.addRule),
        const SizedBox(height: HzSpace.s16),
        HorizontField(label: S.pattern, child: TextField(controller: _pattern, autofocus: true)),
        const SizedBox(height: HzSpace.s12),
        HorizontField(
          label: S.ruleField,
          child: HorizontFieldDropdown<int>(
            value: _field,
            items: const [(0, S.ruleFieldAny), (1, S.ruleFieldTitle), (2, S.ruleFieldAuthor)],
            onChanged: (v) => setState(() => _field = v),
          ),
        ),
        const SizedBox(height: HzSpace.s12),
        HorizontField(
          label: S.ruleAction,
          child: HorizontFieldDropdown<int>(
            value: _action,
            items: const [(0, S.ruleHide), (1, S.ruleMarkRead)],
            onChanged: (v) => setState(() => _action = v),
          ),
        ),
        const SizedBox(height: HzSpace.s12),
        HorizontField(
          label: S.sources,
          child: HorizontFieldDropdown<int?>(
            value: _feed,
            items: [(null, S.ruleAllFeeds), for (final f in feeds) (f.feed.id, f.title)],
            onChanged: (v) => setState(() => _feed = v),
          ),
        ),
        const SizedBox(height: HzSpace.s24),
        HorizontSheetActions(
          saveLabel: S.add,
          onSave: () async {
            final text = _pattern.text.trim();
            if (text.isEmpty) return;
            final navigator = Navigator.of(context);
            await ref.read(repositoryProvider).addRule(pattern: text, field: _field, action: _action, feedId: _feed);
            navigator.pop();
          },
        ),
      ]),
    );
  }
}
