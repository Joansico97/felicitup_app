import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    super.key,
    required this.onTap,
    required this.label,
    required this.icon,
  });

  final VoidCallback onTap;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: context.sp(230),
        padding: EdgeInsets.symmetric(
          horizontal: context.sp(20),
          vertical: context.sp(15),
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFD7DEEA),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.sp(5)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.colors.orange,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: context.colors.orange,
                  ),
                ),
                SizedBox(
                  width: context.sp(16),
                ),
                SizedBox(
                  width: context.sp(100),
                  child: Text(
                    label,
                    style: context.styles.paragraph,
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: context.colors.orange,
              size: 20,
            )
          ],
        ),
      ),
    );
  }
}
