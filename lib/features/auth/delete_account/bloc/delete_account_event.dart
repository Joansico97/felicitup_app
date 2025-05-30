part of 'delete_account_bloc.dart';

@freezed
class DeleteAccountEvent with _$DeleteAccountEvent {
  const factory DeleteAccountEvent.deleteAccountEvent({
    required String userId,
    required List<String> answers,
  }) = _deleteAccountEvent;
}
