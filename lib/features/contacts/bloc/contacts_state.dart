part of 'contacts_bloc.dart';

@freezed
class ContactsState with _$ContactsState {
  const factory ContactsState({
    required bool isLoading,
    List<Map<String, dynamic>>? dataList,
  }) = _ContactsState;

  factory ContactsState.initial() => ContactsState(
        isLoading: false,
      );
}
