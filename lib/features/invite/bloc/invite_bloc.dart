import 'package:bloc/bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_event.dart';
part 'invite_state.dart';
part 'invite_bloc.freezed.dart';

class InviteBloc extends Bloc<InviteEvent, InviteState> {
  InviteBloc({
    required FelicitupRepository felicitupRepository,
    required UserRepository userRepository,
  })  : _felicitupRepository = felicitupRepository,
        _userRepository = userRepository,
        super(InviteState.initial()) {
    on<InviteEvent>((events, emit) async {
      await events.map(
        changeLoading: (_) async => _changeLoading(emit),
        loadInviteData: (event) async => _loadInviteData(emit, event.felicitupId),
        joinFelicitup: (_) async => _joinFelicitup(emit),
      );
    });
  }

  final FelicitupRepository _felicitupRepository;
  final UserRepository _userRepository;

  void _changeLoading(Emitter<InviteState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  Future<void> _loadInviteData(Emitter<InviteState> emit, String felicitupId) async {
    emit(state.copyWith(isLoading: true, status: InviteStatus.loading));
    final result = await _felicitupRepository.getFelicitupById(felicitupId);
    
    result.fold(
      (l) {
        emit(state.copyWith(
          isLoading: false,
          status: InviteStatus.error,
          errorMessage: l.message,
        ));
      },
      (r) {
        emit(state.copyWith(
          isLoading: false,
          status: InviteStatus.initial,
          currentFelicitup: r,
        ));
      },
    );
  }

  Future<void> _joinFelicitup(Emitter<InviteState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      emit(state.copyWith(isLoading: false, status: InviteStatus.authRequired));
      // Revert immediately to initial to avoid locking
      emit(state.copyWith(status: InviteStatus.initial));
      return;
    }

    final felicitup = state.currentFelicitup;
    if (felicitup == null) {
      emit(state.copyWith(isLoading: false, status: InviteStatus.error, errorMessage: 'No felicitup loaded'));
      return;
    }

    if (felicitup.invitedUsers.contains(currentUser.uid)) {
      // User is already in the felicitup
      emit(state.copyWith(isLoading: false, status: InviteStatus.success));
      return;
    }

    try {
      // Get user full data
      final userDataResult = await _userRepository.getUserData(currentUser.uid);
      
      UserModel? fullUser;
      userDataResult.fold(
        (l) => null,
        (r) {
          fullUser = UserModel.fromJson(r);
        }
      );

      final newParticipant = InvitedModel(
        id: currentUser.uid,
        name: fullUser?.firstName ?? currentUser.displayName ?? 'Usuario',
        userImage: fullUser?.userImg ?? currentUser.photoURL,
        assistanceStatus: enumToStringAssistance(AssistanceStatus.accepted),
        paid: enumToStringPayment(PaymentStatus.pending),
        videoData: const VideoDataModel(),
        idInformation: '',
      );

      final updateResult = await _felicitupRepository.updateFelicitupParticipants(
        felicitup.id,
        [newParticipant],
      );

      updateResult.fold(
        (l) {
          emit(state.copyWith(isLoading: false, status: InviteStatus.error, errorMessage: l.message));
        },
        (r) async {
          // Send notification to the owner
          try {
            final userName = fullUser?.firstName ?? currentUser.displayName ?? 'Alguien';
            final ownerName = felicitup.owner.isNotEmpty ? felicitup.owner[0].name : '';
            
            await FirebaseFunctions.instance.httpsCallable('sendNotification').call({
              'userId': felicitup.createdBy,
              'title': 'Nuevo Participante',
              'message': '$userName se ha unido a la felicitup de $ownerName',
            });
          } catch (e) {
            // Ignore notification errors as they shouldn't block the user flow
          }
          emit(state.copyWith(isLoading: false, status: InviteStatus.success));
        }
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, status: InviteStatus.error, errorMessage: e.toString()));
    }
  }
}
