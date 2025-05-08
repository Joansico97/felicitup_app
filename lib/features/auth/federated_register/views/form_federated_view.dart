import 'package:felicitup_app/app/bloc/app_bloc.dart';
import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/core/router/router.dart';
import 'package:felicitup_app/core/widgets/buttons/primary_button.dart';
import 'package:felicitup_app/core/widgets/common/date_time_picker.dart';
import 'package:felicitup_app/features/auth/register/widgets/register_form.dart';
import 'package:felicitup_app/features/auth/register/widgets/register_input_field.dart';
import 'package:felicitup_app/features/features.dart';
import 'package:felicitup_app/gen/assets.gen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class FormFederatedView extends StatefulWidget {
  const FormFederatedView({super.key});

  @override
  State<FormFederatedView> createState() => _FormFederatedViewState();
}

class _FormFederatedViewState extends State<FormFederatedView> {
  bool masculine = false;
  bool feminine = false;
  bool other = false;
  DateTime? birthDate;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final data = context.read<AppBloc>().state.federatedData;
    firstNameController.text = data?['firstName'] ?? '';
    lastNameController.text = data?['lastName'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Column(
        children: [
          Image.asset(Assets.images.logo.path, height: context.sp(60)),
          SizedBox(height: context.sp(12)),
          Image.asset(Assets.images.logoLetter.path, height: context.sp(62)),
          SizedBox(height: context.sp(12)),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextFormField(
                  controller: firstNameController,
                  hintText: 'Nombre',
                ),
                SizedBox(height: context.sp(6)),
                CustomTextFormField(
                  controller: lastNameController,
                  hintText: 'Apellidos',
                ),
                SizedBox(height: context.sp(12)),
                GestureDetector(
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final DateTime? pickedDate = await showGenericDatePicker(
                      context: context,
                      initialDate: DateTime.now().subtract(
                        const Duration(days: 365 * 18),
                      ),
                      firstDate: DateTime(1939),
                      lastDate: DateTime.now().subtract(
                        const Duration(days: 365 * 18),
                      ),
                      helpText: 'Selecciona una fecha',
                      cancelText: 'Cancelar',
                      confirmText: 'OK',
                      locale: const Locale('es', 'ES'),
                    );

                    if (pickedDate == null) return;

                    setState(() {
                      birthDate = pickedDate;
                    });
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
                        Icon(
                          Icons.calendar_month_rounded,
                          color: context.colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.sp(24)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Género', style: context.styles.paragraph),
                ),
                SizedBox(height: context.sp(12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GenreCheckBox(
                      label: 'Masculino',
                      boolValue: masculine,
                      onChanged:
                          (value) => setState(() {
                            masculine = value!;
                            feminine = false;
                            other = false;
                          }),
                    ),
                    GenreCheckBox(
                      label: 'Femenino',
                      boolValue: feminine,
                      onChanged:
                          (value) => setState(() {
                            feminine = value!;
                            masculine = false;
                            other = false;
                          }),
                    ),
                    GenreCheckBox(
                      label: 'Otro',
                      boolValue: other,
                      onChanged:
                          (value) => setState(() {
                            other = value!;
                            feminine = false;
                            masculine = false;
                          }),
                    ),
                  ],
                ),
                SizedBox(height: context.sp(12)),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: 'Al registrarte aceptas los ',
                    style: context.styles.smallText,
                    children: [
                      TextSpan(
                        text: 'Términos y Condiciones ',
                        style: context.styles.smallText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                context.push(
                                  RouterPaths.termsPolicies,
                                  extra: true,
                                );
                              },
                      ),
                      TextSpan(text: 'y la ', style: context.styles.smallText),
                      TextSpan(
                        text: 'Política de Privacidad ',
                        style: context.styles.smallText.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                context.push(
                                  RouterPaths.termsPolicies,
                                  extra: false,
                                );
                              },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.sp(24)),
                SizedBox(
                  height: context.sp(45),
                  width: context.sp(172),
                  child: PrimaryButton(
                    onTap: () {
                      if (firstNameController.text.isNotEmpty &&
                          lastNameController.text.isNotEmpty &&
                          birthDate != null &&
                          (masculine || feminine || other)) {
                        context.read<FederatedRegisterBloc>().add(
                          FederatedRegisterEvent.initRegister(
                            firstNameController.text.trim().capitalize(),
                            lastNameController.text.trim().capitalize(),
                            masculine
                                ? "Masculino"
                                : feminine
                                ? "Feminino"
                                : "Otro",
                            birthDate!,
                          ),
                        );
                      }
                    },
                    label: 'Continuar',
                    isActive: true,
                  ),
                ),
                SizedBox(height: context.sp(12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
