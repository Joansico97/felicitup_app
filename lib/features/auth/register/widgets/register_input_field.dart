import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class AppRegisterInputField extends StatelessWidget {
  const AppRegisterInputField({
    super.key,
    required this.isEmail,
    required this.isText,
    required this.hintText,
    required this.controller,
    required this.validator,
    this.isObscure,
    this.onTap,
  });

  final bool isEmail;
  final bool isText;
  final String hintText;
  final TextEditingController controller;
  final Function validator;
  final bool? isObscure;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return isEmail
        ? Container(
            constraints: BoxConstraints(
              maxHeight: context.sp(45),
              minHeight: context.sp(45),
              maxWidth: context.sp(240),
              minWidth: context.sp(240),
            ),
            alignment: Alignment.center,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              style: context.styles.paragraph,
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: context.colors.darkGrey,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: context.colors.darkGrey,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: context.colors.darkGrey,
                  ),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: context.colors.primary,
                  ),
                ),
                // disabledBorder: InputBorder.none,
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: context.colors.primary,
                  ),
                ),
                hintText: hintText,
                hintStyle: context.styles.paragraph.copyWith(
                  color: context.colors.darkGrey,
                ),
                errorStyle: context.styles.smallText.copyWith(
                  color: context.colors.error,
                ),
              ),
              validator: (value) {
                String pattern =
                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                RegExp regex = RegExp(pattern);

                if (value == null || value.isEmpty) {
                  return 'Debes ingresar un correo electrónico';
                } else if (!regex.hasMatch(value.trim())) {
                  return 'Debes ingresar un correo electrónico válido';
                }
                return null;
              },
              // validator: validator(),
            ),
          )
        : isText
            ? Container(
                constraints: BoxConstraints(
                  maxHeight: context.sp(45),
                  minHeight: context.sp(45),
                  maxWidth: context.sp(240),
                  minWidth: context.sp(240),
                ),
                alignment: Alignment.center,
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  style: context.styles.paragraph,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: context.colors.darkGrey,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: context.colors.darkGrey,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: context.colors.darkGrey,
                      ),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: context.colors.primary,
                      ),
                    ),
                    // disabledBorder: InputBorder.none,
                    focusedErrorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: context.colors.primary,
                      ),
                    ),
                    hintText: hintText,
                    hintStyle: context.styles.paragraph.copyWith(
                      color: context.colors.darkGrey,
                    ),
                    errorStyle: context.styles.smallText.copyWith(
                      color: context.colors.error,
                    ),
                  ),
                  validator: validateText,
                  // validator: validator(),
                ),
              )
            : Container(
                constraints: BoxConstraints(
                  maxHeight: context.sp(45),
                  minHeight: context.sp(45),
                  maxWidth: context.sp(240),
                  minWidth: context.sp(240),
                ),
                alignment: Alignment.center,
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  obscuringCharacter: '*',
                  obscureText: isObscure!,
                  style: context.styles.paragraph,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: context.colors.darkGrey,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 2,
                        color: context.colors.darkGrey,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: context.colors.darkGrey,
                      ),
                    ),
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                        color: context.colors.primary,
                      ),
                    ),
                    hintText: hintText,
                    hintStyle: context.styles.paragraph.copyWith(
                      color: context.colors.darkGrey,
                    ),
                    errorStyle: context.styles.smallText.copyWith(
                      color: context.colors.error,
                    ),
                    suffixIcon: IconButton(
                      onPressed: onTap,
                      icon: Icon(
                        isObscure! ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: context.colors.orange,
                        size: 20,
                      ),
                    ),
                  ),
                  validator: (value) {
                    String pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!\@\#\$%\^&\*\(\)\-_\[\]\{\}]).{8,}$';
                    RegExp regex = RegExp(pattern);
                    if (value == null || value.isEmpty) {
                      return 'Por favor rellena el campo';
                    } else if (value.length <= 5) {
                      return 'La contraseña debe ser de más de 6 caracteres';
                    } else if (!regex.hasMatch(value.trim())) {
                      return 'Ingresa una contraseña segura';
                    }
                    return null;
                  },
                  // validator: validator(),
                ),
              );
  }

  String? validateText(value) {
    if (value == null || value.isEmpty) {
      return 'Por favor rellena el campo';
    }
    return null;
  }
}
