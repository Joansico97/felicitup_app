import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:felicitup_app/core/utils/utils.dart';
import 'package:felicitup_app/data/exceptions/api_exception.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/data/repositories/repositories.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'wish_list_event.dart';
part 'wish_list_state.dart';
part 'wish_list_bloc.freezed.dart';

class WishListBloc extends Bloc<WishListEvent, WishListState> {
  WishListBloc({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(WishListState.initial()) {
    on<WishListEvent>(
      (events, emit) => events.map(
        changeLoading: (_) => _changeLoading(emit),
        editGiftItem: (_) => _editGiftItem(emit),
        createGiftItem: (_) => _createGiftItem(emit),
        setProductName: (event) => _setProductName(emit, event.productName),
        setProductDescription: (event) => _setProductDescription(emit, event.productDescription),
        setProductPrice: (event) => _setProductPrice(emit, event.productPrice),
        setLinks: (event) => _setLinks(emit, event.links),
        createGiftItemInfo: (event) => _createGiftItemInfo(emit),
        editGiftItemInfo: (event) => _editGiftItemInfo(event.item),
        deleteGiftItemInfo: (event) => _deleteGiftItemInfo(emit, event.id),
        startListening: (_) => _startListening(emit),
        recivedData: (event) => _recivedData(emit, event.listGiftcard),
      ),
    );
  }

  final UserRepository _userRepository;

  StreamSubscription<Either<ApiException, List<GiftcarModel>>>? _giftcardListSubscription;

  _changeLoading(Emitter<WishListState> emit) {
    emit(state.copyWith(isLoading: !state.isLoading));
  }

  _editGiftItem(Emitter<WishListState> emit) {
    emit(state.copyWith(isEdit: !state.isEdit));
  }

  _createGiftItem(Emitter<WishListState> emit) {
    emit(state.copyWith(isCreate: !state.isCreate));
  }

  _setProductName(Emitter<WishListState> emit, String productName) {
    emit(state.copyWith(productName: productName));
  }

  _setProductDescription(Emitter<WishListState> emit, String productDescription) {
    emit(state.copyWith(productDescription: productDescription));
  }

  _setProductPrice(Emitter<WishListState> emit, String productPrice) {
    emit(state.copyWith(productPrice: productPrice));
  }

  _setLinks(Emitter<WishListState> emit, List<String> links) {
    emit(state.copyWith(links: links));
  }

  _createGiftItemInfo(Emitter<WishListState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final item = GiftcarModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: state.productName,
        productDescription: state.productDescription,
        productValue: state.productPrice,
        links: state.links,
      );
      await _userRepository.createGiftItem(item);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      logger.error('Error creando giftList item: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  _editGiftItemInfo(GiftcarModel itmeOriginal) async {
    try {
      final item = GiftcarModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productName: state.productName ?? itmeOriginal.productName,
        productDescription: state.productDescription ?? itmeOriginal.productDescription,
        productValue: state.productPrice ?? itmeOriginal.productValue,
        links: state.links ?? itmeOriginal.links,
      );
      await _userRepository.editGiftItem(
        itemId: itmeOriginal.id!,
        newProductName: item.productName,
        newProductDescription: item.productDescription,
        newProductValue: item.productValue,
        newLinks: item.links,
      );
    } catch (e) {
      logger.error('$e');
    }
  }

  _deleteGiftItemInfo(Emitter<WishListState> emit, String id) async {
    try {
      await _userRepository.deleteGiftItem(id);
    } catch (e) {
      logger.error('$e');
    }
  }

  _startListening(Emitter<WishListState> emit) {
    _giftcardListSubscription = _userRepository.getGiftcardListStream().listen((either) {
      either.fold(
        (error) {},
        (listGiftcard) {
          add(WishListEvent.recivedData(listGiftcard));
        },
      );
    });
  }

  Future<void> _recivedData(Emitter<WishListState> emit, List<GiftcarModel> listGiftcard) async {
    emit(state.copyWith(listGiftcard: listGiftcard));
  }

  @override
  Future<void> close() {
    _giftcardListSubscription?.cancel(); // Cancelar la suscripción *SIEMPRE*.
    return super.close();
  }
}
