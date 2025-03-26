import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/contacts/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsContactPage extends StatelessWidget {
  const DetailsContactPage({
    super.key,
    required this.contact,
    required this.isRegistered,
    this.giftcardList,
  });

  final ContactModel contact;
  final bool isRegistered;
  final List<GiftcarModel>? giftcardList;

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppBloc>().state.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CollapsedHeader(
              title: 'Detalle de contacto',
              onPressed: () async => context.pop(),
            ),
            SizedBox(height: context.sp(24)),
            Container(
              height: context.sp(120),
              width: context.sp(120),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.grey,
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.person,
                size: context.sp(100),
              ),
            ),
            SizedBox(height: context.sp(24)),
            Text(
              contact.displayName ?? '',
              style: context.styles.paragraph,
            ),
            SizedBox(height: context.sp(12)),
            Text(
              contact.email ?? '',
              style: context.styles.paragraph.copyWith(
                color: context.colors.text,
              ),
            ),
            Visibility(
              visible: !isRegistered,
              child: Column(
                children: [
                  SizedBox(height: context.sp(12)),
                  TextButton(
                    onPressed: () async {
                      await Clipboard.setData(
                        const ClipboardData(
                          text:
                              '¡Hola! Te invito a Felicitup, la app que te permite enviar felicitaciones a tus amigos y familiares de forma rápida.',
                        ),
                      );
                      showConfirmModal(
                        title:
                            'Hemos copiado a tu portapapeles la invitación para que puedas invitar a tus amigos mediante Whatsapp.',
                        onAccept: () async {
                          String number = contact.phone
                              .replaceAll(' ', '')
                              .replaceAll('(', '')
                              .replaceAll(')', '')
                              .replaceAll('-', '');
                          if (number[0] == '0' && number[1] == '0') {
                            number = number.substring(2);
                            number = '+$number';
                          } else if (number[0] != '+') {
                            number = '${user?.isoCode}$number';
                          }

                          final Uri url = Uri.parse('http://wa.me/$number');
                          await launchUrl(
                            url,
                            mode: LaunchMode.inAppBrowserView,
                          );
                        },
                      );
                    },
                    child: Text(
                      'Invitar',
                      style: context.styles.smallText.copyWith(
                        color: context.colors.darkBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.sp(24)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.sp(24)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Lista de deseos',
                  style: context.styles.subtitle,
                ),
              ),
            ),
            SizedBox(height: context.sp(12)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.sp(24)),
              child: isRegistered
                  ? SizedBox(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...List.generate(
                              giftcardList?.length ?? 0,
                              (index) => ListTile(
                                leading: Icon(
                                  Icons.card_giftcard,
                                  color: context.colors.orange,
                                ),
                                title: Text(
                                  giftcardList?[index].productName ?? '',
                                  style: context.styles.paragraph,
                                ),
                                subtitle: Text(
                                  '\$${giftcardList?[index].productValue ?? 0}',
                                  style: context.styles.paragraph.copyWith(
                                    color: context.colors.text,
                                  ),
                                ),
                                trailing: GestureDetector(
                                  onTap: () => _showNewsDetail(
                                    user?.giftcardList?[index] ?? GiftcarModel(),
                                  ),
                                  child: Icon(
                                    Icons.drag_indicator,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      child: Text(
                        'invita y conecta con tu contacto para ver su lista de deseos',
                        style: context.styles.paragraph.copyWith(
                          color: context.colors.text,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showNewsDetail(GiftcarModel singleNew) {
  showDialog(
    context: rootNavigatorKey.currentContext!,
    useSafeArea: false,
    builder: (_) => GiftcardDetails(
      title: singleNew.productName ?? "",
      body: singleNew.productDescription ?? "",
      price: singleNew.productValue ?? "",
      links: singleNew.links ?? [],
      callbackFuncion: () => rootNavigatorKey.currentContext!.pop(),
    ),
  );
}
