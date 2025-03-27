import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/cupertino.dart';

class SwitchButton extends StatelessWidget {
  const SwitchButton({
    super.key,
    required this.label,
    required this.stateValue,
    required this.onChanged,
  });

  final String label;
  final bool stateValue;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.sp(300),
      padding: EdgeInsets.symmetric(
        horizontal: context.sp(16),
        vertical: context.sp(12),
      ),
      margin: EdgeInsets.only(
        bottom: context.sp(12),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(context.sp(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.styles.paragraph.copyWith(
              fontSize: 14,
            ),
          ),
          CupertinoSwitch(
            value: stateValue,
            onChanged: onChanged,
          )
        ],
      ),
    );
  }
}
