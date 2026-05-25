import 'package:mquiz/core/network/nestjs_api.dart';
import 'package:mquiz/features/quiz/models/category_model.dart';
import 'package:mquiz/features/quiz/models/question_model.dart';

/// Single-source repository for all category/quiz interactions.
class QuizRepository {
  QuizRepository({NestJsApi? api}) : _api = api ?? NestJsApi.instance;

  final NestJsApi _api;

  Future<List<Category>> fetchCategories({String? type}) async {
    final raw = await _api.getCategories(type: type);
    return raw.map(Category.fromJson).toList(growable: false);
  }

  Future<List<Subcategory>> fetchSubcategories(int categoryId) async {
    final raw = await _api.getSubcategories(categoryId);
    return raw.map(Subcategory.fromJson).toList(growable: false);
  }

  Future<List<QuizQuestion>> fetchQuestions({
    int? categoryId,
    int? subcategoryId,
    int? level,
    int? limit,
  }) async {
    final raw = await _api.getQuestions(
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      level: level,
      limit: limit,
    );
    return raw.map(QuizQuestion.fromJson).toList(growable: false);
  }

  /// Submit a completed quiz attempt. The server is the source of truth
  /// for correctness, score, and coin reward — we send raw user answers.
  Future<QuizResult> submitQuiz({
    int? categoryId,
    int? subcategoryId,
    int? level,
    required List<SubmittedAnswer> answers,
    required int durationMs,
  }) async {
    final payload = <String, dynamic>{
      if (categoryId != null) 'categoryId': categoryId,
      if (subcategoryId != null) 'subcategoryId': subcategoryId,
      if (level != null) 'level': level,
      'durationMs': durationMs,
      'answers': answers.map((a) => a.toJson()).toList(),
    };
    final raw = await _api.submitQuiz(payload);
    return QuizResult.fromJson(raw);
  }
}
