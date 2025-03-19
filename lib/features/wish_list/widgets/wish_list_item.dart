import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WishListItem extends StatelessWidget {
  const WishListItem({
    super.key,
    required this.giftcard,
  });

  final GiftcarModel giftcard;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.fullWidth,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withAlpha((.2 * 255).toInt()),
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(
        vertical: context.sp(20),
        horizontal: context.sp(20),
      ),
      child: Row(
        children: [
          Icon(
            Icons.card_giftcard_outlined,
            color: context.colors.orange,
            size: context.sp(32),
          ),
          SizedBox(width: context.sp(16)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: context.sp(100),
                child: Text(
                  giftcard.productName ?? '',
                  style: context.styles.subtitle,
                ),
              ),
              Text(
                'Valor: ${giftcard.productValue}€',
                style: context.styles.smallText.copyWith(
                  color: context.colors.darkGrey,
                ),
              ),
            ],
          ),
          Spacer(),
          IconButton(
            icon: Icon(
              Icons.drag_indicator,
              color: context.colors.orange,
            ),
            onPressed: () => context.push(
              RouterPaths.wishListEdit,
              extra: giftcard,
            ),
          ),
        ],
      ),
    );
  }
}
