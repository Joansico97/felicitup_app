import 'package:bloc_test/bloc_test.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup_dashboard/bloc/details_felicitup_dashboard_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFelicitupRepository extends Mock implements FelicitupRepository {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockFelicitupRepository mockFelicitupRepository;
  late MockUserRepository mockUserRepository;

  final sampleFelicitup = FelicitupModel(
    id: 'felicitup_1',
    createdBy: 'user_1',
    createdAt: DateTime(2025, 1, 1),
    reason: 'Cumpleaños',
    date: DateTime(2025, 1, 1),
    hasBote: false,
    hasVideo: false,
    invitedUsers: [],
    invitedUserDetails: [],
    owner: [],
    boteQuantity: 0,
    limitDate: DateTime(2025, 1, 1),
    chatId: 'chat_1',
  );

  setUp(() {
    mockFelicitupRepository = MockFelicitupRepository();
    mockUserRepository = MockUserRepository();
  });

  group('DetailsFelicitupDashboardBloc', () {
    test('initial state is correct', () {
      final bloc = DetailsFelicitupDashboardBloc(
        felicitupRepository: mockFelicitupRepository,
        userRepository: mockUserRepository,
      );
      expect(bloc.state, DetailsFelicitupDashboardState.initial());
    });

    blocTest<DetailsFelicitupDashboardBloc, DetailsFelicitupDashboardState>(
      'emits updated currentIndex on changeCurrentIndex',
      build: () => DetailsFelicitupDashboardBloc(
        felicitupRepository: mockFelicitupRepository,
        userRepository: mockUserRepository,
      ),
      act: (bloc) => bloc.add(
        const DetailsFelicitupDashboardEvent.changeCurrentIndex(2),
      ),
      expect: () => [
        DetailsFelicitupDashboardState.initial().copyWith(currentIndex: 2),
      ],
    );

    blocTest<DetailsFelicitupDashboardBloc, DetailsFelicitupDashboardState>(
      'emits updated state on recivedData',
      build: () => DetailsFelicitupDashboardBloc(
        felicitupRepository: mockFelicitupRepository,
        userRepository: mockUserRepository,
      ),
      act: (bloc) => bloc.add(
        DetailsFelicitupDashboardEvent.recivedData(sampleFelicitup),
      ),
      expect: () => [
        DetailsFelicitupDashboardState.initial().copyWith(
          felicitup: sampleFelicitup,
          isLoading: false,
        ),
      ],
    );

    blocTest<DetailsFelicitupDashboardBloc, DetailsFelicitupDashboardState>(
      'clears initial sub route on clearInitialSubRoute',
      build: () => DetailsFelicitupDashboardBloc(
        felicitupRepository: mockFelicitupRepository,
        userRepository: mockUserRepository,
      ),
      act: (bloc) => bloc.add(
        const DetailsFelicitupDashboardEvent.clearInitialSubRoute(),
      ),
      expect: () => [
        DetailsFelicitupDashboardState.initial().copyWith(initialSubRoute: null),
      ],
    );
  });
}
