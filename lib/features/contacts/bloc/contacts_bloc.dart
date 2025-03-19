import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';
part 'contacts_bloc.freezed.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc() : super(ContactsState.initial()) {
    on<ContactsEvent>(
      (event, emit) => event.map(
        changeLoading: (_) => _changeLoading(emit),
      ),
    );
  }

  _changeLoading(Emitter<ContactsState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }
}
