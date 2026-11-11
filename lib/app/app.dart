/// The app: Horizont's theme for Landbote in light and dark, the shell.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../l10n/strings.dart';
import '../ui/shell.dart';
import 'settings.dart';

/// The root widget.
class LandboteApp extends ConsumerWidget {
  /// Creates the app.
  const LandboteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    return MaterialApp(
      title: S.appName,
      debugShowCheckedModeBanner: false,
      theme: buildHorizontTheme(HorizontProduct.landbote, Brightness.light),
      darkTheme: buildHorizontTheme(HorizontProduct.landbote, Brightness.dark),
      themeMode: mode,
      themeAnimationStyle: AnimationStyle.noAnimation,
      locale: const Locale('de'),
      supportedLocales: const [Locale('de')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const Shell(),
    );
  }
}
