import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/utils/error_handler.dart';
import 'package:mquiz/features/quiz/data/quiz_repository.dart';
import 'package:mquiz/features/quiz/models/category_model.dart';

sealed class CategoriesState extends Equatable {
  const CategoriesState();
  @override
  List<Object?> get props => const [];
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded(this.categories);
  final List<Category> categories;
  @override
  List<Object?> get props => [categories];
}

class CategoriesError extends CategoriesState {
  const CategoriesError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit(this._repo) : super(const CategoriesInitial());
  final QuizRepository _repo;

  Future<void> load({String? type}) async {
    emit(const CategoriesLoading());
    try {
      final cats = await _repo.fetchCategories(type: type);
      emit(CategoriesLoaded(cats));
    } catch (e) {
      emit(CategoriesError(describeError(e)));
    }
  }
}

sealed class SubcategoriesState extends Equatable {
  const SubcategoriesState();
  @override
  List<Object?> get props => const [];
}

class SubcategoriesInitial extends SubcategoriesState {
  const SubcategoriesInitial();
}

class SubcategoriesLoading extends SubcategoriesState {
  const SubcategoriesLoading();
}

class SubcategoriesLoaded extends SubcategoriesState {
  const SubcategoriesLoaded(this.items);
  final List<Subcategory> items;
  @override
  List<Object?> get props => [items];
}

class SubcategoriesError extends SubcategoriesState {
  const SubcategoriesError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class SubcategoriesCubit extends Cubit<SubcategoriesState> {
  SubcategoriesCubit(this._repo) : super(const SubcategoriesInitial());
  final QuizRepository _repo;

  Future<void> load(int categoryId) async {
    emit(const SubcategoriesLoading());
    try {
      final items = await _repo.fetchSubcategories(categoryId);
      emit(SubcategoriesLoaded(items));
    } catch (e) {
      emit(SubcategoriesError(describeError(e)));
    }
  }
}
