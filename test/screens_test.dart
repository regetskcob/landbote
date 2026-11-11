// Renders the main screens with the real test feeds in the three window
// classes, light and dark, as goldens to look at.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/horizont.dart';
import 'package:horizont/testing.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:landbote/app/app.dart';
import 'package:landbote/app/providers.dart';
import 'package:landbote/app/settings.dart';
import 'package:landbote/app/supporter.dart';
import 'package:landbote/data/db/database.dart';
import 'package:landbote/data/repository.dart';
import 'package:landbote/ui/nav_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

http.Client fixtureClient() => MockClient((r) async {
      final url = r.url.toString();
      if (url.contains('smnvdl.de/20')) {
        return http.Response.bytes(File('test/fixtures/smnvdl_post.html').readAsBytesSync(), 200, headers: {'content-type': 'text/html; charset=UTF-8'});
      }
      if (url.contains('smnvdl')) {
        return http.Response.bytes(File('test/fixtures/smnvdl.xml').readAsBytesSync(), 200, headers: {'content-type': 'application/rss+xml; charset=UTF-8'});
      }
      if (url.contains('regetskcob')) {
        return http.Response.bytes(File('test/fixtures/regetskcob_full.xml').readAsBytesSync(), 200, headers: {'content-type': 'application/xml'});
      }
      return http.Response('', 404);
    });

class Harness {
  Harness(this.db, this.container);
  final LandboteDatabase db;
  final ProviderContainer container;
}

Future<Harness> pumpApp(WidgetTester tester, {required Size size, Brightness brightness = Brightness.light, TargetPlatform platform = TargetPlatform.iOS}) async {
  tester.view.physicalSize = size * 2;
  tester.view.devicePixelRatio = 2;
  debugDefaultTargetPlatformOverride = platform;
  SharedPreferences.setMockInitialValues({'themeMode': brightness == Brightness.dark ? 2 : 1});
  final prefs = await SharedPreferences.getInstance();
  final db = LandboteDatabase(NativeDatabase.memory());
  final client = fixtureClient();
  final container = ProviderContainer(overrides: [
    preferencesProvider.overrideWithValue(prefs),
    databaseProvider.overrideWithValue(db),
    httpClientProvider.overrideWithValue(client),
    storeEnabledProvider.overrideWithValue(false),
  ]);
  await tester.runAsync(() async {
    final repo = container.read(repositoryProvider);
    final folder = await repo.folderNamed('Freunde');
    for (final (url, f) in [('https://smnvdl.de/rss', folder), ('https://www.regetskcob.de/index.xml', null)]) {
      final found = await repo.discover(url);
      await repo.addFeed(found.first, folderId: f);
    }
  });
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const LandboteApp()));
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
    await tester.pump(const Duration(milliseconds: 100));
  }
  return Harness(db, container);
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 8; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 60)));
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> tearDownApp(WidgetTester tester, Harness h) async {
  await tester.pumpWidget(const SizedBox());
  await tester.runAsync(() async {
    h.container.dispose();
    await h.db.close();
  });
  debugDefaultTargetPlatformOverride = null;
  tester.view.reset();
}

void main() {
  setUpAll(loadHorizontFonts);

  for (final b in Brightness.values) {
    testWidgets('phone today ${b.name}', (tester) async {
      final h = await pumpApp(tester, size: const Size(390, 844), brightness: b);
      await settle(tester);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/phone_today_${b.name}.png'));
      await tearDownApp(tester, h);
    });
  }

  testWidgets('phone reader with full text', (tester) async {
    final h = await pumpApp(tester, size: const Size(390, 844));
    await tester.tap(find.text('Kamera-Experimente in der Toskana').first);
    await settle(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/phone_reader_smnvdl.png'));
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -1500));
    await settle(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/phone_reader_smnvdl_scrolled.png'));
    await tearDownApp(tester, h);
  });

  testWidgets('phone reader regetskcob dark', (tester) async {
    final h = await pumpApp(tester, size: const Size(390, 844), brightness: Brightness.dark);
    final rows = await tester.runAsync(() => h.container.read(repositoryProvider).watchArticles(const TodayScope()).first);
    final blog = rows!.firstWhere((r) => r.feedTitle == 'regetskcob');
    await tester.tap(find.text(blog.article.title).first);
    await settle(tester);
    await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -900));
    await settle(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/phone_reader_blog_dark.png'));
    await tearDownApp(tester, h);
  });

  testWidgets('phone sources and map', (tester) async {
    final h = await pumpApp(tester, size: const Size(390, 844));
    await tester.tap(find.text('Quellen').last);
    await settle(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/phone_sources.png'));
    await tester.tap(find.byTooltip('Flurkarte'));
    await settle(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/phone_flurkarte.png'));
    await tearDownApp(tester, h);
  });

  testWidgets('phone settings', (tester) async {
    final h = await pumpApp(tester, size: const Size(390, 844));
    await tester.tap(find.text('Quellen').last);
    await settle(tester);
    await tester.tap(find.byTooltip('Einstellungen'));
    await settle(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/phone_settings.png'));
    await tearDownApp(tester, h);
  });

  testWidgets('phone supporter', (tester) async {
    final h = await pumpApp(tester, size: const Size(390, 844), brightness: Brightness.dark);
    await tester.tap(find.text('Quellen').last);
    await settle(tester);
    await tester.tap(find.byTooltip('Einstellungen'));
    await settle(tester);
    final row = find.byIcon(HorizontSymbols.volunteerActivism);
    await tester.scrollUntilVisible(row, 200, scrollable: find.byType(Scrollable).last);
    await tester.pump();
    await tester.tap(row);
    await settle(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/phone_supporter_dark.png'));
    await tearDownApp(tester, h);
  });

  testWidgets('tablet three panes', (tester) async {
    final h = await pumpApp(tester, size: const Size(1180, 820));
    final rows = await tester.runAsync(() => h.container.read(repositoryProvider).watchArticles(const TodayScope()).first);
    h.container.read(navProvider.notifier).select(rows!.first.article.id);
    await settle(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/tablet_today.png'));
    await tearDownApp(tester, h);
  });

  for (final b in Brightness.values) {
    testWidgets('mac three panes ${b.name}', (tester) async {
      final h = await pumpApp(tester, size: const Size(1440, 900), brightness: b, platform: TargetPlatform.macOS);
      final rows = await tester.runAsync(() => h.container.read(repositoryProvider).watchArticles(const TodayScope()).first);
      final smn = rows!.firstWhere((r) => r.feedTitle == 'Simons Seite');
      h.container.read(navProvider.notifier).select(smn.article.id);
      await settle(tester);
      await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/mac_today_${b.name}.png'));
      await tearDownApp(tester, h);
    });
  }

  testWidgets('mac flurkarte and harvest', (tester) async {
    final h = await pumpApp(tester, size: const Size(1440, 900), platform: TargetPlatform.macOS);
    await tester.runAsync(() => h.container.read(supporterProvider.notifier).unlockForTesting());
    h.container.read(navProvider.notifier).go(Place.sources);
    await h.container.read(settingsProvider.notifier).update((s) => s.copyWith(sourcesAsMap: true));
    await settle(tester);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/mac_flurkarte.png'));
    await tearDownApp(tester, h);
  });
}
