import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mquiz/core/theme/app_colors.dart';
import 'package:mquiz/core/widgets/common_widgets.dart';
import 'package:mquiz/features/lives/cubit/lives_cubit.dart';

/// Shows when the user runs out of lives. Server-authoritative: the result of
/// `restoreWithCoins` / `restoreWithAd` must come from the API.
class OutOfLivesSheet extends StatelessWidget {
  const OutOfLivesSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<LivesCubit>(),
        child: const OutOfLivesSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LivesCubit, LivesUiState>(
      builder: (context, state) {
        final acting = state is LivesLoaded && state.acting;
        final lives = state is LivesLoaded ? state.lives : null;
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_border,
                  color: AppColors.wrong, size: 56),
              const SizedBox(height: 12),
              const Text(
                'Out of Lives',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                lives?.nextRefillAt != null
                    ? 'Next free life in ${_formatCountdown(lives!.nextRefillAt!)}'
                    : 'Restore a life to keep playing.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Restore for 20 coins',
                icon: Icons.bolt_rounded,
                loading: acting,
                onPressed: acting
                    ? null
                    : () async {
                        final ok = await context
                            .read<LivesCubit>()
                            .restoreWithCoins();
                        if (!context.mounted) return;
                        if (ok) Navigator.of(context).pop(true);
                      },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: acting
                    ? null
                    : () async {
                        final ok = await context
                            .read<LivesCubit>()
                            .restoreWithAd();
                        if (!context.mounted) return;
                        if (ok) Navigator.of(context).pop(true);
                      },
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Watch ad for 1 life'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Maybe later'),
              ),
            ],
          ),
        );
      },
    );
  }

  static String _formatCountdown(DateTime target) {
    final d = target.difference(DateTime.now());
    if (d.isNegative) return 'now';
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '${h}h ${m}m' : '${m}:${s}';
  }
}

class LivesIndicator extends StatefulWidget {
  const LivesIndicator({super.key, this.compact = false});
  final bool compact;

  @override
  State<LivesIndicator> createState() => _LivesIndicatorState();
}

class _LivesIndicatorState extends State<LivesIndicator> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LivesCubit, LivesUiState>(
      builder: (context, state) {
        if (state is! LivesLoaded) {
          return const SizedBox.shrink();
        }
        final lives = state.lives;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite, color: AppColors.wrong, size: 16),
            const SizedBox(width: 4),
            Text(
              '${lives.current}/${lives.max}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        );
      },
    );
  }
}
