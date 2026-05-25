import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';

class QuizQuestion extends Equatable {
  const QuizQuestion({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.type,
    required this.options,
    required this.level,
    this.subcategoryId,
    this.languageId,
    this.image,
    this.correctAnswer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> j) {
    final rawOptions = j['options'];
    final options = <String, String>{};
    if (rawOptions is Map) {
      rawOptions.forEach((k, v) {
        if (v == null) return;
        final key = k.toString();
        final value = v.toString().trim();
        if (value.isEmpty) return;
        options[key] = value;
      });
    }
    return QuizQuestion(
      id: parseIntOr(j['id'], 0),
      categoryId: parseIntOr(j['categoryId'], 0),
      text: parseStringOr(j['text'] ?? j['question'], ''),
      type: parseStringOr(j['type'], 'text'),
      options: options,
      level: parseIntOr(j['level'], 1),
      subcategoryId: parseInt(j['subcategoryId']),
      languageId: parseInt(j['languageId']),
      image: parseString(j['image']),
      correctAnswer: parseString(j['answer'] ?? j['correctAnswer']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'text': text,
        'type': type,
        'options': options,
        'level': level,
        if (subcategoryId != null) 'subcategoryId': subcategoryId,
        if (languageId != null) 'languageId': languageId,
        if (image != null) 'image': image,
        if (correctAnswer != null) 'answer': correctAnswer,
      };

  final int id;
  final int categoryId;
  final String text;
  final String type;
  final Map<String, String> options;
  final int level;
  final int? subcategoryId;
  final int? languageId;
  final String? image;
  /// Correct option key (e.g. 'a', 'b'). Populated when the API returns it.
  /// Used for real-time client-side validation in battle mode.
  final String? correctAnswer;

  List<MapEntry<String, String>> get orderedOptions {
    const order = ['a', 'b', 'c', 'd', 'e'];
    return [
      for (final k in order)
        if (options.containsKey(k)) MapEntry(k, options[k]!),
    ];
  }

  @override
  List<Object?> get props => [id, text, type, level, options];
}

/// Single per-question answer the client submits.
class SubmittedAnswer extends Equatable {
  const SubmittedAnswer({
    required this.questionId,
    required this.userAnswer,
    required this.timeTakenMs,
    required this.usedBoosters,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'userAnswer': userAnswer,
        'timeTakenMs': timeTakenMs,
        if (usedBoosters.isNotEmpty) 'usedBoosters': usedBoosters,
      };

  final int questionId;
  final String userAnswer; // 'a'..'e' or '' if skipped
  final int timeTakenMs;
  final List<String> usedBoosters;

  @override
  List<Object?> get props => [questionId, userAnswer, timeTakenMs, usedBoosters];
}

class QuizAnswerBreakdown extends Equatable {
  const QuizAnswerBreakdown({
    required this.questionId,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  factory QuizAnswerBreakdown.fromJson(Map<String, dynamic> j) =>
      QuizAnswerBreakdown(
        questionId: parseIntOr(j['questionId'], 0),
        userAnswer: parseStringOr(j['userAnswer'], ''),
        correctAnswer: parseStringOr(j['correctAnswer'], ''),
        isCorrect: parseBool(j['isCorrect']),
      );

  final int questionId;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;

  @override
  List<Object?> get props =>
      [questionId, userAnswer, correctAnswer, isCorrect];
}

class QuizResult extends Equatable {
  const QuizResult({
    required this.correctCount,
    required this.wrongCount,
    required this.score,
    required this.coinsEarned,
    required this.accuracy,
    required this.breakdown,
    required this.fraudReviewed,
  });

  factory QuizResult.fromJson(Map<String, dynamic> j) {
    final raw = j['breakdown'];
    final breakdown = raw is List
        ? raw
            .whereType<Map>()
            .map((m) =>
                QuizAnswerBreakdown.fromJson(Map<String, dynamic>.from(m)))
            .toList(growable: false)
        : const <QuizAnswerBreakdown>[];
    return QuizResult(
      correctCount: parseIntOr(j['correctCount'], 0),
      wrongCount: parseIntOr(j['wrongCount'], 0),
      score: parseIntOr(j['score'], 0),
      coinsEarned: parseIntOr(j['coinsEarned'], 0),
      accuracy: parseDouble(j['accuracy']) ?? 0,
      breakdown: breakdown,
      fraudReviewed: parseBool(j['fraudReviewed']),
    );
  }

  final int correctCount;
  final int wrongCount;
  final int score;
  final int coinsEarned;
  final double accuracy;
  final List<QuizAnswerBreakdown> breakdown;
  final bool fraudReviewed;

  int get total => correctCount + wrongCount;

  @override
  List<Object?> get props =>
      [correctCount, wrongCount, score, coinsEarned, accuracy, fraudReviewed];
}
