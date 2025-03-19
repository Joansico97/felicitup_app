import 'package:bloc/bloc.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:permission_handler/permission_handler.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(HomeState.initial()) {
    on<HomeEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        changeCreate: (_) => _changeCreate(emit),
        changeShowButton: (_) => _changeShowButton(emit),
        getAndUpdateContacts: (event) => _getAndUpdateContacts(event.currentUser),
      ),
    );
  }

  final UserRepository _userRepository;

  _changeLoading(Emitter<HomeState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _changeCreate(Emitter<HomeState> emit) {
    emit(state.copyWith(create: !state.create));
  }

  _changeShowButton(Emitter<HomeState> emit) {
    emit(state.copyWith(showButton: !state.showButton));
  }

  _getAndUpdateContacts(UserModel currentUser) async {
    final contacts = await getAllInfoContacts();
    List<Map<String, dynamic>> contactsMapList =
        contacts.where((e) => e.displayName.isNotEmpty && e.phones.isNotEmpty).map(
      (e) {
        return {
          'displayName': e.displayName,
          'phone':
              e.phones.first.number.replaceAll('-', '').replaceAll('(', '').replaceAll(')', '').replaceAll(' ', ''),
        };
      },
    ).toList();

    RegExp nameRegex = RegExp(r'\d{3,}');

    contactsMapList.removeWhere((element) => element['displayName'] == null || element['displayName'].isEmpty);
    contactsMapList.removeWhere((element) => nameRegex.hasMatch(element['displayName'] ?? ''));

    for (var element in contactsMapList) {
      if (element['phone'][0] == '0' && element['phone'][1] == '0') {
        String number = element['phone'];
        number = number.substring(2);
        element['phone'] = '+$number';
      } else if (element['phone'][0] != '+') {
        String number = element['phone'];
        String isoCode = currentUser.isoCode ?? '';
        element['phone'] = isoCode + number;
      }
    }

    List<String> friendsPhoneList = contactsMapList.map((e) => e['phone'] as String).toList();
    await _userRepository.updateContacts(contactsMapList, friendsPhoneList);
  }

  Future<List<Contact>> getAllInfoContacts() async {
    bool isGranted = await _checkContactsPermission();

    if (isGranted) {
      final packageContacts = await FastContacts.getAllContacts();
      final List<Contact> contacts = [...packageContacts];
      contacts.removeWhere((element) => element.displayName.isEmpty);
      contacts.sort((a, b) => a.displayName.toLowerCase().trim().compareTo(b.displayName.toLowerCase().trim()));
      contacts.removeWhere((element) => element.phones.isNotEmpty ? element.phones[0].number.length < 8 : false);
      return contacts;
    }

    return [];
  }

  Future<bool> _checkContactsPermission() async {
    final contactsPermissionStatus = await Permission.contacts.status;
    if (contactsPermissionStatus.isDenied) {
      final newPermissionStatus = await Permission.contacts.request();
      if (newPermissionStatus.isGranted) {
        return true;
      } else {
        return false;
      }
    } else if (contactsPermissionStatus.isPermanentlyDenied) {
      return false;
    } else {
      return true;
    }
  }
}
