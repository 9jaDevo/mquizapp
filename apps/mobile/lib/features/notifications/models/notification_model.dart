import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';

class NotificationModel extends Equatable {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.dateSent,
    this.image,
    this.isRead = false,
  });

  final int id;
  final String title;
  final String message;
  final String type;
  final String? image;
  final bool isRead;
  final DateTime dateSent;

  factory NotificationModel.fromJson(Map<String, dynamic> j) {
    return NotificationModel(
      id: parseIntOr(j['id'], 0),
      title: parseStringOr(j['title'], ''),
      message: parseStringOr(j['message'] ?? j['body'], ''),
      type: parseStringOr(j['type'], 'general'),
      image: parseString(j['image']),
      isRead: parseBool(j['isRead'] ?? j['read'] ?? j['is_read']),
      dateSent: _parseDate(j['dateSent'] ?? j['date_sent'] ?? j['createdAt']),
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        message: message,
        type: type,
        image: image,
        isRead: isRead ?? this.isRead,
        dateSent: dateSent,
      );

  static DateTime _parseDate(dynamic raw) {
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  List<Object?> get props => [id, title, message, type, image, isRead, dateSent];
}
