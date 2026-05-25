import 'package:mquiz/core/network/nestjs_api.dart';
import 'package:mquiz/features/store/models/coin_pack_model.dart';

class StoreRepository {
  StoreRepository({NestJsApi? api}) : _api = api ?? NestJsApi.instance;
  final NestJsApi _api;

  Future<List<CoinPack>> fetchCoinStore() async {
    final list = await _api.getCoinStore();
    return list.map(CoinPack.fromJson).toList(growable: false);
  }

  Future<int> fetchBalance() async {
    final data = await _api.getCoinBalance();
    final raw = data['balance'] ?? data['coins'] ?? data['total'];
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
  }

  Future<PaymentInit> initialize({
    required String packId,
    required String provider, // 'paystack' | 'flutterwave'
  }) async {
    final data = await _api.initializePayment({
      'packId': packId,
      'provider': provider,
    });
    return PaymentInit.fromJson(data);
  }

  Future<PaymentResult> verify(String reference) async {
    final data = await _api.verifyPayment(reference);
    return PaymentResult.fromJson(data);
  }
}
