import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/features/auth/cubit/auth_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (ctx, state) {
          if (state is Authenticated) {
            ctx.go(AppConstants.routeHome);
          } else if (state is AuthNeedsProfileSetup) {
            ctx.go(AppConstants.routeProfileSetup);
          } else if (state is AuthOtpSent) {
            ctx.go(
              AppConstants.routeOtp,
              extra: {
                'verificationId': state.verificationId,
                'phoneNumber': state.phoneNumber,
              },
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.wrong,
              ),
            );
          }
        },
        builder: (ctx, state) {
          final isLoading = state is AuthLoading;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  // Hero section
                  const FlutterLogo(size: 72),
                  const SizedBox(height: 24),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Learn. Play. Win.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const Spacer(),
                  // Sign-in buttons
                  _SocialButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata_rounded,
                    onTap: isLoading
                        ? null
                        : () => ctx.read<AuthCubit>().signInWithGoogle(),
                  ),
                  const SizedBox(height: 12),
                  _SocialButton(
                    label: 'Continue with Apple',
                    icon: Icons.apple,
                    color: Colors.black,
                    labelColor: Colors.white,
                    onTap: isLoading
                        ? null
                        : () => ctx.read<AuthCubit>().signInWithApple(),
                  ),
                  const SizedBox(height: 12),
                  _SocialButton(
                    label: 'Continue with Phone',
                    icon: Icons.phone_android,
                    outlined: true,
                    onTap: isLoading ? null : () => _showPhoneDialog(ctx),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => ctx.read<AuthCubit>().signInAsGuest(),
                    child: const Text('Continue as Guest'),
                  ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const LinearProgressIndicator(
                      backgroundColor: AppColors.border,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  const SizedBox(height: 24),
                  // Terms
                  Text(
                    'By continuing you agree to our Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPhoneDialog(BuildContext ctx) {
    final controller = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Enter phone number'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: '+2348012345678',
            prefixIcon: Icon(Icons.phone),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final phone = controller.text.trim();
              if (phone.isNotEmpty) {
                Navigator.pop(ctx);
                ctx.read<AuthCubit>().verifyPhoneNumber(phone);
              }
            },
            child: const Text('Send OTP'),
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    this.onTap,
    this.color,
    this.labelColor,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final Color? labelColor;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
        ),
      );
    }
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: labelColor ?? Colors.white),
      label: Text(
        label,
        style: TextStyle(color: labelColor ?? Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
        minimumSize: const Size(double.infinity, 52),
      ),
    );
  }
}
