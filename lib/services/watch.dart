/// The bridge to the Apple Watch app: Heute goes over, "Später lesen" comes
/// back. On other platforms nothing happens.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/repository.dart';

const _channel = MethodChannel('landbote/watch');

bool get _ios => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// Sends the unread count and the three newest headlines to the watch.
Future<void> updateWatch(int unread, List<ArticleRow> top) async {
  if (!_ios) return;
  try {
    await _channel.invokeMethod<void>('update', {
      'unread': unread,
      'titles': [for (final r in top) r.article.title],
      'sources': [for (final r in top) r.feedTitle],
      'ids': [for (final r in top) r.article.id],
      'at': DateTime.now().millisecondsSinceEpoch,
    });
  } on MissingPluginException {
    // Background isolate or no watch support: nothing to do.
  } on PlatformException {
    // The watch is optional.
  }
}

/// Lets the watch save an article for later.
void listenToWatch(FeedRepository repo) {
  if (!_ios) return;
  _channel.setMethodCallHandler((call) async {
    if (call.method == 'save' && call.arguments is int) await repo.setSaved(call.arguments as int, true);
  });
}
