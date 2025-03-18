import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Color valueOpacity(double value) {
    assert(value >= 0 && value <= 1);
    return withAlpha((value * 255).toInt());
  }
}
