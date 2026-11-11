/// The composition root's providers: real infrastructure is created in
/// `main()` and injected by overriding [databaseProvider] and
/// [preferencesProvider].
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../data/db/database.dart';
import '../data/feeds/fetcher.dart';
import '../data/repository.dart';
import '../data/sync/greader.dart';
import '../data/sync/miniflux.dart';
import '../data/sync/nextcloud.dart';
import '../data/sync/sync_backend.dart';
import '../data/sync/sync_engine.dart';
import 'settings.dart';

/// The database, opened in `main()`.
final databaseProvider = Provider<LandboteDatabase>(
  (ref) => throw UnimplementedError('databaseProvider is overridden in main()'),
);

/// The HTTP client; one per app.
final httpClientProvider = Provider<http.Client>((ref) {
  final c = http.Client();
  ref.onDispose(c.close);
  return c;
});

/// The repository.
final repositoryProvider = Provider<FeedRepository>(
  (ref) => FeedRepository(ref.watch(databaseProvider), Fetcher(ref.watch(httpClientProvider))),
);

/// Articles of a scope; honours the "unread only" setting except in Gemerkt.
final articlesProvider = StreamProvider.family<List<ArticleRow>, ArticleScope>((ref, scope) {
  final unreadOnly = ref.watch(settingsProvider.select((s) => s.unreadOnly));
  return ref.watch(repositoryProvider).watchArticles(scope, unreadOnly: unreadOnly && scope is! SavedScope && scope is! ArchiveScope);
});

/// One article.
final articleProvider = StreamProvider.family<ArticleRow?, int>((ref, id) => ref.watch(repositoryProvider).watchArticle(id));

/// All feeds with counts.
final feedsProvider = StreamProvider<List<FeedRow>>((ref) => ref.watch(repositoryProvider).watchFeeds());

/// All folders.
final foldersProvider = StreamProvider<List<Folder>>((ref) => ref.watch(repositoryProvider).watchFolders());

/// Unread in Heute.
final unreadTodayProvider = StreamProvider<int>((ref) => ref.watch(repositoryProvider).watchUnreadToday());

/// The filter rules.
final rulesProvider = StreamProvider<List<Rule>>((ref) => ref.watch(repositoryProvider).watchRules());

// ------------------------------------------------------------------ account

/// A connected sync account (the secret lives in the keychain).
@immutable
class SyncAccount {
  /// Creates the account.
  const SyncAccount({required this.kind, required this.server, required this.user, this.lastSync});

  /// The server kind.
  final SyncKind kind;

  /// The server address as typed.
  final String server;

  /// The login name (empty for Miniflux tokens).
  final String user;

  /// The last successful sync.
  final DateTime? lastSync;
}

/// The keychain.
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) => const FlutterSecureStorage());

/// The account, or null when Landbote runs on its own.
final accountProvider = NotifierProvider<AccountController, SyncAccount?>(AccountController.new);

/// Connects, stores and forgets the sync account.
class AccountController extends Notifier<SyncAccount?> {
  static const _secretKey = 'landbote.sync.secret';

  @override
  SyncAccount? build() {
    final p = ref.watch(preferencesProvider);
    final kind = p.getString('sync.kind');
    if (kind == null) return null;
    final last = p.getInt('sync.last');
    return SyncAccount(
      kind: SyncKind.values.byName(kind),
      server: p.getString('sync.server') ?? '',
      user: p.getString('sync.user') ?? '',
      lastSync: last == null ? null : DateTime.fromMillisecondsSinceEpoch(last, isUtc: true),
    );
  }

  /// Builds the backend for an account and its [secret].
  SyncBackend backendFor(SyncKind kind, String server, String user, String secret) {
    final client = ref.read(httpClientProvider);
    return switch (kind) {
      SyncKind.freshRss => GReaderBackend(client, server: server, user: user, password: secret),
      SyncKind.miniflux => MinifluxBackend(client, server: server, token: secret),
      SyncKind.nextcloud => NextcloudBackend(client, server: server, user: user, password: secret),
    };
  }

  /// Checks the credentials and stores the account. Throws [SyncException].
  Future<void> connect(SyncKind kind, String server, String user, String secret) async {
    await backendFor(kind, server, user, secret).login();
    final p = ref.read(preferencesProvider);
    await ref.read(secureStorageProvider).write(key: _secretKey, value: secret);
    await p.setString('sync.kind', kind.name);
    await p.setString('sync.server', server);
    await p.setString('sync.user', user);
    await p.remove('sync.last');
    state = SyncAccount(kind: kind, server: server, user: user);
  }

  /// Forgets the account. Feeds and articles stay; they become local.
  Future<void> disconnect() async {
    final p = ref.read(preferencesProvider);
    await ref.read(secureStorageProvider).delete(key: _secretKey);
    for (final k in const ['sync.kind', 'sync.server', 'sync.user', 'sync.last']) {
      await p.remove(k);
    }
    final db = ref.read(databaseProvider);
    await db.customStatement('UPDATE feeds SET remote_id = NULL');
    await db.customStatement('UPDATE articles SET remote_id = NULL');
    await db.delete(db.syncOps).go();
    state = null;
  }

  /// Runs a sync if an account is connected; returns null otherwise.
  Future<SyncReport?> sync() async {
    final a = state;
    if (a == null) return null;
    final secret = await ref.read(secureStorageProvider).read(key: _secretKey);
    if (secret == null) return null;
    final engine = SyncEngine(ref.read(repositoryProvider), backendFor(a.kind, a.server, a.user, secret));
    final report = await engine.sync(since: a.lastSync);
    final now = DateTime.now().toUtc();
    await ref.read(preferencesProvider).setInt('sync.last', now.millisecondsSinceEpoch);
    state = SyncAccount(kind: a.kind, server: a.server, user: a.user, lastSync: now);
    return report;
  }
}

// ------------------------------------------------------------------ refresh

/// The state of the refresh: idle, or running with progress.
@immutable
class RefreshState {
  /// Creates the state.
  const RefreshState({this.running = false, this.done = 0, this.total = 0, this.lastNew, this.lastFailed = 0, this.lastError});

  /// Whether a refresh runs.
  final bool running;

  /// Feeds done.
  final int done;

  /// Feeds in total.
  final int total;

  /// New articles of the last run.
  final int? lastNew;

  /// Failed feeds of the last run.
  final int lastFailed;

  /// A sync error of the last run.
  final String? lastError;
}

/// Refreshes feeds and syncs; one run at a time.
final refreshProvider = NotifierProvider<RefreshController, RefreshState>(RefreshController.new);

/// See [refreshProvider].
class RefreshController extends Notifier<RefreshState> {
  Future<RefreshState>? _running;

  @override
  RefreshState build() => const RefreshState();

  /// Refreshes all local feeds and syncs the account. Concurrent calls join
  /// the running one.
  Future<RefreshState> refresh() => _running ??= _run().whenComplete(() => _running = null);

  Future<RefreshState> _run() async {
    state = const RefreshState(running: true);
    final repo = ref.read(repositoryProvider);
    var fresh = 0;
    String? error;
    try {
      final r = await ref.read(accountProvider.notifier).sync();
      fresh += r?.newArticles ?? 0;
    } on SyncException catch (e) {
      error = e.message;
    }
    final report = await repo.refreshAll(onProgress: (d, t) => state = RefreshState(running: true, done: d, total: t));
    await repo.harvest(days: ref.read(settingsProvider).harvestDays);
    fresh += report.newArticles;
    return state = RefreshState(lastNew: fresh, lastFailed: report.failed, lastError: error);
  }
}
