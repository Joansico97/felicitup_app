import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/wish_list/views/mobile/wish_list_edit_mobile_page.dart';
import 'package:flutter/material.dart';

class WishListEditWebPage extends StatelessWidget {
  const WishListEditWebPage({super.key, required this.wishListItem});

  final GiftcarModel wishListItem;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: WishListEditMobilePage(wishListItem: wishListItem),
      ),
    );
  }
}
