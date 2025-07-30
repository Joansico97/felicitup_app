import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/utils/logger.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/home/bloc/home_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.childView});

  final Widget childView;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<AppBloc>().add(AppEvent.loadUserData());
    context.read<AppBloc>().add(AppEvent.initializeNotifications());
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
      final currentUser = context.read<AppBloc>().state.currentUser;

      context.read<HomeBloc>().add(
        HomeEvent.getAndUpdateContacts(currentUser?.isoCode ?? ''),
      );
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

        if (state.currentUser?.birthDate == null) {
          showConfirmModal(
            title: '¡Que no se te pase tu cumpleaños! 🎂',
            content:
                'Añade tu fecha de nacimiento y Felicitup te ayudará a planificar tu celebración con antelación. Nunca más te quedarás sin tu fiesta.',
            label: 'Añadir mi fecha',
            onAccept: () async {
              DateTime? birthDate;

              await showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: Text(
                        '¿Cuándo es tu cumpleaños?',
                        style: context.styles.header2,
                      ),
                      content: DatePickerWidget(
                        onSelectNewDate: (date) {
                          birthDate = date;
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            context.read<HomeBloc>().add(
                              HomeEvent.setUserBirthdate(
                                date: birthDate ?? DateTime.now(),
                              ),
                            );
                            context.pop();
                          },
                          child: Text('Aceptar', style: context.styles.buttons),
                        ),
                      ],
                    ),
              );
            },
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (state.currentUser != null &&
              (state.currentUser?.friendsPhoneList?.isEmpty ?? false)) {
            requestContactsPermissionWithModal();
          }
          if (state.currentUser != null && state.currentUser!.phone!.isEmpty) {
            context.go(RouterPaths.phoneVerifyInt);
          }
        });
      },
      child: Scaffold(
        drawer: const DrawerApp(),
        backgroundColor: context.colors.background,
        body: widget.childView,
      ),
    );
  }
}

class DatePickerWidget extends StatefulWidget {
  const DatePickerWidget({super.key, required this.onSelectNewDate});

  final Function(DateTime date) onSelectNewDate;

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  DateTime? birthDate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        FocusScope.of(context).unfocus();
        final DateTime? pickedDate = await showGenericDatePicker(
          context: context,
          initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
          firstDate: DateTime(1939),
          lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
          helpText: 'Selecciona una fecha',
          cancelText: 'Cancelar',
          confirmText: 'OK',
          locale: const Locale('es', 'ES'),
        );

        if (pickedDate == null) return;

        setState(() {
          birthDate = pickedDate;
        });

        widget.onSelectNewDate(birthDate!);
      },
      child: Container(
        height: context.sp(45),
        padding: EdgeInsets.symmetric(horizontal: context.sp(12)),
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
                  : DateFormat('dd/MM/yyyy').format(birthDate!),
              style: context.styles.paragraph.copyWith(
                color:
                    birthDate == null
                        ? context.colors.darkGrey
                        : context.colors.black,
              ),
            ),
            Icon(Icons.calendar_month_rounded, color: context.colors.orange),
          ],
        ),
      ),
    );
  }
}
