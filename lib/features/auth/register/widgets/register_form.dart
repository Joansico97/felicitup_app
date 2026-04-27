import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/register/bloc/register_bloc.dart';
import 'package:felicitup_app/features/auth/register/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool isObscure = true;
  bool isRepObscure = true;

  bool get isActive {
    return emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        repeatPasswordController.text.isNotEmpty &&
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty;
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  DateTime? birthDate;

  @override
  void initState() {
    emailController.text = context.read<RegisterBloc>().state.email ?? '';
    passwordController.text = context.read<RegisterBloc>().state.password ?? '';
    repeatPasswordController.text =
        context.read<RegisterBloc>().state.confirmPassword ?? '';
    firstNameController.text = context.read<RegisterBloc>().state.name ?? '';
    lastNameController.text = context.read<RegisterBloc>().state.lastName ?? '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextFormField(
              controller: firstNameController,
              hintText: 'Nombre',
              onChanged: (_) {
                setState(() {});
              },
            ),
            SizedBox(height: context.sp(6)),
            CustomTextFormField(
              controller: lastNameController,
              hintText: 'Apellidos',
              onChanged: (_) {
                setState(() {});
              },
            ),
            SizedBox(height: context.sp(6)),
            CustomTextFormField(
              controller: emailController,
              isEmail: true,
              hintText: 'Email',
              onChanged: (_) {
                setState(() {});
              },
            ),
            SizedBox(height: context.sp(6)),
            CustomTextFormField(
              controller: passwordController,
              isPassword: true,
              hintText: 'Contraseña',
              onChanged: (_) {
                setState(() {});
              },
            ),
            SizedBox(height: context.sp(6)),
            CustomTextFormField(
              controller: repeatPasswordController,
              isPassword: true,
              onChanged: (_) {
                setState(() {});
              },
              hintText: 'Repetir contraseña',
            ),
            Visibility(
              visible: kIsWeb || defaultTargetPlatform == TargetPlatform.android,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  birthDate == null
                                      ? 'Fecha Nacimiento'
                                      : DateFormat(
                                          'dd/MM/yyyy',
                                        ).format(birthDate!),
                                  style: context.styles.paragraph.copyWith(
                                    color: birthDate == null
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
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        context.push(
                          RouterPaths.termsPolicies,
                          extra: {'isTerms': true, 'isFromFederated': false},
                        );
                      },
                  ),
                  TextSpan(text: 'y la ', style: context.styles.smallText),
                  TextSpan(
                    text: 'Política de Privacidad ',
                    style: context.styles.smallText.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        context.push(
                          RouterPaths.termsPolicies,
                          extra: {'isTerms': false, 'isFromFederated': false},
                        );
                      },
                  ),
                ],
              ),
            ),
            SizedBox(height: context.sp(12)),
            SizedBox(
              height: context.sp(45),
              width: context.sp(172),
              child: PrimaryButton(
                onTap: () {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  if (passwordController.text !=
                      repeatPasswordController.text) {
                    ScaffoldMessenger.of(
                      rootNavigatorKey.currentContext!,
                    ).showSnackBar(
                      SnackBar(
                        content: Text('Las contraseñas no coinciden'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return;
                  }

                  context.read<RegisterBloc>().add(
                    RegisterEvent.initRegister(
                      name: firstNameController.text.trim().capitalize(),
                      lastName: lastNameController.text.trim().capitalize(),
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                      confirmPassword: repeatPasswordController.text.trim(),
                      birthDate: birthDate,
                    ),
                  );
                },
                label: 'Continuar',
                isActive: isActive,
              ),
            ),
            SizedBox(height: context.sp(8)),
          ],
        ),
      ),
    );
  }
}
