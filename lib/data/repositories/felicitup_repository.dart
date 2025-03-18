import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';

abstract class FelicitupRepository {
  Future<Either<ApiException, String>> createFelicitup({
    required int boteQuantity,
    required String eventReason,
    required String felicitupMessage,
    required bool hasVideo,
    required bool hasBote,
    required DateTime felicitupDate,
    required List<Map<String, dynamic>> listOwners,
    required List<Map<String, dynamic>> participants,
  });
  Future<Either<ApiException, void>> setLike(String felicitupId, String userId);
  Future<Either<ApiException, FelicitupModel>> getFelicitupById(String felicitupId);
  Stream<Either<ApiException, List<FelicitupModel>>> streamFelicitups(String userId);
  Stream<Either<ApiException, List<FelicitupModel>>> streamPastFelicitups(String userId);
  Stream<Either<ApiException, List<InvitedModel>>> getInvitedStream(String felicitupId);
}
