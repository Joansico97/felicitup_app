import 'package:felicitup_app/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class AppStyles {
  AppStyles(this.context);

  final BuildContext context;

  TextStyle get header1 => TextStyle(
        fontSize: context.sp(24),
        fontWeight: FontWeight.w600,
        fontFamily: 'AvenirNext',
        color: context.colors.black,
      );

  TextStyle get header2 => TextStyle(
        fontSize: context.sp(16),
        fontWeight: FontWeight.w600,
        fontFamily: 'AvenirNext',
        color: context.colors.black,
      );

  TextStyle get buttons => TextStyle(
        fontSize: context.sp(16),
        fontWeight: FontWeight.w500,
        fontFamily: 'AvenirNext',
        color: context.colors.black,
      );

  TextStyle get subtitle => TextStyle(
        fontSize: context.sp(16),
        fontWeight: FontWeight.w400,
        fontFamily: 'AvenirNext',
        color: context.colors.black,
      );

  TextStyle get paragraph => TextStyle(
        fontSize: context.sp(14),
        fontWeight: FontWeight.w400,
        fontFamily: 'AvenirNext',
        color: context.colors.black,
      );

  TextStyle get smallText => TextStyle(
        fontSize: context.sp(12),
        fontWeight: FontWeight.w400,
        fontFamily: 'AvenirNext',
        color: context.colors.black,
      );

  TextStyle get menu => TextStyle(
        fontSize: context.sp(12),
        fontWeight: FontWeight.w500,
        fontFamily: 'AvenirNext',
        color: context.colors.black,
      );
}
