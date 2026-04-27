import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/login/bloc/login_bloc.dart';
import 'package:felicitup_app/features/auth/login/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../gen/assets.gen.dart';

class LoginWebView extends StatelessWidget {
  const LoginWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: context.fullHeight,
        width: context.fullWidth,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                top: -70,
                left: -70,
                child: Container(
                  height: 170,
                  width: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.darkBlue,
                  ),
                ),
              ),
              Positioned(
                top: -110,
                right: -110,
                child: Container(
                  height: 260,
                  width: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.colors.orange,
                  ),
                ),
              ),
              Positioned(
                bottom: -150,
                left: -150,
                child: Container(
                  height: 350,
                  width: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEE775A),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: Center(
                    child: SizedBox(
                      width: 400,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 120),
                          Image.asset(Assets.images.logo.path, height: 60),
                          const SizedBox(height: 23),
                          Image.asset(
                            Assets.images.logoLetter.path,
                            height: 62,
                          ),
                          const SizedBox(height: 24),
                          LoginForm(),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 1,
                                width: 123,
                                color: Colors.black,
                              ),
                              Text('O', style: context.styles.header2),
                              Container(
                                height: 1,
                                width: 123,
                                color: Colors.black,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 40,
                            width: 240,
                            child: BlocBuilder<LoginBloc, LoginState>(
                              builder: (_, state) {
                                return AppSocialRegularButton(
                                  onTap: () => context.read<LoginBloc>().add(
                                    LoginEvent.googleLoginEvent(),
                                  ),
                                  label: 'Entrar con Google',
                                  isActive: true,
                                  icon: Assets.icons.googleIcon,
                                  isLoading: false,
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          Visibility(
                            visible: defaultTargetPlatform == TargetPlatform.iOS,
                            child: SizedBox(
                              height: 40,
                              width: 240,
                              child: BlocBuilder<LoginBloc, LoginState>(
                                builder: (_, state) {
                                  return AppSocialRegularButton(
                                    onTap: () => context.read<LoginBloc>().add(
                                      LoginEvent.appleLoginEvent(),
                                    ),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
