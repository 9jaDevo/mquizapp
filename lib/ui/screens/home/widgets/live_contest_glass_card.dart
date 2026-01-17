import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/quiz/cubits/contest_cubit.dart';
import 'package:flutterquiz/features/quiz/models/contest_model.dart';
import 'package:flutterquiz/ui/styles/glass_theme.dart';
import 'package:flutterquiz/ui/widgets/glass_container.dart';
import 'package:flutterquiz/ui/widgets/q_image.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:intl/intl.dart';

/// Glassmorphism live contest card
class LiveContestGlassCard extends StatelessWidget {
  final ContestModel? contest;
  final VoidCallback? onViewAll;
  final VoidCallback? onPlayNow;

  const LiveContestGlassCard({
    required this.contest,
    super.key,
    this.onViewAll,
    this.onPlayNow,
  });

  @override
  Widget build(BuildContext context) {
    if (contest == null) {
      return _buildEmptyState(context);
    }

    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('h:mm a');

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: context.width * 0.04,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and view all
            Row(
              children: [
                Text(
                  context.tr('contest') ?? 'Live Contest',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.primaryTextColor,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                Semantics(
                  button: true,
                  label: 'View all contests',
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onViewAll?.call();
                    },
                    child: Text(
                      context.tr('viewAll') ?? 'View All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Contest card
            GlassContainer(
              intensity: GlassIntensity.medium,
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contest image
                  if (contest?.image != null && contest!.image!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.primaryColor.withValues(alpha: .2),
                              context.primaryColor.withValues(alpha: .05),
                            ],
                          ),
                        ),
                        child: QImage(
                          imageUrl: contest!.image!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            context.primaryColor,
                            context.primaryColor.withValues(alpha: .7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.trophy,
                        size: 60,
                        color: Colors.white.withValues(alpha: .7),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Contest title
                  Text(
                    contest?.name ?? 'Contest',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.primaryTextColor,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Contest description
                  if (contest?.description != null &&
                      contest!.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        contest!.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.primaryTextColor.withValues(alpha: .65),
                          height: 1.4,
                        ),
                      ),
                    ),

                  // Contest info row
                  Row(
                    children: [
                      // Entry fee
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.attach_money,
                          label: '${contest?.entryFees ?? 0} coins',
                          context: context,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // End date
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.calendar_today,
                          label: dateFormat.format(
                            DateTime.parse(contest?.endDate ?? ''),
                          ),
                          context: context,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Participants badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
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
                          Icons.people,
                          size: 14,
                          color: context.primaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${contest?.totalParticipant ?? 0} participants',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Play Now button
                  Semantics(
                    button: true,
                    label: 'Play contest',
                    child: Material(
                      color: context.primaryColor,
                      borderRadius: BorderRadius.circular(14),
                      elevation: 4,
                      shadowColor: context.primaryColor.withValues(alpha: .4),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          onPlayNow?.call();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                context.tr('play') ?? 'Play Now',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: context.width * 0.04,
      ),
      child: GlassContainer(
        intensity: GlassIntensity.light,
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        height: 120,
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 32,
              color: context.primaryColor,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                context.tr('noContestAvailable') ??
                    'No contests available right now',
                style: TextStyle(
                  fontSize: 14,
                  color: context.primaryTextColor.withValues(alpha: .7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small info chip for contest details
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final BuildContext context;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.primaryColor.withValues(alpha: .2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: context.primaryColor,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
