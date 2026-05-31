import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';

class PartnerContest extends Equatable {
  const PartnerContest({
    required this.id,
    required this.title,
    required this.status,
    this.description,
    this.bannerUrl,
    this.startDate,
    this.endDate,
    this.maxParticipants,
    this.participantCount = 0,
    this.questionCount = 0,
    this.prizeDescription,
    this.coinPrizePool,
    this.timeLimitSeconds,
    this.inviteCode,
    this.customJoinMessage,
    this.orgName,
    this.orgLogoUrl,
    this.hasJoined = false,
  });

  final int id;
  final String title;
  final String status;
  final String? description;
  final String? bannerUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? maxParticipants;
  final int participantCount;
  final int questionCount;
  final String? prizeDescription;
  final int? coinPrizePool;
  final int? timeLimitSeconds;
  final String? inviteCode;
  final String? customJoinMessage;
  final String? orgName;
  final String? orgLogoUrl;
  final bool hasJoined;

  factory PartnerContest.fromJson(Map<String, dynamic> j) => PartnerContest(
        id: parseIntOr(j['id'], 0),
        title: parseStringOr(j['title'], ''),
        status: parseStringOr(j['status'], 'draft'),
        description: parseString(j['description']),
        bannerUrl: parseString(j['bannerUrl']),
        startDate: parseDateTime(j['startDate']),
        endDate: parseDateTime(j['endDate']),
        maxParticipants: parseInt(j['maxParticipants']),
        participantCount: parseIntOr(j['participantCount'] ?? j['_count']?['participants'], 0),
        questionCount: parseIntOr(j['questionCount'] ?? j['_count']?['questions'], 0),
        prizeDescription: parseString(j['prizeDescription']),
        coinPrizePool: parseInt(j['coinPrizePool']),
        timeLimitSeconds: parseInt(j['timeLimitSeconds']),
        inviteCode: parseString(j['inviteCode']),
        customJoinMessage: parseString(j['customJoinMessage']),
        orgName: parseString(j['partner']?['orgName']),
        orgLogoUrl: parseString(j['partner']?['logoUrl']),
        hasJoined: parseBool(j['hasJoined']),
      );

  bool get isLive => status == 'published';
  bool get isEnded => status == 'ended';
  bool get isFull => maxParticipants != null && participantCount >= maxParticipants!;

  @override
  List<Object?> get props => [
        id, title, status, description, bannerUrl, startDate, endDate,
        maxParticipants, participantCount, questionCount, prizeDescription,
        coinPrizePool, timeLimitSeconds, inviteCode, customJoinMessage,
        orgName, orgLogoUrl, hasJoined,
      ];
}
