import 'dart:convert';

import 'package:crypto/crypto.dart';
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
        addManualContact: (event) =>
            _addManualContact(emit, event.user, event.isoCode),
      ),
    );
  }

  final UserRepository _userRepository;

  void _changeIsFirstTime(Emitter<ContactsState> emit) {
    emit(state.copyWith(isFirstTime: false));
  }

  Future<void> _getInfoSingleContact(
    Emitter<ContactsState> emit,
    String phone,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final response = await _userRepository.getUserDataByPhone(phone);
      response.fold(
        (l) {
          logger.error('Error al obtener el usuario: $l');
          emit(
            state.copyWith(
              isLoading: false,
              dataSingleUsers: null,
              errorMessage: l.message,
            ),
          );
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

  Future<void> _addManualContact(
    Emitter<ContactsState> emit,
    Map<String, dynamic> user,
    String isoCode,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final phone = user['phone'] as String?;
      if (phone != null && phone.isNotEmpty) {
        String formattedPhone = phone;
        if (!formattedPhone.startsWith('+')) {
          formattedPhone = isoCode + formattedPhone;
        }
        final hashedPhone = sha256
            .convert(utf8.encode(formattedPhone))
            .toString();
        final updatedUser = Map<String, dynamic>.from(user)
          ..['phone'] = hashedPhone;
        final response = await _userRepository.addManualContact(updatedUser);
        response.fold(
          (l) {
            emit(state.copyWith(isLoading: false, errorMessage: l.message));
          },
          (r) {
            emit(state.copyWith(isLoading: false, reloadContacts: true));
          },
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'El número de teléfono es requerido.',
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
