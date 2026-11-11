/// The Förderpaket: one non-consumable in-app purchase (2,99 €) that unlocks
/// Lesestil, Jahresernte and Morgenausgabe. Everything else is free.
///
/// The app is open source; anyone may build it with the pack unlocked. The
/// purchase is a thank-you, not a lock.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'settings.dart';

/// The store product id, the same in App Store Connect and Play Console.
const supporterProductId = 'de.regetskcob.landbote.foerderpaket';

/// The entitlement state.
@immutable
class SupporterState {
  /// Creates the state.
  const SupporterState({this.unlocked = false, this.since, this.price, this.available = false, this.busy = false, this.message});

  /// Whether the pack is unlocked.
  final bool unlocked;

  /// When it was bought, local.
  final DateTime? since;

  /// The localized store price, e.g. "2,99 €".
  final String? price;

  /// Whether the store answered and offers the product.
  final bool available;

  /// Whether a purchase or restore runs.
  final bool busy;

  /// A sentence for the UI after a store event.
  final String? message;

  /// A copy with fields replaced.
  SupporterState copyWith({bool? unlocked, DateTime? since, String? price, bool? available, bool? busy, String? message}) => SupporterState(
        unlocked: unlocked ?? this.unlocked,
        since: since ?? this.since,
        price: price ?? this.price,
        available: available ?? this.available,
        busy: busy ?? this.busy,
        message: message,
      );
}

/// Whether the store is used at all; off in tests and on platforms without one.
final storeEnabledProvider = Provider<bool>((ref) => defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.macOS);

/// The Förderpaket.
final supporterProvider = NotifierProvider<SupporterController, SupporterState>(SupporterController.new);

/// The only gate: whether a supporter feature may be used.
final isSupporterProvider = Provider<bool>((ref) => ref.watch(supporterProvider.select((s) => s.unlocked)));

/// Talks to the store and keeps the entitlement.
class SupporterController extends Notifier<SupporterState> {
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _product;

  static const _key = 'supporter.since';

  @override
  SupporterState build() {
    final since = ref.read(preferencesProvider).getInt(_key);
    ref.onDispose(() => _sub?.cancel());
    final initial = SupporterState(
      unlocked: since != null,
      since: since == null ? null : DateTime.fromMillisecondsSinceEpoch(since),
    );
    if (ref.read(storeEnabledProvider)) unawaited(_connect());
    return initial;
  }

  Future<void> _connect() async {
    final iap = InAppPurchase.instance;
    try {
      if (!await iap.isAvailable()) return;
      _sub = iap.purchaseStream.listen(_onPurchases, onError: (Object _) {
        state = state.copyWith(busy: false, message: 'failed');
      });
      final response = await iap.queryProductDetails({supporterProductId});
      _product = response.productDetails.firstOrNull;
      state = state.copyWith(available: _product != null, price: _product?.price);
    } on Exception {
      // No store (simulator without account, desktop builds): stay as is.
    }
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != supporterProductId) continue;
      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _unlock();
        case PurchaseStatus.pending:
          state = state.copyWith(busy: true, message: 'pending');
        case PurchaseStatus.error:
          state = state.copyWith(busy: false, message: 'failed');
        case PurchaseStatus.canceled:
          state = state.copyWith(busy: false);
      }
      if (p.pendingCompletePurchase) await InAppPurchase.instance.completePurchase(p);
    }
  }

  Future<void> _unlock() async {
    final p = ref.read(preferencesProvider);
    final existing = p.getInt(_key);
    final since = existing == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(existing);
    if (existing == null) await p.setInt(_key, since.millisecondsSinceEpoch);
    state = state.copyWith(unlocked: true, since: since, busy: false, message: 'thanks');
  }

  /// Starts the purchase.
  Future<void> buy() async {
    final product = _product;
    if (product == null) {
      state = state.copyWith(message: 'unavailable');
      return;
    }
    state = state.copyWith(busy: true);
    try {
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
    } on Exception {
      state = state.copyWith(busy: false, message: 'failed');
    }
  }

  /// Restores an earlier purchase.
  Future<void> restore() async {
    if (!ref.read(storeEnabledProvider)) return;
    state = state.copyWith(busy: true);
    try {
      await InAppPurchase.instance.restorePurchases();
    } on Exception {
      state = state.copyWith(message: 'unavailable');
    } finally {
      // The stream reports restored items; without any, stop the spinner.
      Future<void>.delayed(const Duration(seconds: 8), () {
        if (state.busy) state = state.copyWith(busy: false);
      });
    }
  }

  /// Unlocks without the store: for own builds and tests (the app is open
  /// source, a build flag is honest about that).
  @visibleForTesting
  Future<void> unlockForTesting() => _unlock();
}
