import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/constants/app_constants.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/chat_message_model/chat_message_model.dart';
import 'package:felicitup_app/data/models/user_models/single_chat_model/single_chat_model.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatFirebaseResource implements ChatRepository {
  ChatFirebaseResource({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
    required DatabaseHelper databaseHelper,
  })  : _firestore = firestore,
        _firebaseAuth = firebaseAuth,
        _databaseHelper = databaseHelper;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
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

  @override
  Future<Either<ApiException, void>> sendMessageSingleChat(
    String chatId,
    ChatMessageModel message,
  ) async {
    try {
      await _firestore.collection(AppConstants.singleChatsCollection).doc(chatId).update({
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
  Future<Either<ApiException, String>> createSingleChat(SingleChatModel singleChatData) async {
    try {
      final collectionRef = _firestore.collection(AppConstants.chatsCollection);
      final chatId = collectionRef.doc();
      final collRef = _firestore.collection(AppConstants.usersCollection).doc(_firebaseAuth.currentUser?.uid);
      final otherRef = _firestore.collection(AppConstants.usersCollection).doc(singleChatData.friendId);
      await _databaseHelper.set(
        AppConstants.singleChatsCollection,
        document: chatId.id,
        {
          'messages': [],
        },
      );

      final data = {
        'chatId': chatId.id,
        'userName': singleChatData.userName,
        'friendId': singleChatData.friendId,
        'userImage': singleChatData.userImage,
      };

      await collRef.update({
        'singleChats': FieldValue.arrayUnion([
          data,
        ]),
      });
      await otherRef.update({
        'singleChats': FieldValue.arrayUnion([
          data,
        ]),
      });
      return Right(chatId.id);
    } on FirebaseException catch (e) {
      return Left(ApiException(int.parse(e.code), e.message ?? "Error de Firebase"));
    } catch (e) {
      return Left(ApiException(1000, 'Error creando single chat'));
    }
  }

  @override
  Stream<Either<ApiException, List<ChatMessageModel>>> getChatMessages(String chatId) {
    try {
      return _firestore.collection(AppConstants.singleChatsCollection).doc(chatId).snapshots().map((event) {
        final data = event.data();
        if (data == null) {
          return Left(ApiException(1000, 'Felicitup not found'));
        }
        final List<Map<String, dynamic>> messageData = List.from(data['messages']);
        final List<ChatMessageModel> listMessages = messageData.map((e) => ChatMessageModel.fromJson(e)).toList();
        return Right(listMessages);
      });
    } catch (e) {
      return Stream.value(Left(ApiException(1000, e.toString())));
    }
  }
}
