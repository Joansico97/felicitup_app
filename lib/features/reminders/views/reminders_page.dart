import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AppBloc>().state.currentUser;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CollapsedHeader(title: 'Recordatorios', onPressed: () async => context.go(RouterPaths.felicitupsDashboard)),
            SizedBox(height: context.sp(12)),
            Expanded(
              child: ListView.builder(
                itemCount: currentUser?.remainders?.length ?? 0,
                itemBuilder: (_, index) {
                  final data = currentUser?.remainders?[index];

                  return ListTile(
                    title: Text('Cumpleaños de ${data?.birthdayUserName ?? ''}', style: context.styles.header2),
                    subtitle: Text(
                      'El cumpleaños de ${data?.birthdayUserName ?? ''} será el ${DateFormat('dd·MM·yyyy').format(data?.reminderDate ?? DateTime.now())}',
                      style: context.styles.subtitle,
                    ),
                    trailing: Icon(Icons.calendar_month_outlined, color: context.colors.orange),
                    onTap:
                        () => showConfirDoublemModal(
                          title: 'Qué acción deseas realizar?',
                          needOtherButton: true,
                          label1: 'Crear felicitup',
                          label2: 'Enviar mensaje directo',
                          label3: 'Eliminar recordatorio',
                          onAction1: () async {},
                          onAction2: () async {},
                          onAction3: () async {},
                        ),
                  );
                },
              ),
              // child: Column(
              //   children: [
              //     ...List.generate(
              //       5,
              // (index) => ListTile(
              //   title: Text('Recordatorio ${index + 1}'),
              //   subtitle: Text('Descripción del recordatorio ${index + 1}'),
              //   trailing: Icon(Icons.calendar_month_outlined, color: context.colors.orange),
              //   onTap:
              //       () => showConfirDoublemModal(
              //         title: 'Qué acción deseas realizar?',
              //         needOtherButton: true,
              //         label1: 'Crear felicitup',
              //         label2: 'Enviar mensaje directo',
              //         label3: 'Eliminar recordatorio',
              //         onAction1: () async {},
              //         onAction2: () async {},
              //         onAction3: () async {},
              //       ),
              //   // onTap: () => context.go(RouterPaths.reminderDetails),
              // ),
              //     ),
              //   ],
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
