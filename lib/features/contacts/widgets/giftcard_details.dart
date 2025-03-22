import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GiftcardDetails extends StatelessWidget {
  final String title;
  final String? body;
  final String price;
  final List<String>? links;

  final VoidCallback callbackFuncion;

  const GiftcardDetails({
    super.key,
    required this.title,
    this.body,
    required this.callbackFuncion,
    required this.price,
    this.links,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'Tu deseo',
          style: context.styles.header2,
        ),
        leading: IconButton(
          onPressed: callbackFuncion,
          icon: const Icon(Icons.arrow_back_ios_new_sharp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.sp(48),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: context.sp(24)),
            Text(
              'Deseo:',
              style: context.styles.subtitle,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: context.sp(12)),
            Text(
              title,
              style: context.styles.paragraph,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: context.sp(24)),
            Text(
              'Precio:',
              style: context.styles.subtitle,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: context.sp(12)),
            Text(
              '$price €',
              style: context.styles.paragraph,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: context.sp(24)),
            Text(
              'Descripción corta:',
              style: context.styles.subtitle,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: context.sp(12)),
            Text(
              '$body',
              style: context.styles.paragraph.copyWith(
                color: context.colors.text,
              ),
            ),
            SizedBox(height: context.sp(24)),
            Text(
              'Links:',
              style: context.styles.subtitle,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: context.sp(12)),
            if (links != null)
              for (final link in links!)
                Row(
                  children: [
                    Icon(
                      Icons.link,
                      color: context.colors.primary,
                    ),
                    SizedBox(width: context.sp(8)),
                    GestureDetector(
                      onTap: () async {
                        final Uri url = Uri.parse(link);
                        await launchUrl(
                          url,
                          mode: LaunchMode.inAppBrowserView,
                        );
                      },
                      child: SizedBox(
                        width: context.sp(250),
                        child: Text(
                          link,
                          overflow: TextOverflow.ellipsis,
                          style: context.styles.subtitle,
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
