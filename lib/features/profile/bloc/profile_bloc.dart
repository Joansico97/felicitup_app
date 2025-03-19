import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_event.dart';
part 'profile_state.dart';
part 'profile_bloc.freezed.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileState.initial()) {
    on<ProfileEvent>(
      (events, emit) => events.map(
        changeLoading: (event) => _changeLoading(emit),
      ),
    );
  }

  _changeLoading(Emitter<ProfileState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }
}
