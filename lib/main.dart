/// Landbote, a RSS reader on Horizont.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'app/settings.dart';
import 'services/background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught: $error\n$stack');
    return true;
  };
  registerHorizontLicenses();
  final prefs = await SharedPreferences.getInstance();
  final db = openDatabase();
  final settings = Settings.read(prefs);
  await initBackground();
  unawaited(scheduleBackgroundRefresh(settings.refreshMinutes));
  runApp(ProviderScope(
    overrides: [
      preferencesProvider.overrideWithValue(prefs),
      databaseProvider.overrideWithValue(db),
    ],
    child: const LandboteApp(),
  ));
}
