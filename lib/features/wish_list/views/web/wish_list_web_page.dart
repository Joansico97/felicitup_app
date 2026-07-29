import 'package:felicitup_app/features/wish_list/views/mobile/wish_list_mobile_page.dart';
import 'package:flutter/material.dart';

class WishListWebPage extends StatelessWidget {
  const WishListWebPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 600,
        child: const WishListMobilePage(),
      ),
    );
  }
}
