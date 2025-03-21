part of 'terms_policies_bloc.dart';

@freezed
class TermsPoliciesState with _$TermsPoliciesState {
  const factory TermsPoliciesState({
    required bool isLoading,
  }) = _TermsPoliciesState;

  factory TermsPoliciesState.initial() => const TermsPoliciesState(
        isLoading: false,
      );
}
