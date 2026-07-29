import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/felicitups_dashboard/bloc/felicitups_dashboard_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFelicitupRepository extends Mock implements FelicitupRepository {}

class MockChatRepository extends Mock implements ChatRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late FelicitupRepository felicitupRepository;
  late ChatRepository chatRepository;
  late UserRepository userRepository;
  late FirebaseAuth firebaseAuth;
  late FelicitupsDashboardBloc bloc;

  setUp(() {
    felicitupRepository = MockFelicitupRepository();
    chatRepository = MockChatRepository();
    userRepository = MockUserRepository();
    firebaseAuth = MockFirebaseAuth();

    bloc = FelicitupsDashboardBloc(
      felicitupRepository: felicitupRepository,
      chatRepository: chatRepository,
      userRepository: userRepository,
      firebaseAuth: firebaseAuth,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('FelicitupsDashboardBloc', () {
    test('initial state is FelicitupsDashboardState.initial()', () {
      expect(bloc.state, FelicitupsDashboardState.initial());
      expect(bloc.state.currentIndex, 0);
      expect(bloc.state.status, FelicitupsDashboardStatus.initial);
    });

    blocTest<FelicitupsDashboardBloc, FelicitupsDashboardState>(
      'emits updated currentIndex when changeIndex event is added',
      build: () => bloc,
      act: (b) => b.add(const FelicitupsDashboardEvent.changeIndex(1)),
      expect: () => [
        FelicitupsDashboardState.initial().copyWith(
          currentIndex: 1,
          status: FelicitupsDashboardStatus.initial,
        ),
      ],
    );

    blocTest<FelicitupsDashboardBloc, FelicitupsDashboardState>(
      'emits updated state when recivedData is added',
      build: () => bloc,
      act: (b) => b.add(const FelicitupsDashboardEvent.recivedData([])),
      expect: () => [
        FelicitupsDashboardState.initial().copyWith(
          listFelicitups: [],
          status: FelicitupsDashboardStatus.initial,
        ),
      ],
    );

    blocTest<FelicitupsDashboardBloc, FelicitupsDashboardState>(
      'emits [loading, likeSuccess] when setLike is successful',
      setUp: () {
        when(() => felicitupRepository.setLike('f1', 'u1'))
            .thenAnswer((_) async => const Right(null));
      },
      build: () => bloc,
      act: (b) => b.add(
        const FelicitupsDashboardEvent.setLike('f1', 'u1'),
      ),
      expect: () => [
        FelicitupsDashboardState.initial().copyWith(
          isLoading: true,
          status: FelicitupsDashboardStatus.loading,
        ),
        FelicitupsDashboardState.initial().copyWith(
          isLoading: false,
          status: FelicitupsDashboardStatus.likeSuccess,
        ),
      ],
    );

    blocTest<FelicitupsDashboardBloc, FelicitupsDashboardState>(
      'emits [loading, likeError] when setLike fails',
      setUp: () {
        when(() => felicitupRepository.setLike('f1', 'u1')).thenAnswer(
          (_) async => Left(ApiException(500, 'Like failed')),
        );
      },
      build: () => bloc,
      act: (b) => b.add(
        const FelicitupsDashboardEvent.setLike('f1', 'u1'),
      ),
      expect: () => [
        FelicitupsDashboardState.initial().copyWith(
          isLoading: true,
          status: FelicitupsDashboardStatus.loading,
        ),
        FelicitupsDashboardState.initial().copyWith(
          isLoading: false,
          status: FelicitupsDashboardStatus.likeError,
          errorMessage: 'Like failed',
        ),
      ],
    );
  });
}
