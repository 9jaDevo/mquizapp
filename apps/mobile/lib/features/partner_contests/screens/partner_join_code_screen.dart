import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mquiz/core/constants/app_constants.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/features/partner_contests/cubit/partner_contest_list_cubit.dart';

class PartnerJoinCodeScreen extends StatefulWidget {
  const PartnerJoinCodeScreen({super.key});

  @override
  State<PartnerJoinCodeScreen> createState() => _PartnerJoinCodeScreenState();
}

class _PartnerJoinCodeScreenState extends State<PartnerJoinCodeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _lookup() {
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) return;
    context.read<PartnerJoinCodeCubit>().lookup(code);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        title: const Text('Enter Invite Code'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Got an invite code?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Enter the code below to find a private partner contest.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'e.g. A1B2C3D4',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _lookup,
                ),
              ),
              onSubmitted: (_) => _lookup(),
            ),
            const SizedBox(height: 24),
            BlocConsumer<PartnerJoinCodeCubit, PartnerJoinCodeState>(
              listener: (context, state) {
                if (state is PartnerJoinCodeFound) {
                  context.pushReplacement('/partner-contests/${state.contest.id}', extra: state.contest);
                }
              },
              builder: (context, state) {
                return switch (state) {
                  PartnerJoinCodeLoading() => const Center(child: CircularProgressIndicator()),
                  PartnerJoinCodeError(message: final m) => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppColors.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(m, style: TextStyle(color: AppColors.error))),
                        ],
                      ),
                    ),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Find Contest'),
                onPressed: _lookup,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
