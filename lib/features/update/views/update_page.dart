import 'dart:io';

import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatelessWidget {
  const UpdatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.sp(16)),
          width: context.fullWidth,
          child: PrimaryButton(
            onTap: () {
              if (Platform.isAndroid) {
                launchUrl(
                  Uri.parse(
                    'https://play.google.com/store/apps/details?id=com.felicitup.felicitup_app',
                  ),
                  mode: LaunchMode.externalApplication,
                );
              } else if (Platform.isIOS) {
                launchUrl(
                  Uri.parse(
                    'https://apps.apple.com/co/app/felicitup/id6743689559',
                  ),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            label: 'Actualizar Ahora',
            isActive: true,
          ),
        ),
      ],
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
