import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/constants/app_constants.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/chat_message_model/chat_message_model.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/helpers.dart';

class ChatFirebaseResource implements ChatRepository {
  ChatFirebaseResource({
    required FirebaseFirestore firestore,
    required DatabaseHelper databaseHelper,
  })  : _firestore = firestore,
        _databaseHelper = databaseHelper;

  final FirebaseFirestore _firestore;
  final DatabaseHelper _databaseHelper;

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
    } on FirebaseException catch (e) {
      return Left(ApiException(int.parse(e.code), e.message ?? "Error de Firebase"));
    } catch (e) {
      return Left(ApiException(1000, 'Error enviando mensaje al chat'));
    }
  }

  @override
  Future<Either<ApiException, void>> deleteChatDocument(String chatId) async {
    try {
      await _databaseHelper.delete(AppConstants.chatsCollection, document: chatId);
      return Right(null);
    } on FirebaseException catch (e) {
      return Left(ApiException(int.parse(e.code), e.message ?? "Error de Firebase"));
    } catch (e) {
      return Left(ApiException(1000, 'Error eliminando chat'));
    }
  }
}
