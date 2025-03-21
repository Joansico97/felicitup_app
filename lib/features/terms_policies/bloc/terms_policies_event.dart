part of 'terms_policies_bloc.dart';

@freezed
class TermsPoliciesEvent with _$TermsPoliciesEvent {
  const factory TermsPoliciesEvent.changeLoading() = _changeLoading;
}
