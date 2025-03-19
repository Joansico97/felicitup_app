part of 'wish_list_bloc.dart';

@freezed
class WishListEvent with _$WishListEvent {
  const factory WishListEvent.changeLoading() = _changeLoading;
  const factory WishListEvent.createGiftItem() = _createGiftItem;
  const factory WishListEvent.editGiftItem() = _editGiftItem;
  const factory WishListEvent.createGiftItemInfo(GiftcarModel item) = _createGiftItemInfo;
  const factory WishListEvent.editGiftItemInfo(GiftcarModel item) = _editGiftItemInfo;
  const factory WishListEvent.deleteGiftItemInfo(String id) = _deleteGiftItemInfo;
}
