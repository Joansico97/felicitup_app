part of 'wish_list_bloc.dart';

@freezed
class WishListEvent with _$WishListEvent {
  const factory WishListEvent.changeLoading() = _changeLoading;
  const factory WishListEvent.createGiftItem() = _createGiftItem;
  const factory WishListEvent.editGiftItem() = _editGiftItem;
  const factory WishListEvent.setProductName(String productName) = _setProductName;
  const factory WishListEvent.setProductDescription(String productDescription) = _setProductDescription;
  const factory WishListEvent.setProductPrice(String productPrice) = _setProductPrice;
  const factory WishListEvent.setLinks(List<String> links) = _setLinks;
  const factory WishListEvent.createGiftItemInfo() = _createGiftItemInfo;
  const factory WishListEvent.editGiftItemInfo(GiftcarModel item) = _editGiftItemInfo;
  const factory WishListEvent.deleteGiftItemInfo(String id) = _deleteGiftItemInfo;
  const factory WishListEvent.startListening() = _startListening;
  const factory WishListEvent.recivedData(List<GiftcarModel> listGiftcard) = _recivedData;
}
