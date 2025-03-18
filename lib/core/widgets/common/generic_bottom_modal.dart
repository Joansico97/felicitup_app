import 'package:flutter/material.dart';

Future<T?> showGenericModalBottomSheet<T>({
  required BuildContext context,
  required Widget child, // El widget que se mostrará en el modal.
  bool isScrollControlled = true, // Permite que el modal ocupe más del 50% de la pantalla.
  bool isDismissible = true, // Permite cerrar el modal tocando fuera.
  Color? backgroundColor, // Color de fondo personalizado (opcional).
  double? elevation, // Elevación personalizada (opcional).
  ShapeBorder? shape, // Forma personalizada (opcional).
  Clip? clipBehavior, // Comportamiento de recorte (opcional).
  BoxConstraints? constraints, // Restricciones de tamaño (opcional).
  bool useSafeArea = false, // Usa SafeArea (opcional).
  AnimationController? transitionAnimationController, //Opcional, controlador de animación.
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
      return child; // Muestra el widget que se pasó como parámetro.
    },
  );
}
