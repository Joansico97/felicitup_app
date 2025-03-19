import 'package:bloc/bloc.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wish_list_event.dart';
part 'wish_list_state.dart';
part 'wish_list_bloc.freezed.dart';

class WishListBloc extends Bloc<WishListEvent, WishListState> {
  WishListBloc({
    required FirebaseAuth firebaseAuth,
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(WishListState.initial()) {
    on<WishListEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        editGiftItem: (_) => _editGiftItem(emit),
        createGiftItem: (_) => _createGiftItem(emit),
        createGiftItemInfo: (event) => _createGiftItemInfo(event.item),
        editGiftItemInfo: (event) => _editGiftItemInfo(event.item),
        deleteGiftItemInfo: (event) => _deleteGiftItemInfo(event.id),
      ),
    );
  }

  final UserRepository _userRepository;

  _changeLoading(Emitter<WishListState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _editGiftItem(Emitter<WishListState> emit) {
    emit(state.copyWith(isEdit: !state.isEdit));
  }

  _createGiftItem(Emitter<WishListState> emit) {
    emit(state.copyWith(isCreate: !state.isCreate));
  }

  _createGiftItemInfo(GiftcarModel item) async {
    try {
      await _userRepository.createGiftItem(item);
    } catch (e) {
      logger.error('$e');
    }
  }

  _editGiftItemInfo(GiftcarModel item) async {
    try {
      await _userRepository.editGiftItem(item);
    } catch (e) {
      logger.error('$e');
    }
  }

  _deleteGiftItemInfo(String id) async {
    try {
      await _userRepository.deleteGiftItem(id);
    } catch (e) {
      logger.error('$e');
    }
  }
}
