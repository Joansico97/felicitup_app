import 'dart:io';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/register/widgets/register_input_field.dart';
import 'package:felicitup_app/features/features.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class FormFederatedView extends StatefulWidget {
  const FormFederatedView({super.key});

  @override
  State<FormFederatedView> createState() => _FormFederatedViewState();
}

class _FormFederatedViewState extends State<FormFederatedView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  DateTime? birthDate;

  @override
  void initState() {
    super.initState();
    final data = context.read<AppBloc>().state.federatedData;
    firstNameController.text = data?['firstName'] ?? '';
    lastNameController.text = data?['lastName'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Image.asset(Assets.images.logo.path, height: context.sp(60)),
          SizedBox(height: context.sp(12)),
          Image.asset(Assets.images.logoLetter.path, height: context.sp(62)),
          SizedBox(height: context.sp(12)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.sp(60)),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextFormField(
                    controller: firstNameController,
                    hintText: 'Nombre',
                  ),
                  SizedBox(height: context.sp(6)),
                  CustomTextFormField(
                    controller: lastNameController,
                    hintText: 'Apellidos',
                  ),
                  Visibility(
                    visible: Platform.isAndroid,
                    child: Column(
                      children: [
                        SizedBox(height: context.sp(6)),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  FocusScope.of(context).unfocus();
                                  final DateTime? pickedDate =
                                      await showGenericDatePicker(
                                        context: context,
                                        initialDate: DateTime.now().subtract(
                                          const Duration(days: 365 * 18),
                                        ),
                                        firstDate: DateTime(1939),
                                        lastDate: DateTime.now().subtract(
                                          const Duration(days: 365 * 18),
                                        ),
                                        helpText: 'Selecciona una fecha',
                                        cancelText: 'Cancelar',
                                        confirmText: 'OK',
                                        locale: const Locale('es', 'ES'),
                                      );

                                  if (pickedDate == null) return;

                                  setState(() {
                                    birthDate = pickedDate;
                                  });
                                },
                                child: Container(
                                  height: context.sp(45),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.sp(12),
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        width: context.sp(1),
                                        color: context.colors.darkGrey,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        birthDate == null
                                            ? 'Fecha Nacimiento'
                                            : DateFormat(
                                              'dd/MM/yyyy',
                                            ).format(birthDate!),
                                        style: context.styles.paragraph
                                            .copyWith(
                                              color:
                                                  birthDate == null
                                                      ? context.colors.darkGrey
                                                      : context.colors.black,
                                            ),
                                      ),
                                      Icon(
                                        Icons.calendar_month_rounded,
                                        color: context.colors.orange,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            CommonTooltip(
                              message:
                                  'La fecha de nacimiento se recolecta unica y exclusivamente para el registro de la cuenta.',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.sp(24)),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Al registrarte aceptas los ',
                      style: context.styles.smallText,
                      children: [
                        TextSpan(
                          text: 'Términos y Condiciones ',
                          style: context.styles.smallText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  context.push(
                                    RouterPaths.termsPolicies,
                                    extra: {
                                      'isTerms': true,
                                      'isFromFederated': true,
                                    },
                                  );
                                },
                        ),
                        TextSpan(
                          text: 'y la ',
                          style: context.styles.smallText,
                        ),
                        TextSpan(
                          text: 'Política de Privacidad ',
                          style: context.styles.smallText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap = () {
                                  context.push(
                                    RouterPaths.termsPolicies,
                                    extra: {
                                      'isTerms': false,
                                      'isFromFederated': true,
                                    },
                                  );
                                },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.sp(24)),
                  SizedBox(
                    height: context.sp(45),
                    width: context.sp(172),
                    child: PrimaryButton(
                      onTap: () {
                        if (firstNameController.text.isNotEmpty &&
                            lastNameController.text.isNotEmpty) {
                          context.read<FederatedRegisterBloc>().add(
                            FederatedRegisterEvent.initRegister(
                              name:
                                  firstNameController.text.trim().capitalize(),
                              lastName:
                                  lastNameController.text.trim().capitalize(),
                              birthDate: birthDate,
                            ),
                          );
                        }
                      },
                      label: 'Continuar',
                      isActive: true,
                    ),
                  ),
                  SizedBox(height: context.sp(12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
