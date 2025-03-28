import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:felicitup_app/features/details_felicitup/details_felicitup_dashboard/bloc/details_felicitup_dashboard_bloc.dart';

void redirectHelper({required Map<String, dynamic> data}) {
  final String type = data['type'];
  final pushMessageType = pushMessageTypeToEnum(type);
  final felicitupId = data['felicitupId'] ?? '';
  final chatId = data['chatId'] ?? '';
  final name = data['name'] ?? '';
  final ids = data['ids'] ?? [];

  switch (pushMessageType) {
    case PushMessageType.felicitup:
      CustomRouter().router.go(
            RouterPaths.felicitupNotification,
            extra: felicitupId,
          );
      break;

    case PushMessageType.chat:
      if (CustomRouter().router.routerDelegate.state.matchedLocation == RouterPaths.messageFelicitup) {
        detailsFelicitupNavigatorKey.currentContext!
            .read<DetailsFelicitupDashboardBloc>()
            .add(DetailsFelicitupDashboardEvent.startListening(felicitupId));
      }
      logger.debug(CustomRouter().router.routerDelegate.state.matchedLocation);
      CustomRouter().router.go(
        RouterPaths.messageFelicitup,
        extra: {
          'felicitupId': felicitupId,
          'fromNotification': false,
          'chatId': chatId,
        },
      );

      break;

    case PushMessageType.payment:
      CustomRouter().router.go(
        RouterPaths.boteFelicitup,
        extra: {
          'felicitupId': felicitupId,
          'fromNotification': true,
        },
      );
      break;

    case PushMessageType.singleChat:
      CustomRouter().router.go(
        RouterPaths.singleChat,
        extra: {
          'chatId': chatId,
          'name': name,
          'ids': ids,
        },
      );
      break;

    case PushMessageType.participation:
      CustomRouter().router.go(
        RouterPaths.peopleFelicitup,
        extra: {
          'felicitupId': felicitupId,
          'fromNotification': true,
        },
      );
      break;
    case PushMessageType.video:
      CustomRouter().router.go(
        RouterPaths.videoFelicitup,
        extra: {
          'felicitupId': felicitupId,
          'fromNotification': true,
        },
      );
      break;
    case PushMessageType.past:
      CustomRouter().router.go(
        RouterPaths.chatPastFelicitup,
        extra: {
          'felicitupId': felicitupId,
          'fromNotification': false,
        },
      );
      break;
  }
}
