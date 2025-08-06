import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/buttons/primary_button.dart';
import 'package:felicitup_app/features/auth/auth.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FinishRegisterFederatedView extends StatefulWidget {
  const FinishRegisterFederatedView({super.key});

  @override
  State<FinishRegisterFederatedView> createState() =>
      _FinishRegisterFederatedViewState();
}

class _FinishRegisterFederatedViewState
    extends State<FinishRegisterFederatedView> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () {
      context.read<FederatedRegisterBloc>().add(
        FederatedRegisterEvent.changeLoading(),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        SizedBox(
          height: context.sp(50),
          width: context.sp(250),
          child: PrimaryButton(
            onTap:
                () => context.read<FederatedRegisterBloc>().add(
                  FederatedRegisterEvent.finishEvent(),
                ),
            isBig: false,
            label: 'Acceder',
            isActive: true,
          ),
        ),
      ],
      body: SizedBox(
        height: context.fullHeight,
        width: context.fullWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
          ],
        ),
      ),
    );
  }
}
