import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/data/models/models.dart';

void redirectHelper({required Map<String, dynamic> data}) {
  // 1. OBTENER LA INSTANCIA GLOBAL DEL ROUTER
  // (Esto asume que tu CustomRouter tiene un getter estático o es un singleton)
  final router = CustomRouter().router;

  // 2. PARSEO DE DATOS DE LA NOTIFICACIÓN
  final String type = data['type'] ?? '';
  final pushMessageType = pushMessageTypeToEnum(type);
  final felicitupId = data['felicitupId'] ?? '';
  final chatId = data['chatId'] ?? '';
  final name = data['name'] ?? '';
  final friendId = data['friendId'] ?? '';
  final userImage = data['userImage'] ?? '';

  String? targetPath;
  dynamic extraData;

  // 3. DETERMINAR LA RUTA Y LOS DATOS EXTRA (SIN NAVEGAR AÚN)
  switch (pushMessageType) {
    case PushMessageType.felicitup:
      targetPath = RouterPaths.felicitupNotification;
      extraData = felicitupId;
      break;
    case PushMessageType.chat:
      targetPath = RouterPaths.messageFelicitup;
      extraData = {'felicitupId': felicitupId, 'chatId': chatId};
      break;
    case PushMessageType.payment:
      targetPath = RouterPaths.boteFelicitup;
      extraData = {'felicitupId': felicitupId};
      break;
    case PushMessageType.singleChat:
      targetPath = RouterPaths.singleChat;
      extraData = {
        'data': SingleChatModel(
          chatId: chatId,
          userName: name,
          friendId: friendId,
          userImage: userImage,
        ),
      };
      break;
    case PushMessageType.participation:
      targetPath = RouterPaths.peopleFelicitup;
      extraData = {'felicitupId': felicitupId};
      break;
    case PushMessageType.video:
      targetPath = RouterPaths.videoFelicitup;
      extraData = {'felicitupId': felicitupId};
      break;
    case PushMessageType.past:
      targetPath = RouterPaths.chatPastFelicitup;
      extraData = {'felicitupId': felicitupId};
      break;
    case PushMessageType.reminder:
      targetPath = RouterPaths.reminders;
      extraData = null;
      break;
  }

  // 4. LÓGICA DE NAVEGACIÓN CONDICIONAL
  // Definimos las rutas que pertenecen a cada ShellRoute.
  const detailsFelicitupShellRoutes = [
    RouterPaths.infoFelicitup,
    RouterPaths.messageFelicitup,
    RouterPaths.peopleFelicitup,
    RouterPaths.videoFelicitup,
    RouterPaths.boteFelicitup,
  ];

  const pastDetailsFelicitupShellRoutes = [
    RouterPaths.mainPastFelicitup,
    RouterPaths.chatPastFelicitup,
    RouterPaths.peoplePastFelicitup,
    RouterPaths.videoPastFelicitup,
  ];

  if (detailsFelicitupShellRoutes.contains(targetPath)) {
    // CASO 1: La ruta pertenece al ShellRoute de detalles.
    // Navegamos a la PRIMERA ruta hija (`infoFelicitup`) para que se construya el Shell.
    router.go(
      RouterPaths.infoFelicitup,
      extra: {
        'felicitupId': felicitupId,
        'fromNotification': true,
        'targetSubRoute': targetPath, // <- Le pasamos la ruta final deseada
        'chatId': chatId,
      },
    );
  } else if (pastDetailsFelicitupShellRoutes.contains(targetPath)) {
    // CASO 2: La ruta pertenece al ShellRoute de felicitups pasados.
    router.go(
      RouterPaths.mainPastFelicitup, // <- Navegamos a su primera ruta hija
      extra: {
        'felicitupId': felicitupId,
        'fromNotification': true,
        'targetSubRoute': targetPath, // <- Le pasamos la ruta final deseada
      },
    );
  } else {
    // CASO 3: Es una ruta normal e independiente. Navegamos directamente.
    router.go(targetPath, extra: extraData);
  }
}
