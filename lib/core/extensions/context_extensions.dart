import 'package:felicitup_app/core/theme/theme.dart';
import 'package:flutter/material.dart';
import '../../gen/l10n.dart';

extension ContextExtensions on BuildContext {
  // This is the base width of the design
  static const double baseWidth = 393;

  IntlTrans get locale => IntlTrans.of(this);

  AppStyles get styles => AppStyles(this);

  AppColors get colors => AppColors();

  double sp(double pixel) => (pixel / baseWidth) * MediaQuery.of(this).size.width;

  double get fullWidth => MediaQuery.of(this).size.width;

  double get fullHeight => MediaQuery.of(this).size.height;

  EdgeInsets get screenPadding => MediaQuery.of(this).padding;
}
