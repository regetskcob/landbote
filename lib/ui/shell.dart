/// The frame of the app, chosen by available width, never by device:
/// under 600 a tab bar with Heute, Quellen, Gemerkt; from 600 a sidebar and
/// the list; from 840 the reader as a third pane. With a pointer: keyboard
/// first and, on macOS, the menu bar.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../app/providers.dart';
import '../app/settings.dart';
import '../data/repository.dart';
import '../l10n/strings.dart';
import '../services/background.dart';
import '../services/home_widget.dart';
import '../services/watch.dart';
import 'actions.dart';
import 'list/article_list.dart';
import 'nav_state.dart';
import 'reader/reader_view.dart';
import 'settings/about_page.dart';
import 'settings/settings_page.dart';
import 'sources/add_feed_sheet.dart';
import 'sources/sources_pane.dart';

/// The shell.
class Shell extends ConsumerStatefulWidget {
  /// Creates the shell.
  const Shell({super.key});

  @override
  ConsumerState<Shell> createState() => _ShellState();
}

class _ShellState extends ConsumerState<Shell> with WidgetsBindingObserver {
  Timer? _timer;
  DateTime _lastRefresh = DateTime.fromMillisecondsSinceEpoch(0);
  final _tabNavigators = [GlobalKey<NavigatorState>(), GlobalKey<NavigatorState>(), GlobalKey<NavigatorState>()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    listenToWatch(ref.read(repositoryProvider));
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_refresh()));
    _timer = desktopRefreshTimer(ref.read(settingsProvider).refreshMinutes, _refresh);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && DateTime.now().difference(_lastRefresh) > const Duration(minutes: 15)) {
      unawaited(_refresh());
    }
  }

  Future<void> _refresh() async {
    _lastRefresh = DateTime.now();
    await ref.read(refreshProvider.notifier).refresh();
    await updateHomeWidgets(ref.read(repositoryProvider));
  }

  // ----------------------------------------------------------- commands

  int? get _current => ref.read(navProvider).articleId;

  void _step(int delta) {
    final order = ref.read(visibleOrderProvider);
    if (order.isEmpty) return;
    final cur = _current;
    final i = cur == null ? -1 : order.indexOf(cur);
    final next = (i + delta).clamp(0, order.length - 1);
    ref.read(navProvider.notifier).select(order[next]);
  }

  Future<void> _toggleRead() async {
    final id = _current;
    if (id == null) return;
    final row = await ref.read(repositoryProvider).watchArticle(id).first;
    if (row != null) await ref.read(repositoryProvider).setRead(id, !row.isRead);
  }

  Future<void> _toggleSaved() async {
    final id = _current;
    if (id == null) return;
    final row = await ref.read(repositoryProvider).watchArticle(id).first;
    if (row != null) await ref.read(repositoryProvider).setSaved(id, !row.isSaved);
  }

  Future<void> _openCurrent() async {
    final id = _current;
    if (id == null) return;
    final row = await ref.read(repositoryProvider).watchArticle(id).first;
    if (row?.article.url != null) await openLink(ref, row!.article.url!, forceBrowser: true);
  }

  Future<void> _markAllVisible() => ref.read(repositoryProvider).markAllRead(ref.read(visibleOrderProvider));

  void _toggleSidebar() => ref.read(settingsProvider.notifier).update((s) => s.copyWith(sidebarOpen: !s.sidebarOpen));

  Map<ShortcutActivator, VoidCallback> get _shortcuts {
    final meta = defaultTargetPlatform == TargetPlatform.macOS;
    SingleActivator cmd(LogicalKeyboardKey k, {bool shift = false, bool alt = false}) =>
        SingleActivator(k, meta: meta, control: !meta, shift: shift, alt: alt);
    final nav = ref.read(navProvider.notifier);
    return {
      const SingleActivator(LogicalKeyboardKey.keyJ): () => _step(1),
      const SingleActivator(LogicalKeyboardKey.keyK): () => _step(-1),
      const SingleActivator(LogicalKeyboardKey.keyM): _toggleRead,
      const SingleActivator(LogicalKeyboardKey.keyS): _toggleSaved,
      const SingleActivator(LogicalKeyboardKey.keyO): _openCurrent,
      cmd(LogicalKeyboardKey.enter): _openCurrent,
      cmd(LogicalKeyboardKey.keyR): () => refreshWithMessage(context, ref),
      cmd(LogicalKeyboardKey.keyA, shift: true): _markAllVisible,
      cmd(LogicalKeyboardKey.keyN): () => showAddFeed(context),
      cmd(LogicalKeyboardKey.digit1): () => nav.go(Place.today),
      cmd(LogicalKeyboardKey.digit2): () => nav.go(Place.sources),
      cmd(LogicalKeyboardKey.digit3): () => nav.go(Place.saved),
      cmd(LogicalKeyboardKey.digit4): () => nav.go(Place.archive),
      cmd(LogicalKeyboardKey.keyS, alt: true): _toggleSidebar,
      cmd(LogicalKeyboardKey.comma): () => pushSettings(context),
    };
  }

  // -------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final body = width < HzBreakpoint.medium ? _compact(context) : _wide(context, width);
    Widget shell = Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        // Single-letter shortcuts must never eat what someone types.
        final focus = FocusManager.instance.primaryFocus?.context;
        final typing = focus != null && (focus.widget is EditableText || focus.findAncestorWidgetOfExactType<EditableText>() != null);
        if (typing || event is KeyUpEvent) return KeyEventResult.ignored;
        for (final e in _shortcuts.entries) {
          if (e.key.accepts(event, HardwareKeyboard.instance)) {
            e.value();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: body,
    );
    if (defaultTargetPlatform == TargetPlatform.macOS) shell = _menuBar(shell);
    return shell;
  }

  Widget _menuBar(Widget child) {
    final nav = ref.read(navProvider.notifier);
    PlatformMenuItem item(String label, VoidCallback onSelected, [MenuSerializableShortcut? shortcut]) =>
        PlatformMenuItem(label: label, onSelected: onSelected, shortcut: shortcut);
    const m = true;
    return PlatformMenuBar(
      menus: [
        PlatformMenu(label: S.appName, menus: [
          PlatformMenuItemGroup(members: [
            item(S.about, () => pushPage(context, const AboutPage())),
            item(S.settings, () => pushSettings(context), const SingleActivator(LogicalKeyboardKey.comma, meta: m)),
          ]),
          if (PlatformProvidedMenuItem.hasMenu(PlatformProvidedMenuItemType.quit))
            const PlatformMenuItemGroup(members: [PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.quit)]),
        ]),
        PlatformMenu(label: 'Ablage', menus: [
          item(S.addSource, () => showAddFeed(context), const SingleActivator(LogicalKeyboardKey.keyN, meta: m)),
          item(S.importOpml, () => pushSettings(context, opml: true)),
        ]),
        PlatformMenu(label: 'Darstellung', menus: [
          PlatformMenuItemGroup(members: [
            item(S.today, () => nav.go(Place.today), const SingleActivator(LogicalKeyboardKey.digit1, meta: m)),
            item(S.sources, () => nav.go(Place.sources), const SingleActivator(LogicalKeyboardKey.digit2, meta: m)),
            item(S.saved, () => nav.go(Place.saved), const SingleActivator(LogicalKeyboardKey.digit3, meta: m)),
            item(S.archive, () => nav.go(Place.archive), const SingleActivator(LogicalKeyboardKey.digit4, meta: m)),
          ]),
          item('Seitenleiste', _toggleSidebar, const SingleActivator(LogicalKeyboardKey.keyS, meta: m, alt: true)),
          item(S.showUnreadOnly, () => ref.read(settingsProvider.notifier).update((s) => s.copyWith(unreadOnly: !s.unreadOnly))),
        ]),
        PlatformMenu(label: 'Beitrag', menus: [
          PlatformMenuItemGroup(members: [
            item(S.next, () => _step(1), const SingleActivator(LogicalKeyboardKey.keyJ)),
            item(S.previous, () => _step(-1), const SingleActivator(LogicalKeyboardKey.keyK)),
          ]),
          PlatformMenuItemGroup(members: [
            item('Gelesen / ungelesen', _toggleRead, const SingleActivator(LogicalKeyboardKey.keyM)),
            item(S.save, _toggleSaved, const SingleActivator(LogicalKeyboardKey.keyS)),
            item(S.openInBrowser, _openCurrent, const SingleActivator(LogicalKeyboardKey.enter, meta: m)),
          ]),
          PlatformMenuItemGroup(members: [
            item(S.refresh, () => refreshWithMessage(context, ref), const SingleActivator(LogicalKeyboardKey.keyR, meta: m)),
            item(S.markAllRead, _markAllVisible, const SingleActivator(LogicalKeyboardKey.keyA, meta: m, shift: true)),
          ]),
        ]),
      ],
      child: child,
    );
  }

  // ------------------------------------------------------------ compact

  Widget _compact(BuildContext context) {
    final nav = ref.watch(navProvider);
    final unread = ref.watch(unreadTodayProvider).value ?? 0;
    final tab = switch (nav.place) { Place.today || Place.archive => 0, Place.sources => 1, Place.saved => 2 };
    Widget tabNavigator(int i, Widget root) => Navigator(
          key: _tabNavigators[i],
          onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => root),
        );
    return PopScope(
      canPop: !(_tabNavigators[tab].currentState?.canPop() ?? false),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _tabNavigators[tab].currentState?.maybePop();
      },
      child: Scaffold(
        body: IndexedStack(index: tab, children: [
          tabNavigator(0, ArticleListPane(scope: const TodayScope(), title: S.today, kennung: S.todayKennung)),
          tabNavigator(
            1,
            Builder(
              builder: (context) => SourcesPane(
                onOpen: (scope, title) => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => ArticleListPane(scope: scope, title: title, kennung: (n) => '${S.sources} · $n NEU'),
                )),
              ),
            ),
          ),
          tabNavigator(2, ArticleListPane(scope: const SavedScope(), title: S.saved, kennung: S.savedKennung)),
        ]),
        bottomNavigationBar: HorizontTabBar(
          selectedIndex: tab,
          onSelected: (i) {
            if (i == tab) {
              // A second tap goes back to the tab's root, as on iOS.
              _tabNavigators[i].currentState?.popUntil((r) => r.isFirst);
              return;
            }
            HapticFeedback.selectionClick();
            ref.read(navProvider.notifier).go([Place.today, Place.sources, Place.saved][i]);
          },
          destinations: [
            HorizontDestination(icon: HorizontSymbols.today, label: S.today, badge: unread > 0 ? '$unread' : null),
            const HorizontDestination(icon: HorizontSymbols.rssFeed, label: S.sources),
            const HorizontDestination(icon: HorizontSymbols.bookmark, label: S.saved),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------- wide

  Widget _wide(BuildContext context, double width) {
    final nav = ref.watch(navProvider);
    final settings = ref.watch(settingsProvider);
    final c = HorizontTheme.of(context).colors;
    // Quellen (list or Flurkarte) take the whole width; no reader beside.
    final managing = nav.place == Place.sources && nav.scope is! FeedScope && nav.scope is! FolderScope;
    final readerBeside = width >= HzBreakpoint.expanded && !managing;
    final sidebar = settings.sidebarOpen && (width >= HzBreakpoint.expanded || !readerBeside);
    final toggle = IconButton(
      tooltip: 'Seitenleiste',
      icon: Icon(settings.sidebarOpen ? HorizontSymbols.leftPanelClose : HorizontSymbols.leftPanelOpen),
      onPressed: _toggleSidebar,
    );
    final feeds = ref.watch(feedsProvider).value ?? const <FeedRow>[];

    Widget list;
    if (managing) {
      list = SourcesPane(leading: toggle, onOpen: (scope, _) => ref.read(navProvider.notifier).show(scope));
    } else {
      final (title, kennung) = switch (nav.scope) {
        TodayScope() => (S.today, S.todayKennung),
        SavedScope() => (S.saved, S.savedKennung),
        ArchiveScope() => (S.archive, (int _) => S.archiveKennung),
        FeedScope(:final feedId) => (feeds.where((f) => f.feed.id == feedId).firstOrNull?.title ?? S.sources, (int n) => '${S.sources} · $n NEU'),
        FolderScope(:final folderId) => (
            feeds.where((f) => f.folder?.id == folderId).firstOrNull?.folder?.name ?? S.folder,
            (int n) => '${S.folder} · $n NEU',
          ),
        SearchScope() => (S.search, (int n) => '${S.search} · $n'),
      };
      list = ArticleListPane(
        key: ValueKey(nav.scope),
        scope: nav.scope,
        title: title,
        kennung: kennung,
        readerBeside: readerBeside,
        leading: toggle,
        automaticallyImplyLeading: false,
      );
    }

    return Scaffold(
      body: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (sidebar) const Sidebar(),
        if (readerBeside)
          SizedBox(
            width: HzSize.inspectorWide + HzSpace.s48,
            child: DecoratedBox(
              decoration: BoxDecoration(border: BorderDirectional(end: BorderSide(color: c.line, width: HzLine.hairline))),
              child: list,
            ),
          )
        else
          Expanded(child: list),
        if (readerBeside)
          Expanded(
            child: nav.articleId == null
                ? Scaffold(body: HorizontEmptyHint(text: S.welcomeTitle, icon: HorizontSymbols.article))
                : ReaderView(key: const ValueKey('reader'), articleId: nav.articleId!, embedded: true),
          ),
      ]),
    );
  }
}

/// The sidebar from 600: places, then the sources by folder, adding a
/// source and the settings fixed at the foot. Horizont's [HorizontSidebar]
/// draws it in the soft style; only the lockup on top is Landbote's own.
class Sidebar extends ConsumerWidget {
  /// Creates the sidebar.
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = HorizontTheme.of(context);
    final nav = ref.watch(navProvider);
    final controller = ref.read(navProvider.notifier);
    final unread = ref.watch(unreadTodayProvider).value ?? 0;
    final feeds = ref.watch(feedsProvider).value ?? const <FeedRow>[];
    final folders = ref.watch(foldersProvider).value ?? const [];
    final pointer = h.density == HorizontDensity.pointer;
    final t = Theme.of(context).textTheme;
    String? count(int n) => n > 0 ? '$n' : null;

    final byFolder = <int?, List<FeedRow>>{};
    for (final f in feeds) {
      (byFolder[f.feed.folderId] ??= []).add(f);
    }

    HorizontSidebarItem feed(FeedRow f, {int indent = 0}) => HorizontSidebarItem(
          icon: HorizontSymbols.rssFeed,
          label: f.title,
          count: count(f.unread),
          indent: indent,
          selected: nav.scope == FeedScope(f.feed.id),
          onTap: () => controller.show(FeedScope(f.feed.id)),
        );

    return HorizontSidebar(
      width: pointer ? HzSize.rail + HzSpace.s24 : HzSize.sidebar,
      // On macOS the content runs under the transparent title bar: the
      // lockup keeps clear of the window buttons.
      header: Padding(
        padding: EdgeInsets.only(top: pointer && defaultTargetPlatform == TargetPlatform.macOS ? HzSpace.s16 : 0),
        child: HorizontLockup(h.product, label: S.appName, style: t.titleMedium),
      ),
      footer: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        HorizontSidebarItem(icon: HorizontSymbols.addLink, label: S.addSource, onTap: () => showAddFeed(context)),
        HorizontSidebarItem(icon: HorizontSymbols.settings, label: S.settings, onTap: () => pushSettings(context)),
      ]),
      children: [
        HorizontSidebarItem(
          icon: HorizontSymbols.today,
          label: S.today,
          count: count(unread),
          selected: nav.place == Place.today,
          onTap: () => controller.go(Place.today),
        ),
        HorizontSidebarItem(
          icon: HorizontSymbols.bookmark,
          label: S.saved,
          selected: nav.place == Place.saved,
          onTap: () => controller.go(Place.saved),
        ),
        HorizontSidebarItem(
          icon: HorizontSymbols.archive,
          label: S.archive,
          selected: nav.place == Place.archive,
          onTap: () => controller.go(Place.archive),
        ),
        HorizontSidebarItem(
          icon: HorizontSymbols.map,
          label: S.sources,
          selected: nav.place == Place.sources && nav.scope is! FeedScope && nav.scope is! FolderScope,
          onTap: () {
            controller.show(const TodayScope());
            controller.go(Place.sources);
          },
        ),
        HorizontSidebarLabel(S.sources, count: feeds.length),
        for (final folder in folders)
          if (byFolder.containsKey(folder.id)) ...[
            HorizontSidebarItem(
              icon: HorizontSymbols.folder,
              label: folder.name,
              count: count(byFolder[folder.id]!.fold<int>(0, (a, f) => a + f.unread)),
              selected: nav.scope == FolderScope(folder.id),
              onTap: () => controller.show(FolderScope(folder.id)),
            ),
            for (final f in byFolder[folder.id]!) feed(f, indent: 1),
          ],
        for (final f in byFolder[null] ?? const <FeedRow>[]) feed(f),
      ],
    );
  }
}
