import 'dart:async';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/store/data/store_repository.dart';
import 'package:mquiz/features/store/models/coin_pack_model.dart';

sealed class StoreState extends Equatable {
  const StoreState();
  @override
  List<Object?> get props => const [];
}

final class StoreInitial extends StoreState {
  const StoreInitial();
}

final class StoreLoading extends StoreState {
  const StoreLoading();
}

final class StoreLoaded extends StoreState {
  const StoreLoaded({
    required this.packs,
    required this.balance,
    this.purchasingId,
  });
  final List<CoinPack> packs;
  final int balance;
  final String? purchasingId;

  StoreLoaded copyWith({
    List<CoinPack>? packs,
    int? balance,
    String? purchasingId,
    bool clearPurchasing = false,
  }) =>
      StoreLoaded(
        packs: packs ?? this.packs,
        balance: balance ?? this.balance,
        purchasingId:
            clearPurchasing ? null : (purchasingId ?? this.purchasingId),
      );

  @override
  List<Object?> get props => [packs, balance, purchasingId];
}

final class StoreError extends StoreState {
  const StoreError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class StorePurchaseEvent extends Equatable {
  const StorePurchaseEvent({
    required this.success,
    required this.coinsCredited,
    this.message,
  });
  final bool success;
  final int coinsCredited;
  final String? message;
  @override
  List<Object?> get props => [success, coinsCredited, message];
}

class StoreCubit extends Cubit<StoreState> {
  StoreCubit(this._repo) : super(const StoreInitial());
  final StoreRepository _repo;

  Future<void> load() async {
    emit(const StoreLoading());
    try {
      final results = await Future.wait([
        _repo.fetchCoinStore(),
        _repo.fetchBalance(),
      ]);
      emit(StoreLoaded(
        packs: results[0] as List<CoinPack>,
        balance: results[1] as int,
      ));
    } catch (e) {
      emit(StoreError(describeError(e)));
    }
  }

  /// Initializes a payment. Returns the authorization URL the caller must
  /// open in an in-app browser. The server is the only authority for crediting.
  Future<PaymentInit?> initialize({
    required CoinPack pack,
  }) async {
    final current = state;
    if (current is! StoreLoaded || current.purchasingId != null) return null;
    emit(current.copyWith(purchasingId: pack.id));
    try {
      final init = await _repo.initialize(itemId: int.parse(pack.id));
      return init;
    } catch (e) {
      emit(current.copyWith(clearPurchasing: true));
      emit(StoreError(describeError(e)));
      return null;
    }
  }

  /// Server-authoritative verification. Must be called after user returns
  /// from the payment provider. Refreshes balance from the server result.
  Future<StorePurchaseEvent> verify(String reference) async {
    try {
      final result = await _repo.verify(reference);
      final current = state;
      if (current is StoreLoaded) {
        emit(current.copyWith(
          balance: result.newBalance ?? current.balance,
          clearPurchasing: true,
        ));
      }
      return StorePurchaseEvent(
        success: result.success,
        coinsCredited: result.coinsCredited,
      );
    } catch (e) {
      final current = state;
      if (current is StoreLoaded) {
        emit(current.copyWith(clearPurchasing: true));
      }
      return StorePurchaseEvent(
        success: false,
        coinsCredited: 0,
        message: describeError(e),
      );
    }
  }

  void cancelPurchase() {
    final current = state;
    if (current is StoreLoaded) {
      emit(current.copyWith(clearPurchasing: true));
    }
  }

  // ── Apple In-App Purchase ──────────────────────────────────────────────────

  StreamSubscription<List<PurchaseDetails>>? _iapSubscription;

  /// Initializes the IAP plugin and listens for purchase updates.
  /// Call once after [load()], on iOS only.
  void initIAP() {
    if (!Platform.isIOS) return;
    _iapSubscription?.cancel();
    _iapSubscription = InAppPurchase.instance.purchaseStream
        .listen(_onIAPPurchaseUpdates, onError: (_) {});
  }

  /// Starts a purchase flow for the given App Store product ID.
  Future<void> purchaseIAP(String productId) async {
    if (!Platform.isIOS) return;
    final current = state;
    if (current is! StoreLoaded || current.purchasingId != null) return;
    emit(current.copyWith(purchasingId: productId));
    try {
      final available = await InAppPurchase.instance.isAvailable();
      if (!available) {
        emit(current.copyWith(clearPurchasing: true));
        emit(const StoreError('App Store not available.'));
        return;
      }
      final response = await InAppPurchase.instance
          .queryProductDetails({productId});
      if (response.productDetails.isEmpty) {
        emit(current.copyWith(clearPurchasing: true));
        emit(const StoreError('Product not found in App Store.'));
        return;
      }
      final purchaseParam = PurchaseParam(
        productDetails: response.productDetails.first,
      );
      await InAppPurchase.instance
          .buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      final s = state;
      if (s is StoreLoaded) emit(s.copyWith(clearPurchasing: true));
      emit(StoreError(describeError(e)));
    }
  }

  /// Server-authoritative Apple IAP verification.
  /// Sends Apple receipt data to the correct endpoint (NOT the Paystack
  /// endpoint). The server validates the receipt with Apple and credits coins.
  /// [transactionId] idempotency is enforced server-side — safe to retry.
  Future<StorePurchaseEvent> verifyAppleIAP({
    required String productId,
    required String receiptData,
    required String transactionId,
  }) async {
    try {
      final result = await _repo.verifyAppleIAP(
        productId: productId,
        receiptData: receiptData,
        transactionId: transactionId,
      );
      final current = state;
      if (current is StoreLoaded) {
        emit(current.copyWith(
          balance: result.newBalance ?? current.balance,
          clearPurchasing: true,
        ));
      }
      return StorePurchaseEvent(
        success: result.success,
        coinsCredited: result.coinsCredited,
      );
    } catch (e) {
      final current = state;
      if (current is StoreLoaded) {
        emit(current.copyWith(clearPurchasing: true));
      }
      return StorePurchaseEvent(
        success: false,
        coinsCredited: 0,
        message: describeError(e),
      );
    }
  }

  Future<void> _onIAPPurchaseUpdates(
      List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Use Apple-specific endpoint — NOT the Paystack verify endpoint.
        // Server validates the Apple receipt and credits coins.
        final event = await verifyAppleIAP(
          productId: purchase.productID,
          receiptData: purchase.verificationData.serverVerificationData,
          transactionId: purchase.purchaseID ??
              purchase.verificationData.localVerificationData,
        );
        if (event.success) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        final s = state;
        if (s is StoreLoaded) emit(s.copyWith(clearPurchasing: true));
        emit(StoreError(
            purchase.error?.message ?? 'Purchase failed'));
      } else if (purchase.status == PurchaseStatus.pending) {
        // Ask-to-Buy / deferred — nothing to do until Apple approves
      }
    }
  }

  @override
  Future<void> close() {
    _iapSubscription?.cancel();
    return super.close();
  }
}
