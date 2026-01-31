import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterquiz/commons/widgets/custom_snackbar.dart';
import 'package:flutterquiz/core/core.dart';
import 'package:flutterquiz/features/auth/cubits/auth_cubit.dart';
import 'package:flutterquiz/features/in_app_purchase/in_app_product.dart';
import 'package:flutterquiz/features/in_app_purchase/in_app_purchase_cubit.dart';
import 'package:flutterquiz/features/in_app_purchase/in_app_purchase_repo.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_score_and_coins_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/update_user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/profile_management/profile_management_repository.dart';
import 'package:flutterquiz/ui/widgets/all.dart';
import 'package:flutterquiz/utils/extensions.dart';
import 'package:flutterquiz/utils/ui_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class CoinStoreScreen extends StatefulWidget {
  const CoinStoreScreen({super.key});

  @override
  State<CoinStoreScreen> createState() => _CoinStoreScreenState();

  static Route<dynamic> route() {
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider<InAppPurchaseCubit>(create: (_) => InAppPurchaseCubit()),
          BlocProvider<UpdateCoinsCubit>(
            create: (_) => UpdateCoinsCubit(ProfileManagementRepository()),
          ),
          BlocProvider<UpdateUserDetailCubit>(
            create: (_) => UpdateUserDetailCubit(ProfileManagementRepository()),
          ),
        ],
        child: const CoinStoreScreen(),
      ),
    );
  }
}

class _CoinStoreScreenState extends State<CoinStoreScreen>
    with SingleTickerProviderStateMixin {
  List<String> productIds = [];
  List<InAppProduct> iapProducts = [];

  bool get _isGuest => context.read<AuthCubit>().isGuest;

  String fetchError = '';

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await fetchProducts();
      initPurchase();
    });
  }

  Future<void> fetchProducts() async {
    iapProducts = await InAppPurchaseRepo.fetchInAppProducts()
        .then((value) {
          setState(() {
            fetchError = '';
          });
          return value;
        })
        .catchError((Object e) {
          setState(() {
            fetchError = e.toString();
          });
          return <InAppProduct>[];
        });
    if (context.read<UserDetailsCubit>().removeAds()) {
      iapProducts.removeWhere((e) => e.isRemoveAds);
    }
    productIds = iapProducts.map((e) => e.productId).toSet().toList();
  }

  void initPurchase() {
    context.read<InAppPurchaseCubit>().initializePurchase(productIds);
  }

  Widget _buildProducts(List<ProductDetails> products) {
    final size = context;
    final userBalance = context.read<UserDetailsCubit>().getCoins() ?? '0';

    Future<void> restorePurchases() async {
      return context.read<InAppPurchaseCubit>().restorePurchases();
    }

    return Stack(
      children: [
        _buildBackground(),
        SingleChildScrollView(
          padding: EdgeInsets.only(
            top: 16,
            left: size.width * UiUtils.hzMarginPct,
            right: size.width * UiUtils.hzMarginPct,
            bottom: Platform.isIOS && !_isGuest ? 90 : 24,
          ),
          child: Column(
            children: [
              // Balance card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF1F51D9).withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Your Balance',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: const Color(
                              0xFF1F51D9,
                            ).withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userBalance.toString(),
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F51D9),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA500),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.currency_bitcoin,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Product list
              ...List.generate(
                products.length,
                (idx) {
                  final product = products[idx];
                  final iap = iapProducts.firstWhere(
                    (e) => e.productId == product.id,
                  );

                  void purchaseProduct() {
                    if (context.read<InAppPurchaseCubit>().state
                        is InAppPurchaseProcessInProgress) {
                      return;
                    }

                    if (_isGuest) {
                      showLoginDialog(
                        context,
                        onTapYes: () {
                          context
                            ..shouldPop() // close dialog
                            ..shouldPop() // menu screen
                            ..pushNamed(Routes.login);
                        },
                      );
                      return;
                    }

                    context.read<InAppPurchaseCubit>().buyConsumableProducts(
                      product,
                    );
                  }

                  final isMostPopular = idx == 1; // Middle item is most popular

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: purchaseProduct,
                      child: _ProductCard(
                        product: product,
                        iap: iap,
                        isMostPopular: isMostPopular,
                        onTap: purchaseProduct,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),
              // Info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF1F51D9).withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF1F51D9),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Use coins to unlock special features, enter premium contests, and customize your profile',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF1F51D9).withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        /// Restore Button
        if (Platform.isIOS && !_isGuest)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
              child: CustomRoundedButton(
                widthPercentage: 1,
                backgroundColor: const Color(0xFF1F51D9),
                buttonTitle: context.tr('restorePurchaseProducts'),
                radius: 8,
                showBorder: false,
                fontWeight: FontWeights.semiBold,
                height: 58,
                titleColor: Colors.white,
                onTap: restorePurchases,
                elevation: 6.5,
                textSize: 18,
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (shouldPop, _) {
        if (shouldPop) return;

        if (context.read<InAppPurchaseCubit>().state
            is! InAppPurchaseProcessInProgress) {
          context.shouldPop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE8F1FF),
                  Color(0xFFF5F9FF),
                ],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    if (context.read<InAppPurchaseCubit>().state
                        is! InAppPurchaseProcessInProgress) {
                      context.shouldPop();
                    }
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1F51D9).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF1F51D9),
                      size: 20,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      context.tr(coinStoreKey) ?? 'Coin Store',
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F51D9),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 44), // Spacer to balance the back button
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            _buildBackground(),
            Align(
              alignment: Alignment.topCenter,
              child: BlocConsumer<InAppPurchaseCubit, InAppPurchaseState>(
                bloc: context.read<InAppPurchaseCubit>(),
                listener: (context, state) async {
                  if (state is InAppPurchaseProcessSuccess) {
                    final iap = iapProducts.firstWhere(
                      (e) => e.productId == state.purchasedProductId,
                    );

                    final success = await context
                        .read<InAppPurchaseCubit>()
                        .verifyAndPurchase();

                    if (success) {
                      // We don't want to show the Remove Ads IAP, after purchasing it.
                      if (iap.isRemoveAds) {
                        context.read<UserDetailsCubit>().updateUserProfile(
                          adsRemovedForUser: '1',
                        );

                        state.products.removeWhere(
                          (e) => e.id == iap.productId,
                        );
                        setState(() {});
                      } else {
                        unawaited(
                          context.read<UserDetailsCubit>().fetchUserDetails(),
                        );
                      }

                      ///
                      context.showSnack(
                        "${iap.title} ${context.tr("boughtSuccess")!}",
                      );
                    }
                  } else if (state is InAppPurchaseProcessFailure) {
                    if (!state.errorMessage.contains('userCanceled')) {
                      final error =
                          context.tr(
                            convertErrorCodeToLanguageKey(state.errorMessage),
                          ) ??
                          '';
                      if (error.isNotEmpty) {
                        context.showSnack(error);
                      }
                    }
                  }
                },
                builder: (context, state) {
                  if (fetchError.isNotEmpty) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: false,
                        errorMessage: convertErrorCodeToLanguageKey(fetchError),
                        onTapRetry: () async {
                          await fetchProducts();
                          initPurchase();
                        },
                        showErrorImage: true,
                      ),
                    );
                  }

                  //initial state of cubit
                  if (state is InAppPurchaseInitial ||
                      state is InAppPurchaseLoading) {
                    return const Center(child: CircularProgressContainer());
                  }

                  //if occurred problem while fetching product details
                  //from appstore or playstore
                  if (state is InAppPurchaseFailure) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: false,
                        errorMessage: state.errorMessage,
                        onTapRetry: initPurchase,
                        showErrorImage: true,
                      ),
                    );
                  }

                  if (state is InAppPurchaseNotAvailable) {
                    return Center(
                      child: ErrorContainer(
                        showBackButton: false,
                        errorMessage: inAppPurchaseUnavailableKey,
                        onTapRetry: initPurchase,
                        showErrorImage: true,
                      ),
                    );
                  }

                  //if any error occurred in while making in-app purchase
                  if (state is InAppPurchaseProcessFailure) {
                    return _buildProducts(state.products);
                  }
                  if (state is InAppPurchaseAvailable) {
                    return _buildProducts(state.products);
                  }
                  if (state is InAppPurchaseProcessSuccess) {
                    return _buildProducts(state.products);
                  }
                  if (state is InAppPurchaseProcessInProgress) {
                    final textTheme = Theme.of(context).textTheme;
                    final textColor = Theme.of(context).canvasColor;

                    return Stack(
                      children: [
                        _buildProducts(state.products),
                        Container(
                          width: double.maxFinite,
                          color: Colors.black26,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressContainer(),
                              Text(
                                context.tr('iapProcessingTitle')!,
                                style: textTheme.titleLarge?.copyWith(
                                  color: textColor,
                                ),
                              ),
                              Text(
                                context.tr('iapProcessingMessage')!,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F1FF),
              Color(0xFFF5F9FF),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductDetails product;
  final InAppProduct iap;
  final bool isMostPopular;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.iap,
    required this.isMostPopular,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF1F51D9).withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product details row
              Row(
                children: [
                  // Package icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: iap.image.endsWith('.svg')
                        ? SvgPicture.network(iap.image, width: 36, height: 36)
                        : Image.network(iap.image, width: 36, height: 36),
                  ),
                  const SizedBox(width: 12),

                  // Middle content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          iap.desc,
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: const Color(
                              0xFF1F51D9,
                            ).withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          iap.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F51D9),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.price,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFA500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Right icon button
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F51D9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Purchase Now button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F51D9), Color(0xFF4A75E8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Purchase Now',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Most popular badge
        if (isMostPopular)
          Positioned(
            top: 8,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFA500),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'MOST POPULAR',
                style: GoogleFonts.nunito(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _GlassProductCard extends StatelessWidget {
  const _GlassProductCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF1F51D9).withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
