import 'package:mquiz/features/auth/models/auth_provider_enum.dart';

class AuthModel {
  const AuthModel({
    required this.firebaseUid,
    required this.authProvider,
    required this.isNewUser,
    required this.userId,
    this.name,
    this.email,
    this.photoUrl,
    this.mobile,
  });

  final String firebaseUid;
  final MquizAuthProvider authProvider;
  final bool isNewUser;

  /// The mQuiz backend user ID (returned by /auth/login).
  final String userId;

  final String? name;
  final String? email;
  final String? photoUrl;
  final String? mobile;

  factory AuthModel.fromApiResponse(
    Map<String, dynamic> data,
    String firebaseUid,
    MquizAuthProvider authProvider,
    bool isNewUser,
  ) {
    return AuthModel(
      firebaseUid: firebaseUid,
      authProvider: authProvider,
      isNewUser: isNewUser,
      userId: data['id']?.toString() ?? data['user_id']?.toString() ?? '',
      name: data['name']?.toString(),
      email: data['email']?.toString(),
      photoUrl: data['profile']?.toString() ?? data['photo_url']?.toString(),
      mobile: data['mobile']?.toString(),
    );
  }

  AuthModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? mobile,
    bool? isNewUser,
  }) {
    return AuthModel(
      firebaseUid: firebaseUid,
      authProvider: authProvider,
      isNewUser: isNewUser ?? this.isNewUser,
      userId: userId,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      mobile: mobile ?? this.mobile,
    );
  }
}
