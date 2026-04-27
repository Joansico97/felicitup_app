import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:super_tooltip/super_tooltip.dart';

class CommonTooltip extends StatefulWidget {
  const CommonTooltip({super.key, required this.message, this.direction});

  final TooltipDirection? direction;
  final String message;

  @override
  State<CommonTooltip> createState() => _CommonTooltipState();
}

class _CommonTooltipState extends State<CommonTooltip> {
  final _controller = SuperTooltipController();

  @override
  Widget build(BuildContext context) {
    return SuperTooltip(
      controller: _controller,
      content: Padding(
        padding: EdgeInsets.all(context.sp(12)),
        child: Text(
          widget.message,
          softWrap: true,
          style: context.styles.paragraph.copyWith(color: context.colors.white),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          _controller.showTooltip();
        },
        child: Icon(Icons.info_outline, color: context.colors.darkGrey),
      ),
    );
  }
}
