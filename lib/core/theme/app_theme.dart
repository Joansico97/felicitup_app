import 'package:felicitup_app/core/theme/theme.dart';
import 'package:felicitup_app/gen/fonts.gen.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme();

  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        fontFamily: FontFamily.poppins,
        scaffoldBackgroundColor: AppColors().white,
        brightness: Brightness.light,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        dividerTheme: const DividerThemeData(
          color: Colors.transparent,
        ),
        bottomSheetTheme: BottomSheetThemeData(
          shadowColor: AppColors().lightGrey,
          constraints: BoxConstraints(
            minHeight: 400,
          ),
          modalBarrierColor: AppColors().lightGrey,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors().orange,
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: AppColors().white,
          hourMinuteColor: AppColors().white,
          hourMinuteTextColor: AppColors().primary,
        ),
        cardTheme: CardTheme(
          color: AppColors().white,
        ),
      );
}
