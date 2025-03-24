import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:flutter/material.dart';

void redirectHelper({required Map<String, dynamic> data}) {
  final String type = data['type'];
  final pushMessageType = pushMessageTypeToEnum(type);
  final felicitupId = data['felicitupId'] ?? '';
  final chatId = data['chatId'] ?? '';
  final name = data['name'] ?? '';
  final ids = data['ids'] ?? [];

  switch (pushMessageType) {
    case PushMessageType.felicitup:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomRouter().router.go(
              RouterPaths.felicitupNotification,
              extra: felicitupId,
            );
      });
      break;
    case PushMessageType.chat:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomRouter().router.go(
          RouterPaths.messageFelicitup,
          extra: {
            'felicitupId': felicitupId,
            'fromNotification': false,
          },
        );
      });
    case PushMessageType.payment:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomRouter().router.go(
          RouterPaths.boteFelicitup,
          extra: {
            'felicitupId': felicitupId,
            'fromNotification': true,
          },
        );
      });
    case PushMessageType.singleChat:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomRouter().router.go(
          RouterPaths.singleChat,
          extra: {
            'chatId': chatId,
            'name': name,
            'ids': ids,
          },
        );
      });
      break;
    case PushMessageType.participation:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomRouter().router.go(
          RouterPaths.peopleFelicitup,
          extra: {
            'felicitupId': felicitupId,
            'fromNotification': true,
          },
        );
      });
      break;
    case PushMessageType.video:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomRouter().router.go(
          RouterPaths.videoFelicitup,
          extra: {
            'felicitupId': felicitupId,
            'fromNotification': true,
          },
        );
      });
      break;
    case PushMessageType.past:
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomRouter().router.go(
          RouterPaths.chatPastFelicitup,
          extra: {
            'felicitupId': felicitupId,
            'fromNotification': false,
          },
        );
      });
      break;
  }
}
