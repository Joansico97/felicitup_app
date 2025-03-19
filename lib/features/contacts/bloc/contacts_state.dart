part of 'contacts_bloc.dart';

@freezed
class ContactsState with _$ContactsState {
  const factory ContactsState({
    required bool isLoading,
  }) = _ContactsState;

  factory ContactsState.initial() => ContactsState(
        isLoading: false,
      );
}
