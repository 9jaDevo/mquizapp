import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:mquiz/core/network/nestjs_api.dart';
import 'package:mquiz/features/auth/models/auth_model.dart';
import 'package:mquiz/features/auth/models/auth_provider_enum.dart' as mquiz;

class AuthRemoteDataSource {
  AuthRemoteDataSource();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final NestJsApi _api = NestJsApi.instance;

  // ── Google Sign-In ─────────────────────────────────────────────────────────
  Future<AuthModel> signInWithGoogle({String? fcmToken}) async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCredential.user!;

    final data = await _api.authLogin(
      type: mquiz.MquizAuthProvider.google.apiType,
      name: firebaseUser.displayName,
      email: firebaseUser.email,
      profile: firebaseUser.photoURL,
      fcmToken: fcmToken,
    );

    return AuthModel.fromApiResponse(
      data,
      firebaseUser.uid,
      mquiz.MquizAuthProvider.google,
      userCredential.additionalUserInfo?.isNewUser ?? false,
    );
  }

  // ── Apple Sign-In (required by App Store) ─────────────────────────────────
  Future<AuthModel> signInWithApple({String? fcmToken}) async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential =
        await _firebaseAuth.signInWithCredential(oauthCredential);
    final firebaseUser = userCredential.user!;

    final fullName = [
      appleCredential.givenName,
      appleCredential.familyName,
    ].where((s) => s != null && s.isNotEmpty).join(' ');

    final data = await _api.authLogin(
      type: mquiz.MquizAuthProvider.apple.apiType,
      name: fullName.isNotEmpty ? fullName : firebaseUser.displayName,
      email: appleCredential.email ?? firebaseUser.email,
      fcmToken: fcmToken,
    );

    return AuthModel.fromApiResponse(
      data,
      firebaseUser.uid,
      mquiz.MquizAuthProvider.apple,
      userCredential.additionalUserInfo?.isNewUser ?? false,
    );
  }

  // ── Phone OTP ──────────────────────────────────────────────────────────────
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) onAutoVerified,
    required void Function(FirebaseAuthException) onFailed,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String verificationId) onTimeout,
    Duration timeout = const Duration(seconds: 60),
  }) {
    return _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onAutoVerified,
      verificationFailed: onFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onTimeout,
      timeout: timeout,
    );
  }

  Future<AuthModel> confirmOtp({
    required String verificationId,
    required String smsCode,
    String? fcmToken,
    String? mobile,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCredential.user!;

    final data = await _api.authLogin(
      type: mquiz.MquizAuthProvider.phone.apiType,
      mobile: mobile ?? firebaseUser.phoneNumber,
      fcmToken: fcmToken,
    );

    return AuthModel.fromApiResponse(
      data,
      firebaseUser.uid,
      mquiz.MquizAuthProvider.phone,
      userCredential.additionalUserInfo?.isNewUser ?? false,
    );
  }

  // ── Email / Password ───────────────────────────────────────────────────────
  Future<AuthModel> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String? fcmToken,
  }) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = userCredential.user!;
    await firebaseUser.updateDisplayName(name);

    final data = await _api.authLogin(
      type: mquiz.MquizAuthProvider.email.apiType,
      name: name,
      email: email,
      fcmToken: fcmToken,
    );

    return AuthModel.fromApiResponse(
      data,
      firebaseUser.uid,
      mquiz.MquizAuthProvider.email,
      true,
    );
  }

  Future<AuthModel> signInWithEmail({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = userCredential.user!;

    final data = await _api.authLogin(
      type: mquiz.MquizAuthProvider.email.apiType,
      email: email,
      name: firebaseUser.displayName,
      fcmToken: fcmToken,
    );

    return AuthModel.fromApiResponse(
      data,
      firebaseUser.uid,
      mquiz.MquizAuthProvider.email,
      userCredential.additionalUserInfo?.isNewUser ?? false,
    );
  }

  // ── Guest ──────────────────────────────────────────────────────────────────
  Future<AuthModel> signInAsGuest({String? fcmToken}) async {
    final userCredential = await _firebaseAuth.signInAnonymously();
    final firebaseUser = userCredential.user!;

    final data = await _api.authGuest(appLanguage: 'en');

    return AuthModel.fromApiResponse(
      data,
      firebaseUser.uid,
      mquiz.MquizAuthProvider.guest,
      true,
    );
  }

  // ── Sign Out ───────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ── State ──────────────────────────────────────────────────────────────────
  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
