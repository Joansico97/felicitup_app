import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/phone_verify_int/bloc/phone_verify_int_bloc.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class GetPhoneView extends StatefulWidget {
  const GetPhoneView({super.key});

  @override
  State<GetPhoneView> createState() => _GetPhoneViewState();
}

class _GetPhoneViewState extends State<GetPhoneView> {
  String phone = '';
  String isoCode = '';
  late String userId;

  @override
  void initState() {
    userId = context.read<AppBloc>().state.currentUser?.id ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: context.sp(24)),
            Image.asset(Assets.images.logo.path, height: context.sp(60)),
            SizedBox(height: context.sp(12)),
            Image.asset(Assets.images.logoLetter.path, height: context.sp(62)),
            SizedBox(height: context.sp(36)),
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
                  context.read<PhoneVerifyIntBloc>().add(
                    PhoneVerifyIntEvent.savePhoneInfo(
                      isoCode: isoCode,
                      phoneNumber: phone,
                      userId: userId,
                    ),
                  );
                },
                label: 'Enviar código',
                isActive: true,
              ),
            ),
            SizedBox(height: context.sp(12)),
            SizedBox(
              width: context.sp(250),
              height: context.sp(50),
              child: PrimaryButton(
                onTap: () {
                  context.go(RouterPaths.init);
                },
                label: 'Logout',
                isActive: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
