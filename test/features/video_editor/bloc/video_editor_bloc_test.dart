import 'package:bloc_test/bloc_test.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/video_editor/bloc/video_editor_bloc.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockFelicitupRepository extends Mock implements FelicitupRepository {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFunctionsHelper extends Mock
    implements FirebaseFunctionsHelper {}

void main() {
  late MockUserRepository mockUserRepository;
  late MockFelicitupRepository mockFelicitupRepository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFunctionsHelper mockFirebaseFunctionsHelper;

  setUp(() {
    mockUserRepository = MockUserRepository();
    mockFelicitupRepository = MockFelicitupRepository();
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFunctionsHelper = MockFirebaseFunctionsHelper();
  });

  group('VideoEditorBloc', () {
    test('initial state is correct', () {
      final bloc = VideoEditorBloc(
        userRepository: mockUserRepository,
        felicitupRepository: mockFelicitupRepository,
        firebaseAuth: mockFirebaseAuth,
        firebaseFunctionsHelper: mockFirebaseFunctionsHelper,
      );
      expect(bloc.state, VideoEditorState.initial());
    });

    blocTest<VideoEditorBloc, VideoEditorState>(
      'toggles loading state on changeLoading',
      build: () => VideoEditorBloc(
        userRepository: mockUserRepository,
        felicitupRepository: mockFelicitupRepository,
        firebaseAuth: mockFirebaseAuth,
        firebaseFunctionsHelper: mockFirebaseFunctionsHelper,
      ),
      act: (bloc) => bloc.add(const VideoEditorEvent.changeLoading()),
      expect: () => [
        VideoEditorState.initial().copyWith(isLoading: true),
      ],
    );

    blocTest<VideoEditorBloc, VideoEditorState>(
      'toggles isFullScreen state on changeFullScreen',
      build: () => VideoEditorBloc(
        userRepository: mockUserRepository,
        felicitupRepository: mockFelicitupRepository,
        firebaseAuth: mockFirebaseAuth,
        firebaseFunctionsHelper: mockFirebaseFunctionsHelper,
      ),
      act: (bloc) => bloc.add(const VideoEditorEvent.changeFullScreen()),
      expect: () => [
        VideoEditorState.initial().copyWith(isFullScreen: true),
      ],
    );
  });
}
