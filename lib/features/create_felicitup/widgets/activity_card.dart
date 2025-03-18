import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/widgets.dart';
import 'package:flutter/material.dart';

class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.activity,
    required this.onTap,
    required this.isActive,
  });

  final String activity;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.sp(35),
          vertical: context.sp(18),
        ),
        margin: EdgeInsets.only(
          bottom: context.sp(10),
        ),
        width: context.fullWidth,
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(context.sp(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity,
                  style: context.styles.header2,
                ),
              ],
            ),
            Spacer(),
            CirclePicker(
              isActive: isActive,
            ),
          ],
        ),
      ),
    );
  }
}
