/// Where the person is: tab, list scope, selected article. One write path.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repository.dart';

/// The top-level places (tabs on the phone, sidebar entries from 600).
enum Place {
  /// Heute.
  today,

  /// Quellen (list or Flurkarte).
  sources,

  /// Gemerkt.
  saved,

  /// Archiv (sidebar only).
  archive,
}

/// The navigation state.
@immutable
class NavState {
  /// Creates the state.
  const NavState({this.place = Place.today, this.scope = const TodayScope(), this.articleId, this.expanded = const {}, this.search});

  /// The selected place.
  final Place place;

  /// The list shown (in wide layouts; on the phone lists are pushed).
  final ArticleScope scope;

  /// The article in the reader pane.
  final int? articleId;

  /// Opened bundles.
  final Set<int> expanded;

  /// The search text, if a search is open.
  final String? search;

  /// A copy.
  NavState copyWith({Place? place, ArticleScope? scope, int? Function()? articleId, Set<int>? expanded, String? Function()? search}) => NavState(
        place: place ?? this.place,
        scope: scope ?? this.scope,
        articleId: articleId == null ? this.articleId : articleId(),
        expanded: expanded ?? this.expanded,
        search: search == null ? this.search : search(),
      );
}

/// The navigation.
final navProvider = NotifierProvider<NavController, NavState>(NavController.new);

/// See [navProvider].
class NavController extends Notifier<NavState> {
  @override
  NavState build() => const NavState();

  /// Goes to [place] with its default list.
  void go(Place place) {
    final scope = switch (place) {
      Place.today => const TodayScope(),
      Place.saved => const SavedScope(),
      Place.archive => const ArchiveScope(),
      Place.sources => state.scope,
    };
    state = state.copyWith(place: place, scope: scope, articleId: () => null, search: () => null);
  }

  /// Shows the list of [scope] (a feed or folder, in Quellen).
  void show(ArticleScope scope) => state = state.copyWith(place: Place.sources, scope: scope, articleId: () => null, search: () => null);

  /// Selects article [id] for the reader pane.
  void select(int? id) => state = state.copyWith(articleId: () => id);

  /// Opens or closes the bundle of feed [feedId].
  void toggleBundle(int feedId) {
    final s = {...state.expanded};
    if (!s.remove(feedId)) s.add(feedId);
    state = state.copyWith(expanded: s);
  }

  /// Sets the search text; null closes the search.
  void search(String? text) => state = state.copyWith(search: () => text);
}

/// The ids of the list currently shown, in order: next/previous read here.
final visibleOrderProvider = NotifierProvider<VisibleOrder, List<int>>(VisibleOrder.new);

/// See [visibleOrderProvider].
class VisibleOrder extends Notifier<List<int>> {
  @override
  List<int> build() => const [];

  /// Replaces the order when it changed.
  void set(List<int> ids) {
    if (!listEquals(ids, state)) state = ids;
  }

  /// The article after [id], or null.
  int? after(int id) {
    final i = state.indexOf(id);
    return i < 0 || i + 1 >= state.length ? null : state[i + 1];
  }

  /// The article before [id], or null.
  int? before(int id) {
    final i = state.indexOf(id);
    return i <= 0 ? null : state[i - 1];
  }
}
