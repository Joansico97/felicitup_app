import 'package:bloc/bloc.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'phone_verify_int_event.dart';
part 'phone_verify_int_state.dart';
part 'phone_verify_int_bloc.freezed.dart';

class PhoneVerifyIntBloc
    extends Bloc<PhoneVerifyIntEvent, PhoneVerifyIntState> {
  PhoneVerifyIntBloc({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       super(PhoneVerifyIntState.initial()) {
    on<PhoneVerifyIntEvent>(
      (events, emit) => events.map(
        savePhoneInfo:
            (event) => _savePhoneInfo(emit, event.phoneNumber, event.isoCode),
        initValidation: (_) => _initValidation(emit),
        validateCode: (event) => _validateCode(emit, event.code),
      ),
    );
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  _savePhoneInfo(
    Emitter<PhoneVerifyIntState> emit,
    String phone,
    String isoCode,
  ) async {
    emit(
      state.copyWith(
        isLoading: false,
        phoneNumber: phone,
        isoCode: isoCode,
        currentStep: state.currentStep + 1,
      ),
    );
  }

  _initValidation(Emitter<PhoneVerifyIntState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _authRepository.verifyPhone(
        phone: state.phoneNumber!,
        onCodeSent: (verificationId) {
          emit(
            state.copyWith(verificationId: verificationId, isLoading: false),
          );
        },
        onError: (error) {
          emit(state.copyWith(isLoading: false));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _validateCode(Emitter<PhoneVerifyIntState> emit, String code) async {
    emit(state.copyWith(isLoading: true));
    try {
      final response = await _authRepository.confirmVerification(
        verificationId: state.verificationId!,
        smsCode: code,
        phoneNumber: '${state.isoCode}${state.phoneNumber}',
      );

      return response.fold(
        (l) {
          emit(state.copyWith(isLoading: false));
        },
        (r) async {
          await _setUserInfo();
          emit(state.copyWith(isLoading: false, finished: true));
        },
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  _setUserInfo() async {
    await _userRepository.setUserPhone(state.phoneNumber!, state.isoCode!);
  }
}
