part of 'create_felicitup_bloc.dart';

enum CreateStatus { initial, success, error }

@freezed
class CreateFelicitupState with _$CreateFelicitupState {
  const factory CreateFelicitupState({
    required int steperIndex,
    required bool isLoading,
    required bool hasBote,
    required bool hasVideo,
    required String eventReason,
    required List<Map<String, dynamic>> felicitupOwner,
    required List<Map<String, dynamic>> invitedContacts,
    required List<UserModel> friendList,
    required CreateStatus status,
    int? boteQuantity,
    DateTime? selectedDate,
  }) = _CreateFelicitupState;

  factory CreateFelicitupState.initial() => CreateFelicitupState(
        steperIndex: 0,
        isLoading: false,
        hasBote: false,
        hasVideo: false,
        eventReason: '',
        felicitupOwner: [],
        invitedContacts: [],
        friendList: [],
        status: CreateStatus.initial,
      );
}
