import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';

class Contest extends Equatable {
  const Contest({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.entryCoinCost,
    this.prizePool,
    this.startDate,
    this.endDate,
    this.questionCount,
    this.isParticipated = false,
    this.status,
  });

  final int id;
  final String name;
  final String? description;
  final String? image;
  final int? entryCoinCost;
  final int? prizePool;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? questionCount;
  final bool isParticipated;
  final String? status;

  factory Contest.fromJson(Map<String, dynamic> j) => Contest(
        id: parseIntOr(j['id'], 0),
        name: parseStringOr(j['name'] ?? j['title'], ''),
        description: parseString(j['description']),
        image: parseString(j['image'] ?? j['banner']),
        entryCoinCost: parseInt(j['entryCoinCost'] ?? j['entry_cost']),
        prizePool: parseInt(j['prizePool'] ?? j['prize_pool']),
        startDate: parseDateTime(j['startDate'] ?? j['start_date']),
        endDate: parseDateTime(j['endDate'] ?? j['end_date']),
        questionCount:
            parseInt(j['questionCount'] ?? j['question_count']),
        isParticipated:
            parseBool(j['isParticipated'] ?? j['participated']),
        status: parseString(j['status']),
      );

  bool get isLive {
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        entryCoinCost,
        prizePool,
        startDate,
        endDate,
        questionCount,
        isParticipated,
        status,
      ];
}
