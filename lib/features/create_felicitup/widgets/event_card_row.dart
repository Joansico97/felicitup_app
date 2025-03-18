import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:felicitup_app/features/create_felicitup/widgets/widgets.dart';
import 'package:flutter/material.dart';

class EventCardRow extends StatelessWidget {
  const EventCardRow({
    super.key,
    required this.eventName,
    required this.isSelected,
  });

  final String eventName;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.sp(15)),
      margin: EdgeInsets.only(
        bottom: context.sp(10),
      ),
      width: context.fullWidth,
      decoration: BoxDecoration(
        color: context.colors.white,
        borderRadius: BorderRadius.circular(context.sp(10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            eventName,
            style: context.styles.header2,
          ),
          const Spacer(),
          CirclePicker(
            isActive: isSelected,
          ),
        ],
      ),
    );
  }
}
