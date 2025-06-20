import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class ScrollButton extends StatelessWidget {
  const ScrollButton({super.key, required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.sp(16)),
      child: Column(
        children: [
          SizedBox(
            width: context.fullWidth,
            child: Text(title, style: context.styles.header2),
          ),
          SizedBox(height: context.sp(12)),
          Text(
            content,
            style: context.styles.paragraph,
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: context.sp(12)),
        ],
      ),
    );
  }
}
