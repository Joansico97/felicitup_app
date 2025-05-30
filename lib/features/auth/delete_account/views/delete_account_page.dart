import 'dart:async';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/delete_account/delete_account.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final List<String?> _answers = [null, null, null];

  bool get _isActive => _answers.every((a) => a != null);

  void _setAnswer(int questionIndex, String value) {
    setState(() {
      _answers[questionIndex] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteAccountBloc, DeleteAccountState>(
      listenWhen:
          (previous, current) => previous.isLoading != current.isLoading,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }
      },
      child: Scaffold(
        persistentFooterAlignment: AlignmentDirectional.bottomCenter,
        persistentFooterButtons: [
          SizedBox(
            width: context.sp(300),
            child: PrimaryButton(
              onTap: () {
                final currentUser = context.read<AppBloc>().state.currentUser;
                context.read<DeleteAccountBloc>().add(
                  DeleteAccountEvent.deleteAccountEvent(
                    userId: currentUser?.id ?? '',
                    answers:
                        _answers
                            .where((a) => a != null)
                            .cast<String>()
                            .toList(),
                  ),
                );
              },
              label: 'Eliminar cuenta',
              isActive: _isActive,
            ),
          ),
        ],
        body: SizedBox(
          height: context.fullHeight,
          width: context.fullWidth,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
              child: Column(
                children: [
                  CollapsedHeader(
                    title: 'Eliminar cuenta',
                    onPressed: () => context.go(RouterPaths.profile),
                  ),
                  SizedBox(height: context.sp(12)),
                  Image.asset(Assets.images.logo.path, height: context.sp(60)),
                  SizedBox(height: context.sp(12)),
                  Image.asset(
                    Assets.images.logoLetter.path,
                    height: context.sp(62),
                  ),
                  SizedBox(height: context.sp(24)),
                  Text(
                    '¿Deseas eliminar tu cuenta? Esta acción es irreversible.',
                    style: context.styles.header2,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.sp(24)),
                  Text(
                    'Si decides eliminar tu cuenta, perderás todo el contenido asociado a ella.\nSi deseas continuar, llena el siguiente formulario y pulsa el botón de abajo.',
                    style: context.styles.paragraph,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.sp(24)),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          // Pregunta 1
                          Text(
                            '1. ¿Por qué deseas eliminar tu cuenta?',
                            style: context.styles.header2,
                          ),
                          ...[
                            'No encuentro utilidad en la app',
                            'Preocupaciones sobre privacidad',
                            'Demasiadas notificaciones',
                            'Encontré una mejor alternativa',
                            'Otro motivo',
                          ].map(
                            (option) => ListTile(
                              leading: Icon(
                                _answers[0] == option
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 20,
                              ),
                              title: Text(
                                option,
                                style: context.styles.paragraph,
                              ),
                              onTap: () => _setAnswer(0, option),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          SizedBox(height: context.sp(16)),
                          // Pregunta 2
                          Text(
                            '2. ¿Con qué frecuencia usabas la app?',
                            style: context.styles.header2,
                          ),
                          ...[
                            'Varias veces al día',
                            'Una vez al día',
                            'Varias veces a la semana',
                            'Una vez a la semana',
                            'Rara vez',
                          ].map(
                            (option) => ListTile(
                              leading: Icon(
                                _answers[1] == option
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 20,
                              ),
                              title: Text(
                                option,
                                style: context.styles.paragraph,
                              ),
                              onTap: () => _setAnswer(1, option),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          SizedBox(height: context.sp(16)),
                          // Pregunta 3
                          Text(
                            '3. ¿Recomendarías la app a otras personas?',
                            style: context.styles.header2,
                          ),
                          ...[
                            'Definitivamente sí',
                            'Probablemente sí',
                            'No estoy seguro',
                            'Probablemente no',
                            'Definitivamente no',
                          ].map(
                            (option) => ListTile(
                              leading: Icon(
                                _answers[2] == option
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 20,
                              ),
                              title: Text(
                                option,
                                style: context.styles.paragraph,
                              ),
                              onTap: () => _setAnswer(2, option),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
