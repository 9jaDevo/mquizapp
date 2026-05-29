import 'package:equatable/equatable.dart';
import 'package:mquiz/core/utils/parsers.dart';

class CoinPack extends Equatable {
  const CoinPack({
    required this.id,
    required this.name,
    required this.coins,
    this.bonusCoins,
    this.priceUsd,
    this.priceLocal,
    this.priceKobo = 0,
    this.currency,
    this.image,
    this.isPopular = false,
    this.appStoreProductId,
  });

  final String id;
  final String name;
  final int coins;
  final int? bonusCoins;
  final double? priceUsd;
  final double? priceLocal;
  final int priceKobo;
  final String? currency;
  final String? image;
  final bool isPopular;
  /// App Store product identifier for iOS In-App Purchases.
  /// Falls back to [id] if not explicitly set.
  final String? appStoreProductId;

  int get totalCoins => coins + (bonusCoins ?? 0);
  String get effectiveAppStoreId => appStoreProductId ?? id;

  factory CoinPack.fromJson(Map<String, dynamic> j) => CoinPack(
        id: parseStringOr(j['id'] ?? j['sku'], ''),
        name: parseStringOr(j['name'] ?? j['title'], 'Coin Pack'),
        coins: parseIntOr(j['coins'] ?? j['amount'], 0),
        bonusCoins: parseInt(j['bonusCoins'] ?? j['bonus']),
        priceUsd: parseDouble(j['priceUsd'] ?? j['price_usd']),
        priceLocal: parseDouble(j['priceLocal'] ?? j['price']),
        priceKobo: parseIntOr(j['priceKobo'] ?? j['price_kobo'], 0),
        currency: parseString(j['currency']),
        image: parseString(j['image']),
        isPopular: parseBool(j['isPopular'] ?? j['popular']),
        appStoreProductId:
            parseString(j['appStoreProductId'] ?? j['ios_product_id']),
      );

  @override
  List<Object?> get props => [
        id,
        name,
        coins,
        bonusCoins,
        priceUsd,
        priceLocal,
        priceKobo,
        currency,
        image,
        isPopular,
        appStoreProductId,
      ];
}

class PaymentInit extends Equatable {
  const PaymentInit({
    required this.reference,
    required this.authorizationUrl,
    this.accessCode,
    this.provider,
  });

  final String reference;
  final String authorizationUrl;
  final String? accessCode;
  final String? provider;

  factory PaymentInit.fromJson(Map<String, dynamic> j) => PaymentInit(
        reference: parseStringOr(j['reference'], ''),
        authorizationUrl: parseStringOr(
            j['authorizationUrl'] ?? j['authorization_url'], ''),
        accessCode: parseString(j['accessCode'] ?? j['access_code']),
        provider: parseString(j['provider']),
      );

  @override
  List<Object?> get props =>
      [reference, authorizationUrl, accessCode, provider];
}

class PaymentResult extends Equatable {
  const PaymentResult({
    required this.success,
    required this.coinsCredited,
    this.newBalance,
    this.reference,
  });

  final bool success;
  final int coinsCredited;
  final int? newBalance;
  final String? reference;

  factory PaymentResult.fromJson(Map<String, dynamic> j) => PaymentResult(
        success: parseBool(j['success'] ?? j['verified']),
        coinsCredited: parseIntOr(j['coinsCredited'] ?? j['coins'], 0),
        newBalance: parseInt(j['newBalance'] ?? j['balance']),
        reference: parseString(j['reference']),
      );

  @override
  List<Object?> get props => [success, coinsCredited, newBalance, reference];
}
