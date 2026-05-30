import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';

class BookmarkModel extends Equatable {
  const BookmarkModel({
    required this.id,
    required this.questionId,
    required this.questionText,
    required this.correctOption,
    required this.createdAt,
    this.optiona,
    this.optionb,
    this.optionc,
    this.optiond,
    this.categoryId,
  });

  final int id;
  final int questionId;
  final String questionText;
  final String? optiona;
  final String? optionb;
  final String? optionc;
  final String? optiond;
  final String correctOption;
  final int? categoryId;
  final DateTime createdAt;

  factory BookmarkModel.fromJson(Map<String, dynamic> j) {
    final q = j['question'] as Map<String, dynamic>?;
    return BookmarkModel(
      id: parseIntOr(j['id'], 0),
      questionId: parseIntOr(j['questionId'] ?? j['question_id'], 0),
      questionText:
          parseStringOr(q?['question'] ?? q?['text'] ?? j['questionText'], ''),
      optiona: parseString(q?['optiona'] ?? q?['optionA']),
      optionb: parseString(q?['optionb'] ?? q?['optionB']),
      optionc: parseString(q?['optionc'] ?? q?['optionC']),
      optiond: parseString(q?['optiond'] ?? q?['optionD']),
      correctOption: parseStringOr(
          q?['correct_option'] ?? q?['correctOption'] ?? j['correctOption'],
          'a'),
      categoryId:
          parseInt(q?['category'] ?? q?['category_id'] ?? j['categoryId']),
      createdAt: _parseDate(j['createdAt'] ?? j['created_at']),
    );
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  List<Object?> get props => [
        id,
        questionId,
        questionText,
        optiona,
        optionb,
        optionc,
        optiond,
        correctOption,
        categoryId,
        createdAt,
      ];
}
