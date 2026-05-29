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
                  // App logo
                  Image.asset(
                    'assets/images/logo.png',
                    width: 88,
                    height: 88,
                    fit: BoxFit.contain,
                  ),
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
                    label: 'Continue with Email',
                    icon: Icons.email_outlined,
                    outlined: true,
                    onTap: isLoading
                        ? null
                        : () => _showEmailDialog(ctx),
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

  void _showEmailDialog(BuildContext ctx) {
    final cubit = ctx.read<AuthCubit>();
    showDialog(
      context: ctx,
      builder: (_) => _EmailAuthDialog(cubit: cubit),
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

// ── Email / Password dialog ────────────────────────────────────────────────────

class _EmailAuthDialog extends StatefulWidget {
  const _EmailAuthDialog({required this.cubit});
  final AuthCubit cubit;

  @override
  State<_EmailAuthDialog> createState() => _EmailAuthDialogState();
}

class _EmailAuthDialogState extends State<_EmailAuthDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLogin = true;
  bool _obscure = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    Navigator.of(context).pop(); // dismiss before emitting loading state
    if (_isLogin) {
      widget.cubit.signInWithEmail(email: email, password: password);
    } else {
      widget.cubit.registerWithEmail(
        email: email,
        password: password,
        name: _nameCtrl.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isLogin ? 'Sign in' : 'Create account'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_isLogin) ...[
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter your name'
                      : null,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter your email';
                  if (!v.contains('@')) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter your password';
                  if (!_isLogin && v.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              setState(() => _isLogin = !_isLogin),
          child: Text(_isLogin ? 'New user? Create account' : 'Have an account? Sign in'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isLogin ? 'Sign in' : 'Create account'),
        ),
      ],
    );
  }
}

// ── Generic social button ──────────────────────────────────────────────────────

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
