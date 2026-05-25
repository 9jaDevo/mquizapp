import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/home/data/home_repository.dart';
import 'package:mquiz/features/home/models/home_dashboard_model.dart';

sealed class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => const [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.data, {this.refreshing = false});
  final HomeDashboard data;
  final bool refreshing;

  HomeLoaded copyWith({HomeDashboard? data, bool? refreshing}) =>
      HomeLoaded(data ?? this.data, refreshing: refreshing ?? this.refreshing);

  @override
  List<Object?> get props => [data, refreshing];
}

class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repo) : super(const HomeInitial());

  final HomeRepository _repo;

  Future<void> load() async {
    if (state is! HomeLoaded) emit(const HomeLoading());
    try {
      final data = await _repo.loadDashboard();
      emit(HomeLoaded(data));
    } catch (e) {
      emit(HomeError(describeError(e)));
    }
  }

  Future<void> refresh() async {
    final current = state;
    if (current is HomeLoaded) {
      emit(current.copyWith(refreshing: true));
    }
    try {
      final data = await _repo.loadDashboard();
      emit(HomeLoaded(data));
    } catch (e) {
      if (current is HomeLoaded) {
        emit(current.copyWith(refreshing: false));
      } else {
        emit(HomeError(describeError(e)));
      }
    }
  }
}
