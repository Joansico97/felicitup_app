import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/widgets.dart';
import 'package:felicitup_app/features/auth/register/widgets/register_input_field.dart';
import 'package:felicitup_app/features/complete_user_data/bloc/complete_user_data_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CompleteUserDataWebPage extends StatefulWidget {
  const CompleteUserDataWebPage({super.key});

  @override
  State<CompleteUserDataWebPage> createState() =>
      _CompleteUserDataWebPageState();
}

class _CompleteUserDataWebPageState extends State<CompleteUserDataWebPage> {
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
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: context.sp(20),
            vertical: context.sp(40),
          ),
          child: SizedBox(
            width: context.sp(450),
            child: Container(
              padding: EdgeInsets.all(context.sp(24)),
              decoration: BoxDecoration(
                color: context.colors.backgroundModal,
                borderRadius: BorderRadius.circular(context.sp(24)),
                border: Border.all(color: context.colors.lightGrey),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  SizedBox(height: context.sp(16)),
                  CustomTextFormField(
                    controller: firstNameController,
                    hintText: context.locale.first_name,
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: context.sp(12)),
                  CustomTextFormField(
                    controller: lastNameController,
                    hintText: context.locale.last_name,
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: context.sp(24)),
                  SizedBox(
                    width: context.fullWidth,
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
                    width: context.fullWidth,
                    child: PrimaryButton(
                      onTap: () => context.read<CompleteUserDataBloc>().add(
                            const CompleteUserDataEvent.logout(),
                          ),
                      label: context.locale.logout,
                      isActive: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
