import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/data/models/models.dart';
import 'package:felicitup_app/features/contacts/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class ElementCardRow extends StatelessWidget {
  const ElementCardRow({
    super.key,
    required this.contact,
    required this.isRegistered,
  });

  final ContactModel contact;
  final bool isRegistered;

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: size.symmetric(.05, .02),
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(20),
        vertical: context.sp(10),
      ),
      width: context.fullWidth,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.colors.orange.valueOpacity(.1),
          ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.displayName ?? '',
                  style: context.styles.subtitle,
                ),
                Text(
                  contact.phone.replaceAll(' ', '').replaceAll('(', '').replaceAll(')', '').replaceAll('-', ''),
                  style: context.styles.smallText,
                )
              ],
            ),
          ),
          const Spacer(),
          isRegistered
              ? const Icon(
                  Icons.check,
                  color: Colors.green,
                )
              : TextButton(
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
                        final user = context.read<AppBloc>().state.currentUser;
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
          SizedBox(width: context.sp(8)),
          GestureDetector(
            onTap: () => _showContactDetails(contact, isRegistered),
            child: Icon(
              Icons.drag_indicator,
            ),
          ),
        ],
      ),
    );
  }
}

void _showContactDetails(ContactModel contact, bool isRegistered) {
  showDialog(
    context: rootNavigatorKey.currentContext!,
    useSafeArea: false,
    builder: (_) => DetailsContactPage(
      contact: contact,
      isRegistered: isRegistered,
    ),
  );
}
