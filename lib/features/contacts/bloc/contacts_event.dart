part of 'contacts_bloc.dart';

@freezed
class ContactsEvent with _$ContactsEvent {
  const factory ContactsEvent.changeIsFirstTime() = _changeIsFirstTime;
  const factory ContactsEvent.getInfoSingleContact(String phone) =
      _getInfoSingleContact;
}
