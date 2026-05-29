import 'package:firebase_auth/firebase_auth.dart';
import 'package:mquiz/features/auth/data/auth_local_data_source.dart';
import 'package:mquiz/features/auth/data/auth_remote_data_source.dart';
import 'package:mquiz/features/auth/models/auth_model.dart';

class AuthRepository {
  AuthRepository({
    required AuthLocalDataSource local,
    required AuthRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final AuthLocalDataSource _local;
  final AuthRemoteDataSource _remote;

  Future<AuthModel> signInWithGoogle({String? fcmToken}) async {
    final user = await _remote.signInWithGoogle(fcmToken: fcmToken);
    await _local.saveUser(user);
    return user;
  }

  Future<AuthModel> signInWithApple({String? fcmToken}) async {
    final user = await _remote.signInWithApple(fcmToken: fcmToken);
    await _local.saveUser(user);
    return user;
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) onAutoVerified,
    required void Function(FirebaseAuthException) onFailed,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String verificationId) onTimeout,
  }) {
    return _remote.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onAutoVerified: onAutoVerified,
      onFailed: onFailed,
      onCodeSent: onCodeSent,
      onTimeout: onTimeout,
    );
  }

  Future<AuthModel> confirmOtp({
    required String verificationId,
    required String smsCode,
    String? fcmToken,
    String? mobile,
  }) async {
    final user = await _remote.confirmOtp(
      verificationId: verificationId,
      smsCode: smsCode,
      fcmToken: fcmToken,
      mobile: mobile,
    );
    await _local.saveUser(user);
    return user;
  }

  Future<AuthModel> signInAsGuest({String? fcmToken}) async {
    final user = await _remote.signInAsGuest(fcmToken: fcmToken);
    await _local.saveUser(user);
    return user;
  }

  Future<AuthModel> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String? fcmToken,
  }) async {
    final user = await _remote.registerWithEmail(
      email: email,
      password: password,
      name: name,
      fcmToken: fcmToken,
    );
    await _local.saveUser(user);
    return user;
  }

  Future<AuthModel> signInWithEmail({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    final user = await _remote.signInWithEmail(
      email: email,
      password: password,
      fcmToken: fcmToken,
    );
    await _local.saveUser(user);
    return user;
  }

  Future<void> signOut() async {
    await Future.wait([
      _remote.signOut(),
      _local.clearSession(),
    ]);
  }

  Future<bool> isOnboardingDone() => _local.isOnboardingDone();
  Future<void> setOnboardingDone() => _local.setOnboardingDone();

  User? get currentFirebaseUser => _remote.currentFirebaseUser;
  Stream<User?> get authStateChanges => _remote.authStateChanges;

  Future<String?> getSavedUserId() => _local.getSavedUserId();
}
