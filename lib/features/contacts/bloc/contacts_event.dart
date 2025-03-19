part of 'contacts_bloc.dart';

@freezed
class ContactsEvent with _$ContactsEvent {
  const factory ContactsEvent.changeLoading() = _changeLoading;
}
