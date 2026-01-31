import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/auth/auth_remote_data_source.dart';
import 'package:flutterquiz/features/auth/auth_repository.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/auth/cubits/sign_in_cubit.dart';
import 'package:flutterquiz/features/auth/models/auth_providers_enum.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/app_logo.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/email_textfield.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/pswd_textfield.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/terms_and_condition.dart';
import 'package:flutterquiz/ui/screens/profile/create_or_edit_profile_screen.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();

  static Route<dynamic> route() {
    return CupertinoPageRoute(builder: (_) => const SignInScreen());
  }
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyDialog = GlobalKey<FormState>();

  bool isLoading = false;

  final emailController = TextEditingController();
  final forgotPswdController = TextEditingController();
  final pswdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignInCubit>(
      create: (_) => SignInCubit(AuthRepository()),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              _buildBackground(),
              SafeArea(
                child: SingleChildScrollView(child: showForm(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showForm(BuildContext context) {
    final size = context;
    final c = context.read<SystemConfigCubit>();

    return BlocListener<SignInCubit, SignInState>(
      listener: (context, state) {
        if (state is SignInSuccess &&
            state.authProvider != AuthProviders.email) {
          context.read<AuthCubit>().updateAuthDetails(
            authProvider: state.authProvider,
            firebaseId: state.user.uid,
            authStatus: true,
            isNewUser: state.isNewUser,
          );
          if (state.isNewUser) {
            context.read<UserDetailsCubit>().fetchUserDetails();
            context.pushReplacementNamed(
              Routes.selectProfile,
              arguments: const CreateOrEditProfileScreenArgs(isNewUser: true),
            );
          } else {
            context.read<UserDetailsCubit>().fetchUserDetails();
            context.pushNamedAndRemoveUntil(
              Routes.home,
              predicate: (_) => false,
            );
          }
        } else if (state is SignInFailure &&
            state.authProvider != AuthProviders.email) {
          context.showSnack(
            context.tr(convertErrorCodeToLanguageKey(state.errorMessage))!,
          );
        }
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.02,
            horizontal: size.shortestSide * UiUtils.hzMarginPct + 14,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: size.height * 0.02),
              _buildLogoCard(),
              const SizedBox(height: 24),
              Text(
                'Welcome',
                style: GoogleFonts.nunito(
                  textStyle: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F51D9),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in to compete with players worldwide',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              if (c.areAllLoginMethodsDisabled)
                ..._buildNoLoginMethods()
              else ...[
                if (c.isEmailLoginMethodEnabled) ...[
                  ..._buildEmailLoginMethod(context, size.height),
                ],

                ///
                if (c.isPhoneLoginMethodEnabled ||
                    c.isAppleLoginMethodEnabled ||
                    c.isGmailLoginMethodEnabled)
                  ..._buildSocialMediaLoginMethods(context, size.height),
              ],
              const SizedBox(height: 24),
              const TermsAndCondition(),
              const SizedBox(height: 20),
              _buildPagerDots(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSocialMediaLoginMethods(
    BuildContext context,
    double height,
  ) {
    final c = context.read<SystemConfigCubit>();

    return [
      if (Platform.isIOS && !c.isAppleLoginMethodEnabled) ...[
        const SizedBox(height: 10),
        Text(
          context.tr('forIOSMustEnableAppleLogin')!,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
      ],
      if (c.isEmailLoginMethodEnabled) ...[
        buildOrContinueWith(),
        SizedBox(height: height * 0.02),
        showSocialMedia(context),
      ] else ...[
        BlocBuilder<SignInCubit, SignInState>(
          builder: (context, state) {
            return Column(
              children: state is SignInProgress
                  ? [const Center(child: CircularProgressContainer())]
                  : [
                      /// Apple Login
                      if (Platform.isIOS && c.isAppleLoginMethodEnabled) ...[
                        _buildLoginButton(
                          title: context.tr('signInApple')!,
                          icon: Assets.appleIcon,
                          onTap: () => context.read<SignInCubit>().signInUser(
                            AuthProviders.apple,
                            appLanguage: context
                                .read<AppLocalizationCubit>()
                                .activeLanguage
                                .name,
                          ),
                        ),
                      ],

                      /// Gmail Login
                      if (c.isGmailLoginMethodEnabled) ...[
                        if (Platform.isIOS && c.isAppleLoginMethodEnabled) ...[
                          const SizedBox(height: 10),
                        ],
                        _buildLoginButton(
                          title: context.tr('signInGoogle')!,
                          icon: Assets.googleIcon,
                          onTap: () => context.read<SignInCubit>().signInUser(
                            AuthProviders.gmail,
                            appLanguage: context
                                .read<AppLocalizationCubit>()
                                .activeLanguage
                                .name,
                          ),
                        ),
                      ],

                      /// Phone Login
                      if (c.isPhoneLoginMethodEnabled) ...[
                        if (c.isAppleLoginMethodEnabled ||
                            c.isGmailLoginMethodEnabled) ...[
                          const SizedBox(height: 10),
                        ],
                        _buildLoginButton(
                          title: context.tr('signInPhone')!,
                          icon: Assets.phoneIcon,
                          onTap: () => context.pushNamed(Routes.otpScreen),
                        ),
                      ],
                    ],
            );
          },
        ),
      ],
    ];
  }

  Widget _buildLoginButton({
    required String title,
    required String icon,
    required VoidCallback onTap,
  }) {
    return _buildSocialButton(
      title: title,
      icon: icon,
      onTap: onTap,
      iconBackground: Colors.white,
      iconGradient: null,
    );
  }

  List<Widget> _buildNoLoginMethods() {
    return [
      const SizedBox(height: 20),
      Text(
        context.tr('noLoginMethodsWarning')!,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: Theme.of(context).colorScheme.onTertiary,
          fontWeight: FontWeights.regular,
        ),
      ),
      const SizedBox(height: 20),
    ];
  }

  List<Widget> _buildEmailLoginMethod(BuildContext context, double height) {
    return [
      EmailTextField(controller: emailController),
      SizedBox(height: height * .02),
      PswdTextField(controller: pswdController),
      SizedBox(height: height * .01),
      forgetPwd(),
      SizedBox(height: height * 0.02),
      showSignIn(context),
      SizedBox(height: height * 0.02),
      showGoSignup(),
    ];
  }

  Widget showSignIn(BuildContext context) {
    return SizedBox(
      width: context.width,
      height: 58,
      child: BlocConsumer<SignInCubit, SignInState>(
        bloc: context.read<SignInCubit>(),
        listener: (context, state) async {
          //Exceuting only if authProvider is email
          if (state is SignInSuccess &&
              state.authProvider == AuthProviders.email) {
            //to update authdetails after successfull sign in
            context.read<AuthCubit>().updateAuthDetails(
              authProvider: state.authProvider,
              firebaseId: state.user.uid,
              authStatus: true,
              isNewUser: state.isNewUser,
            );
            if (state.isNewUser) {
              await context.read<UserDetailsCubit>().fetchUserDetails();
              //navigate to select profile screen

              await context.pushReplacementNamed(
                Routes.selectProfile,
                arguments: const CreateOrEditProfileScreenArgs(isNewUser: true),
              );
            } else {
              //get user detials of signed in user
              await context.read<UserDetailsCubit>().fetchUserDetails();
              await context.pushNamedAndRemoveUntil(
                Routes.home,
                predicate: (_) => false,
              );
            }
          } else if (state is SignInFailure &&
              state.authProvider == AuthProviders.email) {
            context.showSnack(
              context.tr(convertErrorCodeToLanguageKey(state.errorMessage))!,
            );
          }
        },
        builder: (context, state) {
          final isLoading =
              state is SignInProgress &&
              state.authProvider == AuthProviders.email;

          return AbsorbPointer(
            absorbing: isLoading,
            child: GestureDetector(
              onTap: () async {
                if (_formKey.currentState!.validate()) {
                  context.read<SignInCubit>().signInUser(
                    AuthProviders.email,
                    email: emailController.text.trim(),
                    password: pswdController.text.trim(),
                    appLanguage: context
                        .read<AppLocalizationCubit>()
                        .activeLanguage
                        .name,
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1F51D9), Color(0xFF4A75E8)],
                  ),
                  border: Border.all(
                    color: const Color(0xFF1F51D9).withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A000000),
                      blurRadius: 25,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: isLoading
                    ? const CircularProgressContainer(whiteLoader: true)
                    : Text(
                        context.tr('loginLbl')!,
                        style: GoogleFonts.nunito(
                          textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeights.bold,
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Padding forgetPwd() {
    return Padding(
      padding: const EdgeInsets.only(right: 6, top: 6, bottom: 6),
      child: Align(
        alignment: Alignment.bottomRight,
        child: InkWell(
          splashColor: Colors.white,
          child: Text(
            context.tr('forgotPwdLbl')!,
            style: TextStyle(
              fontWeight: FontWeights.semiBold,
              fontSize: 14,
              height: 1.21,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
            ),
          ),
          onTap: () async {
            await showModalBottomSheet<void>(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              shape: const RoundedRectangleBorder(
                borderRadius: UiUtils.bottomSheetTopRadius,
              ),
              context: context,
              builder: (context) => Padding(
                padding: MediaQuery.of(context).viewInsets,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: UiUtils.bottomSheetTopRadius,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 24,
                        offset: Offset(0, -6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
                  child: Form(
                    key: _formKeyDialog,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 4,
                          width: 46,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF1F51D9,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          context.tr('resetPwdLbl')!,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFF1F51D9),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tr('resetEnterEmailLbl')!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.7),
                            fontWeight: FontWeights.regular,
                          ),
                        ),
                        const SizedBox(height: 16),
                        EmailTextField(
                          controller: forgotPswdController,
                        ),
                        const SizedBox(height: 18),
                        _buildSheetPrimaryButton(
                          title: context.tr('submitBtn')!,
                          onTap: () {
                            final form = _formKeyDialog.currentState;
                            if (form!.validate()) {
                              form.save();
                              context.showSnack(
                                context.tr('pwdResetLinkLbl')!,
                              );
                              AuthRemoteDataSource().resetPassword(
                                forgotPswdController.text.trim(),
                              );
                              Future.delayed(const Duration(seconds: 1), () {
                                context.pop('Cancel');
                              });

                              forgotPswdController.text = '';
                              form.reset();
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildSheetSecondaryButton(
                          title: context.tr('cancel') ?? 'Cancel',
                          onTap: () => context.pop('Cancel'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildOrContinueWith() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFF1F51D9).withValues(alpha: 0.2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          context.tr('loginSocialMediaLbl') ?? 'or continue with',
          style: TextStyle(
            fontWeight: FontWeights.semiBold,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFF1F51D9).withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }

  Widget showSocialMedia(BuildContext context) {
    return BlocBuilder<SignInCubit, SignInState>(
      builder: (context, state) {
        final c = context.read<SystemConfigCubit>();
        final isLoading =
            state is SignInProgress &&
            state.authProvider != AuthProviders.email;

        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Center(child: CircularProgressContainer()),
          );
        }

        final buttons = <Widget>[];

        if (c.isGmailLoginMethodEnabled) {
          buttons.add(
            _buildSocialButton(
              title: context.tr('signInGoogle')!,
              icon: Assets.googleIcon,
              onTap: () => context.read<SignInCubit>().signInUser(
                AuthProviders.gmail,
                appLanguage: context
                    .read<AppLocalizationCubit>()
                    .activeLanguage
                    .name,
              ),
              iconBackground: Colors.white,
              iconGradient: null,
            ),
          );
        }

        if (c.isPhoneLoginMethodEnabled) {
          buttons.add(
            _buildSocialButton(
              title: context.tr('signInPhone')!,
              icon: Assets.phoneIcon,
              onTap: () => context.pushNamed(Routes.otpScreen),
              iconBackground: null,
              iconGradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1F51D9), Color(0xFF4A75E8)],
              ),
              iconColor: Colors.white,
            ),
          );
        }

        if (Platform.isIOS && c.isAppleLoginMethodEnabled) {
          buttons.add(
            _buildSocialButton(
              title: context.tr('signInApple')!,
              icon: Assets.appleIcon,
              onTap: () => context.read<SignInCubit>().signInUser(
                AuthProviders.apple,
                appLanguage: context
                    .read<AppLocalizationCubit>()
                    .activeLanguage
                    .name,
              ),
              iconBackground: null,
              iconGradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E293B), Color(0xFF000000)],
              ),
              iconColor: Colors.white,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            children: _withSpacing(buttons, 12),
          ),
        );
      },
    );
  }

  Widget showGoSignup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.tr('noAccountLbl')!,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeights.regular,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 4),
        CupertinoButton(
          onPressed: () {
            _formKey.currentState!.reset();
            context.pushNamed(Routes.signUp);
          },
          padding: EdgeInsets.zero,
          child: Text(
            context.tr('signUpLbl')!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeights.semiBold,
              decoration: TextDecoration.underline,
              decorationColor: Theme.of(context).primaryColor,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.6, -0.6),
            radius: 1.1,
            colors: [
              Colors.white,
              Color(0xFFEAF2FF),
              Color(0xFFCFE0FF),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoCard() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1F51D9).withValues(alpha: 0.3),
                const Color(0xFF3B82F6).withValues(alpha: 0.3),
              ],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 40,
                offset: Offset(0, 12),
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 128,
              height: 128,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF1F51D9).withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 50,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: const AppLogo(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPagerDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _PagerDot(opacity: 0.5),
        SizedBox(width: 8),
        _PagerDot(opacity: 0.7),
        SizedBox(width: 8),
        _PagerDot(opacity: 0.9),
      ],
    );
  }

  Widget _buildSocialButton({
    required String title,
    required String icon,
    required VoidCallback onTap,
    Gradient? iconGradient,
    Color? iconBackground,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1F51D9).withValues(alpha: 0.2),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                gradient: iconGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                icon,
                height: 22,
                width: 22,
                colorFilter: iconColor == null
                    ? null
                    : ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeights.semiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _withSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) {
      return [const SizedBox.shrink()];
    }

    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i != children.length - 1) {
        spaced.add(SizedBox(height: spacing));
      }
    }
    return spaced;
  }

  Widget _buildSheetPrimaryButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF1F51D9),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          title,
          style: GoogleFonts.nunito(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeights.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSheetSecondaryButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF1F51D9).withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.nunito(
            textStyle: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: 16,
              fontWeight: FontWeights.semiBold,
            ),
          ),
        ),
      ),
    );
  }
}

class _PagerDot extends StatelessWidget {
  const _PagerDot({required this.opacity});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF1F51D9).withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
