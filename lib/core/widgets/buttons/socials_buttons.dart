import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppSocialRegularButton extends StatelessWidget {
  const AppSocialRegularButton({
    super.key,
    required this.onTap,
    required this.label,
    required this.isActive,
    this.icon,
    required this.isLoading,
  });

  final VoidCallback onTap;
  final String label;
  final bool isActive;
  final bool isLoading;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Container(
        height: context.sp(33),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? context.colors.white : context.colors.error.valueOpacity(.6),
          border: Border.all(
            color: context.colors.black,
          ),
          borderRadius: BorderRadius.circular(context.sp(60)),
        ),
        child: isLoading
            ? CircularProgressIndicator(
                color: context.colors.white,
              )
            : icon == null
                ? Text(
                    label,
                    style: context.styles.paragraph.copyWith(
                      color: isActive ? context.colors.black : context.colors.white.valueOpacity(.3),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        icon!,
                      ),
                      SizedBox(width: context.sp(24)),
                      Text(
                        label,
                        style: context.styles.paragraph.copyWith(
                          color: isActive ? context.colors.black : context.colors.white.valueOpacity(.3),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
