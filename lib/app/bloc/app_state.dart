part of 'app_bloc.dart';

@freezed
class AppState with _$AppState {
  const factory AppState({
    required bool isLoading,
    required AuthorizationStatus status,
    bool? isVerified,
    UserModel? currentUser,
    Map<String, dynamic>? federatedData,
    List<PushMessageModel>? notifications,
  }) = _AppState;

  factory AppState.initial() =>
      AppState(isLoading: false, status: AuthorizationStatus.notDetermined);
}
