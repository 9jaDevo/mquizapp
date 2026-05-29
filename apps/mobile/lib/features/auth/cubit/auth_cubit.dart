import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/features/auth/auth_repository.dart';
import 'package:mquiz/features/auth/models/auth_model.dart';
import 'package:mquiz/features/auth/models/auth_provider_enum.dart';

// ── States ─────────────────────────────────────────────────────────────────────

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class Authenticated extends AuthState {
  const Authenticated(this.user);
  final AuthModel user;

  @override
  List<Object?> get props => [user.userId];
}

final class AuthNeedsProfileSetup extends AuthState {
  const AuthNeedsProfileSetup(this.user);
  final AuthModel user;

  @override
  List<Object?> get props => [user.userId];
}

final class AuthOtpSent extends AuthState {
  const AuthOtpSent({required this.verificationId, required this.phoneNumber});
  final String verificationId;
  final String phoneNumber;

  @override
  List<Object?> get props => [verificationId];
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

final class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo) : super(const AuthInitial());

  final AuthRepository _repo;

  Future<void> checkAuth() async {
    emit(const AuthLoading());
    try {
      final firebaseUser = _repo.currentFirebaseUser;
      if (firebaseUser == null) {
        emit(const Unauthenticated());
        return;
      }
      final savedId = await _repo.getSavedUserId();
      if (savedId == null) {
        emit(const Unauthenticated());
        return;
      }
      // User is authenticated — create a minimal model for routing.
      final user = AuthModel(
        firebaseUid: firebaseUser.uid,
        authProvider: _providerFromFirebase(
          firebaseUser.providerData.firstOrNull?.providerId,
        ),
        isNewUser: false,
        userId: savedId,
        name: firebaseUser.displayName,
        email: firebaseUser.email,
        photoUrl: firebaseUser.photoURL,
      );
      emit(Authenticated(user));
    } catch (_) {
      emit(const Unauthenticated());
    }
  }

  Future<void> signInWithGoogle({String? fcmToken}) async {
    emit(const AuthLoading());
    try {
      final user = await _repo.signInWithGoogle(fcmToken: fcmToken);
      _emitAuthenticated(user);
    } catch (e) {
      emit(AuthError(_mapError(e)));
    }
  }

  Future<void> signInWithApple({String? fcmToken}) async {
    emit(const AuthLoading());
    try {
      final user = await _repo.signInWithApple(fcmToken: fcmToken);
      _emitAuthenticated(user);
    } catch (e) {
      emit(AuthError(_mapError(e)));
    }
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    emit(const AuthLoading());
    await _repo.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      onAutoVerified: (credential) async {
        // Auto-verified (Android only) — treat as OTP confirmed
        emit(AuthOtpSent(
          verificationId: credential.verificationId ?? '',
          phoneNumber: phoneNumber,
        ));
      },
      onFailed: (e) =>
          emit(AuthError(e.message ?? 'Phone verification failed')),
      onCodeSent: (verificationId, _) => emit(
        AuthOtpSent(
          verificationId: verificationId,
          phoneNumber: phoneNumber,
        ),
      ),
      onTimeout: (_) => emit(const AuthError('Verification code timed out')),
    );
  }

  Future<void> confirmOtp({
    required String verificationId,
    required String smsCode,
    String? phoneNumber,
    String? fcmToken,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _repo.confirmOtp(
        verificationId: verificationId,
        smsCode: smsCode,
        mobile: phoneNumber,
        fcmToken: fcmToken,
      );
      _emitAuthenticated(user);
    } catch (e) {
      emit(AuthError(_mapError(e)));
    }
  }

  Future<void> signInAsGuest({String? fcmToken}) async {
    emit(const AuthLoading());
    try {
      final user = await _repo.signInAsGuest(fcmToken: fcmToken);
      _emitAuthenticated(user);
    } catch (e) {
      emit(AuthError(_mapError(e)));
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String name,
    String? fcmToken,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _repo.registerWithEmail(
        email: email,
        password: password,
        name: name,
        fcmToken: fcmToken,
      );
      _emitAuthenticated(user);
    } catch (e) {
      emit(AuthError(_mapError(e)));
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    emit(const AuthLoading());
    try {
      final user = await _repo.signInWithEmail(
        email: email,
        password: password,
        fcmToken: fcmToken,
      );
      _emitAuthenticated(user);
    } catch (e) {
      emit(AuthError(_mapError(e)));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());
    try {
      await _repo.signOut();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError(_mapError(e)));
    }
  }

  void _emitAuthenticated(AuthModel user) {
    if (user.isNewUser || (user.name?.isEmpty ?? true)) {
      emit(AuthNeedsProfileSetup(user));
    } else {
      emit(Authenticated(user));
    }
  }

  String _mapError(Object e) {
    final msg = e.toString();
    if (msg.contains('email-already-in-use')) {
      return 'An account with that email already exists';
    }
    if (msg.contains('user-not-found') || msg.contains('invalid-credential')) {
      return 'Incorrect email or password';
    }
    if (msg.contains('wrong-password')) return 'Incorrect password';
    if (msg.contains('weak-password')) {
      return 'Password must be at least 6 characters';
    }
    if (msg.contains('invalid-email')) return 'Please enter a valid email';
    if (msg.contains('cancelled')) return 'Sign-in cancelled';
    if (msg.contains('network')) return 'No internet connection';
    if (msg.contains('invalid-verification-code')) return 'Invalid OTP code';
    if (msg.contains('too-many-requests')) return 'Too many attempts. Try later';
    return 'Authentication failed. Please try again.';
  }

  static MquizAuthProvider _providerFromFirebase(String? providerId) {
    switch (providerId) {
      case 'password':
        return MquizAuthProvider.email;
      case 'google.com':
        return MquizAuthProvider.google;
      case 'apple.com':
        return MquizAuthProvider.apple;
      case 'phone':
        return MquizAuthProvider.phone;
      default:
        return MquizAuthProvider.guest;
    }
  }
}
