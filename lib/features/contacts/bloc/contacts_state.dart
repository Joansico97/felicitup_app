part of 'contacts_bloc.dart';

@freezed
class ContactsState with _$ContactsState {
  const factory ContactsState({
    required bool isLoading,
    required bool isFirstTime,
    required bool reloadContacts,
    UserModel? dataSingleUsers,
    String? errorMessage,
  }) = _ContactsState;

  factory ContactsState.initial() =>
      ContactsState(isLoading: false, isFirstTime: true, reloadContacts: false);
}
