/// Background refresh: Workmanager on Android, BGTaskScheduler (through
/// Workmanager) on iOS, a timer while the app runs on macOS.
library;

import 'dart:async';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../app/settings.dart';
import '../data/db/database.dart';
import '../data/feeds/fetcher.dart';
import '../data/repository.dart';
import 'home_widget.dart';
import 'notifications.dart';

/// The task name; on iOS also the BGTaskScheduler identifier in Info.plist.
const refreshTask = 'de.regetskcob.landbote.refresh';

bool get _mobile => !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);

/// Opens the app's database (also from the background isolate).
LandboteDatabase openDatabase() => LandboteDatabase(driftDatabase(name: 'landbote'));

/// The entry point of the background isolate.
@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((task, input) async {
    WidgetsFlutterBinding.ensureInitialized();
    final db = openDatabase();
    final client = http.Client();
    try {
      final prefs = await SharedPreferences.getInstance();
      final settings = Settings.read(prefs);
      final repo = FeedRepository(db, Fetcher(client));
      await repo.refreshAll();
      await repo.harvest(days: settings.harvestDays);
      await updateHomeWidgets(repo);
      if (prefs.getInt('supporter.since') != null) {
        await MorningEdition.instance.reschedule(enabled: settings.morningEnabled, minutes: settings.morningMinutes, repo: repo);
      }
      return true;
    } on Exception {
      return false;
    } finally {
      client.close();
      await db.close();
    }
  });
}

/// Initializes the background machinery once in `main()`.
Future<void> initBackground() async {
  if (!_mobile) return;
  await Workmanager().initialize(backgroundDispatcher);
}

/// Schedules the periodic refresh every [minutes]; 0 cancels it. The system
/// decides the exact time; iOS treats the interval as a lower bound.
Future<void> scheduleBackgroundRefresh(int minutes) async {
  if (!_mobile) return;
  final wm = Workmanager();
  await wm.cancelByUniqueName(refreshTask);
  if (minutes <= 0) return;
  await wm.registerPeriodicTask(
    refreshTask,
    refreshTask,
    frequency: Duration(minutes: minutes < 15 ? 15 : minutes),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
  );
}

/// While the desktop app runs, refreshes every [minutes] with [refresh].
Timer? desktopRefreshTimer(int minutes, Future<void> Function() refresh) {
  if (_mobile || minutes <= 0) return null;
  return Timer.periodic(Duration(minutes: minutes), (_) => unawaited(refresh()));
}
