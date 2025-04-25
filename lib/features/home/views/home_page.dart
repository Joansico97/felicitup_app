import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/home/bloc/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.childView});

  final Widget childView;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<AppBloc>().add(AppEvent.loadUserData());
    context.read<AppBloc>().add(AppEvent.initializeNotifications());
    Future.delayed(
      const Duration(milliseconds: 500),
      () => context.read<AppBloc>().add(AppEvent.checkVerifyStatus()),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        if (context.mounted) {
          context.read<AppBloc>().add(AppEvent.checkVerifyStatus());
        }
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listenWhen:
          (previous, current) => previous.currentUser != current.currentUser,
      listener: (_, state) {
        context.read<AppBloc>().add(
          AppEvent.updateMatchList(state.currentUser?.friendsPhoneList ?? []),
        );
        context.read<HomeBloc>().add(
          HomeEvent.getAndUpdateContacts(state.currentUser?.isoCode ?? ''),
        );
      },
      child: Scaffold(
        drawer: const DrawerApp(),
        backgroundColor: context.colors.background,
        body: BlocBuilder<AppBloc, AppState>(
          builder: (_, state) {
            return (state.isVerified ?? false)
                ? widget.childView
                : const VerifyEmailPage();
          },
        ),
      ),
    );
  }
}

class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Text(
                'Tu email aun no fue verificado, por favor verificalo para continuar',
                textAlign: TextAlign.center,
                style: context.styles.subtitle,
              ),
              SizedBox(height: context.sp(20)),
              Text(
                'Si no recibiste el correo de verificacion, puedes solicitarlo nuevamente',
                textAlign: TextAlign.center,
                style: context.styles.smallText,
              ),
              Spacer(),
              SizedBox(
                height: context.sp(50),
                width: context.sp(400),
                child: PrimaryButton(
                  onTap: () {},
                  label: 'Reenviar código',
                  isActive: true,
                  isBig: true,
                ),
              ),
              SizedBox(height: context.sp(12)),
              SizedBox(
                height: context.sp(50),
                width: context.sp(400),
                child: SecondaryButton(
                  onTap: () {
                    context.read<AppBloc>().add(AppEvent.logout());
                    context.go(RouterPaths.init);
                  },
                  label: 'Cerrar sesión',
                  isActive: true,
                  isBig: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
