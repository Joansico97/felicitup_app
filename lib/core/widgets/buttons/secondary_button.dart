import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.onTap,
    required this.label,
    required this.isActive,
    this.isCollapsed = false,
    this.isBig = false,
  });

  final VoidCallback onTap;
  final String label;
  final bool isActive;
  final bool isCollapsed;
  final bool isBig;

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
          backgroundColor:
              isActive
                  ? Colors.transparent
                  : context.colors.lightBlue.valueOpacity(.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.sp(28)),
          ),
        ),
        child: Text(
          label,
          style:
              isBig
                  ? context.styles.paragraph.copyWith(
                    color:
                        isActive
                            ? context.colors.black
                            : context.colors.black.valueOpacity(.3),
                  )
                  : context.styles.buttons.copyWith(
                    color:
                        isActive
                            ? context.colors.black
                            : context.colors.black.valueOpacity(.3),
                  ),
        ),
      ),
    );
  }
}
