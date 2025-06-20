import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';

abstract class FelicitupRepository {
  Future<Either<ApiException, String>> createFelicitup({
    required String id,
    required int boteQuantity,
    required String eventReason,
    required String felicitupMessage,
    required bool hasVideo,
    required bool hasBote,
    required DateTime felicitupDate,
    required List<Map<String, dynamic>> listOwners,
    required List<Map<String, dynamic>> participants,
  });
  Future<Either<ApiException, void>> deleteFelicitup(String felicitupId);
  Future<Either<ApiException, void>> setLike(String felicitupId, String userId);
  Future<Either<ApiException, FelicitupModel>> getFelicitupById(
    String felicitupId,
  );
  Future<Either<ApiException, void>> setParticipation(
    String felicitupId,
    String newStatus,
  );
  Future<Either<ApiException, void>> deleteParticipant(
    String felicitupId,
    String userId,
  );
  Future<Either<ApiException, void>> updatePaymentData(
    String felicitupId,
    String paymentMethod,
    String paymentStatus,
    DateTime paymentDate,
    String fileUrl,
  );
  Future<Either<ApiException, void>> updateVideoData(
    String felicitupId,
    String fileUrl,
  );
  Future<Either<ApiException, void>> confirmPaymentData(
    String felicitupId,
    String userId,
  );
  Future<Either<ApiException, void>> mergeVideos(
    String felicitupId,
    List<String> listUrlVideos,
  );
  Future<Either<ApiException, void>> sendFelicitup(String felicitupId);
  Future<Either<ApiException, void>> updateDateFelicitup(
    String felicitupId,
    DateTime newDate,
  );
  Future<Either<ApiException, void>> updateFelicitupOwner(
    String felicitupId,
    List<OwnerModel> newOwners,
  );
  Future<Either<ApiException, void>> updateFelicitupParticipants(
    String felicitupId,
    List<InvitedModel> newParticipants,
  );
  Future<Either<ApiException, void>> updateBoteFelicitup(
    String felicitupId,
    int newBoteQuantity,
  );
  Future<Either<ApiException, void>> reportUserVideo(
    String felicitupId,
    String videoUrl,
    String userId,
  );
  Stream<Either<ApiException, FelicitupModel>> streamSingleFelicitup(
    String userId,
  );
  Stream<Either<ApiException, List<FelicitupModel>>> streamFelicitups(
    String userId,
  );
  Stream<Either<ApiException, List<FelicitupModel>>> streamPastFelicitups(
    String userId,
  );
  Stream<Either<ApiException, List<InvitedModel>>> getInvitedStream(
    String felicitupId,
  );
  Stream<Either<ApiException, List<ChatMessageModel>>> getChatMessages(
    String chatId,
  );
}
