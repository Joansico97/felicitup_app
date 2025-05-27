part of 'app_bloc.dart';

@freezed
class AppState with _$AppState {
  const factory AppState({
    required bool isLoading,
    required bool showRememberSection,
    required AuthorizationStatus status,
    bool? isVerified,
    UserModel? currentUser,
    Map<String, dynamic>? federatedData,
    List<PushMessageModel>? notifications,
    @Default(0) int counter,
    @DurationConverter() Duration? globalTimerRemaining,
    @Default(false) bool isGlobalTimerActive,
    @DurationConverter() Duration? globalTimerInitialDuration,
  }) = _AppState;

  factory AppState.initial() => AppState(
    isLoading: false,
    showRememberSection: true,
    status: AuthorizationStatus.notDetermined,
    counter: 0,
    globalTimerRemaining: null,
    isGlobalTimerActive: false,
    globalTimerInitialDuration: null,
  );
}

class DurationConverter implements JsonConverter<Duration?, int?> {
  const DurationConverter();

  @override
  Duration? fromJson(int? json) {
    return json == null ? null : Duration(milliseconds: json);
  }

  @override
  int? toJson(Duration? object) {
    return object?.inMilliseconds;
  }
}
