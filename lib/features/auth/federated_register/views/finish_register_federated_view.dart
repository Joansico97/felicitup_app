import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/buttons/primary_button.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FinishRegisterFederatedView extends StatelessWidget {
  const FinishRegisterFederatedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(Assets.images.logo.path, height: context.sp(60)),
        SizedBox(height: context.sp(23)),
        Image.asset(Assets.images.logoLetter.path, height: context.sp(62)),
        SizedBox(height: context.sp(24)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.sp(60)),
          child: Text(
            'Felicidades, tu registro se ha compleado!',
            textAlign: TextAlign.center,
            style: context.styles.header2,
          ),
        ),
        SizedBox(height: context.sp(24)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.sp(60)),
          child: Text(
            'Ahora ya puedes iniciar sesión y disfrutar de todas las funcionalidades de la aplicación.',
            textAlign: TextAlign.center,
            style: context.styles.paragraph,
          ),
        ),
        SizedBox(height: context.sp(24)),
        SizedBox(
          height: context.sp(45),
          width: context.sp(300),
          child: PrimaryButton(
            onTap: () => context.go(RouterPaths.felicitupsDashboard),
            isBig: false,
            label: 'Acceder',
            isActive: true,
          ),
        ),
      ],
    );
  }
}
