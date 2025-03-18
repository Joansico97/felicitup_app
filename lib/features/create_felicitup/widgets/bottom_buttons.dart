import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class BottomButtons extends StatelessWidget {
  const BottomButtons({
    super.key,
    required this.onBack,
    required this.onNext,
    required this.showBack,
    required this.showNext,
  });

  final bool showBack;
  final bool showNext;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(20),
      ),
      child: Row(
        children: [
          Visibility(
            visible: showBack,
            child: GestureDetector(
              onTap: onBack,
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_ios_new_outlined,
                    size: context.sp(10),
                  ),
                  SizedBox(width: context.sp(4)),
                  Text(
                    'Anterior',
                    style: context.styles.menu,
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
          Visibility(
            visible: showNext,
            child: GestureDetector(
              onTap: onNext,
              child: Row(
                children: [
                  Text('Siguiente', style: context.styles.menu),
                  SizedBox(width: context.sp(4)),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: context.sp(10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
