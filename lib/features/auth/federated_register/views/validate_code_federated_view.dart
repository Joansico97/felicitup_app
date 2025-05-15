import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/federated_register/bloc/federated_register_bloc.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ValidateCodeFederatedView extends StatefulWidget {
  const ValidateCodeFederatedView({super.key});

  @override
  State<ValidateCodeFederatedView> createState() =>
      _ValidateCodeFederatedViewState();
}

class _ValidateCodeFederatedViewState extends State<ValidateCodeFederatedView> {
  bool _codeCompleted = true;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CollapsedHeader(
            title: '',
            onPressed:
                () => context.read<FederatedRegisterBloc>().add(
                  const FederatedRegisterEvent.backStep(),
                ),
          ),
          SizedBox(height: context.sp(24)),
          Image.asset(Assets.images.logo.path, height: context.sp(60)),
          SizedBox(height: context.sp(12)),
          Image.asset(Assets.images.logoLetter.path, height: context.sp(62)),
          SizedBox(height: context.sp(36)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.sp(60)),
            child: Text(
              'Código de verificación',
              style: context.styles.header2,
            ),
          ),
          SizedBox(height: context.sp(24)),
          BlocBuilder<FederatedRegisterBloc, FederatedRegisterState>(
            builder: (_, state) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: context.sp(60)),
                child: Text(
                  'Introduce el código de verificación que te hemos enviado por sms al número ${state.phone}.',
                  textAlign: TextAlign.center,
                  style: context.styles.paragraph,
                ),
              );
            },
          ),
          SizedBox(height: context.sp(36)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.sp(60)),
            child: PinCodeTextField(
              appContext: context,
              length: 6,
              controller: _controller,
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
          ),
          SizedBox(height: context.sp(36)),
          SizedBox(
            width: context.sp(250),
            height: context.sp(50),
            child: PrimaryButton(
              onTap: () {
                context.read<FederatedRegisterBloc>().add(
                  FederatedRegisterEvent.validateCode(_controller.text),
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
