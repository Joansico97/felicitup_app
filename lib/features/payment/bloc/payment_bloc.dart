import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_event.dart';
part 'payment_state.dart';
part 'payment_bloc.freezed.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc({
    required FelicitupRepository felicitupRepository,
    required UserRepository userRepository,
  })  : _felicitupRepository = felicitupRepository,
        _userRepository = userRepository,
        super(PaymentState.initial()) {
    on<PaymentEvent>(
      (events, emit) => events.map(
        changeLoadign: (_) => _changeLoading(emit),
        getUserInformation: (event) => _getUserInformation(emit, event.id),
        uploadPaymenFile: (event) => _uploadPaymenFile(emit, event.file),
        confirmPaymentInfo: (event) => _confirmPaymentInfo(emit, event.felicitupId, event.userId),
        updatePaymentInfo: (event) => _updatePaymentInfo(
          emit,
          event.felicitupId,
          event.paymentMethod,
          event.paymentStatus,
          event.paymentDate,
          event.file,
        ),
      ),
    );
  }

  final FelicitupRepository _felicitupRepository;
  final UserRepository _userRepository;

  _changeLoading(Emitter<PaymentState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _getUserInformation(Emitter<PaymentState> emit, String id) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _userRepository.getUserInvitedInformation(id);
      response.fold(
        (error) {
          emit(
            state.copyWith(
              isLoading: false,
              updateStatus: UpdateStatus.error,
              errorMessage: error.message,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              isLoading: false,
              userInvitedInformationModel: data,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        updateStatus: UpdateStatus.error,
        errorMessage: 'Error obteniendo información',
      ));
    }
  }

  _uploadPaymenFile(Emitter<PaymentState> emit, File file) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _userRepository.uploadFile(file, 'payments');
      response.fold(
        (error) {
          emit(
            state.copyWith(
              isLoading: false,
              updateStatus: UpdateStatus.error,
              errorMessage: error.message,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              isLoading: false,
              fileUrl: data,
            ),
          );
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        updateStatus: UpdateStatus.error,
        errorMessage: 'Error subiendo archivo',
      ));
    }
  }

  _updatePaymentInfo(
    Emitter<PaymentState> emit,
    String felicitupId,
    String paymentMethod,
    String paymentStatus,
    DateTime paymentDate,
    String file,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _felicitupRepository.updatePaymentData(
        felicitupId,
        paymentMethod,
        paymentStatus,
        paymentDate,
        state.fileUrl ?? file,
      );
      response.fold(
        (error) {
          emit(
            state.copyWith(
              isLoading: false,
              updateStatus: UpdateStatus.error,
              errorMessage: error.message,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              isLoading: false,
              updateStatus: UpdateStatus.success,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          updateStatus: UpdateStatus.error,
          errorMessage: 'Error actualizando información',
        ),
      );
    }
  }

  _confirmPaymentInfo(Emitter<PaymentState> emit, String felicitupId, String userId) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _felicitupRepository.confirmPaymentData(felicitupId, userId);
      response.fold(
        (error) {
          emit(
            state.copyWith(
              isLoading: false,
              updateStatus: UpdateStatus.error,
              errorMessage: error.message,
            ),
          );
        },
        (data) {
          emit(
            state.copyWith(
              isLoading: false,
              updateStatus: UpdateStatus.success,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          updateStatus: UpdateStatus.error,
          errorMessage: 'Error actualizando información',
        ),
      );
    }
  }
}
