import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/commons/commons.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/ads.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/badges/blocs/badges_cubit.dart';
import 'package:flutterquiz/features/battle_room/cubits/battle_room_cubit.dart';
import 'package:flutterquiz/features/battle_room/cubits/multi_user_battle_room_cubit.dart';
import 'package:flutterquiz/features/exam/cubits/exam_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_local_data_source.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/features/quiz/cubits/contest_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/quiz_category_cubit.dart';
import 'package:flutterquiz/features/quiz/cubits/subcategory_cubit.dart';
import 'package:flutterquiz/features/quiz/models/quiz_type.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/wallet/cubit/monetization_cubit.dart';
import 'package:flutterquiz/features/wallet/models/monetization_models.dart';
import 'package:flutterquiz/features/wallet/widgets/monetization_widgets.dart';
import 'package:flutterquiz/ui/screens/battle/create_or_join_screen.dart';
import 'package:flutterquiz/ui/screens/home/widgets/all.dart';
import 'package:flutterquiz/ui/screens/home/widgets/daily_challenge_card.dart';
import 'package:flutterquiz/ui/screens/profile/create_or_edit_profile_screen.dart';
import 'package:flutterquiz/features/quiz_zone_tab/screens/quiz_zone_tab_screen.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/ui/widgets/skill_tier_badge.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
// (removed duplicate import)

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

typedef ZoneType = ({String title, String img, String desc});

class HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();
  final refreshKey = GlobalKey<RefreshIndicatorState>();

  bool get _isGuest => context.read<AuthCubit>().isGuest;

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  int _notificationId = 0;

  final battleZones = <ZoneType>[
    (title: 'groupPlay', img: Assets.groupBattleIcon, desc: 'desGroupPlay'),
    (title: 'battleQuiz', img: Assets.oneVsOneIcon, desc: 'desBattleQuiz'),
  ];

  final examZones = <ZoneType>[
    (title: 'exam', img: Assets.examQuizIcon, desc: 'desExam'),
    (
      title: 'selfChallenge',
      img: Assets.selfChallengeIcon,
      desc: 'challengeYourselfLbl',
    ),
  ];

  // Screen dimensions
  double get scrWidth => context.width;

  double get scrHeight => context.height;

  // HomeScreen horizontal margin, change from here
  double get hzMargin => scrWidth * UiUtils.hzMarginPct;

  double get _statusBarPadding => MediaQuery.of(context).padding.top;

  // TextStyles
  // check build() method
  late var _boldTextStyle = TextStyle(
    fontWeight: FontWeights.bold,
    fontSize: 18,
    color: Theme.of(context).colorScheme.onTertiary,
  );

  ///
  late String _currLangId;
  late final SystemConfigCubit _sysConfigCubit;

  @override
  void initState() {
    super.initState();

    showAppUnderMaintenanceDialog();

    _sysConfigCubit = context.read<SystemConfigCubit>();

    setQuizMenu();
    _initLocalNotification();
    setupInteractedMessage();

    /// Create Ads
    Future.delayed(Duration.zero, () async {
      await context.read<RewardedAdCubit>().createDailyRewardAd(context);
      context.read<InterstitialAdCubit>().createInterstitialAd(context);

      // Create app open ad
      await context.read<AppOpenAdCubit>().loadAppOpenAd(context);

      // Create rewarded interstitial ad
      await context
          .read<RewardedInterstitialAdCubit>()
          .createRewardedInterstitialAd(context);
    });

    WidgetsBinding.instance.addObserver(this);

    ///
    _currLangId = UiUtils.getCurrentQuizLanguageId(context);

    if (!_isGuest) {
      fetchUserDetails();

      // Fetch banners after user details are loaded (ensures JWT token is available)
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          log('[SPONSOR_BANNER] Triggering getSponsorBanners from HomeScreen');
          context.read<MonetizationCubit>().getSponsorBanners();
        }
      });

      context.read<ContestCubit>().getContest(languageId: _currLangId);

      // Step 2: Register device after login
      _registerDevice();

      // Step 3: Check daily streak with a slight delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          context.read<MonetizationCubit>().checkDailyStreak();
        }
      });
    }
  }

  // Step 2: Device registration helper
  Future<void> _registerDevice() async {
    try {
      final authCubit = context.read<AuthCubit>();
      final deviceId = await authCubit.getDeviceId();
      final deviceType = authCubit.getDeviceType();
      final deviceName = await authCubit.getDeviceName();

      if (mounted) {
        context.read<MonetizationCubit>().registerDevice(
          deviceId: deviceId,
          deviceType: deviceType,
          deviceName: deviceName,
        );
      }
    } catch (e) {
      log('Device registration failed: $e');
    }
  }

  // Step 5: Daily Streak Widget
  Widget _buildDailyStreakWidget() {
    return BlocBuilder<MonetizationCubit, MonetizationState>(
      builder: (context, state) {
        // Show widget if streak data exists (don't hide on loading or if coins == 0)
        if (state.streak != null) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: hzMargin),
            child: DailyStreakWidget(streak: state.streak!),
          );
        }
        // Show loading state while fetching
        if (state.isLoadingStreak) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: hzMargin),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A75E8), Color(0xFF60A5FA)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Step 4: Sponsor Banner Widget
  Widget _buildSponsorBanner() {
    return BlocBuilder<MonetizationCubit, MonetizationState>(
      builder: (context, state) {
        log('[SPONSOR_BANNER_UI] Building sponsor banner widget');
        log(
          '[SPONSOR_BANNER_UI] State - banners: ${state.banners?.length ?? 0}, banner: ${state.banner != null}, loading: ${state.isLoadingBanner}',
        );

        // Multiple banners - show carousel
        if (state.banners != null && state.banners!.isNotEmpty) {
          log(
            '[SPONSOR_BANNER_UI] Showing carousel with ${state.banners!.length} banners',
          );
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: hzMargin),
            child: SizedBox(
              height: 180,
              child: _SponsorBannerCarousel(banners: state.banners!),
            ),
          );
        }
        // Single banner fallback
        if (state.banner != null) {
          log('[SPONSOR_BANNER_UI] Showing single banner');
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: hzMargin),
            child: SponsorBannerWidget(
              banner: state.banner!,
              margin: const EdgeInsets.symmetric(vertical: 12),
              onBannerTap: () async {
                context.read<MonetizationCubit>().recordBannerClick(
                  bannerId: state.banner!.bannerId,
                );
                final uri = Uri.parse(state.banner!.redirectUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
          );
        }
        // Loading state
        if (state.isLoadingBanner) {
          log('[SPONSOR_BANNER_UI] Showing loading indicator');
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: hzMargin),
            child: Container(
              height: 180,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade200,
              ),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }
        log('[SPONSOR_BANNER_UI] No banner to show - returning empty widget');
        return const SizedBox.shrink();
      },
    );
  }

  void onTapTab() {
    if (_scrollController.hasClients && _scrollController.offset != 0) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } else {
      refreshKey.currentState?.show();
    }
  }

  void showAppUnderMaintenanceDialog() {
    Future.delayed(Duration.zero, () {
      if (_sysConfigCubit.isAppUnderMaintenance) {
        showDialog<void>(
          context: context,
          builder: (_) => const AppUnderMaintenanceDialog(),
        );
      }
    });
  }

  Future<void> _initLocalNotification() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initializationSettingsIOS = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onTapLocalNotification,
    );

    /// Request Permissions for IOS
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions();
    }
  }

  void setQuizMenu() {
    Future.delayed(Duration.zero, () {
      if (!_sysConfigCubit.isExamQuizEnabled) {
        examZones.removeWhere((e) => e.title == 'exam');
      }

      if (!_sysConfigCubit.isSelfChallengeQuizEnabled) {
        examZones.removeWhere((e) => e.title == 'selfChallenge');
      }

      if (!_sysConfigCubit.isGroupBattleEnabled) {
        battleZones.removeWhere((e) => e.title == 'groupPlay');
      }

      if (!_sysConfigCubit.isOneVsOneBattleEnabled &&
          !_sysConfigCubit.isRandomBattleEnabled) {
        battleZones.removeWhere((e) => e.title == 'battleQuiz');
      }

      setState(() {});
    });
  }

  static StreamSubscription<RemoteMessage>? notificationStream;

  Future<void> setupInteractedMessage() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        announcement: true,
        provisional: true,
      );
    } else {
      final isGranted = (await Permission.notification.status).isGranted;
      if (!isGranted) await Permission.notification.request();
    }

    await notificationStream?.cancel();

    await FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    // handle background notification
    FirebaseMessaging.onBackgroundMessage(UiUtils.onBackgroundMessage);
    //handle foreground notification
    notificationStream = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) async {
      if (message.data.isNotEmpty) {
        log('Notification arrives : ${message.toMap()}');
        final data = message.data;
        final title = data['title'].toString();
        final body = data['body'].toString();
        final type = data['type'].toString();
        final image = data['image'].toString();

        //payload is some data you want to pass in local notification
        if (image != 'null' && image.isNotEmpty) {
          log('image ${image.runtimeType}');
          await generateImageNotification(title, body, image, type, type);
        } else {
          await generateSimpleNotification(title, body, type);
        }

        //if notification type is badges then update badges in cubit list
        if (type == 'badges') {
          Future.delayed(Duration.zero, () {
            if (context.mounted) {
              context.read<BadgesCubit>().unlockBadge(
                data['badge_type'] as String,
              );
            }
          });
        } else if (type == 'payment_request') {
          Future.delayed(Duration.zero, () {
            context.read<UserDetailsCubit>().updateCoins(
              addCoin: true,
              coins: int.parse(data['coins'] as String),
            );
          });
        }
      }
    });
  }

  //quiz_type according to the notification category
  QuizTypes _getQuizTypeFromCategory(String category) {
    return switch (category) {
      'audio-question-category' => QuizTypes.audioQuestions,
      'guess-the-word-category' => QuizTypes.guessTheWord,
      'fun-n-learn-category' => QuizTypes.funAndLearn,
      _ => QuizTypes.quizZone,
    };
  }

  // notification type is category then move to category screen
  Future<void> _handleMessage(RemoteMessage message) async {
    try {
      if (message.data['type'].toString().contains('category')) {
        await Navigator.of(context).pushNamed(
          Routes.category,
          arguments: QuizZoneTabScreenArgs(
            quizType: _getQuizTypeFromCategory(message.data['type'] as String),
          ),
        );
      } else if (message.data['type'] == 'badges') {
        //if user open app by tapping
        UiUtils.updateBadgesLocally(context);
        await Navigator.of(context).pushNamed(Routes.badges);
      } else if (message.data['type'] == 'payment_request') {
        await Navigator.of(context).pushNamed(Routes.wallet);
      }
    } on Exception catch (e) {
      log(e.toString(), error: e);
    }
  }

  Future<void> _onTapLocalNotification(NotificationResponse? payload) async {
    final type = payload!.payload ?? '';
    if (type == 'badges') {
      await Navigator.of(context).pushNamed(Routes.badges);
    } else if (type.contains('category')) {
      await Navigator.of(context).pushNamed(
        Routes.category,
        arguments: QuizZoneTabScreenArgs(
          quizType: _getQuizTypeFromCategory(type),
        ),
      );
    } else if (type == 'payment_request') {
      await Navigator.of(context).pushNamed(Routes.wallet);
    }
  }

  Future<void> generateImageNotification(
    String title,
    String msg,
    String image,
    String payloads,
    String type,
  ) async {
    final largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: msg,
      htmlFormatSummaryText: true,
    );
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      kPackageName,
      kAppName,
      icon: '@drawable/ic_notification',
      channelDescription: kAppName,
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: bigPictureStyleInformation,
    );
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      _notificationId++,
      title,
      msg,
      platformChannelSpecifics,
      payload: payloads,
    );
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    return filePath;
  }

  // notification on foreground
  Future<void> generateSimpleNotification(
    String title,
    String body,
    String payloads,
  ) async {
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      kPackageName, //channel id
      kAppName, //channel name
      channelDescription: kAppName,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      icon: '@drawable/ic_notification',
    );

    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      _notificationId++,
      title,
      body,
      platformChannelSpecifics,
      payload: payloads,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    ProfileManagementLocalDataSource().updateReversedCoins(0);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    //show you left the game
    if (state == AppLifecycleState.resumed) {
      UiUtils.needToUpdateCoinsLocally(context);

      // Show app open ad when user resumes app
      context.read<AppOpenAdCubit>().showAppOpenAdIfAvailable();
    } else {
      ProfileManagementLocalDataSource().updateReversedCoins(0);
    }
  }

  void _onPressedSelfExam(String index) {
    if (_isGuest) {
      showLoginRequiredDialog(context);
      return;
    }

    if (index == 'exam') {
      context.read<ExamCubit>().reset();
      globalCtx.pushNamed(Routes.exams);
    } else if (index == 'selfChallenge') {
      context.read<QuizCategoryCubit>().reset();
      context.read<SubCategoryCubit>().reset();
      globalCtx.pushNamed(Routes.selfChallenge);
    }
  }

  void _onPressedBattle(String index) {
    if (_isGuest) {
      showLoginRequiredDialog(context);
      return;
    }

    context.read<QuizCategoryCubit>().reset();
    if (index == 'groupPlay') {
      context.read<MultiUserBattleRoomCubit>().reset(cancelSubscription: false);

      globalCtx.push(
        CupertinoPageRoute<void>(
          builder: (_) => BlocProvider<UpdateCoinsCubit>(
            create: (context) =>
                UpdateCoinsCubit(ProfileManagementRepository()),
            child: CreateOrJoinRoomScreen(
              quizType: QuizTypes.groupPlay,
              title: context.tr('groupPlay')!,
            ),
          ),
        ),
      );
    } else if (index == 'battleQuiz') {
      context.read<BattleRoomCubit>().updateState(
        const BattleRoomInitial(),
        cancelSubscription: true,
      );

      if (_sysConfigCubit.isRandomBattleEnabled) {
        globalCtx.pushNamed(Routes.randomBattle);
      } else {
        globalCtx.push(
          CupertinoPageRoute<CreateOrJoinRoomScreen>(
            builder: (_) => BlocProvider<UpdateCoinsCubit>(
              create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
              child: CreateOrJoinRoomScreen(
                quizType: QuizTypes.oneVsOneBattle,
                title: context.tr('playWithFrdLbl')!,
              ),
            ),
          ),
        );
      }
    }
  }

  late String _userName = context.tr('guest')!;
  String _userProfileImg = '';

  Widget _buildBattle() {
    return battleZones.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(
              left: hzMargin,
              right: hzMargin,
              top: scrHeight * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(battleOfTheDayKey)!,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeights.semiBold,
                    color: context.primaryTextColor,
                  ),
                ),

                /// Categories
                GridView.count(
                  // Create a grid with 2 columns. If you change the scrollDirection to
                  // horizontal, this produces 2 rows.
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 20,
                  padding: EdgeInsets.only(top: _statusBarPadding * 0.2),
                  crossAxisSpacing: 20,
                  physics: const NeverScrollableScrollPhysics(),
                  // Generate 100 widgets that display their index in the List.
                  children: List.generate(
                    battleZones.length,
                    (i) => QuizGridCard(
                      onTap: () => _onPressedBattle(battleZones[i].title),
                      title: context.tr(battleZones[i].title)!,
                      desc: context.tr(battleZones[i].desc)!,
                      img: battleZones[i].img,
                    ),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }

  Widget _buildExamSelf() {
    return examZones.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(
              left: hzMargin,
              right: hzMargin,
              top: scrHeight * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                examZones.length,
                (i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => _onPressedSelfExam(examZones[i].title),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF60A5FA).withValues(alpha: 0.15),
                            const Color(0xFF4A75E8).withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF60A5FA).withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icon container
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF4A75E8), Color(0xFF60A5FA)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF4A75E8,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: QImage(
                                imageUrl: examZones[i].img,
                                width: 28,
                                height: 28,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Text content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr(examZones[i].title)!,
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF4A75E8),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.tr(examZones[i].desc)!,
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(
                                      0xFF4A75E8,
                                    ).withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Arrow icon
                          Icon(
                            Icons.flash_on_rounded,
                            color: const Color(0xFF4A75E8),
                            size: 28,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        : const SizedBox();
  }

  Widget _buildDailyAds() {
    var clicked = false;
    return BlocBuilder<RewardedAdCubit, RewardedAdState>(
      builder: (context, state) {
        if (state is RewardedAdLoaded &&
            context.read<UserDetailsCubit>().isDailyAdAvailable) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return GestureDetector(
            onTap: () async {
              if (!clicked) {
                await context.read<RewardedAdCubit>().showDailyAd(
                  context: context,
                );
                clicked = true;
              }
            },
            child: Container(
              margin: EdgeInsets.only(
                left: hzMargin,
                right: hzMargin,
                top: scrHeight * 0.02,
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : const Color(0xFF4A75E8).withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon container with gradient
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4A75E8), Color(0xFF60A5FA)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A75E8).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      Assets.dailyCoins,
                      width: 36,
                      height: 36,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.tr('dailyAdsTitle')!,
                          maxLines: 2,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${context.tr("get")!} "
                          '${_sysConfigCubit.coinsPerDailyAdView} '
                          "${context.tr("dailyAdsDesc")!}",
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.7)
                                : const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A75E8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: const Color(0xFF4A75E8),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLiveContestSection() {
    void onTapViewAll() {
      if (_sysConfigCubit.isContestEnabled) {
        Navigator.of(context).pushNamed(Routes.contest);
      } else {
        context.showSnack(context.tr(currentlyNotAvailableKey)!);
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hzMargin, vertical: 10),
      child: Column(
        children: [
          /// Contest Section Title
          Row(
            children: [
              Text(
                context.tr(contest) ?? contest,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeights.semiBold,
                  color: context.primaryTextColor,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onTapViewAll,
                child: Text(
                  context.tr(viewAllKey) ?? viewAllKey,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeights.semiBold,
                    color: context.primaryTextColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          /// Contest Card
          BlocConsumer<ContestCubit, ContestState>(
            bloc: context.read<ContestCubit>(),
            listener: (context, state) {
              if (state is ContestFailure) {
                if (state.errorMessage == errorCodeUnauthorizedAccess) {
                  showAlreadyLoggedInDialog(context);
                }
              }
            },
            builder: (context, state) {
              if (state is ContestFailure) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  height: 100,
                  alignment: Alignment.center,
                  child: Text(
                    context.tr(
                      convertErrorCodeToLanguageKey(state.errorMessage),
                    )!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeights.regular,
                      color: Theme.of(context).primaryColor,
                    ),
                    maxLines: 2,
                  ),
                );
              }

              if (state is ContestSuccess) {
                final colorScheme = Theme.of(context).colorScheme;

                ///
                final live = state.contestList.live;

                /// No Contest
                if (live.errorMessage.isNotEmpty) {
                  return Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: 100,
                    alignment: Alignment.center,
                    child: Text(
                      context.tr(
                        convertErrorCodeToLanguageKey(live.errorMessage),
                      )!,
                      style: _boldTextStyle.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  );
                }

                final contest = live.contestDetails.first;
                final entryFee = int.parse(contest.entry!);

                void onTapPlayNow() {
                  final userDetailsCubit = context.read<UserDetailsCubit>();

                  if (int.parse(userDetailsCubit.getCoins()!) >= entryFee) {
                    context.read<UpdateCoinsCubit>().updateCoins(
                      coins: entryFee,
                      addCoin: false,
                      title: playedContestKey,
                    );
                    userDetailsCubit.updateCoins(
                      addCoin: false,
                      coins: entryFee,
                    );

                    Navigator.of(globalCtx).pushNamed(
                      Routes.quiz,
                      arguments: {
                        'quizType': QuizTypes.contest,
                        'contestId': contest.id,
                      },
                    );
                  } else {
                    showNotEnoughCoinsDialog(context);
                  }
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top gradient section with contest image
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: Container(
                              height: 160,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF14B8A6),
                                    Color(0xFF06B6D4),
                                  ],
                                ),
                              ),
                              child:
                                  contest.image != null &&
                                      contest.image!.isNotEmpty
                                  ? Image.network(
                                      contest.image!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    )
                                  : const SizedBox(),
                            ),
                          ),
                          // FREE ENTRY Badge
                          if (entryFee == 0)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'FREE ENTRY',
                                  style: GoogleFonts.nunito(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          // Title and description at bottom of image
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.7),
                                  ],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contest.name.toString(),
                                    style: GoogleFonts.nunito(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    contest.description.toString(),
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withValues(
                                        alpha: 0.95,
                                      ),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Bottom white section - all in ONE ROW
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Ends On
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.tr('endsOnLbl')!,
                                    style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    contest.endDate!.split(' ')[0],
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Players
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.tr('playersLbl')!,
                                    style: GoogleFonts.nunito(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${contest.participants} Joined',
                                    style: GoogleFonts.nunito(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Play Now Button
                            GestureDetector(
                              onTap: onTapPlayNow,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4A75E8),
                                      Color(0xFF60A5FA),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF4A75E8,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  context.tr('playnowLbl')!,
                                  style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: CircularProgressContainer());
            },
          ),
        ],
      ),
    );
  }

  String _userRank = '0';
  String _userCoins = '0';
  String _userScore = '0';

  Widget _buildHome() {
    return BlocConsumer<AppLocalizationCubit, AppLocalizationState>(
      listener: (context, state) async {
        _userName = context.tr('guest')!;
        if (_isGuest) return;

        final currentLanguage = state.language.name;
        final userProfile = context.read<UserDetailsCubit>().getUserProfile();

        if (currentLanguage != userProfile.appLanguage) {
          await context.read<UserDetailsCubit>().updateLanguage(
            currentLanguage,
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
            Positioned.fill(
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
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                children: [
                  SizedBox(height: context.height * .12),
                  Expanded(
                    child: RefreshIndicator(
                      key: refreshKey,
                      color: context.primaryColor,
                      backgroundColor: context.scaffoldBackgroundColor,
                      onRefresh: () async {
                        _currLangId = UiUtils.getCurrentQuizLanguageId(context);

                        if (!_isGuest) {
                          fetchUserDetails();

                          await context.read<ContestCubit>().getContest(
                            languageId: _currLangId,
                          );

                          // Refresh monetization data
                          context.read<MonetizationCubit>().checkDailyStreak();
                        }

                        // Always refresh sponsor banners (guests included)
                        context.read<MonetizationCubit>().getSponsorBanners();
                        setState(() {});
                      },
                      child: ListView(
                        controller: _scrollController,
                        children: [
                          const SizedBox(height: 24),
                          UserAchievements(
                            userRank: _userRank,
                            userCoins: _userCoins,
                            userScore: _userScore,
                          ),
                          const SizedBox(height: 16),
                          const DailyChallengeCard(),
                          const SizedBox(height: 8),
                          // Step 5: Daily Streak Widget
                          if (!_isGuest) ...[
                            _buildDailyStreakWidget(),
                            const SizedBox(height: 8),
                          ],
                          // Step 4: Sponsor Banner Widget (shown to all users)
                          _buildSponsorBanner(),
                          const SizedBox(height: 8),
                          if (!_isGuest &&
                              _sysConfigCubit.isAdsEnable &&
                              _sysConfigCubit.isDailyAdsEnabled) ...[
                            _buildDailyAds(),
                          ],
                          if (!_isGuest &&
                              _sysConfigCubit.isContestEnabled) ...[
                            _buildLiveContestSection(),
                          ],
                          _buildBattle(),
                          _buildExamSelf(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: _buildUserProfileHeader(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserProfileHeader() {
    void onTapNotification() {
      if (_isGuest) {
        globalCtx.pushNamed(Routes.login);
      } else {
        globalCtx.pushNamed(Routes.notification);
      }
    }

    void onTapCoinStore() {
      globalCtx.pushNamed(Routes.coinStore);
    }

    const iconSize = 36.0;

    return Container(
      width: context.width,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1F51D9),
            Color(0xFF4A75E8),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Welcome back text and icons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile picture and name section
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: QImage.circular(imageUrl: _userProfileImg),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome back',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Icons on the right
              Row(
                children: [
                  InkWell(
                    onTap: onTapNotification,
                    child: Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: _isGuest
                          ? const Icon(
                              Icons.login_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : QImage(
                              imageUrl: Assets.notificationMenuIcon,
                              color: Colors.white,
                              height: 18,
                              width: 18,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                  if (_sysConfigCubit.isCoinStoreEnabled) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: onTapCoinStore,
                      child: Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: QImage(
                          imageUrl: Assets.coinMenuIcon,
                          color: Colors.white,
                          height: 18,
                          width: 18,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Badges row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildBadge('Rank #$_userRank', Icons.emoji_events_rounded),
                const SizedBox(width: 8),
                _buildBadge('Silver', Icons.stars_rounded),
                const SizedBox(width: 8),
                _buildBadge('70%', Icons.percent_rounded),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Your Total Score card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Your Coins',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userCoins,
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '|',
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Your Total Score',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userScore,
                          style: GoogleFonts.nunito(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void fetchUserDetails() {
    context.read<UserDetailsCubit>().fetchUserDetails();
  }

  bool profileComplete = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    /// need to add this here, cause textStyle doesn't update automatically when changing theme.
    _boldTextStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: context.primaryTextColor,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: _isGuest
          ? _buildHome()
          /// Build home with User
          : BlocConsumer<UserDetailsCubit, UserDetailsState>(
              bloc: context.read<UserDetailsCubit>(),
              listener: (context, state) {
                if (state is UserDetailsFetchSuccess) {
                  final currLang = context
                      .read<AppLocalizationCubit>()
                      .state
                      .language
                      .name;

                  if (state.userProfile.appLanguage != currLang) {
                    context.read<UserDetailsCubit>().updateLanguage(currLang);
                  }

                  UiUtils.fetchBookmarkAndBadges(
                    context: context,
                    userId: state.userProfile.userId!,
                  );
                  if (state.userProfile.profileUrl!.isEmpty ||
                      state.userProfile.name!.isEmpty) {
                    if (!profileComplete) {
                      profileComplete = true;

                      globalCtx.pushNamed(
                        Routes.selectProfile,
                        arguments: const CreateOrEditProfileScreenArgs(
                          isNewUser: false,
                        ),
                      );
                    }
                    return;
                  }
                } else if (state is UserDetailsFetchFailure) {
                  if (state.errorMessage == errorCodeUnauthorizedAccess) {
                    showAlreadyLoggedInDialog(context);
                  }
                }
              },
              builder: (context, state) {
                if (state is UserDetailsFetchInProgress ||
                    state is UserDetailsInitial) {
                  return const Center(child: CircularProgressContainer());
                }
                if (state is UserDetailsFetchFailure) {
                  return Center(
                    child: ErrorContainer(
                      showBackButton: true,
                      errorMessage: convertErrorCodeToLanguageKey(
                        state.errorMessage,
                      ),
                      onTapRetry: fetchUserDetails,
                      showErrorImage: true,
                    ),
                  );
                }

                final user = (state as UserDetailsFetchSuccess).userProfile;

                _userName = user.name!;
                _userProfileImg = user.profileUrl!;
                _userRank = user.allTimeRank!;
                _userCoins = user.coins!;
                _userScore = user.allTimeScore!;

                return _buildHome();
              },
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

// Internal carousel widget for sponsor banners with auto-slide
class _SponsorBannerCarousel extends StatefulWidget {
  final List<SponsorBanner> banners;

  const _SponsorBannerCarousel({required this.banners});

  @override
  State<_SponsorBannerCarousel> createState() => _SponsorBannerCarouselState();
}

class _SponsorBannerCarouselState extends State<_SponsorBannerCarousel> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    log(
      '[SPONSOR_CAROUSEL] Initializing carousel with ${widget.banners.length} banners',
    );
    for (var i = 0; i < widget.banners.length; i++) {
      log('[SPONSOR_CAROUSEL] Banner $i: ${widget.banners[i].title}');
    }
    _pageController = PageController();

    // Start auto-slide only if multiple banners
    if (widget.banners.length > 1) {
      log('[SPONSOR_CAROUSEL] Starting auto-slide timer');
      _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (!mounted) return;
        _currentPage = (_currentPage + 1) % widget.banners.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onBannerTap(SponsorBanner banner) async {
    // Record click and open URL
    context.read<MonetizationCubit>().recordBannerClick(
      bannerId: banner.bannerId,
    );
    final uri = Uri.parse(banner.redirectUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.banners.length,
          onPageChanged: (index) {
            if (mounted) {
              setState(() {
                _currentPage = index;
              });
            }
          },
          itemBuilder: (context, index) {
            final banner = widget.banners[index];
            return SponsorBannerWidget(
              banner: banner,
              margin: EdgeInsets.zero,
              onBannerTap: () => _onBannerTap(banner),
              onErrorRetry: () {
                // No-op: could trigger a refetch if desired
              },
            );
          },
        ),
        // Simple page indicator
        Positioned(
          bottom: 8,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.banners.length, (i) {
                final isActive = i == _currentPage;
                return Container(
                  width: isActive ? 10 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white70,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
