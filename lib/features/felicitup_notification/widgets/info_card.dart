import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.sp(80),
      width: context.sp(70),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Transform.scale(
            scale: 1.5,
            child: Icon(icon),
          ),
          SizedBox(
            width: context.sp(70),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.styles.smallText,
            ),
          ),
        ],
      ),
    );
  }
}
