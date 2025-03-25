part of 'home_bloc.dart';

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.changeLoading() = _changeLoading;
  const factory HomeEvent.changeCreate() = _changeCreate;
  const factory HomeEvent.changeShowButton() = _changeShowButton;
  const factory HomeEvent.getAndUpdateContacts(String isoCode) = _getAndUpdateContacts;
}
