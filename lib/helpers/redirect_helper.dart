import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup_dashboard/bloc/details_felicitup_dashboard_bloc.dart';

void redirectHelper({required Map<String, dynamic> data}) {
  final router = CustomRouter().router;
  final String type = data['type'];
  final pushMessageType = pushMessageTypeToEnum(type);
  final felicitupId = data['felicitupId'] ?? '';
  final chatId = data['chatId'] ?? '';
  final name = data['name'] ?? '';
  final friendId = data['friendId'] ?? '';
  final userImage = data['userImage'] ?? '';

  switch (pushMessageType) {
    case PushMessageType.felicitup:
      router.go(RouterPaths.felicitupNotification, extra: felicitupId);
      break;

    case PushMessageType.chat:
      if (router.routerDelegate.state.matchedLocation ==
          RouterPaths.messageFelicitup) {
        detailsFelicitupNavigatorKey.currentContext!
            .read<DetailsFelicitupDashboardBloc>()
            .add(DetailsFelicitupDashboardEvent.startListening(felicitupId));
      }
      router.go(
        RouterPaths.messageFelicitup,
        extra: {'felicitupId': felicitupId, 'chatId': chatId},
      );

      break;

    case PushMessageType.payment:
      if (router.routerDelegate.state.matchedLocation ==
          RouterPaths.boteFelicitup) {
        detailsFelicitupNavigatorKey.currentContext!
            .read<DetailsFelicitupDashboardBloc>()
            .add(DetailsFelicitupDashboardEvent.startListening(felicitupId));
      }
      router.go(RouterPaths.boteFelicitup, extra: {'felicitupId': felicitupId});

      break;

    case PushMessageType.singleChat:
      final chatModel = SingleChatModel(
        chatId: chatId,
        userName: name,
        friendId: friendId,
        userImage: userImage,
      );
      router.go(RouterPaths.singleChat, extra: {'data': chatModel});
      break;

    case PushMessageType.participation:
      if (router.routerDelegate.state.matchedLocation ==
          RouterPaths.peopleFelicitup) {
        detailsFelicitupNavigatorKey.currentContext!
            .read<DetailsFelicitupDashboardBloc>()
            .add(DetailsFelicitupDashboardEvent.startListening(felicitupId));
      }
      router.go(
        RouterPaths.peopleFelicitup,
        extra: {'felicitupId': felicitupId},
      );
      break;
    case PushMessageType.video:
      if (router.routerDelegate.state.matchedLocation ==
          RouterPaths.videoFelicitup) {
        detailsFelicitupNavigatorKey.currentContext!
            .read<DetailsFelicitupDashboardBloc>()
            .add(DetailsFelicitupDashboardEvent.startListening(felicitupId));
      }
      router.go(
        RouterPaths.videoFelicitup,
        extra: {'felicitupId': felicitupId},
      );

      break;
    case PushMessageType.past:
      router.go(
        RouterPaths.chatPastFelicitup,
        extra: {'felicitupId': felicitupId},
      );
      break;
    case PushMessageType.reminder:
      CustomRouter().router.go(RouterPaths.reminders);
      break;
  }
}
