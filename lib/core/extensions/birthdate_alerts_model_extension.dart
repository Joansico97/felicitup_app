import 'package:felicitup_app/data/models/models.dart';

extension BirthdateAlertsModelExtension on BirthdateAlertsModel {
  String getDisplayName(UserModel? currentUser) {
    if (currentUser == null) {
      return friendName ?? '';
    }
    try {
      final contact = currentUser.friendList?.firstWhere(
        (contact) => contact.uid == friendId,
      );
      return contact?.displayName ?? friendName ?? '';
    } catch (e) {
      return friendName ?? '';
    }
  }
}
