import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mquiz/features/auth/auth_repository.dart';
import 'package:mquiz/features/auth/cubit/auth_cubit.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
  });

  group('AuthCubit —', () {
    test('initial state is AuthInitial', () {
      expect(AuthCubit(repo).state, isA<AuthInitial>());
    });

    blocTest<AuthCubit, AuthState>(
      'checkAuth emits Unauthenticated when no firebase user',
      build: () {
        when(() => repo.currentFirebaseUser).thenReturn(null);
        return AuthCubit(repo);
      },
      act: (c) => c.checkAuth(),
      expect: () => [isA<AuthLoading>(), isA<Unauthenticated>()],
    );

    blocTest<AuthCubit, AuthState>(
      'signOut emits AuthLoading then Unauthenticated',
      build: () {
        when(() => repo.signOut()).thenAnswer((_) async {});
        return AuthCubit(repo);
      },
      act: (c) => c.signOut(),
      expect: () => [isA<AuthLoading>(), isA<Unauthenticated>()],
    );

    blocTest<AuthCubit, AuthState>(
      'signOut emits AuthError when signOut throws',
      build: () {
        when(() => repo.signOut()).thenThrow(Exception('network'));
        return AuthCubit(repo);
      },
      act: (c) => c.signOut(),
      expect: () => [isA<AuthLoading>(), isA<AuthError>()],
    );
  });
}
