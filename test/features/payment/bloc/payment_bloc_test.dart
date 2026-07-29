import 'package:bloc_test/bloc_test.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/payment/bloc/payment_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFelicitupRepository extends Mock implements FelicitupRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockFelicitupRepository mockFelicitupRepository;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockFelicitupRepository = MockFelicitupRepository();
    mockUserRepository = MockUserRepository();
  });

  group('PaymentBloc', () {
    test('initial state is correct', () {
      final bloc = PaymentBloc(
        felicitupRepository: mockFelicitupRepository,
        userRepository: mockUserRepository,
      );
      expect(bloc.state, PaymentState.initial());
    });

    blocTest<PaymentBloc, PaymentState>(
      'toggles loading state on changeLoadign',
      build: () => PaymentBloc(
        felicitupRepository: mockFelicitupRepository,
        userRepository: mockUserRepository,
      ),
      act: (bloc) => bloc.add(const PaymentEvent.changeLoadign()),
      expect: () => [
        PaymentState.initial().copyWith(isLoading: true),
      ],
    );
  });
}
