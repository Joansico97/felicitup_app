import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';

abstract class ChatRepository {
  Future<Either<ApiException, void>> sendMessage(String chatId, ChatMessageModel message);
  Future<Either<ApiException, void>> sendMessageSingleChat(String chatId, ChatMessageModel message);
  Future<Either<ApiException, void>> deleteChatDocument(String chatId);
  Future<Either<ApiException, String>> createSingleChat(SingleChatModel singleChatData);
  Stream<Either<ApiException, List<ChatMessageModel>>> getChatMessages(String chatId);
}
