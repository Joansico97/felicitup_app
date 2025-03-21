import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final InputDecoration? decoration;
  final TextStyle? style;
  final bool isPassword;
  final bool isEmail;
  final double? width;
  final double? height;
  final TextEditingController controller;

  const CustomTextFormField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.onChanged,
    this.decoration,
    this.style,
    this.isPassword = false,
    this.isEmail = false,
    this.width,
    this.height,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // Define el keyboardType según el tipo de campo
    final keyboardType = widget.isEmail
        ? TextInputType.emailAddress
        : widget.isPassword
            ? TextInputType.visiblePassword
            : TextInputType.text;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: context.sp(60),
        minHeight: context.sp(50),
        maxWidth: context.sp(300),
        minWidth: context.sp(240),
      ),
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: context.styles.paragraph.copyWith(
            color: context.colors.darkGrey,
          ),
          hintText: widget.hintText,
          hintStyle: context.styles.paragraph.copyWith(
            color: context.colors.darkGrey,
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: context.colors.darkGrey,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: context.colors.orange,
            ),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: context.colors.darkGrey,
            ),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: context.colors.error,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.sp(16),
            vertical: context.sp(12),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: context.colors.orange,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : null,
          // ...?widget.decoration?.toMap(), // Combina con la decoración personalizada si se proporciona
        ),
        style: context.styles.paragraph.copyWith(
          height: 1,
          letterSpacing: widget.isPassword ? 1.5 : 0,
        ),
        keyboardType: keyboardType, // Asigna el keyboardType dinámico
        obscureText: widget.isPassword ? _obscureText : false,
        obscuringCharacter: '•',
        validator: widget.validator ?? _defaultValidator,
        onChanged: widget.onChanged,
        autovalidateMode: AutovalidateMode.onUserInteraction,
      ),
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (widget.isEmail && !_isValidEmail(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    if (widget.isPassword && !_isValidPassword(value)) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  bool _isValidEmail(String email) {
    // Expresión regular para validar correos
    final emailRegex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    String pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!\@\#\$%\^&\*\(\)\-_\[\]\{\}]).{8,}$';
    RegExp regex = RegExp(pattern);
    // Validación básica de contraseña (al menos 8 caracteres)
    return regex.hasMatch(password) || password.length >= 8;
  }
}
