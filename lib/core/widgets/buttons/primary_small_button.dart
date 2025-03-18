import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class PrimarySmallButton extends StatelessWidget {
  const PrimarySmallButton({
    super.key,
    required this.onTap,
    required this.label,
    required this.isActive,
    this.isCollapsed = false,
  });

  final VoidCallback onTap;
  final String label;
  final bool isActive;
  final bool isCollapsed;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: context.sp(isCollapsed ? 32 : 56),
        maxHeight: context.sp(isCollapsed ? 32 : 56),
        maxWidth: context.fullWidth,
      ),
      child: ElevatedButton(
        onPressed: isActive ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? context.colors.orange : context.colors.lightBlue.valueOpacity(.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.sp(28)),
          ),
        ),
        child: Text(
          label,
          style: context.styles.menu.copyWith(
            color: isActive ? context.colors.white : context.colors.white.valueOpacity(.3),
          ),
        ),
      ),
    );
  }
}
