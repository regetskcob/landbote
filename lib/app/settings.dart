/// The person's settings, stored in SharedPreferences and read before the
/// first frame so the theme does not flash.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// How images in articles load.
enum ImageLoading {
  /// Always.
  always,

  /// Only after a tap.
  onDemand,
}

/// The reading font (Förderpaket).
enum ReaderFont {
  /// Literata, the default: what one reads.
  literata,

  /// Mona Sans.
  mona,
}

/// Line spacing of the reader (Förderpaket).
enum ReaderSpacing {
  /// Line height 1.4.
  tight(1.4),

  /// Line height of the token `reading` (28/18).
  normal(28 / 18),

  /// Line height 1.8.
  wide(1.8);

  const ReaderSpacing(this.height);

  /// The line height factor.
  final double height;
}

/// All settings, immutable.
@immutable
class Settings {
  /// Creates settings; defaults are the free, calm configuration.
  const Settings({
    this.themeMode = ThemeMode.system,
    this.harvestDays = 14,
    this.bundleThreshold = 6,
    this.images = ImageLoading.always,
    this.openInApp = true,
    this.refreshMinutes = 60,
    this.unreadOnly = false,
    this.sidebarOpen = true,
    this.readerFont = ReaderFont.literata,
    this.readerScale = 1.0,
    this.readerSpacing = ReaderSpacing.normal,
    this.justify = false,
    this.morningEnabled = false,
    this.morningMinutes = 7 * 60,
    this.sourcesAsMap = false,
  });

  /// Light, dark or system.
  final ThemeMode themeMode;

  /// After how many days unread articles leave Heute.
  final int harvestDays;

  /// From how many unread articles a feed is bundled into one line.
  final int bundleThreshold;

  /// How article images load.
  final ImageLoading images;

  /// Whether links open in the in-app browser.
  final bool openInApp;

  /// Background refresh interval; 0 is off.
  final int refreshMinutes;

  /// Whether lists show unread only.
  final bool unreadOnly;

  /// Whether the sidebar is open (from 600 wide).
  final bool sidebarOpen;

  /// Förderpaket: reading font.
  final ReaderFont readerFont;

  /// Förderpaket: size factor on top of the system text size.
  final double readerScale;

  /// Förderpaket: line spacing.
  final ReaderSpacing readerSpacing;

  /// Förderpaket: justified text.
  final bool justify;

  /// Förderpaket: morning edition on.
  final bool morningEnabled;

  /// Förderpaket: morning edition time, minutes after midnight.
  final int morningMinutes;

  /// Whether Quellen shows the Flurkarte instead of the list.
  final bool sourcesAsMap;

  /// A copy with the given fields replaced.
  Settings copyWith({
    ThemeMode? themeMode,
    int? harvestDays,
    int? bundleThreshold,
    ImageLoading? images,
    bool? openInApp,
    int? refreshMinutes,
    bool? unreadOnly,
    bool? sidebarOpen,
    ReaderFont? readerFont,
    double? readerScale,
    ReaderSpacing? readerSpacing,
    bool? justify,
    bool? morningEnabled,
    int? morningMinutes,
    bool? sourcesAsMap,
  }) =>
      Settings(
        themeMode: themeMode ?? this.themeMode,
        harvestDays: harvestDays ?? this.harvestDays,
        bundleThreshold: bundleThreshold ?? this.bundleThreshold,
        images: images ?? this.images,
        openInApp: openInApp ?? this.openInApp,
        refreshMinutes: refreshMinutes ?? this.refreshMinutes,
        unreadOnly: unreadOnly ?? this.unreadOnly,
        sidebarOpen: sidebarOpen ?? this.sidebarOpen,
        readerFont: readerFont ?? this.readerFont,
        readerScale: readerScale ?? this.readerScale,
        readerSpacing: readerSpacing ?? this.readerSpacing,
        justify: justify ?? this.justify,
        morningEnabled: morningEnabled ?? this.morningEnabled,
        morningMinutes: morningMinutes ?? this.morningMinutes,
        sourcesAsMap: sourcesAsMap ?? this.sourcesAsMap,
      );

  /// Reads settings from [p].
  static Settings read(SharedPreferences p) => Settings(
        themeMode: ThemeMode.values[(p.getInt('themeMode') ?? 0).clamp(0, 2)],
        harvestDays: p.getInt('harvestDays') ?? 14,
        bundleThreshold: p.getInt('bundleThreshold') ?? 6,
        images: ImageLoading.values[(p.getInt('images') ?? 0).clamp(0, 1)],
        openInApp: p.getBool('openInApp') ?? true,
        refreshMinutes: p.getInt('refreshMinutes') ?? 60,
        unreadOnly: p.getBool('unreadOnly') ?? false,
        sidebarOpen: p.getBool('sidebarOpen') ?? true,
        readerFont: ReaderFont.values[(p.getInt('readerFont') ?? 0).clamp(0, 1)],
        readerScale: p.getDouble('readerScale') ?? 1.0,
        readerSpacing: ReaderSpacing.values[(p.getInt('readerSpacing') ?? 1).clamp(0, 2)],
        justify: p.getBool('justify') ?? false,
        morningEnabled: p.getBool('morningEnabled') ?? false,
        morningMinutes: p.getInt('morningMinutes') ?? 7 * 60,
        sourcesAsMap: p.getBool('sourcesAsMap') ?? false,
      );

  /// Writes all settings to [p].
  Future<void> write(SharedPreferences p) async {
    await p.setInt('themeMode', themeMode.index);
    await p.setInt('harvestDays', harvestDays);
    await p.setInt('bundleThreshold', bundleThreshold);
    await p.setInt('images', images.index);
    await p.setBool('openInApp', openInApp);
    await p.setInt('refreshMinutes', refreshMinutes);
    await p.setBool('unreadOnly', unreadOnly);
    await p.setBool('sidebarOpen', sidebarOpen);
    await p.setInt('readerFont', readerFont.index);
    await p.setDouble('readerScale', readerScale);
    await p.setInt('readerSpacing', readerSpacing.index);
    await p.setBool('justify', justify);
    await p.setBool('morningEnabled', morningEnabled);
    await p.setInt('morningMinutes', morningMinutes);
    await p.setBool('sourcesAsMap', sourcesAsMap);
  }
}

/// The preferences instance, created in `main()` before `runApp`.
final preferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('preferencesProvider is overridden in main()'),
);

/// The settings; [SettingsController.update] is the only write path.
final settingsProvider = NotifierProvider<SettingsController, Settings>(SettingsController.new);

/// Holds and persists [Settings].
class SettingsController extends Notifier<Settings> {
  @override
  Settings build() => Settings.read(ref.watch(preferencesProvider));

  /// Applies [change] and persists the result.
  Future<void> update(Settings Function(Settings) change) async {
    state = change(state);
    await state.write(ref.read(preferencesProvider));
  }
}
