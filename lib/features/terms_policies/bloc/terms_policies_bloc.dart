import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'terms_policies_event.dart';
part 'terms_policies_state.dart';
part 'terms_policies_bloc.freezed.dart';

class TermsPoliciesBloc extends Bloc<TermsPoliciesEvent, TermsPoliciesState> {
  TermsPoliciesBloc() : super(TermsPoliciesState.initial()) {
    on<TermsPoliciesEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
      ),
    );
  }

  _changeLoading(Emitter<TermsPoliciesState> emit) {
    emit(
      state.copyWith(
        isLoading: !state.isLoading,
      ),
    );
  }
}
