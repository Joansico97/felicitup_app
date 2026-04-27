part of 'contacts_bloc.dart';

@freezed
abstract class ContactsEvent with _$ContactsEvent {
  const factory ContactsEvent.changeIsFirstTime() = _changeIsFirstTime;
  const factory ContactsEvent.getInfoSingleContact(String phone) =
      _getInfoSingleContact;
  const factory ContactsEvent.addManualContact({
    required Map<String, dynamic> user,
    required String isoCode,
  }) = _addManualContact;
}
