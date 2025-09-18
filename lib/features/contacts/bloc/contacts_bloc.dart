import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';
part 'contacts_bloc.freezed.dart';

class ContactListItem {
  final ContactModel contact;
  final bool isRegistered;

  ContactListItem(this.contact, this.isRegistered);
}

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(ContactsState.initial()) {
    on<ContactsEvent>(
      (event, emit) => event.map(
        changeIsFirstTime: (_) => _changeIsFirstTime(emit),
        getInfoSingleContact: (event) =>
            _getInfoSingleContact(emit, event.phone),
      ),
    );
  }

  final UserRepository _userRepository;

  _changeIsFirstTime(Emitter<ContactsState> emit) {
    emit(state.copyWith(isFirstTime: false));
  }

  _getInfoSingleContact(Emitter<ContactsState> emit, String phone) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _userRepository.getUserDataByPhone(phone);
      response.fold(
        (l) {
          logger.error('Error al obtener el usuario: $l');
          emit(state.copyWith(isLoading: false, dataSingleUsers: null));
        },
        (r) {
          emit(
            state.copyWith(
              isLoading: false,
              dataSingleUsers: UserModel.fromJson(r),
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, dataSingleUsers: null));
    }
  }
}
