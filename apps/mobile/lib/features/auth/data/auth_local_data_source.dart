import 'package:mquiz/core/security/secure_storage.dart';
import 'package:mquiz/features/auth/models/auth_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource();

  final SecureStorage _storage = SecureStorage.instance;

  Future<void> saveUser(AuthModel user) async {
    await Future.wait([
      _storage.storeUserId(user.userId),
      _storage.storeFirebaseUid(user.firebaseUid),
    ]);
  }

  Future<String?> getSavedUserId() => _storage.getUserId();

  Future<String?> getSavedFirebaseUid() => _storage.getFirebaseUid();

  Future<bool> isOnboardingDone() => _storage.isOnboardingDone();

  Future<void> setOnboardingDone() => _storage.setOnboardingDone();

  Future<void> clearSession() => _storage.clearAuthData();
}
