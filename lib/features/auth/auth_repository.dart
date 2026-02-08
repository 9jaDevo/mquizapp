import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterquiz/core/constants/api_exception.dart';
import 'package:flutterquiz/core/constants/constants.dart';
import 'package:flutterquiz/features/auth/auth_local_data_source.dart';
import 'package:flutterquiz/features/auth/auth_remote_data_source.dart';
import 'package:flutterquiz/features/auth/models/auth_providers_enum.dart';

class AuthRepository {
  factory AuthRepository() {
    _authRepository._authLocalDataSource = AuthLocalDataSource();
    _authRepository._authRemoteDataSource = AuthRemoteDataSource();
    return _authRepository;
  }

  AuthRepository._internal();

  static final AuthRepository _authRepository = AuthRepository._internal();
  late AuthLocalDataSource _authLocalDataSource;
  late AuthRemoteDataSource _authRemoteDataSource;

  //to get auth detials stored in hive box
  Map<String, dynamic> getLocalAuthDetails() {
    return {
      'isLogin': AuthLocalDataSource.checkIsAuth(),
      'jwtToken': AuthLocalDataSource.getJwtToken(),
      'firebaseId': AuthLocalDataSource.getUserFirebaseId(),
      'authProvider': getAuthProviderFromString(
        AuthLocalDataSource.getAuthType(),
      ),
    };
  }

  Future<void> setLocalAuthDetails({
    String? jwtToken,
    String? firebaseId,
    String? authType,
    bool? authStatus,
    bool? isNewUser,
  }) async {
    await _authLocalDataSource.changeAuthStatus(authStatus: authStatus);
    await _authLocalDataSource.setUserFirebaseId(firebaseId);
    await _authLocalDataSource.setAuthType(authType);
  }

  //First we signing user with given provider then add user details
  Future<({bool isNewUser, User user})> signInUser(
    AuthProviders authProvider, {
    required String email,
    required String password,
    required String verificationId,
    required String smsCode,
    String? appLanguage,
  }) async {
    try {
      final userCredentials = await _authRemoteDataSource.signInUser(
        authProvider,
        email: email,
        password: password,
        smsCode: smsCode,
        verificationId: verificationId,
      );

      final user = userCredentials.user;
      final additionalUserInfo = userCredentials.additionalUserInfo!;
      var isNewUser = additionalUserInfo.isNewUser;

      final firebaseUser = FirebaseAuth.instance.currentUser!;

      final userEmail =
          user?.email ??
          additionalUserInfo.profile?['email'] as String? ??
          firebaseUser.email ??
          '';
      final userPhotoUrl =
          user?.photoURL ??
          additionalUserInfo.profile?['picture'] as String? ??
          firebaseUser.photoURL ??
          '';
      final userPhoneNumber =
          user?.phoneNumber ?? firebaseUser.phoneNumber ?? '';
      final userName =
          user?.displayName ??
          additionalUserInfo.profile?['name'] as String? ??
          firebaseUser.displayName ??
          '';
      final userUid = user!.uid;

      /// checks in panel
      var userExists = !isNewUser;

      if (authProvider == AuthProviders.email) {
        print('[DEBUG] Checking if user exists for firebase_id: $userUid');
        userExists = await _authRemoteDataSource.isUserExist(userUid);
        print('[DEBUG] User exists in backend: $userExists');
      }

      if (!userExists) {
        isNewUser = true;
        print(
          '[DEBUG] Creating new user with firebase_id: $userUid, email: $userEmail',
        );
        final registeredUser = await _authRemoteDataSource.addUser(
          email: userEmail,
          firebaseId: userUid,
          mobile: userPhoneNumber,
          name: userName,
          type: authProvider.name,
          profile: userPhotoUrl,
          appLanguage: appLanguage,
        );

        print(
          '[DEBUG] Received user data - firebase_id: ${registeredUser['firebase_id']}, has api_token: ${registeredUser.containsKey('api_token')}',
        );

        await AuthLocalDataSource.setJwtToken(
          registeredUser['api_token'].toString(),
        );
        print('[DEBUG] Saved JWT token for new user');
      } else {
        print('[DEBUG] User exists, getting JWT for firebase_id: $userUid');
        final jwtToken = await _authRemoteDataSource.getJWTTokenOfUser(
          firebaseId: userUid,
          type: authProvider.name,
        );
        print('[DEBUG] Got JWT token: ${jwtToken.substring(0, 50)}...');

        await AuthLocalDataSource.setJwtToken(jwtToken);
        await _authRemoteDataSource.updateFcmId(
          firebaseId: userUid,
          userLoggingOut: false,
        );
      }

      return (user: user, isNewUser: isNewUser);
    } catch (e) {
      await signOut(authProvider);
      throw ApiException(e.toString());
    }
  }

  //to signUp user
  Future<void> signUpUser(String email, String password) async {
    try {
      await _authRemoteDataSource.signUpUser(email, password);
    } catch (e) {
      if (e.toString() != errorCodeEmailExists) {
        await signOut(AuthProviders.email);
      }
      throw ApiException(e.toString());
    }
  }

  Future<void> signOut(AuthProviders? authProvider) async {
    try {
      // Deregister user's device from FCM to prevent receiving notifications.
      await _authRemoteDataSource.updateFcmId(
        firebaseId: AuthLocalDataSource.getUserFirebaseId(),
        userLoggingOut: true,
      );
      await _authRemoteDataSource.signOut(authProvider);
      await setLocalAuthDetails(
        authStatus: false,
        authType: '',
        jwtToken: '',
        firebaseId: '',
        isNewUser: false,
      );
    } catch (e) {
      rethrow;
    }
  }

  //to add user's data to database. This will be in use when authenticating using phoneNumber
  Future<Map<String, dynamic>> addUserData({
    required String firebaseId,
    required String type,
    required String name,
    String? profile,
    String? mobile,
    String? email,
    String? referCode,
    String? friendCode,
    String? appLanguage,
  }) async {
    try {
      final result = await _authRemoteDataSource.addUser(
        email: email,
        firebaseId: firebaseId,
        friendCode: friendCode,
        mobile: mobile,
        name: name,
        profile: profile,
        referCode: referCode,
        type: type,
        appLanguage: appLanguage,
      );

      //Update jwt token
      await AuthLocalDataSource.setJwtToken(result['api_token'].toString());

      return Map.from(result); //
    } catch (e) {
      await signOut(AuthProviders.mobile);
      throw ApiException(e.toString());
    }
  }

  AuthProviders getAuthProviderFromString(String? value) {
    AuthProviders authProvider;
    if (value == 'gmail') {
      authProvider = AuthProviders.gmail;
    } else if (value == 'mobile') {
      authProvider = AuthProviders.mobile;
    } else if (value == 'apple') {
      authProvider = AuthProviders.apple;
    } else {
      authProvider = AuthProviders.email;
    }
    return authProvider;
  }
}
