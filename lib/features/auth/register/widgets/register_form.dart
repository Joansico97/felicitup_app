import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/register/bloc/register_bloc.dart';
import 'package:felicitup_app/features/auth/register/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool isObscure = true;
  bool isRepObscure = true;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController =
      TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

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
            ),
            SizedBox(height: context.sp(6)),
            CustomTextFormField(
              controller: lastNameController,
              hintText: 'Apellidos',
            ),
            SizedBox(height: context.sp(6)),
            CustomTextFormField(
              controller: emailController,
              isEmail: true,
              hintText: 'Email',
            ),
            SizedBox(height: context.sp(6)),
            CustomTextFormField(
              controller: passwordController,
              isPassword: true,
              hintText: 'Contraseña',
            ),
            SizedBox(height: context.sp(6)),
            CustomTextFormField(
              controller: repeatPasswordController,
              isPassword: true,
              hintText: 'Repetir contraseña',
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
                                'isFromFederated': false,
                              },
                            );
                          },
                  ),
                  TextSpan(text: 'y la ', style: context.styles.smallText),
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
                                'isFromFederated': false,
                              },
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
                  if (passwordController.text.isNotEmpty &&
                      repeatPasswordController.text.isNotEmpty &&
                      passwordController.text ==
                          repeatPasswordController.text &&
                      emailController.text.isNotEmpty &&
                      firstNameController.text.isNotEmpty &&
                      lastNameController.text.isNotEmpty) {
                    context.read<RegisterBloc>().add(
                      RegisterEvent.initRegister(
                        name: firstNameController.text.trim().capitalize(),
                        lastName: lastNameController.text.trim().capitalize(),
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                        confirmPassword: repeatPasswordController.text.trim(),
                      ),
                    );
                  }
                },
                label: 'Continuar',
                isActive: true,
              ),
            ),
            SizedBox(height: context.sp(8)),
          ],
        ),
      ),
    );
  }
}
