import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/repositories/auth_repository.dart';
import 'package:felicitup_app/features/auth/forgot_password/bloc/forgot_password_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthRepository authRepository;
  late ForgotPasswordBloc bloc;

  setUp(() {
    authRepository = MockAuthRepository();
    bloc = ForgotPasswordBloc(authRepository: authRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('ForgotPasswordBloc', () {
    test('initial state is ForgotPasswordState.initial()', () {
      expect(bloc.state, ForgotPasswordState.initial());
      expect(bloc.state.isLoading, isFalse);
    });

    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits [loading, not-loading] when sendEmailEvent succeeds',
      setUp: () {
        when(() => authRepository.forgotPassword(email: 'test@example.com'))
            .thenAnswer((_) async => const Right('Email sent'));
      },
      build: () => bloc,
      act: (b) => b.add(
        const ForgotPasswordEvent.sendEmailEvent('test@example.com'),
      ),
      expect: () => [
        ForgotPasswordState.initial().copyWith(isLoading: true),
        ForgotPasswordState.initial().copyWith(isLoading: false),
      ],
    );

    blocTest<ForgotPasswordBloc, ForgotPasswordState>(
      'emits [loading, not-loading] when sendEmailEvent fails',
      setUp: () {
        when(() => authRepository.forgotPassword(email: 'test@example.com'))
            .thenAnswer(
          (_) async => Left(ApiException(400, 'User not found')),
        );
      },
      build: () => bloc,
      act: (b) => b.add(
        const ForgotPasswordEvent.sendEmailEvent('test@example.com'),
      ),
      expect: () => [
        ForgotPasswordState.initial().copyWith(isLoading: true),
        ForgotPasswordState.initial().copyWith(isLoading: false),
      ],
    );
  });
}
