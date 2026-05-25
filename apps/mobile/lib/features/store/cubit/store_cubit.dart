import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    required String packId,
    String provider = 'paystack',
  }) async {
    final current = state;
    if (current is! StoreLoaded || current.purchasingId != null) return null;
    emit(current.copyWith(purchasingId: packId));
    try {
      final init = await _repo.initialize(packId: packId, provider: provider);
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
}
