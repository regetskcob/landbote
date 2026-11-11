/// Synchronisieren: connect FreshRSS, Miniflux or Nextcloud News, or none.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../../app/providers.dart';
import '../../data/sync/sync_backend.dart';
import '../../l10n/strings.dart';
import '../format.dart';
import '../list/article_list.dart';
import '../sources/feed_sheet.dart';

/// The account page.
class AccountPage extends ConsumerStatefulWidget {
  /// Creates the page.
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  SyncKind _kind = SyncKind.freshRss;
  final _server = TextEditingController();
  final _user = TextEditingController();
  final _secret = TextEditingController();
  bool _busy = false;
  bool _failed = false;

  @override
  void dispose() {
    _server.dispose();
    _user.dispose();
    _secret.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await ref.read(accountProvider.notifier).connect(_kind, _server.text.trim(), _user.text.trim(), _secret.text);
      _secret.clear();
      if (mounted) await refreshWithMessage(context, ref);
    } on SyncException {
      if (mounted) setState(() => _failed = true);
    } on Exception {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountProvider);
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: HorizontTitle.toolbarHeight(context),
        title: const HorizontTitle(kennung: S.sectionAccount, title: S.account),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(HzSpace.s16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: HzSize.form),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: account != null ? _connected(account) : [
              Text(S.accountHelp, style: t.bodyMedium),
              const SizedBox(height: HzSpace.s24),
              HorizontField(
                label: S.server,
                child: HorizontFieldDropdown<SyncKind>(
                  value: _kind,
                  items: [for (final k in SyncKind.values) (k, k.label)],
                  onChanged: (v) => setState(() => _kind = v),
                ),
              ),
              const SizedBox(height: HzSpace.s12),
              HorizontField(
                label: S.serverUrl,
                child: TextField(controller: _server, keyboardType: TextInputType.url, autocorrect: false, decoration: const InputDecoration(hintText: 'rss.example.org')),
              ),
              if (_kind != SyncKind.miniflux) ...[
                const SizedBox(height: HzSpace.s12),
                HorizontField(label: S.user, child: TextField(controller: _user, autocorrect: false, autofillHints: const [AutofillHints.username])),
              ],
              const SizedBox(height: HzSpace.s12),
              HorizontField(
                label: _kind == SyncKind.miniflux ? S.apiToken : S.password,
                help: switch (_kind) {
                  SyncKind.freshRss => S.passwordHelpFreshRss,
                  SyncKind.miniflux => S.tokenHelpMiniflux,
                  SyncKind.nextcloud => null,
                },
                child: TextField(controller: _secret, obscureText: true, autocorrect: false, autofillHints: const [AutofillHints.password]),
              ),
              if (_failed) ...[
                const SizedBox(height: HzSpace.s16),
                const HorizontNotice(HorizontStatus.critical, child: Text(S.connectFailed)),
              ],
              const SizedBox(height: HzSpace.s24),
              FilledButton(onPressed: _busy ? null : _connect, child: Text(_busy ? S.connecting : S.connect)),
            ]),
          ),
        ),
      ),
    );
  }

  List<Widget> _connected(SyncAccount a) => [
        HorizontFact(term: S.connectedTo, value: a.kind.label),
        HorizontFact(term: S.server, value: a.server, measured: true, selectable: true),
        if (a.user.isNotEmpty) HorizontFact(term: S.user, value: a.user, measured: true),
        HorizontFact(term: S.lastSync, value: a.lastSync == null ? '–' : longDate(a.lastSync!), measured: true),
        const SizedBox(height: HzSpace.s24),
        FilledButton(onPressed: () => refreshWithMessage(context, ref), child: const Text(S.syncNow)),
        const SizedBox(height: HzSpace.s8),
        OutlinedButton(
          onPressed: () async {
            if (await confirmDestructive(context, message: S.disconnectConfirm, action: S.disconnect)) {
              await ref.read(accountProvider.notifier).disconnect();
            }
          },
          child: const Text(S.disconnect),
        ),
      ];
}
