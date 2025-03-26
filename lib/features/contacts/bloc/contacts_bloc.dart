import 'package:bloc/bloc.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'contacts_event.dart';
part 'contacts_state.dart';
part 'contacts_bloc.freezed.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(ContactsState.initial()) {
    on<ContactsEvent>(
      (event, emit) => event.map(
        changeLoading: (_) => _changeLoading(emit),
        generateListData: (event) => _generateListData(emit, event.contacts, event.ids),
        getInfoContacts: (event) => _getInfoContacts(emit, event.phones),
      ),
    );
  }

  final UserRepository _userRepository;

  _changeLoading(Emitter<ContactsState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _generateListData(Emitter<ContactsState> emit, List<ContactModel> contacts, List<String> ids) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _userRepository.getListUserDataByPhone(ids);
      response.fold(
        (l) {
          emit(state.copyWith(isLoading: false, dataList: []));
        },
        (r) {
          List<Map<String, dynamic>> dataList = [];
          List<String> registeredContacts = [];
          List<String> listPhones = r.map((e) => e.phone ?? '').toList();
          for (ContactModel contact in contacts) {
            bool isRegistered = listPhones.contains(contact.phone);
            dataList.add({
              'contact': contact,
              'isRegistered': isRegistered,
            });
            if (isRegistered) {
              registeredContacts.add(contact.phone);
            }
          }
          dataList.sort((a, b) {
            bool aIsRegistered = a['isRegistered'] as bool;
            bool bIsRegistered = b['isRegistered'] as bool;

            if (aIsRegistered && !bIsRegistered) {
              return -1;
            } else if (!aIsRegistered && bIsRegistered) {
              return 1;
            } else {
              String aName = (a['contact'] as ContactModel).displayName!;
              String bName = (b['contact'] as ContactModel).displayName!;
              return aName.compareTo(bName);
            }
          });
          add(ContactsEvent.getInfoContacts(registeredContacts));
          emit(state.copyWith(isLoading: false, dataList: dataList));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, dataList: []));
    }
  }

  _getInfoContacts(Emitter<ContactsState> emit, List<String> phones) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _userRepository.getListUserDataByPhone(phones);

      response.fold(
        (l) {
          emit(state.copyWith(isLoading: false, listDataUsers: []));
        },
        (r) {
          emit(state.copyWith(isLoading: false, listDataUsers: r));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, listDataUsers: []));
    }
  }
}
