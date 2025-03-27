part of 'profile_bloc.dart';

@freezed
class ProfileEvent with _$ProfileEvent {
  const factory ProfileEvent.changeLoading() = _changeLoading;
  const factory ProfileEvent.updateUserImageFromUrl(String url) = _updateUserImageFromUrl;
  const factory ProfileEvent.updateUserImageFromFile(File file) = _updateUserImageFromFile;
  const factory ProfileEvent.updateUserInfo(UserModel user) = _updateUserInfo;
}
