import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/auth/auth_repository.dart';
import 'package:flutterquiz/features/auth/models/auth_model.dart';
import 'package:flutterquiz/features/auth/models/auth_providers_enum.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

sealed class AuthState {
  const AuthState();
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class Authenticated extends AuthState {
  const Authenticated({required this.authModel});

  final AuthModel authModel;
}

final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._authRepository) : super(const AuthInitial()) {
    _checkAuthStatus();
  }

  final AuthRepository _authRepository;

  AuthProviders getAuthProvider() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.authProvider;
    }
    return AuthProviders.email;
  }

  void _checkAuthStatus() {
    //authDetails is map. keys are isLogin,userId,authProvider,jwtToken
    final authDetails = _authRepository.getLocalAuthDetails();

    if (authDetails['isLogin'] as bool) {
      emit(Authenticated(authModel: AuthModel.fromJson(authDetails)));
    } else {
      emit(const Unauthenticated());
    }
  }

  //to update auth status
  void updateAuthDetails({
    String? firebaseId,
    AuthProviders? authProvider,
    bool? authStatus,
    bool? isNewUser,
  }) {
    //updating authDetails locally
    _authRepository.setLocalAuthDetails(
      jwtToken: '',
      firebaseId: firebaseId,
      authType: authProvider!.name,
      authStatus: authStatus,
      isNewUser: isNewUser,
    );

    //emitting new state in cubit
    emit(
      Authenticated(
        authModel: AuthModel(
          jwtToken: '',
          firebaseId: firebaseId!,
          authProvider: authProvider,
          isNewUser: isNewUser!,
        ),
      ),
    );
  }

  bool get isGuest => state is Unauthenticated;
  bool get isLoggedIn => state is Authenticated;

  // Device registration helpers
  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown';
      }
      return 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  String getDeviceType() {
    if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    }
    return 'unknown';
  }

  Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.name} ${iosInfo.model}';
      }
      return 'Unknown Device';
    } catch (e) {
      return 'Unknown Device';
    }
  }

  void logoutOrDeleteAccount() {
    if (state is Authenticated) {
      _authRepository.signOut((state as Authenticated).authModel.authProvider);
      emit(const Unauthenticated());
    }
  }
}
