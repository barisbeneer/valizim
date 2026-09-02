import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../config/app_config.dart';
import 'entitlement_store.dart';

/// Result of the most recent purchase or restore attempt, as the UI needs to
/// describe it. An enum rather than a message so all copy stays localized.
enum PurchaseOutcome {
  none,
  pending,
  purchased,
  restored,
  cancelled,
  failed,
  nothingToRestore,
  storeUnavailable,
}

/// Observable purchase state.
@immutable
class PurchaseState {
  const PurchaseState({
    this.isPro = false,
    this.storeAvailable = false,
    this.loadingProducts = false,
    this.purchaseInFlight = false,
    this.product,
    this.outcome = PurchaseOutcome.none,
  });

  /// Entitlement as the app believes it, cache included. Drives every gate.
  final bool isPro;

  final bool storeAvailable;
  final bool loadingProducts;

  /// A buy or restore is running: the paywall's buttons stay disabled.
  final bool purchaseInFlight;

  /// Localized title and price straight from the store. Never hard-coded.
  final ProductDetails? product;

  final PurchaseOutcome outcome;

  /// Store price string, or null while it is not known.
  String? get formattedPrice => product?.price;

  PurchaseState copyWith({
    bool? isPro,
    bool? storeAvailable,
    bool? loadingProducts,
    bool? purchaseInFlight,
    ProductDetails? product,
    PurchaseOutcome? outcome,
  }) {
    return PurchaseState(
      isPro: isPro ?? this.isPro,
      storeAvailable: storeAvailable ?? this.storeAvailable,
      loadingProducts: loadingProducts ?? this.loadingProducts,
      purchaseInFlight: purchaseInFlight ?? this.purchaseInFlight,
      product: product ?? this.product,
      outcome: outcome ?? this.outcome,
    );
  }
}

/// Owns the StoreKit conversation.
///
/// **Verification posture.** v1 has no backend, so entitlement is decided on
/// device from what StoreKit reports. Apple and Google both recommend
/// server-side receipt verification; a jailbroken or instrumented device can
/// defeat client-side checks. This is a deliberate, documented trade-off for a
/// one-time unlock on a local-only app (spec section 7) - see README,
/// "Purchase verification". Revisit if revenue justifies a verification server.
class PurchaseService extends ChangeNotifier {
  PurchaseService({
    required EntitlementStore entitlements,
    InAppPurchase? iap,
  })  :
        // A named parameter cannot bind to a private field, so an
        // initializing formal is not available here.
        // ignore: prefer_initializing_formals
        _entitlements = entitlements,
        _injectedIap = iap {
    _state = PurchaseState(isPro: _entitlements.isPro);
  }

  final EntitlementStore _entitlements;
  final InAppPurchase? _injectedIap;
  InAppPurchase? _resolvedIap;

  /// Resolved on first use rather than in the constructor.
  ///
  /// `InAppPurchase.instance` reaches for the platform implementation, which is
  /// not available in a widget test. Deferring it means a screen that merely
  /// reads the cached entitlement - which is every screen except the paywall -
  /// can be tested without a store at all.
  InAppPurchase get _iap => _resolvedIap ??= _injectedIap ?? InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  late PurchaseState _state;
  bool _disposed = false;

  PurchaseState get state => _state;

  bool get isPro => _state.isPro;

  /// Connects to the store and loads the product.
  ///
  /// Failure here is never fatal: the app is fully usable offline, and a cached
  /// Pro entitlement survives a store that cannot be reached.
  Future<void> initialize() async {
    _subscription ??= _iap.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object error, StackTrace stack) {
        _emit(_state.copyWith(
          purchaseInFlight: false,
          outcome: PurchaseOutcome.failed,
        ));
      },
    );

    final available = await _iap.isAvailable();
    _emit(_state.copyWith(storeAvailable: available));
    if (!available) return;

    await refreshProducts();
  }

  Future<void> refreshProducts() async {
    _emit(_state.copyWith(loadingProducts: true));
    try {
      final response =
          await _iap.queryProductDetails(AppConfig.storeProductIds);
      final product = response.productDetails
          .where((ProductDetails p) => p.id == AppConfig.proProductId)
          .firstOrNull;
      _emit(_state.copyWith(loadingProducts: false, product: product));
    } on Object {
      _emit(_state.copyWith(loadingProducts: false));
    }
  }

  /// Starts a non-consumable purchase. Returns false when there is nothing to
  /// buy, so the caller can show the right message instead of a dead button.
  Future<bool> buyPro() async {
    final product = _state.product;
    if (product == null || !_state.storeAvailable) {
      _emit(_state.copyWith(outcome: PurchaseOutcome.storeUnavailable));
      return false;
    }
    _emit(_state.copyWith(
      purchaseInFlight: true,
      outcome: PurchaseOutcome.none,
    ));
    try {
      // Non-consumable: bought once, restorable forever.
      return await _iap.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } on Object {
      _emit(_state.copyWith(
        purchaseInFlight: false,
        outcome: PurchaseOutcome.failed,
      ));
      return false;
    }
  }

  /// Restore Purchases. Apple requires this to be reachable from the paywall.
  Future<void> restore() async {
    if (!_state.storeAvailable) {
      _emit(_state.copyWith(outcome: PurchaseOutcome.storeUnavailable));
      return;
    }
    _emit(_state.copyWith(
      purchaseInFlight: true,
      outcome: PurchaseOutcome.none,
    ));
    _restoredAnything = false;
    try {
      await _iap.restorePurchases();
      // StoreKit answers on the purchase stream. If nothing arrives within a
      // short window there is nothing to restore, and the user needs to be told
      // that rather than left watching a spinner.
      Timer(const Duration(seconds: 6), () {
        if (_disposed || !_state.purchaseInFlight) return;
        _emit(_state.copyWith(
          purchaseInFlight: false,
          outcome: _restoredAnything
              ? PurchaseOutcome.restored
              : PurchaseOutcome.nothingToRestore,
        ));
      });
    } on Object {
      _emit(_state.copyWith(
        purchaseInFlight: false,
        outcome: PurchaseOutcome.failed,
      ));
    }
  }

  bool _restoredAnything = false;

  /// Clears the acknowledged outcome so a message is not shown twice.
  void acknowledgeOutcome() {
    if (_state.outcome == PurchaseOutcome.none) return;
    _emit(_state.copyWith(outcome: PurchaseOutcome.none));
  }

  /// Test and debug hook for flipping entitlement without the store.
  @visibleForTesting
  Future<void> setProForTesting({required bool value}) async {
    await _entitlements.setPro(value: value);
    _emit(_state.copyWith(isPro: value));
  }

  /// Wipes the cached entitlement. Only called from "delete all app data";
  /// the purchase itself lives on in the user's Apple Account and comes back
  /// through Restore Purchases.
  Future<void> clearCachedEntitlement() async {
    await _entitlements.setPro(value: false);
    _emit(_state.copyWith(isPro: false));
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != AppConfig.proProductId) {
        // Not ours, but StoreKit still needs it acknowledged or it is
        // re-delivered on every launch.
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        continue;
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _emit(_state.copyWith(
            purchaseInFlight: true,
            outcome: PurchaseOutcome.pending,
          ));

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final restored = purchase.status == PurchaseStatus.restored;
          _restoredAnything = _restoredAnything || restored;
          await _entitlements.setPro(value: true);
          _emit(_state.copyWith(
            isPro: true,
            purchaseInFlight: false,
            outcome: restored
                ? PurchaseOutcome.restored
                : PurchaseOutcome.purchased,
          ));

        case PurchaseStatus.canceled:
          _emit(_state.copyWith(
            purchaseInFlight: false,
            outcome: PurchaseOutcome.cancelled,
          ));

        case PurchaseStatus.error:
          _emit(_state.copyWith(
            purchaseInFlight: false,
            outcome: PurchaseOutcome.failed,
          ));
      }

      // Always complete, including on error: an uncompleted transaction is
      // replayed on every launch and blocks the queue.
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  void _emit(PurchaseState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
  }
}
