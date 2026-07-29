import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.sp(300),
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(16),
        vertical: context.sp(16),
      ),
      decoration: BoxDecoration(
        color: context.colors.lightGrey,
        borderRadius: BorderRadius.circular(context.sp(8)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: context.styles.paragraph.copyWith(
              color: context.colors.darkGrey,
            ),
          ),
          const Spacer(),
          icon != null ? Icon(icon, size: context.sp(20)) : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
