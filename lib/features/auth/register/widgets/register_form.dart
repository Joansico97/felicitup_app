import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/widgets/buttons/primary_button.dart';
import 'package:felicitup_app/features/auth/register/bloc/register_bloc.dart';
import 'package:felicitup_app/features/auth/register/widgets/widgets.dart';
import 'package:felicitup_app/helpers/validates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    super.key,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool isObscure = true;
  bool isRepObscure = true;
  bool masculine = false;
  bool feminine = false;
  bool other = false;
  DateTime? birthDate;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          AppRegisterInputField(
            isEmail: false,
            isText: true,
            hintText: 'Nombre',
            controller: firstNameController,
            validator: () => validateText,
          ),
          SizedBox(height: context.sp(12)),
          AppRegisterInputField(
            isEmail: false,
            isText: true,
            hintText: 'Apellidos',
            controller: lastNameController,
            validator: () => validateText,
          ),
          SizedBox(height: context.sp(12)),
          AppRegisterInputField(
            isEmail: true,
            isText: false,
            hintText: 'Email',
            controller: emailController,
            validator: () => validateText,
          ),
          SizedBox(height: context.sp(12)),
          AppRegisterInputField(
            isEmail: false,
            isText: false,
            hintText: 'Contraseña',
            controller: passwordController,
            isObscure: isObscure,
            onTap: () => setState(() {
              isObscure = !isObscure;
            }),
            validator: () => validateText,
          ),
          SizedBox(height: context.sp(12)),
          AppRegisterInputField(
            isEmail: false,
            isText: false,
            hintText: 'Repetir Contraseña',
            controller: repeatPasswordController,
            isObscure: isRepObscure,
            onTap: () => setState(() {
              isRepObscure = !isRepObscure;
            }),
            validator: () => validateText,
          ),
          SizedBox(height: context.sp(12)),
          BlocBuilder<RegisterBloc, RegisterState>(
            builder: (context, state) {
              return GestureDetector(
                onTap: () {},
                child: Container(
                  height: context.sp(45),
                  width: context.sp(240),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.sp(12),
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: birthDate == null ? context.sp(1) : context.sp(2),
                        color: context.colors.darkGrey,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        birthDate == null ? 'Fecha Nacimiento' : DateFormat('dd/MM/yyyy').format(birthDate!),
                        style: context.styles.paragraph.copyWith(
                          color: birthDate == null ? context.colors.darkGrey : Colors.black,
                        ),
                      ),
                      Icon(
                        Icons.calendar_month_rounded,
                        color: context.colors.orange,
                      )
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: context.sp(12)),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Género',
              style: context.styles.paragraph,
            ),
          ),
          SizedBox(height: context.sp(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GenderCheckBox(
                label: 'Masculino',
                boolValue: masculine,
                onChanged: (value) => setState(() {
                  masculine = value!;
                  feminine = false;
                  other = false;
                }),
              ),
              GenderCheckBox(
                label: 'Femenino',
                boolValue: feminine,
                onChanged: (value) => setState(() {
                  feminine = value!;
                  masculine = false;
                  other = false;
                }),
              ),
              GenderCheckBox(
                label: 'Otro',
                boolValue: other,
                onChanged: (value) => setState(() {
                  other = value!;
                  feminine = false;
                  masculine = false;
                }),
              ),
            ],
          ),
          SizedBox(height: context.sp(24)),
          SizedBox(
            height: context.sp(45),
            width: context.sp(172),
            child: PrimaryButton(
              onTap: () {
                if (passwordController.text.isNotEmpty &&
                    repeatPasswordController.text.isNotEmpty &&
                    passwordController.text == repeatPasswordController.text &&
                    emailController.text.isNotEmpty &&
                    firstNameController.text.isNotEmpty &&
                    lastNameController.text.isNotEmpty) {
                  // registerProccess();
                }
              },
              label: 'Continuar',
              isActive: true,
            ),
          ),
          SizedBox(height: context.sp(12)),
        ],
      ),
    );
  }
}

class GenderCheckBox extends StatelessWidget {
  const GenderCheckBox({
    super.key,
    required this.label,
    required this.boolValue,
    required this.onChanged,
  });

  final String label;
  final bool boolValue;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: context.styles.paragraph,
        ),
        Checkbox(
          value: boolValue,
          onChanged: (value) => onChanged(value),
          activeColor: context.colors.orange,
          checkColor: context.colors.white,
        ),
      ],
    );
  }
}
