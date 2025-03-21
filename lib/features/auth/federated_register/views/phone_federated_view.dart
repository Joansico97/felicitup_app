import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/buttons/primary_button.dart';
import 'package:felicitup_app/features/features.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneFederatedView extends StatefulWidget {
  const PhoneFederatedView({super.key});

  @override
  State<PhoneFederatedView> createState() => _PhoneFederatedViewState();
}

class _PhoneFederatedViewState extends State<PhoneFederatedView> {
  String phone = '';
  String isoCode = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          Assets.images.logo.path,
          height: context.sp(60),
        ),
        SizedBox(height: context.sp(12)),
        Image.asset(
          Assets.images.logoLetter.path,
          height: context.sp(62),
        ),
        SizedBox(height: context.sp(12)),
        Text(
          'Ingresa tu número de teléfono',
          style: context.styles.header2,
        ),
        SizedBox(height: context.sp(24)),
        Text(
          'Por favor introduce tu número de teléfono y te enviaremos un sms con un código de verificación.',
          textAlign: TextAlign.center,
          style: context.styles.paragraph,
        ),
        SizedBox(height: context.sp(36)),
        SizedBox(
          width: context.sp(250),
          child: IntlPhoneField(
            languageCode: 'es',
            decoration: InputDecoration(
              labelText: '000 00 00 00',
              labelStyle: context.styles.smallText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            initialCountryCode: 'ES',
            onChanged: (value) {
              setState(() {
                phone = value.completeNumber;
                isoCode = value.countryCode;
              });
            },
          ),
        ),
        SizedBox(height: context.sp(36)),
        SizedBox(
          width: context.sp(250),
          height: context.sp(50),
          child: PrimaryButton(
            onTap: () {
              context.read<FederatedRegisterBloc>().add(FederatedRegisterEvent.savePhoneInfo(phone, isoCode));
            },
            label: 'Enviar código',
            isActive: true,
          ),
        ),
      ],
    );
  }
}
