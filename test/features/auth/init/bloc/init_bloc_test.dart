import 'package:felicitup_app/features/auth/init/bloc/init_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InitBloc initBloc;

  setUp(() {
    initBloc = InitBloc();
  });

  tearDown(() {
    initBloc.close();
  });

  group('InitBloc', () {
    test('initial state is InitState.initial()', () {
      expect(initBloc.state, InitState.initial());
      expect(initBloc.state.status, InitEnum.initial);
    });
  });
}
