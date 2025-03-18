import 'dart:async';
import 'dart:io';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/login/bloc/login_bloc.dart';
import 'package:felicitup_app/features/auth/login/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../gen/assets.gen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isObscure = true;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.status == LoginStatus.error) {
          await showErrorModal(state.errorMessage);
        }

        if (state.status == LoginStatus.success) {
          context.read<AppBloc>().add(AppEvent.loadUserData());
          context.go(RouterPaths.felicitupsDashboard);
        }
      },
      child: Scaffold(
        body: SizedBox(
          height: context.fullHeight,
          width: context.fullWidth,
          child: SafeArea(
            top: false,
            bottom: false,
            child: Stack(
              children: [
                Positioned(
                  top: -context.sp(70),
                  left: -context.sp(70),
                  child: Container(
                    height: context.sp(170),
                    width: context.sp(170),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.darkBlue,
                    ),
                  ),
                ),
                Positioned(
                  top: -context.sp(110),
                  right: -context.sp(110),
                  child: Container(
                    height: context.sp(260),
                    width: context.sp(260),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.orange,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -context.sp(150),
                  left: -context.sp(150),
                  child: Container(
                    height: context.sp(350),
                    width: context.sp(350),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEE775A),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sp(60),
                  ),
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: Column(
                      children: [
                        SizedBox(height: context.sp(120)),
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
                        SizedBox(
                          child: Form(
                            child: Column(
                              children: [
                                LoginInput(
                                  controller: emailController,
                                  hintText: 'Email',
                                ),
                                SizedBox(height: context.sp(12)),
                                LoginInput(
                                  controller: passwordController,
                                  hintText: 'Contraseña',
                                  isPassword: true,
                                  isObscure: isObscure,
                                  changeObscure: () => setState(() {
                                    isObscure = !isObscure;
                                  }),
                                ),
                                SizedBox(height: context.sp(12)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () => context.push(RouterPaths.resetPassword),
                                      child: Text(
                                        'Olvidaste tu contraseña?',
                                        style: context.styles.smallText,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: context.sp(24)),
                                SizedBox(
                                  height: context.sp(45),
                                  width: context.sp(172),
                                  child: PrimaryButton(
                                    onTap: () => context.read<LoginBloc>().add(
                                          LoginEvent.loginEvent(
                                            emailController.text,
                                            passwordController.text,
                                          ),
                                        ),
                                    isBig: false,
                                    label: 'Acceder',
                                    isActive: true,
                                  ),
                                ),
                                SizedBox(height: context.sp(24)),
                                RichText(
                                  text: TextSpan(
                                    text: 'Aun no tienes cuenta? ',
                                    style: context.styles.smallText,
                                    children: [
                                      TextSpan(
                                        text: 'Registrate',
                                        style: context.styles.smallText.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => context.push(RouterPaths.register),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: context.sp(24)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: context.sp(1),
                              width: context.sp(123),
                              color: Colors.black,
                            ),
                            Text(
                              'O',
                              style: context.styles.header1,
                            ),
                            Container(
                              height: context.sp(1),
                              width: context.sp(123),
                              color: Colors.black,
                            ),
                          ],
                        ),
                        SizedBox(height: context.sp(24)),
                        SizedBox(
                          width: context.sp(240),
                          child: BlocBuilder<LoginBloc, LoginState>(
                            builder: (_, state) {
                              return AppSocialRegularButton(
                                // onTap: () async => await notifier.signInWithGoogle(),
                                onTap: () {},
                                label: 'Entrar con Google',
                                isActive: true,
                                icon: Assets.icons.googleIcon,
                                isLoading: false,
                              );
                            },
                          ),
                        ),
                        SizedBox(height: context.sp(12)),
                        Visibility(
                          visible: Platform.isIOS,
                          child: SizedBox(
                            width: context.sp(240),
                            child: BlocBuilder<LoginBloc, LoginState>(
                              builder: (_, state) {
                                return AppSocialRegularButton(
                                  // onTap: () async => await notifier.signInWithApple(),
                                  onTap: () {},
                                  label: 'Entrar con Apple',
                                  isActive: true,
                                  icon: Assets.icons.appleIcon,
                                  isLoading: false,
                                );
                              },
                            ),
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
    );
  }
}
