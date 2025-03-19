import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class EditInputField extends StatelessWidget {
  const EditInputField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: context.sp(50),
        maxWidth: context.sp(300),
      ),
      child: TextFormField(
        controller: controller,
        style: context.styles.paragraph,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.sp(16),
            vertical: context.sp(15),
          ),
          fillColor: context.colors.grey,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: context.colors.grey,
            ),
            borderRadius: BorderRadius.circular(context.sp(10)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2,
              color: context.colors.grey,
            ),
            borderRadius: BorderRadius.circular(context.sp(10)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: context.colors.grey,
            ),
            borderRadius: BorderRadius.circular(context.sp(10)),
          ),
          disabledBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          hintText: hintText,
          hintStyle: context.styles.paragraph.copyWith(
            color: context.colors.black.valueOpacity(.5),
          ),
          suffixIcon: Icon(
            Icons.edit,
            color: context.colors.black,
            size: 20,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
      ),
    );
  }
}
