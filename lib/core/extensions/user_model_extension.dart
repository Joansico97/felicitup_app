import 'package:collection/collection.dart';
import 'package:felicitup_app/data/models/models.dart';

extension UserModelExtension on UserModel {
  String getDisplayName(UserModel? currentUser) {
    if (currentUser == null || currentUser.friendList == null) {
      return fullName ?? '';
    }

    if (id == currentUser.id) {
      return fullName ?? '';
    }

    final contact = currentUser.friendList!.firstWhereOrNull(
      (contact) => contact.phone == phone,
    );

    return contact?.displayName ?? fullName ?? '';
  }
}
