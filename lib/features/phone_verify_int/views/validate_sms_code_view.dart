import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/phone_verify_int/bloc/phone_verify_int_bloc.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ValidateSmsCodeView extends StatefulWidget {
  const ValidateSmsCodeView({super.key});

  @override
  State<ValidateSmsCodeView> createState() => _ValidateCodeViewState();
}

class _ValidateCodeViewState extends State<ValidateSmsCodeView> {
  bool _codeCompleted = true;
  final TextEditingController _pinCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: context.sp(24)),
          Image.asset(Assets.images.logo.path, height: context.sp(60)),
          SizedBox(height: context.sp(12)),
          Image.asset(Assets.images.logoLetter.path, height: context.sp(62)),
          SizedBox(height: context.sp(36)),
          Text('Código de verificación', style: context.styles.header2),
          SizedBox(height: context.sp(24)),
          BlocBuilder<PhoneVerifyIntBloc, PhoneVerifyIntState>(
            builder: (_, state) {
              return Text(
                'Introduce el código de verificación que te hemos enviado por sms al número ${state.phoneNumber}.',
                textAlign: TextAlign.center,
                style: context.styles.paragraph,
              );
            },
          ),
          SizedBox(height: context.sp(36)),
          PinCodeTextField(
            appContext: context,
            controller: _pinCodeController,
            length: 6,
            obscureText: false,
            animationType: AnimationType.fade,
            keyboardType: TextInputType.number,
            textStyle: context.styles.header1,
            pastedTextStyle: context.styles.header1,
            cursorHeight: context.sp(24),
            cursorColor: context.colors.primary.valueOpacity(.5),
            cursorWidth: context.sp(2),
            pinTheme: PinTheme(
              shape: PinCodeFieldShape.underline,
              borderWidth: context.sp(1.5),
              fieldHeight: context.sp(37),
              fieldWidth: context.sp(32),
              activeFillColor: Colors.transparent,
              inactiveFillColor: Colors.transparent,
              selectedFillColor: Colors.transparent,
              activeColor: context.colors.primary,
              inactiveColor: context.colors.lightGrey,
              selectedColor: context.colors.orange,
            ),
            onChanged: (value) {
              if (value.length == 6) {
                setState(() {
                  _codeCompleted = false;
                });
              } else {
                setState(() {
                  _codeCompleted = true;
                });
              }
            },
          ),
          SizedBox(height: context.sp(36)),
          SizedBox(
            width: context.sp(250),
            height: context.sp(50),
            child: PrimaryButton(
              onTap: () {
                context.read<PhoneVerifyIntBloc>().add(
                  PhoneVerifyIntEvent.validateCode(_pinCodeController.text),
                );
              },
              label: 'Validar código',
              isActive: !_codeCompleted,
            ),
          ),
        ],
      ),
    );
  }
}
