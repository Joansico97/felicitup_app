import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class LoginInput extends StatefulWidget {
  const LoginInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.validate,
    this.isPassword = false,
    this.isObscure,
    this.changeObscure,
    this.onchangeEditing,
  });

  final TextEditingController controller;
  final String hintText;
  final bool isPassword;
  final bool? isObscure;
  final void Function()? changeObscure;
  final String? Function(String?)? validate;
  final void Function(String)? onchangeEditing;

  @override
  State<LoginInput> createState() => _LoginInputState();
}

class _LoginInputState extends State<LoginInput> {
  String errorText = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: context.sp(45),
            minHeight: context.sp(45),
            maxWidth: context.sp(240),
            minWidth: context.sp(240),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.sp(100)),
            ),
            child: TextFormField(
              controller: widget.controller,
              keyboardType: widget.isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
              obscuringCharacter: '•',
              obscureText: widget.isPassword ? widget.isObscure! : false,
              style: context.styles.menu.copyWith(
                letterSpacing: widget.isPassword ? 1.5 : 1,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.sp(16),
                  vertical: context.sp(15),
                ),
                fillColor: Colors.white,
                filled: true,
                isCollapsed: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: context.sp(1),
                    color: context.colors.darkGrey,
                  ),
                  borderRadius: BorderRadius.circular(context.sp(200)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: context.sp(1),
                    color: context.colors.darkGrey,
                  ),
                  borderRadius: BorderRadius.circular(context.sp(200)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: context.sp(1),
                    color: context.colors.darkGrey,
                  ),
                  borderRadius: BorderRadius.circular(context.sp(200)),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: context.sp(1),
                    color: context.colors.error,
                  ),
                  borderRadius: BorderRadius.circular(context.sp(200)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: context.sp(1),
                    color: context.colors.error,
                  ),
                  borderRadius: BorderRadius.circular(context.sp(200)),
                ),
                errorStyle: context.styles.paragraph.copyWith(
                  color: context.colors.error,
                  fontSize: 0.1,
                  height: .01,
                ),
                disabledBorder: InputBorder.none,
                hintText: widget.hintText,
                hintStyle: context.styles.paragraph.copyWith(
                  color: context.colors.darkGrey,
                ),
                suffixIcon: IconButton(
                  onPressed: widget.changeObscure,
                  icon: Icon(
                    widget.isPassword
                        ? widget.isObscure!
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined
                        : null,
                    color: context.colors.black,
                    size: 20,
                  ),
                ),
              ),
              validator: widget.validate != null
                  ? (e) {
                      final error = widget.validate!(e);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          errorText = error ?? '';
                        });
                      });
                      return error;
                    }
                  : null,
              onChanged: widget.onchangeEditing,
            ),
          ),
        ),
        Visibility(
          visible: errorText.isNotEmpty,
          child: Text(
            errorText,
            style: context.styles.paragraph.copyWith(
              color: context.colors.error,
            ),
          ),
        ),
      ],
    );
  }
}
