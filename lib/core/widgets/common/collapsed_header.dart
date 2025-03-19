import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class CollapsedHeader extends StatelessWidget {
  const CollapsedHeader({
    super.key,
    required this.title,
    required this.onPressed,
  });

  final String title;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.sp(50),
      width: context.fullWidth,
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: context.fullWidth,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: context.styles.subtitle,
            ),
          ),
          Container(
            width: context.fullWidth,
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
              ),
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}
