import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/create_felicitup/bloc/create_felicitup_bloc.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {}

class MockFirebaseFunctionsHelper extends Mock
    implements FirebaseFunctionsHelper {}

class MockUserRepository extends Mock implements UserRepository {}

class MockFelicitupRepository extends Mock implements FelicitupRepository {}

void main() {
  late MockDatabaseHelper mockDatabaseHelper;
  late MockFirebaseFunctionsHelper mockFirebaseFunctionsHelper;
  late MockUserRepository mockUserRepository;
  late MockFelicitupRepository mockFelicitupRepository;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockFirebaseFunctionsHelper = MockFirebaseFunctionsHelper();
    mockUserRepository = MockUserRepository();
    mockFelicitupRepository = MockFelicitupRepository();
  });

  group('CreateFelicitupBloc', () {
    test('initial state is correct', () {
      final bloc = CreateFelicitupBloc(
        databaseHelper: mockDatabaseHelper,
        firebaseFunctionsHelper: mockFirebaseFunctionsHelper,
        userRepository: mockUserRepository,
        felicitupRepository: mockFelicitupRepository,
      );
      expect(bloc.state, CreateFelicitupState.initial());
    });

    blocTest<CreateFelicitupBloc, CreateFelicitupState>(
      'emits updated state on toggleHasVideo',
      build: () => CreateFelicitupBloc(
        databaseHelper: mockDatabaseHelper,
        firebaseFunctionsHelper: mockFirebaseFunctionsHelper,
        userRepository: mockUserRepository,
        felicitupRepository: mockFelicitupRepository,
      ),
      act: (bloc) => bloc.add(const CreateFelicitupEvent.toggleHasVideo()),
      expect: () => [
        CreateFelicitupState.initial().copyWith(hasVideo: true),
      ],
    );

    blocTest<CreateFelicitupBloc, CreateFelicitupState>(
      'emits updated state on toggleHasBote',
      build: () => CreateFelicitupBloc(
        databaseHelper: mockDatabaseHelper,
        firebaseFunctionsHelper: mockFirebaseFunctionsHelper,
        userRepository: mockUserRepository,
        felicitupRepository: mockFelicitupRepository,
      ),
      act: (bloc) => bloc.add(const CreateFelicitupEvent.toggleHasBote()),
      expect: () => [
        CreateFelicitupState.initial().copyWith(hasBote: true),
      ],
    );

    blocTest<CreateFelicitupBloc, CreateFelicitupState>(
      'emits updated state on changeBoteQuantity',
      build: () => CreateFelicitupBloc(
        databaseHelper: mockDatabaseHelper,
        firebaseFunctionsHelper: mockFirebaseFunctionsHelper,
        userRepository: mockUserRepository,
        felicitupRepository: mockFelicitupRepository,
      ),
      act: (bloc) =>
          bloc.add(const CreateFelicitupEvent.changeBoteQuantity(50)),
      expect: () => [
        CreateFelicitupState.initial().copyWith(boteQuantity: 50),
      ],
    );

    blocTest<CreateFelicitupBloc, CreateFelicitupState>(
      'emits updated state on changeEventReason',
      build: () => CreateFelicitupBloc(
        databaseHelper: mockDatabaseHelper,
        firebaseFunctionsHelper: mockFirebaseFunctionsHelper,
        userRepository: mockUserRepository,
        felicitupRepository: mockFelicitupRepository,
      ),
      act: (bloc) =>
          bloc.add(const CreateFelicitupEvent.changeEventReason('Cumpleaños')),
      expect: () => [
        CreateFelicitupState.initial().copyWith(eventReason: 'Cumpleaños'),
      ],
    );

    blocTest<CreateFelicitupBloc, CreateFelicitupState>(
      'emits initial state on deleteCurrentFelicitup',
      build: () => CreateFelicitupBloc(
        databaseHelper: mockDatabaseHelper,
        firebaseFunctionsHelper: mockFirebaseFunctionsHelper,
        userRepository: mockUserRepository,
        felicitupRepository: mockFelicitupRepository,
      ),
      act: (bloc) =>
          bloc.add(const CreateFelicitupEvent.deleteCurrentFelicitup()),
      expect: () => [
        CreateFelicitupState.initial(),
      ],
    );

    blocTest<CreateFelicitupBloc, CreateFelicitupState>(
      'emits updated friends list when loadFriendsData succeeds',
      build: () {
        when(() => mockUserRepository.getListUserData(['user_1'])).thenAnswer(
          (_) async => Right([
            {'id': 'user_1', 'firstName': 'Juan', 'lastName': 'Pérez'}
          ]),
        );
        return CreateFelicitupBloc(
          databaseHelper: mockDatabaseHelper,
          firebaseFunctionsHelper: mockFirebaseFunctionsHelper,
          userRepository: mockUserRepository,
          felicitupRepository: mockFelicitupRepository,
        );
      },
      act: (bloc) =>
          bloc.add(const CreateFelicitupEvent.loadFriendsData(['user_1'])),
      expect: () => [
        CreateFelicitupState.initial().copyWith(isLoading: true),
        CreateFelicitupState.initial().copyWith(
          isLoading: false,
          friendList: [
            const UserModel(id: 'user_1', firstName: 'Juan', lastName: 'Pérez')
          ],
        ),
      ],
    );
  });
}
