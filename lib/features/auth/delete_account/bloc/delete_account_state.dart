part of 'delete_account_bloc.dart';

@freezed
class DeleteAccountState with _$DeleteAccountState {
  const factory DeleteAccountState({required bool isLoading}) =
      _DeleteAccountState;

  factory DeleteAccountState.initial() => DeleteAccountState(isLoading: false);
}
