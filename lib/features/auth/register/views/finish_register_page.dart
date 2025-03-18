import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/buttons/primary_button.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FinishRegisterPage extends StatelessWidget {
  const FinishRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: context.fullHeight,
          width: context.fullWidth,
          padding: EdgeInsets.symmetric(horizontal: context.sp(24)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Image.asset(
                Assets.images.logo.path,
                height: context.sp(60),
              ),
              SizedBox(height: context.sp(23)),
              Image.asset(
                Assets.images.logoLetter.path,
                height: context.sp(62),
              ),
              SizedBox(height: context.sp(24)),
              Text(
                'Felicidades, tu registro se ha compleado!',
                textAlign: TextAlign.center,
                style: context.styles.header2,
              ),
              SizedBox(height: context.sp(24)),
              Text(
                'Ahora ya puedes iniciar sesión y disfrutar de todas las funcionalidades de la aplicación.',
                textAlign: TextAlign.center,
                style: context.styles.paragraph,
              ),
              const Spacer(),
              SizedBox(
                height: context.sp(45),
                width: context.sp(172),
                child: PrimaryButton(
                  onTap: () => context.go(RouterPaths.login),
                  isBig: false,
                  label: 'Iniciar Sesión',
                  isActive: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
