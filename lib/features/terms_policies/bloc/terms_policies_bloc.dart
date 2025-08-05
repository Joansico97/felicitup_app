import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'terms_policies_event.dart';
part 'terms_policies_state.dart';
part 'terms_policies_bloc.freezed.dart';

class TermsPoliciesBloc extends Bloc<TermsPoliciesEvent, TermsPoliciesState> {
  TermsPoliciesBloc({required GeneralDataRepository generalDataRepository})
    : _generalDataRepository = generalDataRepository,
      super(TermsPoliciesState.initial()) {
    on<TermsPoliciesEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        getGeneralData: (_) => _getGeneralData(emit),
      ),
    );
  }

  final GeneralDataRepository _generalDataRepository;

  _changeLoading(Emitter<TermsPoliciesState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _getGeneralData(Emitter<TermsPoliciesState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _generalDataRepository.getTermsPoliciesTexts();
      response.fold(
        (error) {
          logger.error(error);
          emit(
            state.copyWith(
              termsAndConditions: null,
              privacyPolicy: null,
              isLoading: false,
            ),
          );
        },
        (data) {
          if (data.isNotEmpty) {
            emit(
              state.copyWith(
                termsAndConditions: data['termsAndCoditions'],
                privacyPolicy: data['privacyPolicies'],
                isLoading: false,
              ),
            );
          } else {
            emit(
              state.copyWith(
                termsAndConditions: null,
                privacyPolicy: null,
                isLoading: false,
              ),
            );
          }
        },
      );
    } catch (e) {
      logger.error('Error loading general data: $e');
      emit(state.copyWith(isLoading: false));
    }
  }
}
