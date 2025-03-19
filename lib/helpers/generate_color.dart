import 'package:flutter/material.dart';

Color generateColorForUser(String userId) {
  // 1. Obtener el hash (usando hashCode, que ya está disponible en String).
  //    Podrías usar un algoritmo de hash más robusto si quieres mayor seguridad
  //    o evitar colisiones, pero para este caso hashCode es suficiente.
  final int hash = userId.hashCode;

  // 2. Mapear el hash a un valor de Hue (0-360).
  //    Usamos el operador % para asegurar que el valor esté en el rango.
  final double hue = (hash % 360).toDouble();

  // 3. Crear el color HSL.
  //    Mantenemos la saturación y la luminosidad constantes.
  return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor(); // Ajusta S y L a tu gusto
}
