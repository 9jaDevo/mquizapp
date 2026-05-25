import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';

class ProgressStage extends Equatable {
  const ProgressStage({
    required this.stageNumber,
    required this.title,
    this.description,
    this.categoryId,
    this.subcategoryId,
    this.unlocked = false,
    this.completed = false,
    this.starsEarned = 0,
    this.maxStars = 3,
    this.coinReward,
    this.questionCount,
  });

  final int stageNumber;
  final String title;
  final String? description;
  final int? categoryId;
  final int? subcategoryId;
  final bool unlocked;
  final bool completed;
  final int starsEarned;
  final int maxStars;
  final int? coinReward;
  final int? questionCount;

  factory ProgressStage.fromJson(Map<String, dynamic> j) => ProgressStage(
        stageNumber:
            parseIntOr(j['stageNumber'] ?? j['stage_number'] ?? j['order'], 0),
        title: parseStringOr(j['title'] ?? j['name'], 'Stage'),
        description: parseString(j['description']),
        categoryId: parseInt(j['categoryId'] ?? j['category_id']),
        subcategoryId: parseInt(j['subcategoryId'] ?? j['subcategory_id']),
        unlocked: parseBool(j['unlocked']),
        completed: parseBool(j['completed']),
        starsEarned: parseIntOr(j['starsEarned'] ?? j['stars'], 0),
        maxStars: parseIntOr(j['maxStars'] ?? j['max_stars'], 3),
        coinReward: parseInt(j['coinReward'] ?? j['coin_reward']),
        questionCount:
            parseInt(j['questionCount'] ?? j['question_count']),
      );

  @override
  List<Object?> get props => [
        stageNumber,
        title,
        description,
        categoryId,
        subcategoryId,
        unlocked,
        completed,
        starsEarned,
        maxStars,
        coinReward,
        questionCount,
      ];
}
