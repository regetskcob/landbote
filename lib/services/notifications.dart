/// The Morgenausgabe: one local notification a day at the chosen time,
/// rescheduled after every refresh with what is new. Nothing leaves the
/// device; there is no push server.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/repository.dart';
import '../l10n/strings.dart';

/// The notification service.
class MorningEdition {
  MorningEdition._();

  /// The one instance.
  static final instance = MorningEdition._();

  static const _id = 7;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  bool get _supported => !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.macOS);

  Future<void> _init() async {
    if (_ready || !_supported) return;
    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } on Exception {
      tz.setLocalLocation(tz.getLocation('Europe/Berlin'));
    }
    const darwin = DarwinInitializationSettings(requestAlertPermission: false, requestBadgePermission: false, requestSoundPermission: false);
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: darwin,
        macOS: darwin,
      ),
    );
    _ready = true;
  }

  /// Asks for permission; true when granted.
  Future<bool> requestPermission() async {
    if (!_supported) return false;
    await _init();
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final mac = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await ios?.requestPermissions(alert: true) ?? await mac?.requestPermissions(alert: true) ?? await android?.requestNotificationsPermission() ?? false;
    return granted;
  }

  /// Schedules (or cancels) the next morning edition with the current count.
  Future<void> reschedule({required bool enabled, required int minutes, required FeedRepository repo}) async {
    if (!_supported) return;
    await _init();
    await _plugin.cancel(id: _id);
    if (!enabled) return;
    final unread = await repo.watchArticles(const TodayScope(), unreadOnly: true).first;
    if (unread.isEmpty) return;
    final feeds = unread.map((r) => r.article.feedId).toSet().length;
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(tz.local, now.year, now.month, now.day, minutes ~/ 60, minutes % 60);
    if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: _id,
      title: S.morningTitle,
      body: S.morningBody(unread.length, feeds),
      scheduledDate: at,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails('morning', S.morningEdition, importance: Importance.low, priority: Priority.low),
        iOS: DarwinNotificationDetails(presentSound: false),
        macOS: DarwinNotificationDetails(presentSound: false),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
