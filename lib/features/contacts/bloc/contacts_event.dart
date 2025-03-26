part of 'contacts_bloc.dart';

@freezed
class ContactsEvent with _$ContactsEvent {
  const factory ContactsEvent.changeLoading() = _changeLoading;
  const factory ContactsEvent.generateListData(
    List<ContactModel> contacts,
    List<String> ids,
  ) = _generateListData;
  const factory ContactsEvent.getInfoContacts(List<String> phones) = _getInfoContacts;
}
