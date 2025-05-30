import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/init/bloc/init_bloc.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class InitPage extends StatelessWidget {
  const InitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<InitBloc, InitState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (_, state) {
        if (state.status == InitEnum.cannotContinue) {
          context.go(RouterPaths.updatePage);
        }
      },
      child: Scaffold(
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                height: context.sp(720),
                width: context.fullWidth,
                decoration: BoxDecoration(
                  color: context.colors.lightGrey,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(context.sp(40)),
                    bottomRight: Radius.circular(context.sp(40)),
                  ),
                ),
                child: SafeArea(
                  child: SizedBox(
                    height: context.fullHeight,
                    width: context.fullWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: context.sp(190)),
                        Image.asset(
                          Assets.images.logo.path,
                          fit: BoxFit.contain,
                          height: context.sp(77),
                        ),
                        SizedBox(height: context.sp(32)),
                        Image.asset(
                          Assets.images.logoLetter.path,
                          fit: BoxFit.contain,
                          width: context.sp(276),
                        ),
                        SizedBox(height: context.sp(12)),
                        Text(
                          'La app para amigos de verdad',
                          style: context.styles.paragraph,
                        ),
                        SizedBox(height: context.sp(39)),
                        SizedBox(
                          width: context.sp(172),
                          height: context.sp(50),
                          child: PrimaryButton(
                            onTap: () => context.push(RouterPaths.register),
                            label: 'Crear cuenta',
                            isActive: true,
                          ),
                        ),
                        // SizedBox(height: context.sp(190)),
                      ],
                    ),
                  ),
                ),
              ),
              Spacer(),
              RichText(
                text: TextSpan(
                  text: '¿Ya tienes una cuenta? ',
                  style: context.styles.paragraph,
                  children: [
                    TextSpan(
                      text: 'Inicia sesión',
                      style: context.styles.paragraph.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () => context.push(RouterPaths.login),
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.sp(24)),
            ],
          ),
        ),
      ),
    );
  }
}
