/// Adding a source: one field, Landbote finds the feed.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../../app/providers.dart';
import '../../data/feeds/discovery.dart';
import '../../l10n/strings.dart';

/// Shows the sheet; [initial] prefills the address.
Future<void> showAddFeed(BuildContext context, {String? initial}) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => AddFeedSheet(initial: initial),
    );

/// The sheet.
class AddFeedSheet extends ConsumerStatefulWidget {
  /// Creates the sheet.
  const AddFeedSheet({this.initial, super.key});

  /// A prefilled address.
  final String? initial;

  @override
  ConsumerState<AddFeedSheet> createState() => _AddFeedSheetState();
}

class _AddFeedSheetState extends ConsumerState<AddFeedSheet> {
  late final _url = TextEditingController(text: widget.initial);
  bool _busy = false;
  bool _notFound = false;
  List<DiscoveredFeed> _found = const [];
  int? _chosen;
  int? _folder;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _find() async {
    if (_url.text.trim().isEmpty) return;
    setState(() {
      _busy = true;
      _notFound = false;
      _found = const [];
    });
    final found = await ref.read(repositoryProvider).discover(_url.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _found = found;
      _chosen = found.isEmpty ? null : 0;
      _notFound = found.isEmpty;
    });
  }

  Future<void> _add() async {
    final i = _chosen;
    if (i == null) return;
    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colors = HorizontTheme.of(context).colors;
    final repo = ref.read(repositoryProvider);
    await repo.addFeed(_found[i], folderId: _folder);
    // With an account, the server learns about it on the next sync.
    navigator.pop();
    messenger.showSnackBar(horizontMessageSnackBar(colors, S.added, status: HorizontStatus.positive));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = HorizontTheme.of(context).colors;
    final folders = ref.watch(foldersProvider).value ?? const [];
    return Padding(
      padding: horizontSheetPadding(context),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: HzSize.form),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const HorizontTitle(kennung: S.sources, title: S.addSource),
            const SizedBox(height: HzSpace.s16),
            HorizontField(
              label: S.addSourceHint,
              help: S.addSourceHelp,
              child: TextField(
                controller: _url,
                autofocus: widget.initial == null,
                keyboardType: TextInputType.url,
                autocorrect: false,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _find(),
                decoration: InputDecoration(
                  hintText: 'regetskcob.de',
                  suffixIcon: HorizontFieldIconButton(
                    tooltip: S.find,
                    icon: const Icon(HorizontSymbols.travelExplore),
                    onPressed: _busy ? null : _find,
                  ),
                ),
              ),
            ),
            if (_busy) ...[
              const SizedBox(height: HzSpace.s16),
              Row(children: [
                const SizedBox.square(dimension: HzIconSize.inline, child: CircularProgressIndicator.adaptive(strokeWidth: 2)),
                const SizedBox(width: HzSpace.s8),
                Text(S.finding, style: t.bodySmall),
              ]),
            ],
            if (_notFound) ...[
              const SizedBox(height: HzSpace.s16),
              const HorizontNotice(HorizontStatus.warning, child: Text(S.noFeedFound)),
            ],
            for (var i = 0; i < _found.length; i++)
              Padding(
                padding: const EdgeInsets.only(top: HzSpace.s12),
                child: HorizontSelectableCard(
                  selected: _chosen == i,
                  onTap: () => setState(() => _chosen = i),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: HzSpace.s24),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Kennung('${_found[i].feed.items.length} Beiträge', oneLine: true),
                      Text(_found[i].feed.title, style: t.titleSmall),
                      Text(_found[i].url.toString(), style: HorizontTheme.of(context).data.copyWith(color: c.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                      if ((_found[i].feed.description ?? '').isNotEmpty)
                        Text(_found[i].feed.description!, style: t.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                ),
              ),
            if (_found.isNotEmpty && folders.isNotEmpty) ...[
              const SizedBox(height: HzSpace.s16),
              HorizontField(
                label: S.folder,
                child: HorizontFieldDropdown<int?>(
                  value: _folder,
                  items: [(null, S.noFolder), for (final f in folders) (f.id, f.name)],
                  onChanged: (v) => setState(() => _folder = v),
                ),
              ),
            ],
            const SizedBox(height: HzSpace.s24),
            HorizontSheetActions(
              saveLabel: _found.isEmpty ? S.find : S.add,
              saving: _busy,
              onSave: _busy ? null : (_found.isEmpty ? _find : _add),
            ),
          ]),
        ),
      ),
    );
  }
}
