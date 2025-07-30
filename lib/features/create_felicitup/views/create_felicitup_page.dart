import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/logger.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/create_felicitup/bloc/create_felicitup_bloc.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/widgets.dart';
import 'package:felicitup_app/features/home/bloc/home_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CreateFelicitupPage extends StatefulWidget {
  const CreateFelicitupPage({super.key});

  @override
  State<CreateFelicitupPage> createState() => _CreateFelicitupPageState();
}

class _CreateFelicitupPageState extends State<CreateFelicitupPage> {
  final TextEditingController messageController = TextEditingController();

  List<String> steps = ['Quién', 'Evento', 'Participantes', 'Qué', 'Resumen'];

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = context.read<AppBloc>().state.currentUser;
      if (currentUser?.friendsPhoneList?.isEmpty ?? false) {
        requestContactsPermissionWithModal();
      }
    });

    List<String> listData = [
      ...context.read<AppBloc>().state.currentUser?.matchList ?? [],
    ];
    listData.removeWhere(
      (element) => element == context.read<AppBloc>().state.currentUser?.id,
    );
    context.read<CreateFelicitupBloc>().add(
      CreateFelicitupEvent.loadFriendsData(listData),
    );

    pages = [
      SelectContactsView(),
      SelectEventView(),
      SelectParticipantsView(),
      SelectComplementsView(),
      SummaryView(messageController: messageController),
    ];
  }

  Future<void> requestContactsPermissionWithModal() async {
    final result = await showDialog<bool>(
      context: rootNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            title: Text(
              'Acceso a tus Contactos para una Mejor Experiencia en FELICITUP',
              style: context.styles.header2,
            ),
            content: RichText(
              text: TextSpan(
                text:
                    'Para que FELICITUP pueda ayudarte a recordar cumpleaños de tus amigos y familiares, y para que puedas crear fácilmente Felicitups grupales, necesitamos acceder a tu lista de contactos.',
                style: context.styles.paragraph,
                children: [
                  TextSpan(
                    text:
                        '\n\nLos números de teléfono/correos electrónicos de tus contactos serán hasheados (transformados en códigos irreconocibles) en tu dispositivo y subidos de forma segura a nuestros servidores. Esto nos permite encontrar automáticamente a tus contactos que ya usan FELICITUP para facilitar las invitaciones y los recordatorios. Nunca subimos nombres ni otra información sensible sin cifrar',
                    style: context.styles.paragraph.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text:
                        '\n\nEste proceso es esencial para la funcionalidad de matchmaking y para asegurar que recibas recordatorios precisos para tu círculo social.',
                    style: context.styles.paragraph,
                  ),
                  TextSpan(
                    text:
                        '\n\nPuedes obtener más información visitando nuestra "Política de Seguridad"',
                    style: context.styles.paragraph.copyWith(
                      decoration: TextDecoration.underline,
                    ),
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {
                            logger.debug('voy a la URL');
                          },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => rootNavigatorKey.currentContext!.pop(false),
                child: Text('Cancelar', style: context.styles.buttons),
              ),
              TextButton(
                onPressed: () => rootNavigatorKey.currentContext!.pop(true),
                child: Text('Aceptar', style: context.styles.buttons),
              ),
            ],
          ),
    );

    if (result == true) {
      final currentUser = context.select(
        (AppBloc appBloc) => appBloc.state.currentUser,
      );

      context.read<HomeBloc>().add(
        HomeEvent.getAndUpdateContacts(currentUser?.isoCode ?? ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateFelicitupBloc, CreateFelicitupState>(
      listenWhen:
          (previous, current) =>
              previous.isLoading != current.isLoading ||
              previous.status != current.status,
      listener: (_, state) async {
        if (state.isLoading) {
          unawaited(startLoadingModal());
        } else {
          await stopLoadingModal();
        }

        if (state.status == CreateStatus.success) {
          showFinishModal(() {
            context.read<CreateFelicitupBloc>().add(
              const CreateFelicitupEvent.deleteCurrentFelicitup(),
            );
            context.go(RouterPaths.felicitupsDashboard);
          });
        }
      },
      child: BlocBuilder<CreateFelicitupBloc, CreateFelicitupState>(
        builder: (_, state) {
          return Scaffold(
            backgroundColor: context.colors.background,
            drawer: const DrawerApp(),
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  CommonHeader(),
                  FadeInUp(
                    child: Container(
                      width: context.sp(360),
                      padding: EdgeInsets.symmetric(
                        horizontal: context.sp(8),
                        // vertical: context.sp(8),
                      ),
                      margin: EdgeInsets.only(top: context.sp(20)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(context.sp(20)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: context.sp(5)),
                            Container(
                              width: context.fullWidth,
                              height: context.sp(30),
                              margin: EdgeInsets.only(bottom: context.sp(10)),
                              padding: EdgeInsets.symmetric(
                                horizontal: context.sp(5),
                              ),
                              child: Row(
                                children: [
                                  Spacer(),
                                  GestureDetector(
                                    onTap:
                                        () => showConfirmModal(
                                          title:
                                              '¿Quieres salir de la creación de tu felicitup?',
                                          onAccept: () async {
                                            context.go(
                                              RouterPaths.felicitupsDashboard,
                                            );
                                            context.read<CreateFelicitupBloc>().add(
                                              CreateFelicitupEvent.deleteCurrentFelicitup(),
                                            );
                                          },
                                        ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: context.colors.orange,
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.sp(20),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Column(
                                    children: [
                                      SizedBox(height: context.sp(10)),
                                      SizedBox(
                                        width: context.sp(200),
                                        child: Divider(
                                          color: Color(0xFFE3E3E3),
                                        ),
                                      ),
                                    ],
                                  ),
                                  BlocBuilder<
                                    CreateFelicitupBloc,
                                    CreateFelicitupState
                                  >(
                                    builder: (_, state) {
                                      final currentStep = state.steperIndex;
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          ...List.generate(
                                            steps.length,
                                            (index) => _HeaderStep(
                                              title: steps[index],
                                              step: (index + 1).toString(),
                                              isActive: index == currentStep,
                                              onTap:
                                                  () => context
                                                      .read<
                                                        CreateFelicitupBloc
                                                      >()
                                                      .add(
                                                        CreateFelicitupEvent.jumpToStep(
                                                          index,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: context.sp(20)),
                            BlocBuilder<
                              CreateFelicitupBloc,
                              CreateFelicitupState
                            >(
                              builder: (_, state) {
                                return AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  transitionBuilder: (widget, animation) {
                                    final slideAnimation = Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(animation);

                                    final fadeAnimation = Tween<double>(
                                      begin: 0.0,
                                      end: 1.0,
                                    ).animate(animation);
                                    return FadeTransition(
                                      opacity: fadeAnimation,
                                      child: SlideTransition(
                                        position: slideAnimation,
                                        child: widget,
                                      ),
                                    );
                                  },
                                  child: pages[state.steperIndex],
                                );
                              },
                            ),
                            SizedBox(height: context.sp(20)),
                            BlocBuilder<
                              CreateFelicitupBloc,
                              CreateFelicitupState
                            >(
                              builder: (_, state) {
                                final currentStep = state.steperIndex;
                                return BottomButtons(
                                  showBack: currentStep > 0,
                                  showNext: currentStep < steps.length - 1,
                                  onBack:
                                      () => context.read<CreateFelicitupBloc>().add(
                                        const CreateFelicitupEvent.previousStep(),
                                      ),
                                  onNext:
                                      () => context
                                          .read<CreateFelicitupBloc>()
                                          .add(
                                            CreateFelicitupEvent.nextStep(
                                              steps.length - 1,
                                            ),
                                          ),
                                );
                              },
                            ),
                            SizedBox(height: context.sp(16)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderStep extends StatelessWidget {
  const _HeaderStep({
    required this.title,
    required this.step,
    required this.isActive,
    required this.onTap,
  });

  final String title;
  final String step;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: context.sp(40)),
        child: Column(
          children: [
            Text(
              title,
              style: context.styles.menu.copyWith(fontSize: context.sp(10)),
            ),
            SizedBox(height: context.sp(6)),
            Container(
              padding: EdgeInsets.all(context.sp(8)),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isActive ? context.colors.orange : context.colors.text,
                  width: 1,
                ),
                color: isActive ? context.colors.white : Color(0xFFEDEDED),
                shape: BoxShape.circle,
              ),
              child: Text(
                step,
                style: context.styles.menu.copyWith(
                  color: isActive ? context.colors.orange : context.colors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
