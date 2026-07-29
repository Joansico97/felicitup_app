import 'package:bloc_test/bloc_test.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/profile/bloc/profile_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late UserRepository userRepository;
  late ProfileBloc bloc;

  setUp(() {
    userRepository = MockUserRepository();
    bloc = ProfileBloc(userRepository: userRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('ProfileBloc', () {
    test('initial state is ProfileState.initial()', () {
      expect(bloc.state, ProfileState.initial());
      expect(bloc.state.isLoading, isFalse);
      expect(bloc.state.status, ProfileStatus.initial);
    });

    blocTest<ProfileBloc, ProfileState>(
      'emits [loading, success] when updateUserImageFromUrl succeeds',
      setUp: () {
        when(() => userRepository.updateUserImageFromUrl('http://avatar.png'))
            .thenAnswer((_) async => const Right(null));
      },
      build: () => bloc,
      act: (b) => b.add(
        const ProfileEvent.updateUserImageFromUrl('http://avatar.png'),
      ),
      expect: () => [
        ProfileState.initial().copyWith(isLoading: true),
        ProfileState.initial().copyWith(
          isLoading: false,
          status: ProfileStatus.success,
        ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [loading, not-loading] when updateUserImageFromUrl fails',
      setUp: () {
        when(() => userRepository.updateUserImageFromUrl('http://avatar.png'))
            .thenAnswer((_) async => Left(ApiException(500, 'Error')));
      },
      build: () => bloc,
      act: (b) => b.add(
        const ProfileEvent.updateUserImageFromUrl('http://avatar.png'),
      ),
      expect: () => [
        ProfileState.initial().copyWith(isLoading: true),
        ProfileState.initial().copyWith(isLoading: false),
      ],
    );

    final testUser = const UserModel(id: 'u1', firstName: 'John');

    blocTest<ProfileBloc, ProfileState>(
      'emits [loading, success] when updateUserInfo succeeds',
      setUp: () {
        when(() => userRepository.updateUserInfo(testUser))
            .thenAnswer((_) async => const Right(null));
      },
      build: () => bloc,
      act: (b) => b.add(ProfileEvent.updateUserInfo(testUser)),
      expect: () => [
        ProfileState.initial().copyWith(isLoading: true),
        ProfileState.initial().copyWith(
          isLoading: false,
          status: ProfileStatus.success,
        ),
      ],
    );
  });
}
