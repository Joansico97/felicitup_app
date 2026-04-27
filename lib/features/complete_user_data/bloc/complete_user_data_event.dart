part of 'complete_user_data_bloc.dart';

@freezed
class CompleteUserDataEvent with _$CompleteUserDataEvent {
  const factory CompleteUserDataEvent.completeUserData({
    required String firstName,
    required String lastName,
  }) = _completeUserData;
  const factory CompleteUserDataEvent.logout() = _logout;
}
