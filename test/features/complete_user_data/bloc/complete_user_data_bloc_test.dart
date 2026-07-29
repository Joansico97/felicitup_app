import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/complete_user_data/bloc/complete_user_data_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late UserRepository userRepository;
  late FirebaseAuth firebaseAuth;
  late CompleteUserDataBloc bloc;

  setUp(() {
    userRepository = MockUserRepository();
    firebaseAuth = MockFirebaseAuth();

    bloc = CompleteUserDataBloc(
      userRepository: userRepository,
      firebaseAuth: firebaseAuth,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('CompleteUserDataBloc', () {
    test('initial state is CompleteUserDataState.initial()', () {
      expect(bloc.state, CompleteUserDataState.initial());
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.status, CompleteUserDataStatus.none);
    });

    blocTest<CompleteUserDataBloc, CompleteUserDataState>(
      'emits [loading, success] when completeUserData succeeds',
      setUp: () {
        when(() => userRepository.completeeUserInfo('John', 'Doe'))
            .thenAnswer((_) async => const Right(null));
      },
      build: () => bloc,
      act: (b) => b.add(
        const CompleteUserDataEvent.completeUserData(
          firstName: 'John',
          lastName: 'Doe',
        ),
      ),
      expect: () => [
        CompleteUserDataState.initial().copyWith(isLoading: true),
        CompleteUserDataState.initial().copyWith(
          isLoading: false,
          status: CompleteUserDataStatus.success,
        ),
      ],
    );

    blocTest<CompleteUserDataBloc, CompleteUserDataState>(
      'emits [loading, error] when completeUserData fails',
      setUp: () {
        when(() => userRepository.completeeUserInfo('John', 'Doe')).thenAnswer(
          (_) async => Left(ApiException(400, 'Error updating info')),
        );
      },
      build: () => bloc,
      act: (b) => b.add(
        const CompleteUserDataEvent.completeUserData(
          firstName: 'John',
          lastName: 'Doe',
        ),
      ),
      expect: () => [
        CompleteUserDataState.initial().copyWith(isLoading: true),
        CompleteUserDataState.initial().copyWith(
          isLoading: false,
          status: CompleteUserDataStatus.error,
          errorMessage: 'Error updating info',
        ),
      ],
    );
  });
}
