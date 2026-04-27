import 'package:flutter/material.dart';

Future<T?> showGenericModalBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = true,
  bool isDismissible = true,
  Color? backgroundColor,
  double? elevation,
  ShapeBorder? shape,
  Clip? clipBehavior,
  BoxConstraints? constraints,
  bool useSafeArea = false,
  AnimationController? transitionAnimationController,
  Color? barrierColor,
}) async {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    backgroundColor: backgroundColor,
    elevation: elevation,
    shape: shape,
    clipBehavior: clipBehavior,
    constraints: constraints,
    barrierColor: barrierColor,
    useSafeArea: useSafeArea,
    transitionAnimationController: transitionAnimationController,
    builder: (BuildContext context) {
      return child;
    },
  );
}
