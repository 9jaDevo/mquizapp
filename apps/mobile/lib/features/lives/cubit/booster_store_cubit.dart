import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/lives/data/lives_repository.dart';
import 'package:mquiz/features/lives/models/lives_models.dart';

sealed class BoosterStoreState extends Equatable {
  const BoosterStoreState();
  @override
  List<Object?> get props => const [];
}

final class BoosterStoreInitial extends BoosterStoreState {
  const BoosterStoreInitial();
}

final class BoosterStoreLoading extends BoosterStoreState {
  const BoosterStoreLoading();
}

final class BoosterStoreLoaded extends BoosterStoreState {
  const BoosterStoreLoaded({
    required this.catalog,
    required this.owned,
    this.purchasingId,
  });
  final List<Booster> catalog;
  final List<Booster> owned;
  final int? purchasingId;

  BoosterStoreLoaded copyWith({
    List<Booster>? catalog,
    List<Booster>? owned,
    int? purchasingId,
    bool clearPurchasing = false,
  }) =>
      BoosterStoreLoaded(
        catalog: catalog ?? this.catalog,
        owned: owned ?? this.owned,
        purchasingId:
            clearPurchasing ? null : (purchasingId ?? this.purchasingId),
      );

  @override
  List<Object?> get props => [catalog, owned, purchasingId];
}

final class BoosterStoreError extends BoosterStoreState {
  const BoosterStoreError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class BoosterStoreCubit extends Cubit<BoosterStoreState> {
  BoosterStoreCubit(this._repo) : super(const BoosterStoreInitial());
  final LivesRepository _repo;

  Future<void> load() async {
    emit(const BoosterStoreLoading());
    try {
      final results = await Future.wait([
        _repo.fetchBoosterTypes(),
        _repo.fetchMyBoosters(),
      ]);
      emit(BoosterStoreLoaded(
        catalog: results[0],
        owned: results[1],
      ));
    } catch (e) {
      emit(BoosterStoreError(describeError(e)));
    }
  }

  Future<bool> purchase(int boosterTypeId) async {
    final current = state;
    if (current is! BoosterStoreLoaded || current.purchasingId != null) {
      return false;
    }
    emit(current.copyWith(purchasingId: boosterTypeId));
    try {
      await _repo.purchaseBooster(boosterTypeId);
      final owned = await _repo.fetchMyBoosters();
      emit(BoosterStoreLoaded(catalog: current.catalog, owned: owned));
      return true;
    } catch (e) {
      emit(current.copyWith(clearPurchasing: true));
      emit(BoosterStoreError(describeError(e)));
      return false;
    }
  }
}
