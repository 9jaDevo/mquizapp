import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/widgets/custom_snackbar.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/auth/auth_repository.dart';
import 'package:flutterquiz/features/auth/cubits/sign_up_cubit.dart';
import 'package:flutterquiz/features/auth/models/auth_providers_enum.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/app_logo.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/email_textfield.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/pswd_textfield.dart';
import 'package:flutterquiz/ui/screens/auth/widgets/terms_and_condition.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();

  static Route<dynamic> route() {
    return CupertinoPageRoute(builder: (_) => const SignUpScreen());
  }
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  final emailController = TextEditingController();
  final pswdController = TextEditingController();
  final confirmPswdController = TextEditingController();
  String userEmail = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignUpCubit>(
      create: (_) => SignUpCubit(AuthRepository()),
      child: Builder(
        builder: (_) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              _buildBackground(),
              SafeArea(child: SingleChildScrollView(child: form())),
            ],
          ),
        ),
      ),
    );
  }

  Widget form() {
    final size = context;

    return Form(
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
            Align(alignment: Alignment.centerLeft, child: _buildBackButton()),
            const SizedBox(height: 16),
            _buildLogoCard(),
            const SizedBox(height: 24),
            Text(
              'Create Account',
              style: GoogleFonts.nunito(
                textStyle: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F51D9),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Join the competition today',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: size.height * 0.04),
            EmailTextField(controller: emailController),
            SizedBox(height: size.height * 0.02),
            PswdTextField(controller: pswdController),
            SizedBox(height: size.height * 0.02),
            PswdTextField(
              controller: confirmPswdController,
              hintText: "${context.tr("cnPwdLbl")!}*",
              validator: (val) {
                if (val != pswdController.text) {
                  return context.tr('cnPwdNotMatchMsg');
                }
                return null;
              },
            ),
            SizedBox(height: size.height * 0.04),
            signupButton(),
            const SizedBox(height: 18),
            showGoSignIn(),
            const SizedBox(height: 20),
            const TermsAndCondition(),
            const SizedBox(height: 20),
            _buildPagerDots(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget showGoSignIn() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.tr('alreadyAccountLbl')!,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: Navigator.of(context).pop,
          child: Text(
            context.tr('loginLbl')!,
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

  Widget signupButton() {
    return SizedBox(
      width: context.width,
      height: 58,
      child: BlocConsumer<SignUpCubit, SignUpState>(
        listener: (context, state) async {
          if (state is SignUpSuccess) {
            //on signup success navigate user to sign in screen
            context.showSnack(
              "${context.tr('emailVerify')} $userEmail",
            );
            setState(() {
              Navigator.pop(context);
            });
          } else if (state is SignUpFailure) {
            //show error message
            context.showSnack(
              context.tr(
                convertErrorCodeToLanguageKey(state.errorMessage),
              )!,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is SignUpProgress;

          return AbsorbPointer(
            absorbing: isLoading,
            child: GestureDetector(
              onTap: () async {
                if (_formKey.currentState!.validate()) {
                  //calling signup user
                  context.read<SignUpCubit>().signUpUser(
                    AuthProviders.email,
                    emailController.text.trim(),
                    pswdController.text.trim(),
                  );
                  userEmail = emailController.text.trim();
                  resetForm();
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
                        context.tr('signUpLbl')!,
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

  void resetForm() {
    setState(() {
      isLoading = false;
      emailController.text = '';
      pswdController.text = '';
      confirmPswdController.text = '';
      _formKey.currentState!.reset();
    });
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

  Widget _buildBackButton() {
    return InkWell(
      onTap: Navigator.of(context).pop,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF1F51D9).withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 15,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF1F51D9),
            ),
          ),
        ),
      ),
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
