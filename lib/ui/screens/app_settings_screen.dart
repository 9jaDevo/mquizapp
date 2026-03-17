import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/ads/utils/ad_analytics_collector.dart';
import 'package:flutterquiz/features/ads/utils/ad_feature_flags.dart';
import 'package:flutterquiz/features/system_config/cubits/app_settings_cubit.dart';
import 'package:flutterquiz/features/system_config/system_config_repository.dart';
import 'package:flutterquiz/ui/widgets/custom_appbar.dart';
import 'package:flutterquiz/ui/widgets/error_container.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// AppSettingsScreen shows app setting details like about us,
/// privacy policy, terms and conditions, etc.
///
/// It takes a required [title] parameter indicating which setting to load.
/// Uses AppSettingsCubit and SystemConfigRepository to fetch setting data.
/// _settingType determines type string to pass to cubit based on [title].
/// fetchAppSetting calls cubit method to fetch data.
///
/// _onTapUrl handles launching external urls.

final class AppSettingsScreenArgs extends RouteArgs {
  const AppSettingsScreenArgs(this.title);

  final String title;
}

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({required this.args, super.key});

  final AppSettingsScreenArgs args;

  static Route<AppSettingsScreen> route(RouteSettings routeSettings) {
    final args = routeSettings.args<AppSettingsScreenArgs>();

    return CupertinoPageRoute(
      builder: (_) => BlocProvider<AppSettingsCubit>(
        create: (_) => AppSettingsCubit(SystemConfigRepository()),
        child: AppSettingsScreen(args: args),
      ),
    );
  }

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late final String _settingType = switch (widget.args.title) {
    aboutUs => 'about_us',
    privacyPolicy => 'privacy_policy',
    termsAndConditions => 'terms_conditions',
    contactUs => 'contact_us',
    howToPlayLbl => 'instructions',
    _ => '',
  };
  late final String _screenTitle = context.tr(widget.args.title)!;

  @override
  void initState() {
    super.initState();
    fetchAppSetting();
  }

  void fetchAppSetting() {
    Future.delayed(Duration.zero, () {
      context.read<AppSettingsCubit>().getAppSetting(_settingType);
    });
  }

  FutureOr<bool> _onTapUrl(String url) async {
    final canLaunch = await canLaunchUrl(Uri.parse(url));
    if (canLaunch) {
      await launchUrl(Uri.parse(url));
    } else {
      log('Error Launching URL : $url', name: 'Launch URL');
    }
    return false;
  }

  Future<void> _openAdAdminSheet() async {
    if (!kDebugMode) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        var utility = AdFeatureFlags.isEnabled(
          AdFeatureFlags.utilityInterstitials,
        );
        var walletBanner = AdFeatureFlags.isEnabled(
          AdFeatureFlags.walletBannerPlacement,
        );
        var coinStoreBanner = AdFeatureFlags.isEnabled(
          AdFeatureFlags.coinStoreBannerPlacement,
        );
        var rewardedFallback = AdFeatureFlags.isEnabled(
          AdFeatureFlags.rewardedFallback,
        );

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ad Rollout Admin',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      FutureBuilder<int>(
                        future: AdAnalyticsCollector.getComplianceEventCount(),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? 0;
                          return Text('Compliance events stored: $count');
                        },
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        value: utility,
                        title: const Text('Utility interstitials'),
                        onChanged: (value) async {
                          await AdFeatureFlags.set(
                            AdFeatureFlags.utilityInterstitials,
                            value,
                          );
                          setModalState(() => utility = value);
                        },
                      ),
                      SwitchListTile.adaptive(
                        value: walletBanner,
                        title: const Text('Wallet banner placement'),
                        onChanged: (value) async {
                          await AdFeatureFlags.set(
                            AdFeatureFlags.walletBannerPlacement,
                            value,
                          );
                          setModalState(() => walletBanner = value);
                        },
                      ),
                      SwitchListTile.adaptive(
                        value: coinStoreBanner,
                        title: const Text('Coin store banner placement'),
                        onChanged: (value) async {
                          await AdFeatureFlags.set(
                            AdFeatureFlags.coinStoreBannerPlacement,
                            value,
                          );
                          setModalState(() => coinStoreBanner = value);
                        },
                      ),
                      SwitchListTile.adaptive(
                        value: rewardedFallback,
                        title: const Text('Rewarded fallback ladder'),
                        onChanged: (value) async {
                          await AdFeatureFlags.set(
                            AdFeatureFlags.rewardedFallback,
                            value,
                          );
                          setModalState(() => rewardedFallback = value);
                        },
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: () async {
                          await AdAnalyticsCollector.clearComplianceEvents();
                          setModalState(() {});
                        },
                        child: const Text('Clear Compliance Logs'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Debug only: long-press the info icon to open this panel.',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QAppBar(
        title: Text(_screenTitle),
        actions: [
          if (kDebugMode && _settingType == 'about_us')
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: _openAdAdminSheet,
              onLongPress: _openAdAdminSheet,
              tooltip: 'Ad Admin',
            ),
        ],
      ),
      body: BlocBuilder<AppSettingsCubit, AppSettingsState>(
        bloc: context.read<AppSettingsCubit>(),
        builder: (context, state) {
          if (state is AppSettingsFetchFailure) {
            return Center(
              child: ErrorContainer(
                errorMessage: convertErrorCodeToLanguageKey(state.errorCode),
                onTapRetry: fetchAppSetting,
                showErrorImage: true,
                errorMessageColor: Theme.of(context).primaryColor,
              ),
            );
          }

          if (state is AppSettingsFetchSuccess) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: context.height * UiUtils.vtMarginPct,
                horizontal: context.width * UiUtils.hzMarginPct + 10,
              ),
              child: HtmlWidget(
                state.settingsData,
                onErrorBuilder: (_, e, err) => Text('$e error: $err'),
                onLoadingBuilder: (_, e, l) =>
                    const Center(child: CircularProgressIndicator()),
                textStyle: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
                onTapUrl: _onTapUrl,
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
