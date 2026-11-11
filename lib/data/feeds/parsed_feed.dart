/// The format-neutral result of parsing a feed document.
library;

import 'package:flutter/foundation.dart';

/// A parsed feed: channel metadata and its items, newest first as published.
@immutable
class ParsedFeed {
  /// Creates a parsed feed.
  const ParsedFeed({
    required this.title,
    required this.items,
    this.siteUrl,
    this.iconUrl,
    this.description,
    this.selfUrl,
  });

  /// The channel title, never empty (falls back to the host).
  final String title;

  /// The web page the feed belongs to.
  final String? siteUrl;

  /// A small image of the channel, if the feed names one.
  final String? iconUrl;

  /// The channel description as plain text.
  final String? description;

  /// The canonical URL of the feed itself (`atom:link rel="self"`).
  final String? selfUrl;

  /// The items in document order.
  final List<ParsedItem> items;
}

/// One entry of a feed.
@immutable
class ParsedItem {
  /// Creates a parsed item.
  const ParsedItem({
    required this.guid,
    required this.title,
    this.url,
    this.author,
    this.summaryHtml,
    this.contentHtml,
    this.imageUrl,
    this.published,
    this.categories = const [],
  });

  /// A stable identity within its feed: guid/id, else the link, else a hash.
  final String guid;

  /// The headline as plain text; may be empty for title-less posts.
  final String title;

  /// The permalink, absolute.
  final String? url;

  /// The author's name.
  final String? author;

  /// The short description (RSS `description`, Atom `summary`), HTML.
  final String? summaryHtml;

  /// The full content (`content:encoded`, Atom `content`), HTML.
  final String? contentHtml;

  /// A lead image for the list thumbnail, absolute.
  final String? imageUrl;

  /// When the item was published, in UTC.
  final DateTime? published;

  /// Tags or categories.
  final List<String> categories;
}
