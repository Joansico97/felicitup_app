import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class DetailsRow extends StatelessWidget {
  const DetailsRow({
    super.key,
    required this.prefixChild,
    required this.sufixChild,
    this.onTap,
  });

  final VoidCallback? onTap;
  final Widget prefixChild;
  final Widget sufixChild;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.sp(45),
        width: context.fullWidth,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: context.sp(20)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.sp(20)),
          color: Colors.white.withValues(alpha: .6),
          border: Border.all(
            color: Colors.white,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            prefixChild,
            Spacer(),
            sufixChild,
          ],
        ),
      ),
    );
  }
}
