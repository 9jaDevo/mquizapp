import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/wallet/cubit/monetization_cubit.dart';
import 'package:flutterquiz/features/wallet/models/monetization_models.dart';
import 'package:flutterquiz/ui/styles/glass_theme.dart';
import 'package:flutterquiz/ui/widgets/glass_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';

/// Glassmorphism daily streak widget
class DailyStreakGlassWidget extends StatelessWidget {
  final DailyStreakModel streak;

  const DailyStreakGlassWidget({
    required this.streak,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GlassContainer(
        intensity: GlassIntensity.accent,
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            // Fire icon with glow
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF6B6B), // Red
                    Color(0xFFFFA500), // Orange
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B6B).withValues(alpha: .4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Text(
                '🔥',
                style: TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(width: 16),

            // Streak info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.tr('dailyStreak') ?? 'Daily Streak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.primaryTextColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${streak.currentStreak} days',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• +${streak.coinsEarned} coins',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.primaryTextColor.withValues(alpha: .65),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.primaryColor.withValues(alpha: .3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star,
                    size: 14,
                    color: context.primaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Keep it up!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glassmorphism sponsor banner widget
class SponsorBannerGlassWidget extends StatelessWidget {
  final SponsorBannerModel banner;
  final VoidCallback? onBannerTap;

  const SponsorBannerGlassWidget({
    required this.banner,
    super.key,
    this.onBannerTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onBannerTap,
        child: GlassContainer(
          intensity: GlassIntensity.medium,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(20),
          height: 160,
          child: Stack(
            children: [
              // Background image or gradient
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: banner.bannerImage != null &&
                          banner.bannerImage!.isNotEmpty
                      ? Image.network(
                          banner.bannerImage!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: context.primaryColor.withValues(alpha: .1),
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator.adaptive(),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    context.primaryColor,
                                    context.primaryColor
                                        .withValues(alpha: .7),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                context.primaryColor,
                                context.primaryColor.withValues(alpha: .7),
                              ],
                            ),
                          ),
                        ),
                ),
              ),

              // Overlay gradient
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: .3),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Sponsor badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: .3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite,
                            size: 14,
                            color: Colors.white.withValues(alpha: .8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Sponsored',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: .8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Banner title and CTA
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          banner.bannerTitle ?? 'Special Offer',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Colors.white.withValues(alpha: .9),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Learn more',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: .9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Monetization section wrapper
class MonetizationGlassSection extends StatefulWidget {
  final bool isGuest;

  const MonetizationGlassSection({
    required this.isGuest,
    super.key,
  });

  @override
  State<MonetizationGlassSection> createState() =>
      _MonetizationGlassSectionState();
}

class _MonetizationGlassSectionState extends State<MonetizationGlassSection> {
  @override
  void initState() {
    super.initState();
    // Load sponsor banner when widget builds
    if (!widget.isGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<MonetizationCubit>().getSponsorBanner();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGuest) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Daily streak
        BlocBuilder<MonetizationCubit, MonetizationState>(
          builder: (context, state) {
            if (state.streak != null && state.streak!.coinsEarned > 0) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.width * UiUtils.hzMarginPct,
                ),
                child: DailyStreakGlassWidget(streak: state.streak!),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 8),

        // Sponsor banner
        BlocBuilder<MonetizationCubit, MonetizationState>(
          builder: (context, state) {
            if (state.banner != null) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.width * UiUtils.hzMarginPct,
                ),
                child: SponsorBannerGlassWidget(
                  banner: state.banner!,
                  onBannerTap: () {
                    context.read<MonetizationCubit>().recordBannerClick(
                      bannerId: state.banner!.bannerId,
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
