import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/notification/cubit/notification_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/ui/widgets/already_logged_in_dialog.dart';
import 'package:flutterquiz/ui/widgets/circular_progress_container.dart';
import 'package:flutterquiz/ui/widgets/custom_rounded_button.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreen();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (_) => BlocProvider<NotificationCubit>(
        create: (_) => NotificationCubit(),
        child: const NotificationScreen(),
      ),
    );
  }
}

class _NotificationScreen extends State<NotificationScreen> {
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    controller.addListener(scrollListener);
    context.read<NotificationCubit>().fetchNotifications();
  }

  void scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<NotificationCubit>().hasMore) {
        context.read<NotificationCubit>().fetchMoreNotifications();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildHeader(context),
                const SizedBox(height: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.width * UiUtils.hzMarginPct,
                    ),
                    child: BlocConsumer<NotificationCubit, NotificationState>(
                      bloc: context.read<NotificationCubit>(),
                      listener: (context, state) {
                        if (state is NotificationFailure) {
                          if (state.errorMessageCode ==
                              errorCodeUnauthorizedAccess) {
                            showAlreadyLoggedInDialog(context);
                          }
                        }
                      },
                      builder: (context, state) {
                        if (state is NotificationProgress ||
                            state is NotificationInitial) {}
                        if (state is NotificationFailure) {
                          return ErrorContainer(
                            showBackButton: false,
                            errorMessageColor: Theme.of(
                              context,
                            ).colorScheme.onTertiary,
                            showErrorImage: true,
                            errorMessage: convertErrorCodeToLanguageKey(
                              state.errorMessageCode,
                            ),
                            onTapRetry: context
                                .read<NotificationCubit>()
                                .fetchNotifications,
                          );
                        }

                        if (state is NotificationSuccess) {
                          return ListView.separated(
                            controller: controller,
                            itemCount: state.notifications.length,
                            separatorBuilder: (_, i) =>
                                const SizedBox(height: UiUtils.listTileGap),
                            itemBuilder: (_, i) {
                              if (state.hasMore &&
                                  i == (state.notifications.length - 1)) {
                                return const Center(
                                  child: CircularProgressContainer(),
                                );
                              }
                              return _NotificationCard(state.notifications[i]);
                            },
                          );
                        }

                        return const Center(child: CircularProgressContainer());
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.width * UiUtils.hzMarginPct,
      ),
      child: Row(
        children: [
          _GlassIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: Navigator.of(context).pop,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.tr('notificationLbl')!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F51D9),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard(this.notification);

  final Map<String, dynamic> notification;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd/MM 'at' ").add_jm();
    final formattedDate = dateFormat.format(
      DateTime.parse(notification['date_sent'].toString()),
    );

    final title = notification['title'].toString();
    final message = notification['message'].toString();
    final image = notification['image'].toString();
    final type = notification['type'].toString();

    void onTapNotification() {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: UiUtils.bottomSheetTopRadius,
        ),
        builder: (context) {
          void onTapLetsPlay() {
            context.shouldPop();
            Navigator.of(context).pushNamed(
              Routes.category,
              arguments: {
                'quizType': switch (type) {
                  'guess-the-word-category' => QuizTypes.guessTheWord,
                  'audio-question-category' => QuizTypes.audioQuestions,
                  'fun-n-learn-category' => QuizTypes.funAndLearn,
                  _ => QuizTypes.quizZone,
                },
              },
            );
          }

          return ClipRRect(
            borderRadius: UiUtils.bottomSheetTopRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: UiUtils.bottomSheetTopRadius,
                  border: Border.all(
                    color: const Color(0xFF1F51D9).withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                height: context.height * .7,
                padding: EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: context.shortestSide * UiUtils.hzMarginPct + 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// Close Button
                    Row(
                      children: [
                        const Spacer(),
                        _GlassIconButton(
                          icon: Icons.close_rounded,
                          onTap: context.shouldPop,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    ///
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: Color(0xFF1F51D9),
                              ),
                            ),

                            ///
                            const SizedBox(height: 12),
                            if (image.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: image,
                                  fit: BoxFit.cover,
                                  placeholder: (_, s) =>
                                      Image.asset(Assets.placeholder),
                                  errorWidget: (_, s, d) =>
                                      Image.asset(Assets.placeholder),
                                ),
                              ),

                            ///
                            const SizedBox(height: 12),
                            Text(
                              message,
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                                color: const Color(
                                  0xFF1F51D9,
                                ).withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    ///
                    const SizedBox(height: 12),
                    if (type.endsWith('category'))
                      CustomRoundedButton(
                        onTap: onTapLetsPlay,
                        widthPercentage: context.shortestSide,
                        backgroundColor: const Color(0xFF4A75E8),
                        buttonTitle: context.tr('letsPlay'),
                        radius: 12,
                        showBorder: false,
                        height: 48,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: onTapNotification,
      child: _GlassListCard(
        child: Row(
          children: [
            /// Image
            const SizedBox(width: 12),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: image,
                  fit: BoxFit.cover,
                  placeholder: (_, s) => Image.asset(Assets.placeholder),
                  errorWidget: (_, s, d) => Image.asset(Assets.placeholder),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),

                  /// Title
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1F51D9),
                    ),
                  ),

                  /// Desc
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                      color: const Color(0xFF1F51D9).withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 6),

                  /// Date
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                      color: const Color(0xFF1F51D9).withValues(alpha: 0.45),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _GlassListCard extends StatelessWidget {
  const _GlassListCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF1F51D9).withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF1F51D9).withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1F51D9),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
