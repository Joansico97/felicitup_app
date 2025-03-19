import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';

abstract class ChatRepository {
  Future<Either<ApiException, void>> sendMessage(String chatId, ChatMessageModel message);
}
