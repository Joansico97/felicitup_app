import 'package:either_dart/either.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/general_data_models/terms_policies_model/terms_policies_model.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:felicitup_app/helpers/helpers.dart';

class GeneralDataFirebaseResource implements GeneralDataRepository {
  GeneralDataFirebaseResource({required DatabaseHelper databaseHelper})
    : _databaseHelper = databaseHelper;

  final DatabaseHelper _databaseHelper;

  @override
  Future<Either<ApiException, Map<String, dynamic>>>
  getTermsPoliciesTexts() async {
    try {
      final data = await _databaseHelper.get(
        'GeneralData',
        document: '8cqaSB2z9pRyMbm9BYie',
      );

      if (data.isEmpty) {
        return Left(
          ApiException(1000, 'No se encontraron datos de términos y políticas'),
        );
      }

      final List<TermsPoliciesModel> policies = [];
      final List<TermsPoliciesModel> termsData = [];

      policies.addAll(
        (data['privacyPolicies'] as List)
            .map((item) => TermsPoliciesModel.fromJson(item))
            .toList(),
      );
      termsData.addAll(
        (data['termsAndCoditions'] as List)
            .map((item) => TermsPoliciesModel.fromJson(item))
            .toList(),
      );

      return Right({
        'privacyPolicies': policies,
        'termsAndCoditions': termsData,
      });
    } catch (e) {
      return Left(ApiException(1000, e.toString()));
    }
  }
}
