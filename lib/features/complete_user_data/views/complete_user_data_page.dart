import 'dart:async';

import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/register/widgets/register_input_field.dart';
import 'package:felicitup_app/features/complete_user_data/bloc/complete_user_data_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CompleteUserDataPage extends StatefulWidget {
  const CompleteUserDataPage({super.key});

  @override
  State<CompleteUserDataPage> createState() => _CompleteUserDataPageState();
}

class _CompleteUserDataPageState extends State<CompleteUserDataPage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  bool get isComplete =>
      (firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty);

  @override
  void initState() {
    final currentUser = context.read<AppBloc>().state.currentUser;
    firstNameController.text = currentUser?.firstName ?? '';
    lastNameController.text = currentUser?.lastName ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompleteUserDataBloc, CompleteUserDataState>(
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

        if (state.status == CompleteUserDataStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Error desconocido'),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        if (state.status == CompleteUserDataStatus.success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Datos guardados correctamente'),
              duration: Duration(seconds: 2),
            ),
          );
          context.go(RouterPaths.felicitupsDashboard);
        }
      },
      child: Scaffold(
        persistentFooterAlignment: AlignmentDirectional.center,
        persistentFooterButtons: [
          SizedBox(
            width: context.sp(400),
            child: PrimaryButton(
              onTap:
                  () => context.read<CompleteUserDataBloc>().add(
                    CompleteUserDataEvent.completeUserData(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                    ),
                  ),
              label: 'Guardar',
              isActive: isComplete,
            ),
          ),
          SizedBox(height: context.sp(12)),
          SizedBox(
            width: context.sp(400),
            child: PrimaryButton(
              onTap:
                  () => context.read<CompleteUserDataBloc>().add(
                    CompleteUserDataEvent.logout(),
                  ),
              label: 'Cerrar sesión',
              isActive: true,
            ),
          ),
        ],
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            height: context.fullHeight,
            width: context.fullWidth,
            padding: EdgeInsets.symmetric(horizontal: context.sp(24)),
            child: Column(
              children: [
                SizedBox(height: context.screenPadding.top + context.sp(24)),
                Text('Completa tu perfil', style: context.styles.header2),
                SizedBox(height: context.sp(24)),
                Text(
                  'Parece que hubo un problema al obtener tus datos. Por favor, completa tu información para continuar utilizando la aplicación.',
                  style: context.styles.paragraph,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.sp(12)),
                CustomTextFormField(
                  controller: firstNameController,
                  hintText: 'Nombre',
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: context.sp(6)),
                CustomTextFormField(
                  controller: lastNameController,
                  hintText: 'Apellidos',
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
