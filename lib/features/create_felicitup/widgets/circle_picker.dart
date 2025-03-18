import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class CirclePicker extends StatelessWidget {
  const CirclePicker({
    super.key,
    required this.isActive,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.sp(25),
      width: context.sp(25),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? context.colors.orange : context.colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: context.colors.darkGrey,
          width: context.sp(1),
        ),
      ),
      child: isActive
          ? Icon(
              Icons.check,
              color: Colors.white,
            )
          : null,
    );
  }
}
