import 'package:bloc_test/bloc_test.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/features/wish_list/bloc/wish_list_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  group('WishListBloc', () {
    test('initial state is correct', () {
      final bloc = WishListBloc(userRepository: mockUserRepository);
      expect(bloc.state, WishListState.initial());
    });

    blocTest<WishListBloc, WishListState>(
      'toggles loading state on changeLoading',
      build: () => WishListBloc(userRepository: mockUserRepository),
      act: (bloc) => bloc.add(const WishListEvent.changeLoading()),
      expect: () => [
        WishListState.initial().copyWith(isLoading: true),
      ],
    );

    blocTest<WishListBloc, WishListState>(
      'toggles isEdit state on editGiftItem',
      build: () => WishListBloc(userRepository: mockUserRepository),
      act: (bloc) => bloc.add(const WishListEvent.editGiftItem()),
      expect: () => [
        WishListState.initial().copyWith(isEdit: true),
      ],
    );

    blocTest<WishListBloc, WishListState>(
      'toggles isCreate state on createGiftItem',
      build: () => WishListBloc(userRepository: mockUserRepository),
      act: (bloc) => bloc.add(const WishListEvent.createGiftItem()),
      expect: () => [
        WishListState.initial().copyWith(isCreate: true),
      ],
    );

    blocTest<WishListBloc, WishListState>(
      'updates productName on setProductName',
      build: () => WishListBloc(userRepository: mockUserRepository),
      act: (bloc) => bloc.add(const WishListEvent.setProductName('Laptop')),
      expect: () => [
        WishListState.initial().copyWith(productName: 'Laptop'),
      ],
    );
  });
}
