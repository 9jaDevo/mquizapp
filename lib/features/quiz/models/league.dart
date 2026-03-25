final class Leagues {
  const Leagues({
    required this.active,
    required this.upcoming,
    required this.past,
  });

  Leagues.fromJson(Map<String, dynamic> json)
    : active = LeagueGroup.fromJson(
        (json['active_leagues'] as Map<String, dynamic>? ??
            <String, dynamic>{'error': true, 'message': '', 'data': []}),
      ),
      upcoming = LeagueGroup.fromJson(
        (json['upcoming_leagues'] as Map<String, dynamic>? ??
            <String, dynamic>{'error': true, 'message': '', 'data': []}),
      ),
      past = LeagueGroup.fromJson(
        (json['past_leagues'] as Map<String, dynamic>? ??
            <String, dynamic>{'error': true, 'message': '', 'data': []}),
      );

  final LeagueGroup active;
  final LeagueGroup upcoming;
  final LeagueGroup past;
}

final class LeagueGroup {
  const LeagueGroup({required this.errorMessage, required this.items});

  LeagueGroup.fromJson(Map<String, dynamic> json)
    : errorMessage = (json['error'] as bool? ?? false)
          ? (json['message'] as String? ?? '')
          : '',
      items = (json['error'] as bool? ?? false)
          ? <LeagueItem>[]
          : ((json['data'] as List? ?? <dynamic>[])
                .cast<Map<String, dynamic>>()
                .map(LeagueItem.fromJson)
                .toList(growable: false));

  final String errorMessage;
  final List<LeagueItem> items;
}

final class LeagueItem {
  LeagueItem({
    this.id,
    this.name,
    this.description,
    this.image,
    this.startDate,
    this.endDate,
    this.entry,
    this.participants,
    this.userStatus,
  });

  LeagueItem.fromJson(Map<String, dynamic> json)
    : id = json['id']?.toString(),
      name = json['name'] as String?,
      description = json['description'] as String?,
      image = json['image'] as String?,
      startDate = json['start_date'] as String?,
      endDate = json['end_date'] as String?,
      entry = json['entry']?.toString(),
      participants = json['participants']?.toString(),
      userStatus = json['user_status'] as String?;

  final String? id;
  final String? name;
  final String? description;
  final String? image;
  final String? startDate;
  final String? endDate;
  final String? entry;
  final String? participants;
  final String? userStatus;
}
