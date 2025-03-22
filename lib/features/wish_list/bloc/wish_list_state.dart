part of 'wish_list_bloc.dart';

@freezed
class WishListState with _$WishListState {
  const factory WishListState({
    required bool isLoading,
    required bool isCreate,
    required bool isEdit,
    String? productName,
    String? productDescription,
    String? productPrice,
    List<String>? links,
    List<GiftcarModel>? listGiftcard,
  }) = _WishListState;

  factory WishListState.initial() => const WishListState(
        isLoading: false,
        isCreate: false,
        isEdit: false,
      );
}
