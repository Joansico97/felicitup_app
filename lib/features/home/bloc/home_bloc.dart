import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:fast_contacts/fast_contacts.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:permission_handler/permission_handler.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

class HashedContact {
  final String displayName;
  final String hashedPhone;

  HashedContact({required this.displayName, required this.hashedPhone});
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({required UserRepository userRepository})
    : _userRepository = userRepository,
      super(HomeState.initial()) {
    on<HomeEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        changeCreate: (_) => _changeCreate(emit),
        setUserBirthdate: (event) => _setUserBirthdate(emit, event.date),
        changeShowButton: (_) => _changeShowButton(emit),
        getAndUpdateContacts: (event) =>
            _getAndUpdateContacts(emit, event.isoCode),
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

  _getAndUpdateContacts(Emitter<HomeState> emit, String isoCode) async {
    final contacts = await getHashedContacts(isoCode);

    List<Map<String, dynamic>> contactsMapList = contacts
        .where((e) => e.displayName.isNotEmpty && e.hashedPhone.isNotEmpty)
        .map((e) {
          return {'displayName': e.displayName, 'phone': e.hashedPhone};
        })
        .toList();

    RegExp nameRegex = RegExp(r'\d{3,}');
    contactsMapList.removeWhere(
      (element) =>
          element['displayName'] == null || element['displayName'].isEmpty,
    );
    contactsMapList.removeWhere(
      (element) => nameRegex.hasMatch(element['displayName'] ?? ''),
    );

    List<String> friendsPhoneList = contactsMapList
        .map((e) => e['phone'] as String)
        .toList();

    await _userRepository.updateContacts(contactsMapList, friendsPhoneList);
    emit(state.copyWith(status: HomeStatus.contactsUpdateSuccess));
  }

  _setUserBirthdate(Emitter<HomeState> emit, DateTime date) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _userRepository.updateUserBirthdate(date);

      response.fold(
        (l) {
          emit(state.copyWith(isLoading: false));
          throw l;
        },
        (r) {
          emit(state.copyWith(isLoading: false));
          ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                'Fecha de cumpleaños actualizada correctamente',
                style: rootNavigatorKey.currentContext!.styles.paragraph
                    .copyWith(
                      color: rootNavigatorKey.currentContext!.colors.white,
                    ),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<List<HashedContact>> getHashedContacts(String isoCode) async {
    bool isGranted = await _checkContactsPermission();

    if (isGranted) {
      final packageContacts = await FastContacts.getAllContacts();

      List<HashedContact> hashedContacts = [];

      for (var contact in packageContacts) {
        if (contact.displayName.isEmpty || contact.phones.isEmpty) continue;

        String phoneNumber = contact.phones[0].number;
        if (phoneNumber.length < 8) continue;

        String normalizedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

        if (!normalizedPhone.startsWith('+')) {
          normalizedPhone = '+$isoCode$normalizedPhone';
        }

        var bytes = utf8.encode(normalizedPhone);
        var digest = sha256.convert(bytes);
        String hashedPhone = digest.toString();

        hashedContacts.add(
          HashedContact(
            displayName: contact.displayName,
            hashedPhone: hashedPhone,
          ),
        );
      }

      hashedContacts.sort(
        (a, b) => a.displayName.toLowerCase().trim().compareTo(
          b.displayName.toLowerCase().trim(),
        ),
      );

      return hashedContacts;
    }

    return [];
  }

  Future<bool> _checkContactsPermission() async {
    final contactsPermissionStatus = await Permission.contacts.status;

    if (!contactsPermissionStatus.isGranted) {
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
