part of 'app_bloc.dart';

@freezed
abstract class AppState with _$AppState {
  const factory AppState({
    required bool isLoading,
    required bool isLoadingContacts,
    required bool reloadContacts,
    required bool showRememberSection,
    required AuthorizationStatus status,
    required PermissionStatus contactsPermissionStatus,
    TermsPoliciesModel? termsAndConditions,
    TermsPoliciesModel? privacyPolicy,
    Map<String, dynamic>? pendingNotificationPayload,
    List<Map<String, dynamic>>? dataList,
    bool? isVerified,
    UserModel? currentUser,
    Map<String, dynamic>? federatedData,
    List<PushMessageModel>? notifications,
  }) = _AppState;

  factory AppState.initial() => AppState(
    isLoading: false,
    isLoadingContacts: false,
    reloadContacts: true,
    showRememberSection: true,
    status: AuthorizationStatus.notDetermined,
    contactsPermissionStatus: PermissionStatus.denied,
  );
}
