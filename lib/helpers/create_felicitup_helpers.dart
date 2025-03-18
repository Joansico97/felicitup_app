import 'package:felicitup_app/data/models/models.dart';

List<String> createListIds({
  required String userId,
  required List<Map<String, dynamic>> participants,
}) {
  List<String> invitedIds = [];
  invitedIds.add(userId);
  for (var i = 0; i < participants.length; i++) {
    invitedIds.add(participants[i]['id']);
  }
  return invitedIds;
}

List<Map<String, dynamic>> createListIdsFromUsers({
  required UserModel currentUser,
  required List<Map<String, dynamic>> participants,
}) {
  List<Map<String, dynamic>> invitedIds = [];
  final Map<String, dynamic> user = {
    'id': currentUser.id ?? '',
    'name': currentUser.fullName,
    'userImage': currentUser.userImg,
    'assistanceStatus': enumToStringAssistance(AssistanceStatus.accepted),
    'videoData': {
      'videoUrl': '',
      'videoThumbnail': '',
    },
    'paid': enumToStringPayment(PaymentStatus.paid),
    'idInformation': '',
  };

  invitedIds.add(user);

  for (final element in participants) {
    final invitedUser = {
      'id': element['id'],
      'name': element['name'],
      'userImage': element['userImg'],
      'assistanceStatus': enumToStringAssistance(AssistanceStatus.pending),
      'videoData': {
        'videoUrl': '',
        'videoThumbnail': '',
      },
      'paid': enumToStringPayment(PaymentStatus.pending),
      'idInformation': '',
    };
    invitedIds.add(invitedUser);
  }
  return invitedIds;
}
