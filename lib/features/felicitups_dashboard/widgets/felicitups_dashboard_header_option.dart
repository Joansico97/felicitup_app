import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FelicitupsDashboardHeaderOption extends StatelessWidget {
  const FelicitupsDashboardHeaderOption({
    super.key,
    required this.label,
    required this.isActive,
    required this.onActive,
    required this.activeColor,
    required this.textColor,
  });

  final String label;
  final bool isActive;
  final VoidCallback onActive;
  final Color activeColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onActive,
      child: Container(
        height: kIsWeb ? 28 : context.sp(28),
        width: kIsWeb ? 90 : context.sp(90),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kIsWeb ? 20 : context.sp(20)),
          color: context.colors.ligthOrange.valueOpacity(.6),
          border: Border.all(color: context.colors.white),
        ),
        child: Text(
          label,
          style: context.styles.menu.copyWith(
            color: isActive ? activeColor : context.colors.darkGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
