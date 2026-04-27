import 'dart:io';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/contacts/contacts.dart';
import 'package:felicitup_app/features/contacts/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ElementCardRow extends StatelessWidget {
  const ElementCardRow({
    super.key,
    required this.contact,
    required this.isRegistered,
    this.giftcars,
  });

  final ContactModel contact;
  final bool isRegistered;
  final List<GiftcarModel>? giftcars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(24),
        vertical: context.sp(12),
      ),
      width: context.fullWidth,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.colors.orange.valueOpacity(.1)),
        ),
      ),
      child: Row(
        children: [
          Container(
            height: context.sp(40),
            width: context.sp(40),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.grey,
            ),
            child: Text(
              contact.displayName != null ? contact.displayName![0] : '',
              style: context.styles.subtitle.copyWith(
                color: context.colors.orange,
              ),
            ),
          ),
          SizedBox(width: context.sp(24)),
          SizedBox(
            width: context.sp(150),
            child: Text(
              contact.displayName ?? '',
              style: context.styles.subtitle,
            ),
          ),
          const Spacer(),
          isRegistered
              ? const Icon(Icons.check, color: Colors.green)
              : TextButton(
                  onPressed: () async {
                    final encoded =
                        ''''¡Hola! Te invito a Felicitup, la app que te permite enviar felicitaciones a tus amigos y familiares de forma rápida.
Descárgala desde play store aquí: https://play.google.com/store/apps/details?id=com.felicitup.felicitup_app
Descárgala desde app store aquí: https://apps.apple.com/co/app/felicitup/id6743689559
                          ''';

                    final Uri url = Uri.parse("whatsapp://send?text=$encoded");

                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      const playStore =
                          "https://play.google.com/store/apps/details?id=com.whatsapp";
                      const appStore =
                          "https://apps.apple.com/app/whatsapp-messenger/id310633997";

                      await launchUrl(
                        Uri.parse(Platform.isAndroid ? playStore : appStore),
                      );
                    }
                  },
                  child: Text(
                    'Invitar',
                    style: context.styles.smallText.copyWith(
                      color: context.colors.darkBlue,
                    ),
                  ),
                ),
          SizedBox(width: context.sp(8)),
          GestureDetector(
            onTap: () {
              if (isRegistered) {
                context.read<ContactsBloc>().add(
                  ContactsEvent.getInfoSingleContact(contact.phone),
                );
              }
              _showContactDetails(contact, isRegistered, context);
            },
            child: Icon(
              isRegistered
                  ? Icons.card_giftcard_outlined
                  : Icons.drag_indicator,
            ),
          ),
        ],
      ),
    );
  }
}

void _showContactDetails(
  ContactModel contact,
  bool isRegistered,
  BuildContext context,
) {
  showDialog(
    context: context,
    useSafeArea: false,
    builder: (_) => BlocProvider.value(
      value: context.read<ContactsBloc>(),
      child: BlocBuilder<ContactsBloc, ContactsState>(
        builder: (_, state) {
          return DetailsContactView(
            contact: contact,
            isRegistered: isRegistered,
            giftcardList: isRegistered
                ? state.dataSingleUsers?.giftcardList
                : [],
          );
        },
      ),
    ),
  );
}
