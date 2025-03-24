import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/constants/constants.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_felicitup_event.dart';
part 'create_felicitup_state.dart';
part 'create_felicitup_bloc.freezed.dart';

class CreateFelicitupBloc extends Bloc<CreateFelicitupEvent, CreateFelicitupState> {
  CreateFelicitupBloc({
    required DatabaseHelper databaseHelper,
    required UserRepository userRepository,
    required FelicitupRepository felicitupRepository,
  })  : _databaseHelper = databaseHelper,
        _userRepository = userRepository,
        _felicitupRepository = felicitupRepository,
        super(CreateFelicitupState.initial()) {
    on<CreateFelicitupEvent>(
      (events, emit) => events.map(
        deleteCurrentFelicitup: (_) => _deleteCurrentFelicitup(emit),
        previousStep: (_) => _previousStep(emit),
        nextStep: (event) => _nextStep(emit, event.lenght),
        jumpToStep: (event) => _jumpToStep(emit, event.index),
        toggleHasVideo: (_) => _toggleHasVideo(emit),
        toggleHasBote: (_) => _toggleHasBote(emit),
        changeBoteQuantity: (event) => _changeBoteQuantity(emit, event.quantity),
        changeEventReason: (event) => _changeEventReason(emit, event.reason),
        changeFelicitupDate: (event) => _changeFelicitupDate(emit, event.felicitupDate),
        changeFelicitupOwner: (event) => _changeFelicitupOwner(emit, event.felicitupOwner),
        addParticipant: (event) => _addParticipant(emit, event.participant),
        loadFriendsData: (event) => _loadFriendsData(emit, event.usersIds),
        createFelicitup: (event) => _createFelicitup(emit, event.felicitupMessage),
        searchEvent: (event) => _searchEvent(emit, event.value),
      ),
    );
  }

  final DatabaseHelper _databaseHelper;
  final UserRepository _userRepository;
  final FelicitupRepository _felicitupRepository;

  _previousStep(Emitter<CreateFelicitupState> emit) {
    emit(state.copyWith(steperIndex: state.steperIndex - 1));
  }

  _nextStep(Emitter<CreateFelicitupState> emit, int lenght) {
    switch (state.steperIndex) {
      case 0:
        if (state.felicitupOwner.length == 1 || (state.felicitupOwner.length >= 2 && state.selectedDate != null)) {
          emit(state.copyWith(steperIndex: state.steperIndex + 1));
        } else {
          ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                state.felicitupOwner.length > 1 && state.selectedDate == null
                    ? 'Debes seleccionar una fecha'
                    : 'Debes seleccionar al menos un amigo',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
      case 1:
        if (state.eventReason.isNotEmpty) {
          emit(state.copyWith(steperIndex: state.steperIndex + 1));
        } else {
          ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                'Debes seleccionar un motivo',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
      case 2:
        if (state.felicitupOwner.isNotEmpty) {
          emit(state.copyWith(steperIndex: state.steperIndex + 1));
        } else {
          ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                'Debes seleccionar al menos un amigo',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
      case 3:
        if ((state.hasBote && state.boteQuantity != null) || !state.hasBote) {
          emit(state.copyWith(steperIndex: state.steperIndex + 1));
        } else {
          ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                'Debes agregar una cantidad para el bote',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
      case 4:
        break;
    }
  }

  _jumpToStep(Emitter<CreateFelicitupState> emit, int index) {
    switch (index) {
      case 0:
        emit(state.copyWith(steperIndex: index));
        break;
      case 1:
        if (state.felicitupOwner.length == 1 || (state.felicitupOwner.length >= 2 && state.selectedDate != null)) {
          emit(state.copyWith(steperIndex: index));
        } else {
          ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                state.felicitupOwner.length > 1 && state.selectedDate == null
                    ? 'Debes seleccionar una fecha'
                    : 'Debes seleccionar al menos un amigo',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
      case 2:
        if (state.eventReason.isNotEmpty) {
          emit(state.copyWith(steperIndex: index));
        } else {
          ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                'Debes seleccionar un motivo',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
      case 3:
        if (state.felicitupOwner.isNotEmpty) {
          emit(state.copyWith(steperIndex: index));
        } else {
          ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                'Debes seleccionar al menos un amigo',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
      case 4:
        if (state.felicitupOwner.isNotEmpty && state.eventReason.isNotEmpty) {
          emit(state.copyWith(steperIndex: index));
        } else {
          ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
            SnackBar(
              content: Text(
                'Debes completar los pasos previos',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        break;
      default:
    }
  }

  _deleteCurrentFelicitup(Emitter<CreateFelicitupState> emit) {
    emit(CreateFelicitupState.initial());
  }

  _changeEventReason(Emitter<CreateFelicitupState> emit, String reason) {
    emit(state.copyWith(eventReason: reason));
  }

  _changeFelicitupDate(Emitter<CreateFelicitupState> emit, DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  _toggleHasVideo(Emitter<CreateFelicitupState> emit) {
    emit(state.copyWith(hasVideo: !state.hasVideo));
  }

  _toggleHasBote(Emitter<CreateFelicitupState> emit) {
    emit(state.copyWith(hasBote: !state.hasBote));
  }

  _changeBoteQuantity(Emitter<CreateFelicitupState> emit, int quantity) {
    emit(state.copyWith(boteQuantity: quantity));
  }

  _changeFelicitupOwner(Emitter<CreateFelicitupState> emit, Map<String, dynamic> owner) {
    final List<Map<String, dynamic>> owners = [...state.felicitupOwner];
    bool exist = owners.any((element) => element['name'] == owner['name']);
    if (!exist) {
      owners.add(owner);
    } else {
      owners.remove(owner);
    }
    emit(state.copyWith(felicitupOwner: owners));
  }

  _addParticipant(Emitter<CreateFelicitupState> emit, Map<String, dynamic> participant) {
    final List<Map<String, dynamic>> participants = [...state.invitedContacts];
    logger.debug(participants);
    if (participants.contains(participant)) {
      participants.remove(participant);
    } else {
      participants.add(participant);
    }
    emit(state.copyWith(invitedContacts: participants));
  }

  _loadFriendsData(Emitter<CreateFelicitupState> emit, List<String> usersIds) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _userRepository.getListUserData(usersIds);
      response.fold(
        (error) {
          emit(state.copyWith(isLoading: false));
          unawaited(showErrorModal(error.message));
        },
        (users) {
          List<UserModel> usersList = [];
          for (final data in users) {
            usersList.add(UserModel.fromJson(data));
          }
          emit(state.copyWith(isLoading: false, friendList: usersList));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _createFelicitup(Emitter<CreateFelicitupState> emit, String felicitupMessage) async {
    emit(state.copyWith(isLoading: true));
    try {
      final now = DateTime.now();
      DateTime felicitupDate = state.selectedDate ?? state.felicitupOwner.first['date'];
      int currentMonth = now.month;
      int currentDay = now.day;
      int otherMonth = felicitupDate.month;
      int otherDay = felicitupDate.day;
      if (otherMonth < currentMonth || (otherMonth == currentMonth && otherDay < currentDay)) {
        felicitupDate = DateTime(
          DateTime.now().year + 1,
          felicitupDate.month,
          felicitupDate.day,
          felicitupDate.hour,
          felicitupDate.minute,
          felicitupDate.second,
        );
      } else {
        felicitupDate = DateTime(
          DateTime.now().year,
          felicitupDate.month,
          felicitupDate.day,
          felicitupDate.hour,
          felicitupDate.minute,
          felicitupDate.second,
        );
      }
      final felicitupId = _databaseHelper.createId(AppConstants.feclitiupsCollection);

      final response = await _felicitupRepository.createFelicitup(
        id: felicitupId,
        boteQuantity: state.boteQuantity ?? 0,
        eventReason: state.eventReason,
        felicitupMessage: felicitupMessage,
        hasVideo: state.hasVideo,
        hasBote: state.hasBote,
        felicitupDate: felicitupDate,
        listOwners: state.felicitupOwner,
        participants: state.invitedContacts,
      );

      response.fold(
        (l) {
          emit(state.copyWith(isLoading: false));
          unawaited(showErrorModal(l.message));
        },
        (r) async {
          List participants = [...state.invitedContacts];
          List<String> ids = participants.map((e) => e['id'] as String).toList();
          ids.removeAt(0);
          for (String id in ids) {
            await _userRepository.sendNotification(
              id,
              'Nueva Felicitup',
              'Has sido invitado a un felicitup',
              '',
              DataMessageModel(
                type: enumToPushMessageType(PushMessageType.felicitup),
                felicitupId: felicitupId,
                chatId: '',
                name: '',
              ),
            );
          }

          emit(state.copyWith(
            isLoading: false,
            status: CreateStatus.success,
          ));
          emit(CreateFelicitupState.initial());
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      showErrorModal('Ocurrió un error al crear la felicitup');
    }
  }

  _searchEvent(Emitter<CreateFelicitupState> emit, String value) {
    final listProv = state.friendList.where((element) {
      return element.fullName != null &&
          value.toLowerCase().split('').every((char) => element.fullName!.toLowerCase().contains(char));
    }).toList();
    emit(state.copyWith(friendList: listProv));
  }
}
