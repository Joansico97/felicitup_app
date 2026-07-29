import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/register/widgets/register_input_field.dart';
import 'package:felicitup_app/features/complete_user_data/bloc/complete_user_data_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompleteUserDataMobilePage extends StatefulWidget {
  const CompleteUserDataMobilePage({super.key});

  @override
  State<CompleteUserDataMobilePage> createState() =>
      _CompleteUserDataMobilePageState();
}

class _CompleteUserDataMobilePageState
    extends State<CompleteUserDataMobilePage> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  bool get isComplete =>
      (firstNameController.text.isNotEmpty &&
      lastNameController.text.isNotEmpty);

  @override
  void initState() {
    super.initState();
    final currentUser = context.read<AppBloc>().state.currentUser;
    firstNameController.text = currentUser?.firstName ?? '';
    lastNameController.text = currentUser?.lastName ?? '';
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        SizedBox(
          width: context.sp(400),
          child: PrimaryButton(
            onTap: () => context.read<CompleteUserDataBloc>().add(
                  CompleteUserDataEvent.completeUserData(
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                  ),
                ),
            label: context.locale.save,
            isActive: isComplete,
          ),
        ),
        SizedBox(height: context.sp(12)),
        SizedBox(
          width: context.sp(400),
          child: PrimaryButton(
            onTap: () => context.read<CompleteUserDataBloc>().add(
                  const CompleteUserDataEvent.logout(),
                ),
            label: context.locale.logout,
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
              Text(
                context.locale.complete_profile_title,
                style: context.styles.header2,
              ),
              SizedBox(height: context.sp(24)),
              Text(
                context.locale.complete_profile_info,
                style: context.styles.paragraph,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.sp(12)),
              CustomTextFormField(
                controller: firstNameController,
                hintText: context.locale.first_name,
                onChanged: (_) => setState(() {}),
              ),
              SizedBox(height: context.sp(6)),
              CustomTextFormField(
                controller: lastNameController,
                hintText: context.locale.last_name,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
