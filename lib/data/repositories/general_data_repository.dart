import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';

abstract class GeneralDataRepository {
  Future<Either<ApiException, Map<String, dynamic>>> getTermsPoliciesTexts();
}
