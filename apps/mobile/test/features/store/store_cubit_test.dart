import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mquiz/features/store/cubit/store_cubit.dart';
import 'package:mquiz/features/store/data/store_repository.dart';
import 'package:mquiz/features/store/models/coin_pack_model.dart';

class MockStoreRepository extends Mock implements StoreRepository {}

final _pack = CoinPack(
  id: '1',
  name: 'Starter Pack',
  coins: 100,
  priceKobo: 50000,
  currency: 'NGN',
  appStoreProductId: 'mquiz.coins.100',
  isPopular: false,
);

final _paymentInit = PaymentInit(
  reference: 'REF-001',
  authorizationUrl: 'https://paystack.com/pay/test',
);

final _verifyResult = PaymentResult(
  success: true,
  coinsCredited: 100,
  newBalance: 200,
);

void main() {
  late MockStoreRepository repo;

  setUpAll(() {
    registerFallbackValue(0);
  });

  setUp(() {
    repo = MockStoreRepository();
  });

  group('StoreCubit —', () {
    test('initial state is StoreInitial', () {
      expect(StoreCubit(repo).state, isA<StoreInitial>());
    });

    blocTest<StoreCubit, StoreState>(
      'load emits Loading then Loaded with packs and balance',
      build: () {
        when(() => repo.fetchCoinStore()).thenAnswer((_) async => [_pack]);
        when(() => repo.fetchBalance()).thenAnswer((_) async => 100);
        return StoreCubit(repo);
      },
      act: (c) => c.load(),
      expect: () => [isA<StoreLoading>(), isA<StoreLoaded>()],
      verify: (c) {
        final s = c.state as StoreLoaded;
        expect(s.packs.length, 1);
        expect(s.balance, 100);
      },
    );

    blocTest<StoreCubit, StoreState>(
      'load emits StoreError on network failure',
      build: () {
        when(() => repo.fetchCoinStore()).thenThrow(Exception('fail'));
        when(() => repo.fetchBalance()).thenAnswer((_) async => 0);
        return StoreCubit(repo);
      },
      act: (c) => c.load(),
      expect: () => [isA<StoreLoading>(), isA<StoreError>()],
    );

    blocTest<StoreCubit, StoreState>(
      'verifyAppleIAP credits coins and updates balance',
      build: () {
        when(() => repo.fetchCoinStore()).thenAnswer((_) async => [_pack]);
        when(() => repo.fetchBalance()).thenAnswer((_) async => 100);
        when(() => repo.verifyAppleIAP(
              productId: any(named: 'productId'),
              receiptData: any(named: 'receiptData'),
              transactionId: any(named: 'transactionId'),
            )).thenAnswer((_) async => _verifyResult);
        return StoreCubit(repo);
      },
      act: (c) async {
        await c.load();
        final event = await c.verifyAppleIAP(
          productId: 'mquiz.coins.100',
          receiptData: 'base64-receipt',
          transactionId: 'TX-001',
        );
        expect(event.success, isTrue);
        expect(event.coinsCredited, 100);
      },
      skip: 2,
      expect: () => [isA<StoreLoaded>()],
      verify: (c) {
        final s = c.state as StoreLoaded;
        expect(s.balance, 200);
        expect(s.purchasingId, isNull);
      },
    );

    blocTest<StoreCubit, StoreState>(
      'cancelPurchase clears purchasingId',
      build: () {
        when(() => repo.fetchCoinStore()).thenAnswer((_) async => [_pack]);
        when(() => repo.fetchBalance()).thenAnswer((_) async => 100);
        when(() => repo.initialize(itemId: any(named: 'itemId')))
            .thenAnswer((_) async => _paymentInit);
        return StoreCubit(repo);
      },
      act: (c) async {
        await c.load();
        await c.initialize(pack: _pack);
        c.cancelPurchase();
      },
      skip: 2,
      expect: () => [
        isA<StoreLoaded>(), // purchasingId set
        isA<StoreLoaded>(), // purchasingId cleared
      ],
    );
  });
}
