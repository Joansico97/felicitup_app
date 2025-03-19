import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/constants/app_constants.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/chat_message_model/chat_message_model.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';

class ChatFirebaseResource implements ChatRepository {
  ChatFirebaseResource({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  final FirebaseFirestore _firestore;
  @override
  Future<Either<ApiException, void>> sendMessage(
    String chatId,
    ChatMessageModel message,
  ) async {
    try {
      await _firestore.collection(AppConstants.chatsCollection).doc(chatId).update({
        'messages': FieldValue.arrayUnion([message.toJson()]),
      });
      return Right(null);
    } catch (e) {
      return Left(ApiException(1000, 'Error enviando mensaje al chat'));
    }
  }
}
