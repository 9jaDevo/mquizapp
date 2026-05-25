import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/features/auth/cubit/auth_cubit.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  final String verificationId;
  final String phoneNumber;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otp = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (ctx, state) {
          if (state is Authenticated) {
            ctx.go(AppConstants.routeHome);
          } else if (state is AuthNeedsProfileSetup) {
            ctx.go(AppConstants.routeProfileSetup);
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Text(
                  'Enter OTP',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sent to ${widget.phoneNumber}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 40),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10),
                    fieldHeight: 56,
                    fieldWidth: 48,
                    activeFillColor: AppColors.surface,
                    selectedFillColor: AppColors.surface,
                    inactiveFillColor: AppColors.pageBackground,
                    activeColor: AppColors.primary,
                    selectedColor: AppColors.primary,
                    inactiveColor: AppColors.border,
                  ),
                  enableActiveFill: true,
                  onChanged: (value) => _otp = value,
                  onCompleted: (value) {
                    _otp = value;
                    _confirm(ctx);
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : () => _confirm(ctx),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Verify'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirm(BuildContext ctx) {
    if (_otp.length < 6) return;
    ctx.read<AuthCubit>().confirmOtp(
          verificationId: widget.verificationId,
          smsCode: _otp,
          phoneNumber: widget.phoneNumber,
        );
  }
}
