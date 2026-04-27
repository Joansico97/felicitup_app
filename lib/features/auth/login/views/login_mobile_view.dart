import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/login/bloc/login_bloc.dart';
import 'package:felicitup_app/features/auth/login/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../gen/assets.gen.dart';

class LoginMobileView extends StatelessWidget {
  const LoginMobileView({super.key});

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
                    color: const Color(0xFFEE775A),
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: context.sp(60)),
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
                      LoginForm(),
                      SizedBox(height: context.sp(24)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: context.sp(1),
                            width: context.sp(123),
                            color: Colors.black,
                          ),
                          Text('O', style: context.styles.header2),
                          Container(
                            height: context.sp(1),
                            width: context.sp(123),
                            color: Colors.black,
                          ),
                        ],
                      ),
                      SizedBox(height: context.sp(24)),
                      SizedBox(
                        height: context.sp(40),
                        width: context.sp(240),
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
                      SizedBox(height: context.sp(12)),
                      Visibility(
                        visible: defaultTargetPlatform == TargetPlatform.iOS,
                        child: SizedBox(
                          height: context.sp(40),
                          width: context.sp(240),
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
            ],
          ),
        ),
      ),
    );
  }
}
