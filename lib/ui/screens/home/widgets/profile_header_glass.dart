import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/ui/widgets/glass_container.dart';
import 'package:flutterquiz/ui/widgets/skill_tier_badge.dart';
import 'package:flutterquiz/utils/extensions.dart';

/// Glassmorphism profile header for home screen
class ProfileHeaderGlass extends StatelessWidget {
  final String userName;
  final String userProfileImg;
  final bool isGuest;
  final VoidCallback onTapNotification;
  final VoidCallback onTapCoinStore;

  const ProfileHeaderGlass({
    required this.userName,
    required this.userProfileImg,
    required this.isGuest,
    required this.onTapNotification,
    required this.onTapCoinStore,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const minHeaderHeight = 100.0;
    const minContentHeight = 48.0;
    const iconSize = 48.0; // Increased from 36 to 48 for accessibility
    const avatarSize = 50.0; // Increased from 44 to 50

    final headerHeight = (context.height * .16).clamp(minHeaderHeight, 160.0);
    final sysConfigCubit = context.read<SystemConfigCubit>();

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Glass shadow effect
        Container(
          height: context.height * .01,
          width: context.width * .8,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.elliptical(context.height * .04, context.height * .04),
            ),
            boxShadow: [
              BoxShadow(
                color: context.primaryTextColor.withValues(alpha: .15),
                blurRadius: 20,
                spreadRadius: 6,
              ),
            ],
          ),
        ),

        // Glass header container
        GlassContainer(
          intensity: GlassIntensity.medium,
          height: headerHeight,
          width: context.width,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20), // Increased from 10 to 20
          ),
          child: SafeArea(
            bottom: false,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: minContentHeight),
              child: Row(
                children: [
                  // User Avatar with glass effect
                  _buildAvatar(context, avatarSize),
                  const SizedBox(width: 12),

                  // User info
                  Expanded(
                    child: _buildUserInfo(context),
                  ),
                  const SizedBox(width: 12),

                  // Notification button
                  _buildIconButton(
                    context: context,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTapNotification();
                    },
                    size: iconSize,
                    semanticLabel: isGuest
                        ? context.tr('login')
                        : context.tr('notificationsLbl'),
                    child: isGuest
                        ? Icon(
                            Icons.login_rounded,
                            color: context.surfaceColor,
                            size: 22,
                          )
                        : QImage(
                            imageUrl: Assets.notificationMenuIcon,
                            color: context.surfaceColor,
                            height: 22,
                            width: 22,
                            fit: BoxFit.contain,
                          ),
                  ),

                  // Coin store button (if enabled)
                  if (sysConfigCubit.isCoinStoreEnabled) ...[
                    const SizedBox(width: 12),
                    _buildIconButton(
                      context: context,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTapCoinStore();
                      },
                      size: iconSize,
                      semanticLabel: context.tr('coinStore') ?? 'Coin Store',
                      child: QImage(
                        imageUrl: Assets.coinMenuIcon,
                        color: context.surfaceColor,
                        height: 22,
                        width: 22,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context, double size) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: context.primaryTextColor.withValues(alpha: .15),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: context.primaryColor.withValues(alpha: .2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(3),
      width: size,
      height: size,
      child: QImage.circular(imageUrl: userProfileImg),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          userName,
          textAlign: TextAlign.start,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.primaryTextColor,
            fontSize: 19,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 6),
        const SkillTierBadge(),
      ],
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required VoidCallback onTap,
    required double size,
    required Widget child,
    required String? semanticLabel,
  }) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: context.primaryColor,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: context.primaryColor.withValues(alpha: .3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
