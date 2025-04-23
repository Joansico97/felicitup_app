import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/data/models/user_models/giftcard_models/giftcard_model.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class InfoWishListItemView extends StatelessWidget {
  const InfoWishListItemView({super.key, required this.wishListItem});

  final GiftcarModel wishListItem;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: context.sp(40)),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.sp(24)),
            Text(
              'Deseo:',
              style: context.styles.subtitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: context.sp(12)),
            Text(
              wishListItem.productName ?? '',
              style: context.styles.subtitle,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: context.sp(24)),
            Text(
              'Precio:',
              style: context.styles.subtitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: context.sp(12)),
            Text(
              '${wishListItem.productValue} €',
              style: context.styles.subtitle,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: context.sp(24)),
            Text(
              'Descripción corta:',
              style: context.styles.subtitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: context.sp(12)),
            Text(
              '${wishListItem.productDescription}',
              style: context.styles.paragraph,
            ),
            SizedBox(height: context.sp(24)),
            Text(
              'Links:',
              style: context.styles.subtitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: context.sp(12)),
            if (wishListItem.links != null)
              for (final link in wishListItem.links!)
                Row(
                  children: [
                    Icon(Icons.link, color: context.colors.orange),
                    SizedBox(width: context.sp(8)),
                    GestureDetector(
                      onTap: () async {
                        final Uri url = Uri.parse(link);
                        await launchUrl(url, mode: LaunchMode.inAppBrowserView);
                      },
                      child: SizedBox(
                        width: context.sp(250),
                        child: Text(
                          link,
                          overflow: TextOverflow.ellipsis,
                          style: context.styles.paragraph,
                        ),
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
