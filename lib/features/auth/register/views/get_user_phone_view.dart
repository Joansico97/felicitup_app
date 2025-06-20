import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/register/bloc/register_bloc.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class GetUserPhoneView extends StatefulWidget {
  const GetUserPhoneView({super.key});

  @override
  State<GetUserPhoneView> createState() => _GetUserPhoneViewState();
}

class _GetUserPhoneViewState extends State<GetUserPhoneView> {
  String phone = '';
  String isoCode = '';
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    _phoneController.text = context.read<RegisterBloc>().state.phone ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: context.sp(12)),
        child: Column(
          children: [
            CollapsedHeader(
              title: '',
              onPressed:
                  () => context.read<RegisterBloc>().add(
                    RegisterEvent.previousStep(),
                  ),
            ),
            // SizedBox(height: context.sp(24)),
            Image.asset(Assets.images.logo.path, height: context.sp(60)),
            SizedBox(height: context.sp(12)),
            Image.asset(Assets.images.logoLetter.path, height: context.sp(62)),
            SizedBox(height: context.sp(36)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.sp(60)),
              child: Text(
                'Ingresa tu número de teléfono',
                style: context.styles.header2,
              ),
            ),
            SizedBox(height: context.sp(24)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.sp(60)),
              child: Text(
                'Por favor introduce tu número de teléfono y te enviaremos un sms con un código de verificación.',
                textAlign: TextAlign.center,
                style: context.styles.paragraph,
              ),
            ),
            SizedBox(height: context.sp(36)),
            SizedBox(
              width: context.sp(250),
              child: IntlPhoneField(
                languageCode: 'es',
                controller: _phoneController,
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
                  context.read<RegisterBloc>().add(
                    RegisterEvent.savePhoneInfo(phone, isoCode),
                  );
                },
                label: 'Enviar código',
                isActive: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
