import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class UpdatePage extends StatelessWidget {
  const UpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: context.fullHeight,
        width: context.fullWidth,
        padding: EdgeInsets.symmetric(horizontal: context.sp(24)),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: context.sp(120)),
              Column(
                children: [
                  Image.asset(Assets.images.logo.path, height: context.sp(60)),
                  SizedBox(height: context.sp(23)),
                  Image.asset(
                    Assets.images.logoLetter.path,
                    height: context.sp(62),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'Tienes una versión obsoleta de la app',
                    textAlign: TextAlign.center,
                    style: context.styles.header1,
                  ),
                  SizedBox(height: context.sp(24)),
                  Text(
                    'Actualiza la app para seguir disfrutando de Felicitup',
                    textAlign: TextAlign.center,
                    style: context.styles.subtitle,
                  ),
                ],
              ),
              SizedBox(height: context.sp(240)),
            ],
          ),
        ),
      ),
    );
  }
}
