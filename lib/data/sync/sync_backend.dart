/// The common surface of the sync servers Landbote speaks to.
library;

import 'package:flutter/foundation.dart';

/// Which kind of server an account is.
enum SyncKind {
  /// FreshRSS through its Google Reader API (also Inoreader-compatible
  /// servers such as The Old Reader).
  freshRss('FreshRSS'),

  /// Miniflux through its REST API with an API token.
  miniflux('Miniflux'),

  /// Nextcloud News through API v1-3 with user and password.
  nextcloud('Nextcloud News');

  const SyncKind(this.label);

  /// The product name, shown as is.
  final String label;
}

/// A subscription on the server.
@immutable
class RemoteFeed {
  /// Creates a remote feed.
  const RemoteFeed({required this.id, required this.url, required this.title, this.siteUrl, this.folder});

  /// The server's id.
  final String id;

  /// The feed URL.
  final String url;

  /// The title.
  final String title;

  /// The web page.
  final String? siteUrl;

  /// The folder or category name.
  final String? folder;
}

/// An article on the server.
@immutable
class RemoteItem {
  /// Creates a remote item.
  const RemoteItem({
    required this.id,
    required this.feedId,
    required this.title,
    required this.read,
    required this.starred,
    this.url,
    this.author,
    this.html,
    this.published,
    this.imageUrl,
  });

  /// The server's id, normalized to a decimal string where servers differ.
  final String id;

  /// The server's feed id.
  final String feedId;

  /// The headline.
  final String title;

  /// The permalink.
  final String? url;

  /// The author.
  final String? author;

  /// The content.
  final String? html;

  /// The publication date, UTC.
  final DateTime? published;

  /// Whether it is read on the server.
  final bool read;

  /// Whether it is starred on the server.
  final bool starred;

  /// An image enclosure.
  final String? imageUrl;
}

/// A failed sync call. [message] is technical.
class SyncException implements Exception {
  /// Creates the exception.
  const SyncException(this.message, {this.unauthorized = false});

  /// What went wrong.
  final String message;

  /// Whether the server refused the credentials.
  final bool unauthorized;

  @override
  String toString() => 'SyncException: $message';
}

/// One sync server.
abstract interface class SyncBackend {
  /// Signs in or checks the credentials. Throws [SyncException].
  Future<void> login();

  /// All subscriptions.
  Future<List<RemoteFeed>> feeds();

  /// Articles published or changed after [since] (or the recent ones).
  Future<List<RemoteItem>> items({DateTime? since});

  /// Ids of all unread articles.
  Future<Set<String>> unreadIds();

  /// Ids of all starred articles.
  Future<Set<String>> starredIds();

  /// Marks [ids] read or unread.
  Future<void> setRead(List<String> ids, {required bool read});

  /// Stars or unstars [ids].
  Future<void> setStarred(List<String> ids, {required bool starred});

  /// Subscribes to [url]; returns the new feed id.
  Future<String?> subscribe(String url);

  /// Unsubscribes from feed [id].
  Future<void> unsubscribe(String id);
}
