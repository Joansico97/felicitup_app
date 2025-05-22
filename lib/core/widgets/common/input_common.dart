import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class InputCommon extends StatefulWidget {
  const InputCommon({
    super.key,
    required this.controller,
    required this.hintText,
    required this.titleText,
    this.validate,
    this.changeObscure,
    this.onchangeEditing,
    this.isPrice = false,
    this.focusNode,
    this.onSave,
  });

  final TextEditingController controller;
  final String hintText;
  final String titleText;
  final bool isPrice;
  final FocusNode? focusNode;

  final void Function()? changeObscure;
  final String? Function(String?)? validate;
  final void Function(String)? onchangeEditing;
  final void Function(String)? onSave;

  @override
  State<InputCommon> createState() => _InputCommonState();
}

class _InputCommonState extends State<InputCommon> {
  String errorText = '';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.titleText, style: context.styles.menu),
            SizedBox(height: context.sp(8)),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: context.sp(56),
                maxWidth: context.fullWidth,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                keyboardType:
                    widget.isPrice ? TextInputType.number : TextInputType.text,
                style: context.styles.smallText.copyWith(letterSpacing: 0.5),
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
                      width: 1,
                      color: context.colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(context.sp(8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      color: context.colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(context.sp(8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      color: context.colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(context.sp(8)),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      color: context.colors.error,
                    ),
                    borderRadius: BorderRadius.circular(context.sp(8)),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                      color: context.colors.error,
                    ),
                    borderRadius: BorderRadius.circular(context.sp(8)),
                  ),
                  errorStyle: context.styles.paragraph.copyWith(
                    color: context.colors.error,
                    fontSize: 0.1,
                    height: .01,
                  ),
                  disabledBorder: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: context.styles.paragraph.copyWith(
                    color: Colors.black.withValues(alpha: .5),
                    letterSpacing: 0.5,
                  ),
                ),
                onSaved: (e) => widget.onSave!(e!),
                validator:
                    widget.validate != null
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
            Visibility(
              visible: errorText.isNotEmpty,
              child: Text(
                errorText,
                style: context.styles.smallText.copyWith(
                  color: context.colors.error,
                  fontSize: context.sp(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
