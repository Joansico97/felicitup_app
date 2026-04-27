part of 'terms_policies_bloc.dart';

@freezed
abstract class TermsPoliciesState with _$TermsPoliciesState {
  const factory TermsPoliciesState({
    required bool isLoading,
    List<TermsPoliciesModel>? termsAndConditions,
    List<TermsPoliciesModel>? privacyPolicy,
  }) = _TermsPoliciesState;

  factory TermsPoliciesState.initial() =>
      const TermsPoliciesState(isLoading: false);
}
