/// Data for the home screen widgets ("Heute") on iOS and Android and for the
/// watch: the unread count and the three newest headlines, written to the
/// shared app group; the native widgets only read.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../data/repository.dart';
import 'watch.dart';

/// The app group shared with the widget extension and the watch app.
const appGroup = 'group.de.regetskcob.landbote';

/// The iOS widget kind and the Android provider class.
const iosWidget = 'LandboteHeute';

/// See [iosWidget].
const androidWidget = 'de.regetskcob.landbote.HeuteWidgetProvider';

bool get _supported => !kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);

/// Writes the current Heute to the widgets and asks them to redraw.
Future<void> updateHomeWidgets(FeedRepository repo) async {
  if (!_supported) return;
  try {
    await HomeWidget.setAppGroupId(appGroup);
    final unread = await repo.watchArticles(const TodayScope(), unreadOnly: true, limit: 50).first;
    await updateWatch(unread.length, unread.take(3).toList());
    final top = [
      for (final r in unread.take(3)) {'title': r.article.title, 'source': r.feedTitle, 'id': r.article.id},
    ];
    await HomeWidget.saveWidgetData<int>('unread', unread.length);
    await HomeWidget.saveWidgetData<String>('top', jsonEncode(top));
    await HomeWidget.saveWidgetData<int>('updated', DateTime.now().millisecondsSinceEpoch);
    await HomeWidget.updateWidget(iOSName: iosWidget, qualifiedAndroidName: androidWidget);
  } on Exception {
    // A missing widget extension must never break a refresh.
  }
}
