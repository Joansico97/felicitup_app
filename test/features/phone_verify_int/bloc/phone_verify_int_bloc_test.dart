import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/phone_verify_int/bloc/phone_verify_int_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
  });

  group('PhoneVerifyIntBloc', () {
    test('initial state is correct', () {
      final bloc = PhoneVerifyIntBloc(
        authRepository: mockAuthRepository,
        userRepository: mockUserRepository,
      );
      expect(bloc.state, PhoneVerifyIntState.initial());
    });
  });
}
