import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/foundation.dart';
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
            maxHeight: kIsWeb ? 50 : context.sp(50),
            minHeight: kIsWeb ? 50 : context.sp(50),
            // maxWidth: kIsWeb ? 240 : context.sp(240),
            // minWidth: kIsWeb ? 240 : context.sp(240),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                kIsWeb ? 200 : context.sp(100),
              ),
            ),
            child: TextFormField(
              controller: widget.controller,
              keyboardType: widget.isPassword
                  ? TextInputType.visiblePassword
                  : TextInputType.emailAddress,
              obscuringCharacter: '•',
              obscureText: widget.isPassword ? widget.isObscure! : false,
              textAlignVertical: TextAlignVertical.center,
              style: context.styles.menu.copyWith(
                letterSpacing: widget.isPassword ? 1.5 : 1,
                height: 1,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: kIsWeb ? 16 : context.sp(16),
                  vertical: kIsWeb ? 14 : context.sp(14),
                ),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: kIsWeb ? 1 : context.sp(1),
                    color: context.colors.darkGrey,
                  ),
                  borderRadius: BorderRadius.circular(
                    kIsWeb ? 200 : context.sp(200),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: kIsWeb ? 1 : context.sp(1),
                    color: context.colors.darkGrey,
                  ),
                  borderRadius: BorderRadius.circular(
                    kIsWeb ? 200 : context.sp(200),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: kIsWeb ? 1 : context.sp(1),
                    color: context.colors.darkGrey,
                  ),
                  borderRadius: BorderRadius.circular(
                    kIsWeb ? 200 : context.sp(200),
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: kIsWeb ? 1 : context.sp(1),
                    color: context.colors.error,
                  ),
                  borderRadius: BorderRadius.circular(
                    kIsWeb ? 200 : context.sp(200),
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: kIsWeb ? 1 : context.sp(1),
                    color: context.colors.error,
                  ),
                  borderRadius: BorderRadius.circular(
                    kIsWeb ? 200 : context.sp(200),
                  ),
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
                  height: 1,
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        padding: EdgeInsets.only(
                          right: kIsWeb ? 12 : context.sp(12),
                        ),
                        constraints: const BoxConstraints(),
                        onPressed: widget.changeObscure,
                        icon: Icon(
                          widget.isObscure!
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: context.colors.black,
                          size: 20,
                        ),
                      )
                    : null,
              ),
              validator: widget.validate != null
                  ? (e) {
                      final error = widget.validate!(e);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            errorText = error ?? '';
                          });
                        }
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
