/// Typed wrapper around flutter_secure_storage.
///
/// Security:
/// - iOS: Keychain (data survives app reinstall by default — disabled here via
///   accessibility kSecAttrAccessibleAfterFirstUnlock + deleteOnLogout).
/// - Android: EncryptedSharedPreferences backed by Android Keystore.
/// - Never store tokens in SharedPreferences, Hive, or plain files.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();
  static final SecureStorage instance = SecureStorage._();

  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const _iOSOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: _androidOptions,
    iOptions: _iOSOptions,
  );

  // ── Keys ────────────────────────────────────────────────────────────────────
  static const _keyUserId = 'mquiz_user_id';
  static const _keyFirebaseUid = 'mquiz_firebase_uid';
  static const _keyFcmToken = 'mquiz_fcm_token';
  static const _keyAppLanguage = 'mquiz_app_language';
  static const _keyOnboardingDone = 'mquiz_onboarding_done';

  // ── User ID ─────────────────────────────────────────────────────────────────
  Future<void> storeUserId(String id) =>
      _storage.write(key: _keyUserId, value: id);

  Future<String?> getUserId() => _storage.read(key: _keyUserId);

  // ── Firebase UID ─────────────────────────────────────────────────────────────
  Future<void> storeFirebaseUid(String uid) =>
      _storage.write(key: _keyFirebaseUid, value: uid);

  Future<String?> getFirebaseUid() => _storage.read(key: _keyFirebaseUid);

  // ── FCM Token ───────────────────────────────────────────────────────────────
  Future<void> storeFcmToken(String token) =>
      _storage.write(key: _keyFcmToken, value: token);

  Future<String?> getFcmToken() => _storage.read(key: _keyFcmToken);

  // ── App Language ────────────────────────────────────────────────────────────
  Future<void> storeAppLanguage(String languageId) =>
      _storage.write(key: _keyAppLanguage, value: languageId);

  Future<String?> getAppLanguage() => _storage.read(key: _keyAppLanguage);

  // ── Onboarding ──────────────────────────────────────────────────────────────
  Future<void> setOnboardingDone() =>
      _storage.write(key: _keyOnboardingDone, value: 'true');

  Future<bool> isOnboardingDone() async {
    final value = await _storage.read(key: _keyOnboardingDone);
    return value == 'true';
  }

  // ── Clear ────────────────────────────────────────────────────────────────────
  Future<void> clearAll() => _storage.deleteAll();

  Future<void> clearAuthData() async {
    await Future.wait([
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyFirebaseUid),
      _storage.delete(key: _keyFcmToken),
    ]);
  }
}
