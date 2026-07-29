import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/home/bloc/home_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late UserRepository userRepository;
  late HomeBloc homeBloc;

  setUp(() {
    userRepository = MockUserRepository();
    homeBloc = HomeBloc(userRepository: userRepository);
  });

  tearDown(() {
    homeBloc.close();
  });

  group('HomeBloc', () {
    test('initial state is HomeState.initial()', () {
      expect(homeBloc.state, HomeState.initial());
      expect(homeBloc.state.isLoading, isFalse);
      expect(homeBloc.state.status, HomeStatus.initial);
    });

    blocTest<HomeBloc, HomeState>(
      'emits updated state when changeLoading is added',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const HomeEvent.changeLoading()),
      expect: () => [
        HomeState.initial().copyWith(
          isLoading: true,
          status: HomeStatus.initial,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits updated state when changeCreate is added',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const HomeEvent.changeCreate()),
      expect: () => [
        HomeState.initial().copyWith(
          create: true,
          status: HomeStatus.initial,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits updated state when changeShowButton is added',
      build: () => homeBloc,
      act: (bloc) => bloc.add(const HomeEvent.changeShowButton()),
      expect: () => [
        HomeState.initial().copyWith(
          showButton: false,
          status: HomeStatus.initial,
        ),
      ],
    );

    final birthdate = DateTime(1995, 5, 15);

    blocTest<HomeBloc, HomeState>(
      'emits [loading, success] when setUserBirthdate succeeds',
      setUp: () {
        when(() => userRepository.updateUserBirthdate(birthdate))
            .thenAnswer((_) async => const Right(null));
      },
      build: () => homeBloc,
      act: (bloc) => bloc.add(HomeEvent.setUserBirthdate(date: birthdate)),
      expect: () => [
        HomeState.initial().copyWith(
          isLoading: true,
          status: HomeStatus.loading,
        ),
        HomeState.initial().copyWith(
          isLoading: false,
          status: HomeStatus.success,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [loading, error] when setUserBirthdate fails',
      setUp: () {
        when(() => userRepository.updateUserBirthdate(birthdate)).thenAnswer(
          (_) async => Left(ApiException(500, 'Error updating date')),
        );
      },
      build: () => homeBloc,
      act: (bloc) => bloc.add(HomeEvent.setUserBirthdate(date: birthdate)),
      expect: () => [
        HomeState.initial().copyWith(
          isLoading: true,
          status: HomeStatus.loading,
        ),
        HomeState.initial().copyWith(
          isLoading: false,
          status: HomeStatus.error,
        ),
      ],
    );
  });
}
